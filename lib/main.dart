import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:loading/loading.dart';
import 'package:loading/indicator/ball_pulse_indicator.dart';
import 'package:path_provider/path_provider.dart';
import 'package:traindown/traindown.dart';

void main() => runApp(MaterialApp(home: Scaffold(body: Transponder())));

class _Transponder extends State<Transponder> {
  int activeSessionIndex;
  Directory _appData;
  List<File> _sessions = [];

  Future<void> _initAppData() async {
    final directory = await getApplicationDocumentsDirectory();
    setState(() => _appData = directory);
  }

  Future<void> _createSession() async {
    print('create');
    File session = File(
        '${_appData.path}/${DateTime.now().millisecondsSinceEpoch}.traindown');
    setState(() {
      _sessions.add(session);
      activeSessionIndex = _sessions.length - 1;
    });
  }

  Widget _createSessionButton() {
    return FlatButton(
        textColor: Colors.blue,
        child: Text('Add new session'),
        onPressed: () => _createSession());
  }

  void _deleteSession(String session) {}

  Widget _loading() {
    return Center(
        child: Loading(
            color: Colors.blue, indicator: BallPulseIndicator(), size: 100.0));
  }

  void _sessionEditor(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      builder: (BuildContext context) {
        return Container(
            height: MediaQuery.of(context).size.height * 0.85,
            child: TraindownEditor(),
            padding: EdgeInsets.only(top: 20.0));
      },
    );
  }

  Widget _sessionList() {
    return Expanded(
        child: ListView.builder(
            itemCount: _sessions.length,
            itemBuilder: (context, index) {
              return Card(
                child: ListTile(
                  leading: Icon(Icons.directions_run),
                  onLongPress: () => {}, //_showDeleteModal(index - 1),
                  onTap: () => _sessionEditor(context),
                  title: Text(_sessions[index].toString()),
                ),
              );
            }));
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (_appData == null) {
      _initAppData();
      body = _loading();
    } else if (activeSessionIndex == null) {
      body = _sessionList();
    } else {
      body = Text('yay');
    }

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

class SessionList extends StatelessWidget {
  final List<File> sessions;
  final ValueChanged<String> deleteSession;

  SessionList({Key key, @required this.sessions, @required this.deleteSession})
      : super(key: key);

/*
  Future<void> _showDeleteModal(int sessionIndex) async {
    return showCupertinoDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text('Delete ${sessions[sessionIndex]}?'),
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
                setState(() => titles.removeAt(sessionIndex));
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  
  void _showModal(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      builder: (BuildContext context) {
        return Container(
            height: MediaQuery.of(context).size.height * 0.85,
            child: TraindownEditor(),
            padding: EdgeInsets.only(top: 20.0));
      },
    );
  }
*/
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: sessions.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              leading: Icon(Icons.directions_run),
              onLongPress: () => {}, //_showDeleteModal(index - 1),
              onTap: () => {}, //_showModal(context),
              title: Text(sessions[index].toString()),
            ),
          );
        });
  }
}

class TraindownEditor extends StatefulWidget {
  TraindownEditor({Key key}) : super(key: key);

  @override
  _TraindownEditor createState() => _TraindownEditor();
}

class _TraindownEditor extends State<TraindownEditor> {
  TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addText(String addition) {
    int start = _controller.selection.extentOffset;
    int end = _controller.selection.extentOffset + addition.length;
    _controller.value = _controller.value.copyWith(
        text: _controller.text.replaceRange(start, start, addition),
        selection: TextSelection.collapsed(offset: end));
  }

  void _formatText() {
    Formatter formatter = Formatter.for_string(_controller.text);
    formatter.format();
    String text = formatter.output.toString();

    _controller.value = _controller.value.copyWith(
        text: text, selection: TextSelection.collapsed(offset: text.length));
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
            buttonPadding: EdgeInsets.all(1.0),
            mainAxisSize: MainAxisSize.min,
            overflowButtonSpacing: 10.0,
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
