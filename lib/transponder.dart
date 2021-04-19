import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:traindown/traindown.dart';

import 'session.dart';
import 'session_list.dart';
import 'settings.dart';
import 'traindown_editor.dart';
import 'traindown_viewer.dart';

class _Transponder extends State<Transponder> {
  TTSession _activeSession;
  Directory _appData;

  final Set<String> _filterList = <String>{};
  final List<TTSession> _sessions = [];

  String get _activeSessionContent {
    try {
      return _activeSession.file.readAsStringSync();
    } catch (e) {
      return '';
    }
  }

  // TODO: All this needs to be cleaned up!
  Future<void> _copySession(String filename) async {
    String tmpFilename = DateTime.now().millisecondsSinceEpoch.toString();
    File tmpFile = File(fullFilePath(tmpFilename));
    String content = fetchSession(filename).file.readAsStringSync();
    Parser parser = Parser(content);
    List<Token> tokens = parser.tokens().map((Token token) {
      if (token.tokenType != TokenType.DateTime) return token;

      return Token(
          TokenType.DateTime, DateFormat('yyyy-MM-dd').format(DateTime.now()));
    }).toList();
    Formatter formatter = Formatter();
    tmpFile.writeAsStringSync(formatter.format(tokens));
    TTSession session = TTSession(tmpFile, empty: false);
    setState(() {
      _sessions.add(session);
      _activeSession = session;
      _showSessionEditor();
    });
  }

  Future<void> _createSession() async {
    String tmpFilename = DateTime.now().millisecondsSinceEpoch.toString();
    TTSession session = TTSession(File(fullFilePath(tmpFilename)),
        unit: widget.sharedPreferences.getString('defaultUnit'));
    setState(() {
      _sessions.add(session);
      _activeSession = session;
      _showSessionEditor();
    });
  }

  Future<void> _filterSessions() async => _showSessionsFilters();

  String fullFilePath(String filename) =>
      '${_appData.path}/$filename.traindown';

  Future<void> _initAppData() async {
    Directory directory = await getApplicationDocumentsDirectory();
    List<FileSystemEntity> files = directory.listSync();
    setState(() {
      _appData = directory;
      if (files.isNotEmpty) {
        files.forEach((file) {
          if (file is File) {
            _sessions.add(TTSession(file, empty: false));
          }
        });
      }
    });
  }

  File moveFile(File sourceFile, String newPath) {
    try {
      return sourceFile.renameSync(newPath);
    } on FileSystemException catch (_) {
      final newFile = sourceFile.copySync(newPath);
      sourceFile.deleteSync();
      return newFile;
    }
  }

  Widget _renderActionBar() {
    return Row(children: [
      Expanded(child: _renderCreateSessionButton()),
      Expanded(child: _renderFilterSessionsButton()),
      Expanded(child: _renderSettingsButton())
    ]);
  }

  Widget _renderCreateSessionButton() {
    return FlatButton(
        textColor: Theme.of(context).primaryColor,
        child: Icon(Icons.add_circle_outline),
        onPressed: () => _createSession());
  }

  Widget _renderFilterSessionsButton() {
    return FlatButton(
        textColor: Theme.of(context).primaryColor,
        child: Icon(Icons.filter_alt_outlined),
        onPressed: () => _filterSessions());
  }

  Widget _renderSessionList() {
    return SessionList(
        sessions: sessions,
        onCopy: (filename) => _copySession(filename),
        onDelete: (filename) => _showDeleteModal(filename),
        onEmail: (filename) => _sendEmail(session: fetchSession(filename)),
        onEdit: (filename) {
          _activeSession = fetchSession(filename);
          _showSessionEditor();
        },
        onView: (filename) {
          _activeSession = fetchSession(filename);
          _showSessionViewer();
        });
  }

  Widget _renderSettingsButton() {
    return FlatButton(
        textColor: Theme.of(context).primaryColor,
        child: Icon(Icons.settings),
        onPressed: () => _showSettings());
  }

