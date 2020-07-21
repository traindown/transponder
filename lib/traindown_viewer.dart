import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:traindown/traindown.dart';

import 'kvp_chip.dart';
import 'note.dart';

class TraindownViewer extends StatelessWidget {
  final String content;
  final Parser parser;
  final ScrollController scrollController;

  TraindownViewer({Key key, this.content, this.scrollController})
      : parser = Parser.for_string(content),
        super(key: key) {
    // TODO: Make this better
    try {
      parser.call();
    } catch (e) {}
  }

  List<Movement> get movements => parser.movements;

  Widget renderKvps(BuildContext context, Map<String, String> kvps,
      {leftPad = 15.0}) {
    if (kvps.isEmpty) return null;

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
                                .headline3
                                .copyWith(color: Theme.of(context).accentColor))
                      ]),
                  Divider(color: Colors.grey),
                  renderNotes(context, movement.metadata.notes, leftPad: 0.0),
                  renderKvps(context, movement.metadata.kvps, leftPad: 0.0),
                  renderPerformances(context, movement.performances),
                ].where((Object o) => o != null).toList())));
  }

  Widget renderNotes(BuildContext context, List<String> notes,
      {leftPad = 15.0}) {
    if (notes.isEmpty) return null;

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
    performances.forEach((p) {
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
            child: Text(p.repeat.toString(),
                style: Theme.of(context).textTheme.bodyText1,
                textAlign: TextAlign.left))
      ]));

      if (p.metadata.notes.isNotEmpty) {
        rows.add(renderNotes(context, p.metadata.notes, leftPad: 10.0));
      }

      if (p.metadata.kvps.isNotEmpty) {
        rows.add(renderKvps(context, p.metadata.kvps, leftPad: 10.0));
      }
    });

    return Column(children: rows);
  }

  String get occurred => DateFormat.yMMMMEEEEd('en_US').format(parser.occurred);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
          Expanded(
              child: ListView(
                  primary: false,
                  controller: scrollController,
                  children: <Widget>[
                        Padding(
                            padding: EdgeInsets.only(bottom: 20.0),
                            child: Text(occurred,
                                style: Theme.of(context).textTheme.headline1,
                                textAlign: TextAlign.center))
                      ] +
                      ([renderNotes(context, parser.metadata.notes)] +
                              [renderKvps(context, parser.metadata.kvps)] +
                              movements
                                  .map((m) => renderMovement(context, m))
                                  .toList())
                          .where((Object o) => o != null)
                          .toList()))
        ]));
  }
}
