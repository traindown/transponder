import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'session.dart';

enum SessionMenuOption { copy, delete, edit, email }

class SessionList extends StatelessWidget {
  final List<Session> sessions;
  final ValueChanged<int> onCopy;
  final ValueChanged<int> onDelete;
  final ValueChanged<int> onEmail;
  final ValueChanged<int> onEdit;
  final ValueChanged<int> onView;

  SessionList(
      {Key key,
      this.sessions,
      this.onCopy,
      this.onDelete,
      this.onEmail,
      this.onEdit,
      this.onView})
      : super(key: key);

  Widget renderList(BuildContext context) {
    return Expanded(
        child: ListView.builder(
            itemCount: sessions.length,
            itemBuilder: (context, index) {
              Session session = sessions[index];

              return Card(
                  child: InkWell(
                      splashColor: Colors.blue.withAlpha(30),
                      onTap: () => onView(index),
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(15.0, 0, 15.0, 10.0),
                        child: Column(children: [
                          ListTile(
                            contentPadding: EdgeInsets.all(0.0),
                            onTap: () => onView(index),
                            title: Text(session.name),
                            subtitle: Text(session.liftsSentence),
                            trailing:
                                Row(mainAxisSize: MainAxisSize.min, children: [
                              PopupMenuButton<SessionMenuOption>(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  tooltip: 'Session action menu',
                                  onSelected: (SessionMenuOption action) {
                                    switch (action) {
                                      case SessionMenuOption.copy:
                                        onCopy(index);
                                        break;
                                      case SessionMenuOption.delete:
                                        onDelete(index);
                                        break;
                                      case SessionMenuOption.edit:
                                        onEdit(index);
                                        break;
                                      case SessionMenuOption.email:
                                        onEmail(index);
                                        break;
                                    }
                                  },
                                  itemBuilder: (BuildContext context) =>
                                      <PopupMenuEntry<SessionMenuOption>>[
                                        const PopupMenuItem<SessionMenuOption>(
                                          value: SessionMenuOption.edit,
                                          child: ListTile(
                                              leading: Icon(Icons.edit),
                                              title: Text('Edit')),
                                        ),
                                        const PopupMenuItem<SessionMenuOption>(
                                          value: SessionMenuOption.copy,
                                          child: ListTile(
                                              leading: Icon(Icons.content_copy),
                                              title: Text('Copy')),
                                        ),
                                        const PopupMenuItem<SessionMenuOption>(
                                          value: SessionMenuOption.email,
                                          child: ListTile(
                                              leading: Icon(Icons.email),
                                              title: Text('Email')),
                                        ),
                                        const PopupMenuDivider(),
                                        const PopupMenuItem<SessionMenuOption>(
                                            value: SessionMenuOption.delete,
                                            child: ListTile(
                                                leading: Icon(Icons.delete),
                                                title: Text('Delete',
                                                    style: TextStyle(
                                                        color: Colors.red)))),
                                      ])
                            ]),
                          ),
                          Row(children: [
                            Expanded(
                                child: Column(children: [
                              Text(session.volumeString,
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              Text('volume')
                            ])),
                            Expanded(
                                child: Column(children: [
                              Text(session.movements.length.toString(),
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              Text('exercises')
                            ])),
                            Expanded(
                                child: Column(children: [
                              Text(session.setCount.toString(),
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              Text('sets')
                            ])),
                            Expanded(
                                child: Column(children: [
                              Text(session.repCount.toString(),
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              Text('reps')
                            ])),
                          ])
                        ]),
                      )));
            }));
  }

  Widget renderSplash(BuildContext context) {
    return Expanded(
        child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                      padding: EdgeInsets.only(bottom: 5.0),
                      child: Text('No Sessions yet',
                          style: TextStyle(fontSize: 20.0))),
                  RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                          text: 'To get started, just tap the',
                          style: TextStyle(color: Colors.grey, fontSize: 18.0),
                          children: [
                            WidgetSpan(
                                child: Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 3.0),
                                    child: Icon(Icons.add_circle_outline,
                                        color: Colors.grey, size: 18.0))),
                            TextSpan(
                                text:
                                    'button at the top of the screen to add a new session.')
                          ]))
                ])));
  }

  @override
  Widget build(BuildContext context) {
    if (sessions.isEmpty) {
      return renderSplash(context);
    } else {
      return renderList(context);
    }
  }
}