  void _sendExportEmail() async {
    List<Session> rawSessions =
        _sessions.where((s) => !s.errored).map((s) => s.session).toList();
    Inspector inspector = Inspector(rawSessions);

    await _sendEmail(content: inspector.export());
  }

  Future<void> _sendEmail({String content, TTSession session}) async {
    List<String> recipients =
        widget.sharedPreferences.getString('sendToEmails') == null
            ? []
            : widget.sharedPreferences
                .getString('sendToEmails')
                .split(',')
                .map((e) => e.trim())
                .toList();
    // TODO: Make more specific subject.
    String subject = session != null ? session.name : 'Traindown Export';
    final Email email = Platform.isIOS
        ? Email(
            body: session != null ? session.file.readAsStringSync() : content,
            subject: subject,
            recipients: recipients,
            attachmentPaths: session != null ? [session.file.path] : [],
          )
        : Email(
            body: session != null ? session.file.readAsStringSync() : content,
            subject: subject,
            recipients: recipients,
          );

    String sendResponse;

    try {
      await FlutterEmailSender.send(email);
      sendResponse = 'Email sent!';
    } catch (error) {
      sendResponse = error.toString();
    }

    return showCupertinoDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text('Email Status'),
            content: Text(sendResponse),
            actions: <Widget>[
              FlatButton(
                textColor: Colors.blue,
                child: Text('Okay'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          );
        });
  }

  void setPreference(String key, {int integerValue, String stringValue}) {
    if (integerValue != null) {
      widget.sharedPreferences.setInt(key, integerValue);
    } else if (stringValue != null) {
      widget.sharedPreferences.setString(key, stringValue);
    }
  }

