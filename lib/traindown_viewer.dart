import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:traindown/traindown.dart';

class TraindownViewer extends StatelessWidget {
  final String content;
  final Parser parser;
  final ScrollController scrollController;

  TraindownViewer({Key key, this.content, this.scrollController})
      : parser = Parser.for_string(content),
        super(key: key) {
    parser.call();
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
              runSpacing: 4.0,
              children: kvps.keys.map((k) {
                return Chip(
                    backgroundColor: Theme.of(context).accentColor,
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

  Widget renderMovement(BuildContext context, Movement movement) {
    return Padding(
        padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 20.0),
        child: Card(
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
                              style: Theme.of(context).textTheme.headline2,
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
                                style: TextStyle(
                                    color: Theme.of(context).accentColor,
                                    fontSize: 18.0))
                          ]),
                      Divider(color: Colors.grey),
                      renderNotes(context, movement.metadata.notes,
                          leftPad: 0.0),
                      renderKvps(context, movement.metadata.kvps, leftPad: 0.0),
                      renderPerformances(context, movement.performances),
                    ].where((Object o) => o != null).toList()))));
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
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                            padding: EdgeInsets.only(top: 6.0),
                            child: Icon(Icons.lens, size: 6.0)),
                        Expanded(
                            child: Padding(
                                padding: EdgeInsets.only(left: 5.0),
                                child: Text(notes[index],
                                    style:
                                        Theme.of(context).textTheme.bodyText2)))
                      ]));
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
          ]))
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
                        Text(occurred,
                            style: Theme.of(context).textTheme.headline1,
                            textAlign: TextAlign.center)
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
