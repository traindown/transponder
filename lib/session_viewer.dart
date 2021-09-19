import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:traindown/traindown.dart';

import 'kvp_chip.dart';
import 'note.dart';
import 'stored_session.dart';

class SessionViewer extends StatelessWidget {
  final StoredSession session;

  SessionViewer({Key? key, required this.session}) : super(key: key);

  List<Movement> get movements => session.movements!;

  Widget renderKvps(BuildContext context, Map<String, String> kvps,
      {leftPad = 15.0}) {
    return Container(
        padding: EdgeInsets.fromLTRB(leftPad, 0.0, 0.0, 10.0),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Wrap(
              spacing: 4.0,
              runSpacing: -8.0,
              children: kvps.keys
                  .map((k) => KvpChip(keyLabel: k, valueLabel: kvps[k]))
                  .toList()),
        ));
  }

  Widget renderMovement(BuildContext context, Movement movement) {
    return Card(
        margin: EdgeInsets.all(10.0),
        child: Padding(
            padding: EdgeInsets.all(15.0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                            child: Text.rich(TextSpan(
                          text: movement.name.trim(),
                          style: Theme.of(context).textTheme.headline3,
                          children: movement.superSetted
                              ? <TextSpan>[
                                  TextSpan(
                                      text: ' (superset)',
                                      style: TextStyle(
                                          color: Colors.grey,
                                          fontWeight: FontWeight.normal,
                                          fontSize: 14.0)),
                                ]
                              : [],
                        ))),
                        Text(
                            NumberFormat.decimalPattern()
                                .format(movement.volume),
                            style: Theme.of(context)
                                .textTheme
                                .headline3!
                                .copyWith(color: Theme.of(context).accentColor))
                      ]),
                  Divider(color: Colors.grey),
                  renderNotes(context, movement.metadata.notes, leftPad: 0.0),
                  renderKvps(context, movement.metadata.kvps, leftPad: 0.0),
                  renderPerformances(context, movement.performances),
                ].whereType<Widget>().toList())));
  }

  Widget renderNotes(BuildContext context, List<String> notes,
      {leftPad = 15.0}) {
    return Container(
        child: ListView.builder(
            primary: false,
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0),
            itemCount: notes.length,
            itemBuilder: (BuildContext context, int index) {
              return Padding(
                  padding: EdgeInsets.fromLTRB(leftPad, 0.0, 0.0, 0.0),
                  child: Note(text: notes[index]));
            }));
  }

  Widget renderPerformances(
      BuildContext context, List<Performance> performances) {
    List<Widget> rows = [
      Container(
          padding: EdgeInsets.only(top: 15.0),
          child: Row(children: [
            Expanded(
                child: Text('Load',
                    style: Theme.of(context).textTheme.headline6,
                    textAlign: TextAlign.left)),
            Expanded(
                child: Text('Reps',
                    style: Theme.of(context).textTheme.headline6,
                    textAlign: TextAlign.left)),
            Expanded(
                child: Text('Sets',
                    style: Theme.of(context).textTheme.headline6,
                    textAlign: TextAlign.left)),
          ]))
    ];

    for (Performance p in performances) {
      rows.add(Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        Expanded(
            child: Text.rich(
                TextSpan(
                  text: p.load.toString(),
                  style: Theme.of(context).textTheme.bodyText1,
                  children: <TextSpan>[
                    TextSpan(
                        text: p.unit, style: TextStyle(color: Colors.grey)),
                  ],
                ),
                textAlign: TextAlign.left)),
        Expanded(
            child: Text.rich(
                TextSpan(
                  text: p.reps.toString(),
                  style: Theme.of(context).textTheme.bodyText1,
                  children: p.fails > 0
                      ? <TextSpan>[
                          TextSpan(
                              text: '(${p.fails})',
                              style: TextStyle(color: Colors.red))
                        ]
                      : [],
                ),
                textAlign: TextAlign.left)),
        Expanded(
            child: Text(p.sets.toString(),
                style: Theme.of(context).textTheme.bodyText1,
                textAlign: TextAlign.left))
      ]));

      if (p.metadata.notes.isNotEmpty) {
        rows.add(renderNotes(context, p.metadata.notes, leftPad: 10.0));
      }

      if (p.metadata.kvps.isNotEmpty) {
        rows.add(renderKvps(context, p.metadata.kvps, leftPad: 10.0));
      }
    }

    return Column(children: rows);
  }

  String get occurred {
    return DateFormat.yMMMMEEEEd('en_US').format(session.occurred);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        // NOTE: This is critical if used in SplitView
        controller: ScrollController(),
        child: Column(
            children: <Widget>[
                  Padding(
                      padding: EdgeInsets.symmetric(vertical: 25.0),
                      child: Text(occurred,
                          style: Theme.of(context).textTheme.headline1,
                          textAlign: TextAlign.center)),
                  ButtonBar(alignment: MainAxisAlignment.center, children: [
                    OutlinedButton(
                        onPressed: () => {}, child: Text('Duplicate')),
                    OutlinedButton(onPressed: () => {}, child: Text('Edit'))
                  ])
                ] +
                ([renderNotes(context, session.session!.metadata.notes)] +
                        [renderKvps(context, session.session!.metadata.kvps)] +
                        movements
                            .map((m) => renderMovement(context, m))
                            .toList())
                    .whereType<Widget>()
                    .toList()));
  }
}
