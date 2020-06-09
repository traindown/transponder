import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:path_provider/path_provider.dart';
import 'package:traindown/traindown.dart';

void main() => runApp(MaterialApp(home: Scaffold(body: Transponder())));

class _Transponder extends State<Transponder> {
  int _activeSessionIndex;
  Directory _appData;
  final List<File> _sessions = [];

  Future<void> _initAppData() async {
    Directory directory = await getApplicationDocumentsDirectory();
    setState(() => _appData = directory);
  }

  String fullFilePath(String filename) =>
      '${_appData.path}/$filename.traindown';

  Future<void> _createSession() async {
    File session = File(fullFilePath('untitled'));
    setState(() {
      _sessions.add(session);
      _activeSessionIndex = _sessions.length - 1;
      _sessionEditor();
    });
  }

  Widget _createSessionButton() {
    return FlatButton(
        textColor: Colors.blue,
        child: Text('Add new session'),
        onPressed: () => _createSession());
  }

  Future<void> _showDeleteModal(int sessionIndex) async {
    return showCupertinoDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title:
              Text('Delete ${_sessions[sessionIndex].path.split("/").last}?'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Deleting this session will permanently remove its data.'),
                Text('Are you sure you want to delete?'),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              textColor: Colors.red,
              child: Text('Delete'),
              onPressed: () {
                setState(() => _sessions.removeAt(sessionIndex));
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  String get _activeSessionContent {
    try {
      return _sessions[_activeSessionIndex].readAsStringSync();
    } catch (e) {
      return '';
    }
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

  void _syncFilenameToContent() {
    File session = _sessions[_activeSessionIndex];
    String content = session.readAsStringSync();

    String possibleFilename = content.split('\n').first.split('@').last.trim();

    if (!session.path.split('/').last.startsWith(possibleFilename)) {
      setState(() {
        _sessions[_activeSessionIndex] =
            moveFile(session, fullFilePath(possibleFilename));
      });
    }
  }

  void _writeSession(String content) =>
      _sessions[_activeSessionIndex].writeAsString(content);

  void _sessionEditor() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      builder: (BuildContext context) {
        return Container(
            height: MediaQuery.of(context).size.height * 0.85,
            child: TraindownEditor(
                content: _activeSessionContent, onChange: _writeSession),
            padding: EdgeInsets.only(top: 20.0));
      },
    ).whenComplete(() => _syncFilenameToContent());
  }

  Widget _sessionList() {
    return Expanded(
        child: ListView.builder(
            itemCount: _sessions.length,
            itemBuilder: (context, index) {
              return Card(
                child: ListTile(
                  leading: Icon(Icons.fitness_center),
                  onLongPress: () => _showDeleteModal(index),
                  onTap: () {
                    _activeSessionIndex = index;
                    _sessionEditor();
                  },
                  title: Text(_sessions[index].path.split('/').last),
                ),
              );
            }));
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
            minimum: const EdgeInsets.all(16.0),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[_createSessionButton(), _sessionList()])));
  }
}

class Transponder extends StatefulWidget {
  Transponder({Key key}) : super(key: key);

  @override
  _Transponder createState() => _Transponder();
}

class TraindownEditor extends StatefulWidget {
  final String content;
  final ValueChanged<String> onChange;

  TraindownEditor({Key key, this.content, this.onChange}) : super(key: key);

  @override
  _TraindownEditor createState() => _TraindownEditor();
}

class _TraindownEditor extends State<TraindownEditor> {
  TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.content);
  }

  @override
  void dispose() {
    _formatText();
    _controller.dispose();
    super.dispose();
  }

  void _addText(String addition) {
    addition = addition.isEmpty ? '' : addition;
    int start = _controller.selection.extentOffset;
    int end = _controller.selection.extentOffset + addition.length;
    _controller.value = _controller.value.copyWith(
        text: _controller.text.replaceRange(start, start, addition),
        selection: TextSelection.collapsed(offset: end));
    widget.onChange(_controller.value.text);
  }

  void _formatText() {
    Formatter formatter = Formatter.for_string(_controller.text);
    formatter.format();
    String text = formatter.output.toString();

    _controller.value = _controller.value.copyWith(
        text: text, selection: TextSelection.collapsed(offset: text.length));

    widget.onChange(_controller.value.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(10.0),
              child: EditableText(
                autocorrect: false,
                autofocus: true,
                backgroundCursorColor: Colors.blue,
                cursorColor: Colors.red,
                cursorWidth: 5,
                controller: _controller,
                enableSuggestions: false,
                expands: true,
                focusNode: FocusNode(),
                onChanged: (String text) => widget.onChange(text),
                scrollPadding: EdgeInsets.all(20.0),
                keyboardType: TextInputType.multiline,
                maxLines: null,
                style: TextStyle(
                    color: Colors.black.withOpacity(0.8),
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
          ButtonBar(
            alignment: MainAxisAlignment.center,
            buttonHeight: 10.0,
            buttonMinWidth: 10.0,
            buttonPadding: EdgeInsets.all(1.0),
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              FlatButton(
                child: Text('Meta'),
                onPressed: () => _addText('\n# '),
              ),
              FlatButton(
                child: Text('Colon'),
                onPressed: () => _addText(': '),
              ),
              FlatButton(
                child: Text('Note'),
                onPressed: () => _addText('\n* '),
              ),
              FlatButton(
                child: Text('Superset'),
                onPressed: () => _addText('\n+ '),
              ),
              FlatButton(
                child: Text('Date'),
                onPressed: () => _addText('@ '),
              ),
              FlatButton(
                child: Text('\u{1F9F9}'),
                onPressed: () => _formatText(),
              ),
            ],
          ),
        ]));
  }
}
