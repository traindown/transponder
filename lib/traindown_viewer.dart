import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

//import 'package:traindown/traindown.dart';

class TraindownViewer extends StatelessWidget {
  final String content;

  TraindownViewer({Key key, this.content}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
          Expanded(
            child: Padding(padding: EdgeInsets.all(10.0), child: Text(content)),
          ),
        ]));
  }
}
