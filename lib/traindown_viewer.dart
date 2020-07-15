import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:traindown/traindown.dart';

class TraindownViewer extends StatelessWidget {
  final String content;
  final Parser parser;
  final ScrollController controller;

  TraindownViewer({Key key, this.content, this.controller})
      : parser = Parser.for_string(content),
        super(key: key) {
    parser.call();
  }

  List<Movement> get movements => parser.movements;

  Widget renderKvps(Map<String, String> kvps, {leftPad = 15.0}) {
    if (kvps.isEmpty) return null;

    return Container(
        padding: EdgeInsets.fromLTRB(leftPad, 0.0, 0.0, 10.0),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Wrap(
              spacing: 4.0,
              runSpacing: 4.0,
              children: kvps.keys.map((k) {
                return Chip(
                    backgroundColor: Colors.grey[200],
                    labelPadding: EdgeInsets.all(0.0),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding: EdgeInsets.all(5.0),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(5.0))),
                    label: Text.rich(TextSpan(
                      text: '$k: ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                      children: <TextSpan>[
                        TextSpan(
                            text: kvps[k],
                            style: TextStyle(fontWeight: FontWeight.normal)),
                      ],
                    )));
              }).toList()),
        ));
  }

  Widget renderMovement(Movement movement) {
    return Padding(
        padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 20.0),
        child: Card(
            child: Padding(
                padding: EdgeInsets.all(10.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text.rich(TextSpan(
                              text: movement.name.trim(),
                              style: TextStyle(
                                  fontSize: 18.0, fontWeight: FontWeight.bold),
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
                      renderNotes(movement.metadata.notes, leftPad: 0.0),
                      renderKvps(movement.metadata.kvps, leftPad: 0.0),
                      renderPerformances(movement.performances),
                    ].where((Object o) => o != null).toList()))));
  }

  Widget renderNotes(List<String> notes, {leftPad = 15.0}) {
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
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                            padding: EdgeInsets.only(top: 6.0),
                            child: Icon(Icons.lens, size: 6.0)),
                        Expanded(
                            child: Padding(
                                padding: EdgeInsets.only(left: 5.0),
                                child: Text(notes[index])))
                      ]));
            }));
  }

  Widget renderPerformances(List<Performance> performances) {
    List<Widget> rows = [
      Row(children: [
        Expanded(
            child: Text('Load',
                style: TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.left)),
        Expanded(
            child: Text('Reps',
                style: TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.left)),
        Expanded(
            child: Text('Sets',
                style: TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.left)),
      ])
    ];
    performances.forEach((p) {
      rows.add(Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        Expanded(
            child: Text.rich(
                TextSpan(
                  text: p.load.toString(),
                  style: TextStyle(fontSize: 16.0),
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
                  style: TextStyle(fontSize: 16.0),
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
                style: TextStyle(fontSize: 16.0), textAlign: TextAlign.left))
      ]));

      if (p.metadata.notes.isNotEmpty) {
        rows.add(renderNotes(p.metadata.notes, leftPad: 10.0));
      }

      if (p.metadata.kvps.isNotEmpty) {
        rows.add(renderKvps(p.metadata.kvps, leftPad: 10.0));
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
          Container(
              margin: EdgeInsets.symmetric(vertical: 20.0),
              child: Text(occurred,
                  style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center)),
          Expanded(
              child: ListView(
                  primary: false,
                  controller: controller,
                  children: ([renderNotes(parser.metadata.notes)] +
                          [renderKvps(parser.metadata.kvps)] +
                          movements.map((m) => renderMovement(m)).toList())
                      .where((Object o) => o != null)
                      .toList()))
        ]));
  }
}
