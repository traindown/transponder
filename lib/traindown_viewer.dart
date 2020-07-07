import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:traindown/traindown.dart';

class TraindownViewer extends StatelessWidget {
  final String content;
  final Parser parser;

  TraindownViewer({Key key, this.content})
      : parser = Parser.for_string(content),
        super(key: key) {
    parser.call();
  }

  List<Movement> get movements => parser.movements;

  Widget renderKvps(Map<String, String> kvps) {
    if (kvps.isEmpty) return null;

    return Container(
        color: Colors.grey[100],
        padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 2.0),
        child: ListView.builder(
            primary: false,
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0),
            itemCount: kvps.keys.length,
            itemBuilder: (BuildContext context, int keyIndex) {
              return Row(children: [
                Padding(
                    padding: EdgeInsets.only(left: 5.0),
                    child: Text.rich(TextSpan(
                      text: '${kvps.keys.elementAt(keyIndex)}: ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                      children: <TextSpan>[
                        TextSpan(
                            text: kvps[kvps.keys.elementAt(keyIndex)],
                            style: TextStyle(fontWeight: FontWeight.normal)),
                      ],
                    )))
              ]);
            }));
  }

  Widget renderNotes(List<String> notes) {
    if (notes.isEmpty) return null;

    return Container(
        color: Colors.grey[100],
        padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 2.0),
        child: ListView.builder(
            primary: false,
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0),
            itemCount: notes.length,
            itemBuilder: (BuildContext context, int index) {
              return Row(children: [
                Icon(Icons.lens, size: 6.0),
                Padding(
                    padding: EdgeInsets.only(left: 5.0),
                    child: Text(notes[index]))
              ]);
            }));
  }

  Widget renderPerformances(List<Performance> performances) {
    List<Widget> rows = [
      Row(children: [
        Expanded(child: Text('LOAD', style: TextStyle(color: Colors.grey))),
        Expanded(child: Text('REPS', style: TextStyle(color: Colors.grey))),
        Expanded(child: Text('SETS', style: TextStyle(color: Colors.grey))),
      ])
    ];
    performances.forEach((p) {
      rows.add(Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        Expanded(
            child: Text.rich(TextSpan(
          text: p.load.toString(),
          style: TextStyle(fontSize: 16.0),
          children: <TextSpan>[
            TextSpan(text: p.unit, style: TextStyle(color: Colors.grey)),
          ],
        ))),
        Expanded(
            child: Text.rich(TextSpan(
          text: p.reps.toString(),
          style: TextStyle(fontSize: 16.0),
          children: p.fails > 0
              ? <TextSpan>[
                  TextSpan(
                      text: '(${p.fails})', style: TextStyle(color: Colors.red))
                ]
              : [],
        ))),
        Expanded(
            child: Text(p.repeat.toString(), style: TextStyle(fontSize: 16.0)))
      ]));

      if (p.metadata.notes.isNotEmpty) {
        rows.add(renderNotes(p.metadata.notes));
      }
    });
    return Column(children: rows);
  }

  Widget renderMovement(Movement movement) {
    return Padding(
        padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 20.0),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text.rich(TextSpan(
                  text: movement.name.trim(),
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
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
                )),
                Text(movement.volume.toString(),
                    style: TextStyle(fontSize: 18.0))
              ]),
              Divider(color: Colors.grey),
              renderNotes(movement.metadata.notes),
              renderKvps(movement.metadata.kvps),
              renderPerformances(movement.performances),
            ].where((Object o) => o != null).toList()));
  }

  String get occurred => DateFormat.yMMMMEEEEd('en_US').format(parser.occurred);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
          Container(
              margin: EdgeInsets.only(bottom: 10.0),
              child: Text(occurred,
                  style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center)),
          Expanded(
              child: ListView(
                  children: ([renderNotes(parser.metadata.notes)] +
                          [renderKvps(parser.metadata.kvps)] +
                          movements.map((m) => renderMovement(m)).toList())
                      .where((Object o) => o != null)
                      .toList()))
        ]));
  }
}
