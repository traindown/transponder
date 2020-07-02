import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:traindown/traindown.dart';

class TraindownViewer extends StatelessWidget {
  final String content;
  Parser parser;

  TraindownViewer({Key key, this.content}) : super(key: key) {
    parser = Parser.for_string(content);
    // TODO: Guard this
    try {
      parser.parse();
    } catch (_) {}
  }

  List<Movement> get movements => parser.movements;

  Widget renderMovement(Movement movement) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(movement.name),
          Table(
              children: [
                    TableRow(children: [
                      TableCell(child: Text('Weight')),
                      TableCell(child: Text('Reps')),
                      TableCell(child: Text('Sets'))
                    ])
                  ] +
                  movement.performances.map((p) {
                    return TableRow(children: [
                      TableCell(child: Text(p.load.toString())),
                      TableCell(child: Text(p.reps.toString())),
                      TableCell(child: Text(p.repeat.toString())),
                    ]);
                  }).toList())
        ]);
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
                  itemBuilder: (context, index) {
                    return Card(child: renderMovement(movements[index]));
                  }))
        ]));
  }
}
