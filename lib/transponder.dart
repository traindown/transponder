import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:traindown/traindown.dart';

import 'editor_modal.dart';
import 'filters_modal.dart';
import 'repo.dart';
import 'session_list.dart';
import 'settings_modal.dart';
import 'stored_session.dart';
import 'traindown_viewer.dart';

class _Transponder extends State<Transponder> {
  StoredSession _activeSession;
  final Set<String> _filterList = <String>{};
  List<StoredSession> _sessions = [];

  _Transponder(Repo repo) {
    repo.allSessions().then((List<StoredSession> allSessions) {
      setState(() => _sessions = allSessions);
    });
  }

  // Getters

  List<StoredSession> get sessions {
    List<Session> validRawSessions = _sessions
        .where((s) => s.session != null && !s.errored)
        .map((s) => s.session)
        .toList();

    Map<String, String> filters = {};

    for (String filterString in _filterList) {
      List<String> kvp = filterString.split(':');
      filters[kvp[0]] = kvp[1];
    }

    Inspector inspector = Inspector(validRawSessions);

    List<Session> matchedSessions = inspector.sessionQuery(metaLike: filters);
    List<StoredSession> result =
        _sessions.where((s) => matchedSessions.contains(s.session)).toList();

    result.sort((a, b) => b.occurred.compareTo(a.occurred));

    return result;
  }

  // Public

  void setPreference(String key, {int integerValue, String stringValue}) {
    if (integerValue != null) {
      widget.sharedPreferences.setInt(key, integerValue);
    } else if (stringValue != null) {
      widget.sharedPreferences.setString(key, stringValue);
    }
  }

  // Private

  Future<void> _copySession(StoredSession session) async {
    Parser parser = Parser(session.traindown);
    List<Token> tokens = parser.tokens().map((Token token) {
      if (token.tokenType != TokenType.DateTime) return token;

      return Token(
          TokenType.DateTime, DateFormat('yyyy-MM-dd').format(DateTime.now()));
    }).toList();
    Formatter formatter = Formatter();
    StoredSession copy = StoredSession(formatter.format(tokens), widget.repo);

    setState(() {
      _sessions.add(copy);
      _activeSession = copy;
      _showSessionEditor();
    });
  }

  Future<void> _createSession() async {
    StoredSession newSession = StoredSession.blank(widget.repo,
        unit: widget.sharedPreferences.getString('defaultUnit'));
    setState(() {
      _sessions.add(newSession);
      _activeSession = newSession;
      _showSessionEditor();
    });
  }

  Future<void> _filterSessions() async => _showSessionsFilters();

  Widget _renderActionBar() {
    return Row(children: [
      Expanded(child: _renderCreateSessionButton()),
      Expanded(child: _renderFilterSessionsButton()),
      Expanded(child: _renderSettingsButton())
    ]);
  }

  Widget _renderCreateSessionButton() {
    return IconButton(
        color: Theme.of(context).primaryColor,
        icon: Icon(Icons.add_circle_outline),
        onPressed: () => _createSession());
  }

