import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'stored_session.dart';
import 'traindown_info.dart';

enum SessionMenuOption { copy, delete, edit, email }

class SessionList extends StatelessWidget {
  final List<StoredSession> sessions;
  final ValueChanged<StoredSession> onCopy;
  final ValueChanged<StoredSession> onDelete;
  final ValueChanged<StoredSession> onEmail;
  final ValueChanged<StoredSession> onEdit;
  final ValueChanged<StoredSession> onView;

  SessionList(
      {Key key,
      this.sessions,
      this.onCopy,
      this.onDelete,
      this.onEmail,
      this.onEdit,
      this.onView})
      : super(key: key);

  Widget metric(BuildContext context, String amount, String label) {
    return Expanded(
        child: Column(children: [
      Text(amount,
          style: Theme.of(context)
              .textTheme
              .bodyText1
              .copyWith(color: Theme.of(context).accentColor)),
      Text(label, style: TextStyle(color: Colors.grey))
    ]));
  }

  Widget renderList(BuildContext context) {
    return Expanded(
        child: ListView.builder(
            itemCount: sessions.length,
            itemBuilder: (context, index) {
              StoredSession session = sessions[index];

              return Card(
                  color: session.errored
                      ? Colors.red
                      : Theme.of(context).cardColor,
                  child: InkWell(
                      splashColor: Colors.blue.withAlpha(30),
                      onTap: () => onView(session),
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(15.0, 0, 15.0, 10.0),
                        child: Column(children: [
                          ListTile(
                            contentPadding: EdgeInsets.all(0.0),
                            onTap: () => onView(session),
                            title: Text(session.name,
                                style: Theme.of(context).textTheme.headline6),
                            trailing:
                                Row(mainAxisSize: MainAxisSize.min, children: [
                              PopupMenuButton<SessionMenuOption>(
                                  icon: Icon(Icons.more_vert),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  tooltip: 'Session action menu',
                                  onSelected: (SessionMenuOption action) {
                                    switch (action) {
                                      case SessionMenuOption.copy:
                                        onCopy(session);
                                        break;
                                      case SessionMenuOption.delete:
                                        onDelete(session);
                                        break;
                                      case SessionMenuOption.edit:
                                        onEdit(session);
                                        break;
                                      case SessionMenuOption.email:
                                        onEmail(session);
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
                          Container(
                              padding: EdgeInsets.only(bottom: 10.0),
                              child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Wrap(children: [
                                    Text(session.liftsSentence,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText2
                                            .copyWith(
                                                color: Theme.of(context)
                                                    .hintColor)),
                                  ]))),
                          Row(children: [
                            metric(context, session.volumeString, 'volume'),
                            metric(context, session.movements.length.toString(),
                                'exercises'),
                            metric(
                                context, session.setCount.toString(), 'sets'),
                            metric(
                                context, session.repCount.toString(), 'reps'),
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
                          ])),
                  TraindownInfo()
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
