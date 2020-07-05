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

  Widget renderNotes(List<String> notes) {
    if (notes.isEmpty) return null;

    return Padding(
        padding: EdgeInsets.only(bottom: 10.0),
        child: ListView.builder(
            primary: false,
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0),
            itemCount: notes.length,
            itemBuilder: (BuildContext context, int index) {
              return Row(children: [
                Icon(Icons.stars, size: 10.0),
                Padding(
                    padding: EdgeInsets.only(left: 5.0),
                    child: Text(notes[index]))
              ]);
            }));
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
                Text(movement.volume.toString())
              ]),
              Divider(color: Colors.grey),
              renderNotes(movement.metadata.notes),
              Table(
                  children: [
                        TableRow(children: [
                          TableCell(
                              child: Text('LOAD',
                                  style: TextStyle(color: Colors.grey))),
                          TableCell(
                              child: Text('REPS',
                                  style: TextStyle(color: Colors.grey))),
                          TableCell(
                              child: Text('SETS',
                                  style: TextStyle(color: Colors.grey))),
                        ])
                      ] +
                      movement.performances.map((p) {
                        return TableRow(children: [
                          TableCell(
                              child: Text.rich(TextSpan(
                            text: p.load.toString(),
                            style: TextStyle(fontSize: 16.0),
                            children: <TextSpan>[
                              TextSpan(
                                  text: p.unit,
                                  style: TextStyle(color: Colors.grey)),
                            ],
                          ))),
                          TableCell(
                              child: Text.rich(TextSpan(
                            text: p.reps.toString(),
                            style: TextStyle(fontSize: 16.0),
                            children: p.fails > 0
                                ? <TextSpan>[
                                    TextSpan(
                                        text: '(${p.fails})',
                                        style: TextStyle(color: Colors.red))
                                  ]
                                : [],
                          ))),
                          TableCell(
                              child: Text(p.repeat.toString(),
                                  style: TextStyle(fontSize: 16.0))),
                        ]);
                      }).toList())
            ].where((Object o) => o != null).toList()));
  }

  String get occurred => DateFormat.yMMMMEEEEd('en_US').format(parser.occurred);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
          Text(occurred,
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center),
          Expanded(
              child: ListView.builder(
                  itemCount: movements.length,
                  itemBuilder: (context, index) =>
                      renderMovement(movements[index])))
        ]));
  }
}
