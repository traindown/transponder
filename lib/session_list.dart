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
                  onTap: () => onView(index),
                  leading: IconButton(
                    icon: Icon(Icons.edit),
                    color: Colors.blue,
                    onPressed: () => onEdit(index),
                  ),
                  title: Text(sessions[index].name),
                  subtitle: Text(sessions[index].liftsSentence),
                  trailing: PopupMenuButton<SessionMenuOption>(
                      elevation: 2.0,
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
                  Text(
                      'To get started, just tap the \'Add new session\' button at the top of the screen.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey)),
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
