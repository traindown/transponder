import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'session.dart';

enum SessionMenuOption { copy, delete, email }

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
              return Card(
                child: ListTile(
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                  onTap: () => onView(index),
                  title: Text(sessions[index].name),
                  subtitle: Text(sessions[index].liftsSentence),
                  trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                    IconButton(
                      icon: Icon(Icons.fitness_center),
                      color: Colors.blue,
                      onPressed: () => onEdit(index),
                    ),
                    PopupMenuButton<SessionMenuOption>(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        tooltip: 'Session action menu',
                        onSelected: (SessionMenuOption action) {
                          switch (action) {
                            case SessionMenuOption.delete:
                              onDelete(index);
                              break;
                            case SessionMenuOption.copy:
                              onCopy(index);
                              break;
                            case SessionMenuOption.email:
                              onEmail(index);
                              break;
                          }
                        },
                        itemBuilder: (BuildContext context) =>
                            <PopupMenuEntry<SessionMenuOption>>[
                              const PopupMenuItem<SessionMenuOption>(
                                value: SessionMenuOption.copy,
                                child: Text('Create copy'),
                              ),
                              const PopupMenuItem<SessionMenuOption>(
                                value: SessionMenuOption.email,
                                child: Text('Send via email'),
                              ),
                              const PopupMenuDivider(),
                              const PopupMenuItem<SessionMenuOption>(
                                value: SessionMenuOption.delete,
                                child: Text('Delete session',
                                    style: TextStyle(color: Colors.red)),
                              ),
                            ])
                  ]),
                ),
              );
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