  Future<void> _showDeleteModal(String filename) async {
    TTSession session = fetchSession(filename);

    return showCupertinoDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text('Delete ${session.name}?'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text(
                      'Deleting this session will permanently remove its data.'),
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                textColor: Colors.blue,
                child: Text('Cancel', style: TextStyle(fontSize: 16.0)),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                textColor: Colors.red,
                child: Text('Delete',
                    style:
                        TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
                onPressed: () {
                  if (session.teardown()) {
                    setState(() => _sessions.removeWhere((s) => s == session));
                    Navigator.of(context).pop();
                  } else {
                    Navigator.of(context).pop();
                    _showErrorModal('Could not delete session');
                  }
                },
              ),
            ],
          );
        }).whenComplete(() => setState(() {}));
  }

  Future<void> _showErrorModal(String message) async {
    return showCupertinoDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
              title: Text('An error occurred'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Text('The following error occurred:\n'),
                    Text(message)
                  ],
                ),
              ),
              actions: <Widget>[
                FlatButton(
                    textColor: Colors.blue,
                    child: Text('Huh. Okay'),
                    onPressed: () => Navigator.of(context).pop())
              ]);
        });
  }

  void _showSessionEditor() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
            expand: true,
            initialChildSize: 1,
            minChildSize: 0.99,
            builder: (_, controller) {
              return Container(
                  child: TraindownEditor(
                      content: _activeSessionContent,
                      onChange: _writeSession,
                      scrollController: controller),
                  padding: EdgeInsets.only(top: 20.0));
            });
      },
    ).whenComplete(() => _syncFilenameToContent());
  }

  // TODO: Pull into own widget
  void _showSessionsFilters() {
    List<Session> rawSessions =
        _sessions.where((s) => !s.errored).map((s) => s.session).toList();
    Inspector inspector = Inspector(rawSessions);
    Map<String, Set<String>> metadata = inspector.metadataByKey();
    List<String> keys = metadata.keys.toList()..sort();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return DraggableScrollableSheet(
              expand: true,
              initialChildSize: 1,
              minChildSize: 0.99,
              builder: (_, controller) {
                return Container(
                    padding: EdgeInsets.only(top: 20.0),
                    child: ListView.separated(
                        controller: controller,
                        separatorBuilder: (context, index) =>
                            Divider(color: Colors.grey),
                        itemCount: keys.length,
                        itemBuilder: (context, index) {
                          String key = keys[index];
                          List<String> values = metadata[key].toList();
                          values.sort((a, b) => a.compareTo(b));

                          List<Widget> valueChecks = [];
                          for (String value in values) {
                            String filterString = '$key:$value';

                            valueChecks.add(Column(children: [
                              Checkbox(
                                  value: _filterList.contains(filterString),
                                  onChanged: (bool checkedValue) {
                                    setState(() {
                                      if (checkedValue) {
                                        _filterList.add(filterString);
                                      } else {
                                        _filterList.remove(filterString);
                                      }
                                    });
                                  }),
                              Text(value),
                            ]));
                          }

                          return Column(children: [
                            Row(children: [
                              Container(
                                  padding: EdgeInsets.only(left: 15.0),
                                  child: Text.rich(TextSpan(
                                      text: key,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline6)))
                            ]),
                            Wrap(spacing: 8.0, children: valueChecks)
                          ]);
                        }));
              });
        });
      },
    ).whenComplete(() => setState(() {}));
  }

  void _showSessionViewer() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
            expand: true,
            initialChildSize: 1,
            minChildSize: 0.99,
            builder: (_, controller) {
              return Container(
                  child: TraindownViewer(
                      content: _activeSessionContent,
                      scrollController: controller),
                  padding: EdgeInsets.only(top: 20.0));
            });
      },
    );
  }

  void _showSettings() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
            expand: true,
            initialChildSize: 1,
            minChildSize: 0.99,
            builder: (_, controller) {
              return Container(
                  padding: EdgeInsets.only(top: 20.0),
                  child: Settings(
                      sharedPreferences: widget.sharedPreferences,
                      exportCallback: _sendExportEmail));
            });
      },
    );
  }

  void _syncFilenameToContent() {
    String content = _activeSession.file.readAsStringSync();
    String possibleFilename = content.split('\n').first.split('@').last.trim();

    if (!_activeSession.filename.startsWith(possibleFilename)) {
      int existingSessionsCount = _sessions.fold(0, (count, session) {
        if (session.filename == '$possibleFilename.traindown') count++;
        return count;
      });

      if (existingSessionsCount > 0) {
        possibleFilename += '.$existingSessionsCount';
      }

      setState(() {
        _activeSession.file =
            moveFile(_activeSession.file, fullFilePath(possibleFilename));
      });
    }

    // NOTE: This just kicks the getters for _activeSession
    setState(() => _activeSession = _activeSession.refresh());
  }

  TTSession fetchSession(String filename) {
    return _sessions.where((s) => s.filename == filename).first;
  }

  void _writeSession(String content) =>
      _activeSession.file.writeAsString(content);

  List<TTSession> get sessions {
    List<Session> sessions =
        _sessions.where((s) => !s.errored).map((s) => s.session).toList();
    Inspector inspector = Inspector(sessions);

    Map<String, String> filters = {};
    _filterList.forEach((String filterString) {
      List<String> kvp = filterString.split(':');
      filters[kvp[0]] = kvp[1];
    });

    List<Session> matchedSessions = inspector.sessionQuery(metaLike: filters);
    List<TTSession> result =
        _sessions.where((s) => matchedSessions.contains(s.session)).toList();
    result.sort((a, b) => b.filename.compareTo(a.filename));
    return result;
  }

  @override
  Widget build(BuildContext context) {
    if (_appData == null) _initAppData();

    return Align(
        alignment: Alignment.topLeft,
        child: SafeArea(
            left: true,
            top: true,
            right: true,
            bottom: true,
            minimum: const EdgeInsets.all(5.0),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[_renderSessionList(), _renderActionBar()])));
  }
}

class Transponder extends StatefulWidget {
  final SharedPreferences sharedPreferences;

  Transponder({Key key, @required this.sharedPreferences})
      : assert(sharedPreferences != null),
        super(key: key);

  @override
  _Transponder createState() => _Transponder();
}
