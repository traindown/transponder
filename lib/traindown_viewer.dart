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

  Widget renderMovement(Movement movement) {
    return Padding(
        padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 20.0),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(movement.name,
                  style:
                      TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
              Divider(color: Colors.grey),
              Table(
                  children: [
                        TableRow(children: [
                          TableCell(
                              child: Text('WEIGHT',
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
                              child: Text(p.load.toString(),
                                  style: TextStyle(fontSize: 16.0))),
                          TableCell(
                              child: Text(p.reps.toString(),
                                  style: TextStyle(fontSize: 16.0))),
                          TableCell(
                              child: Text(p.repeat.toString(),
                                  style: TextStyle(fontSize: 16.0))),
                        ]);
                      }).toList())
            ]));
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