  Widget _renderFilterSessionsButton() {
    List<Widget> children = [
      IconButton(
          color: Theme.of(context).primaryColor,
          icon: Icon(Icons.filter_alt_outlined),
          onPressed: () => _filterSessions())
    ];

    if (!_filterList.isEmpty) {
      children.add(Padding(
          padding: EdgeInsets.only(bottom: 15.0, left: 15.0),
          child: Stack(children: [
            Container(
                padding: EdgeInsets.all(2.0),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    color: Theme.of(context).accentColor),
                constraints: BoxConstraints(maxHeight: 12, maxWidth: 12)),
            Text(_filterList.length.toString(),
                textAlign: TextAlign.right,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 6))
          ])));
    }
    ;

    return Stack(alignment: Alignment.center, children: children);
  }

  Widget _renderSessionList() {
    return SessionList(
        sessions: sessions,
        onCopy: (StoredSession session) => _copySession(session),
        onDelete: (StoredSession session) => _showDeleteModal(session),
        onEmail: (StoredSession session) =>
            _sendEmail(body: session.traindown, subject: session.name),
        onEdit: (StoredSession session) {
          _activeSession = session;
          _showSessionEditor();
        },
        onView: (StoredSession session) {
          _activeSession = session;
          _showSessionViewer();
        });
  }

  Widget _renderSettingsButton() {
    return IconButton(
        color: Theme.of(context).primaryColor,
        icon: Icon(Icons.settings),
        onPressed: () => _showSettings());
  }

  Future<void> _sendEmail(
      {String body, String subject, List<String> recipients}) async {
    recipients ??= widget.sharedPreferences.getString('sendToEmails') == null
        ? []
        : widget.sharedPreferences
            .getString('sendToEmails')
            .split(',')
            .map((e) => e.trim())
            .toList();
    final Email email = Email(
      body: body,
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

    return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Email Status'),
            content: Text(sendResponse),
            actions: <Widget>[
              TextButton(
                style: TextButton.styleFrom(
                    primary: Theme.of(context).primaryColor),
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Okay'),
              ),
            ],
          );
        });
  }

  void _sendExportEmail() async {
    List<Session> rawSessions =
        sessions.where((s) => !s.errored).map((s) => s.session).toList();
    Inspector inspector = Inspector(rawSessions);

    // TODO: Fix lib conditional export...
    await _sendEmail(body: inspector.export(), subject: 'Traindown Export');
  }

  void _sendLogEmail() async {
    List<Map> logs = await widget.repo.dumpLogs(limit: 200);

    var lines = logs
        .map((log) {
          return "${log['created_at']} [${log['type']}] ${log['subject']}: ${log['message']}";
        })
        .toList()
        .reversed;

    await _sendEmail(
        body: lines.join('\r\n'),
        recipients: ['tyler@greaterscott.com'],
        subject: '[Transponder] Crash report');
  }

  Future<void> _showDeleteModal(StoredSession session) async {
    return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
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
              TextButton(
                style: TextButton.styleFrom(
                    primary: Theme.of(context).primaryColor),
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Cancel', style: TextStyle(fontSize: 16.0)),
              ),
              TextButton(
                style: TextButton.styleFrom(
                    primary: Theme.of(context).accentColor),
                onPressed: () async {
                  bool deleted = await session.destroy();
                  Navigator.of(context).pop();

                  if (deleted) {
                    setState(() {
                      _sessions.removeWhere((s) => s.id == session.id);
                    });
                  } else {
                    _showErrorModal('Failed to delete session.');
                  }
                },
                child: Text('Delete',
                    style:
                        TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
              ),
            ],
          );
        });
  }

  Future<void> _showErrorModal(String message) async {
    return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
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
                TextButton(
                    style: TextButton.styleFrom(
                        primary: Theme.of(context).primaryColor),
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('Huh. Okay'))
              ]);
        });
  }

  void _showSessionEditor() {
    if (_activeSession.isPersisted) {
      widget.repo.log("Editing ${_activeSession.id}", subject: 'Session');
    } else {
      widget.repo.log("Writing new", subject: 'Session');
    }

    Navigator.of(context)
        .push(EditorModal(
            content: _activeSession.traindown,
            onChange: (String traindown) {
              _activeSession.traindown = traindown;
            }))
        .then((_) async {
      bool saved = await _activeSession.save();

      widget.repo.log("Edited ${_activeSession.id}", subject: 'Session');

      if (saved) {
        setState(() => _activeSession = _activeSession);
      } else {
        widget.repo.log(
            "Failed to save Session ${_activeSession.id}. Error: ${_activeSession.error}",
            type: 'error',
            subject: 'Session');
        _showErrorModal(
            'Failed to save session! Please go to Settings and send a crash report.');
      }
    });
  }

  // TODO: Pull into own widget
  void _showSessionsFilters() async {
    List<Session> rawSessions =
        sessions.where((s) => !s.errored).map((s) => s.session).toList();
    Inspector inspector = Inspector(rawSessions);

    Navigator.of(context).push(FiltersModal(
        filterList: _filterList,
        metadataByKey: inspector.metadataByKey(),
        onAdd: (String f) {
          setState(() {
            _filterList.add(f);
          });
        },
        onRemove: (String f) {
          setState(() {
            _filterList.remove(f);
          });
        }));
  }

  void _showSessionViewer() {
    showModalBottomSheet<void>(
      backgroundColor: Colors.transparent,
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
            initialChildSize: 0.85,
            expand: true,
            builder: (_, controller) {
              return Container(
                  child: TraindownViewer(
                      content: _activeSession.traindown,
                      scrollController: controller));
            });
      },
    );
  }

  void _showSettings() {
    Navigator.of(context).push(SettingsModal(
        sharedPreferences: widget.sharedPreferences,
        onExport: _sendExportEmail,
        onLogs: _sendLogEmail));
  }

  // void _writeSession(String content) => _activeSession.updateTraindown(content);

  @override
  Widget build(BuildContext context) {
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
  final Repo repo;
  final SharedPreferences sharedPreferences;

  Transponder({Key key, @required this.repo, @required this.sharedPreferences})
      : assert(sharedPreferences != null),
        super(key: key);

  @override
  _Transponder createState() => _Transponder(repo);
}
