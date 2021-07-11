import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Note extends StatelessWidget {
  final String? text;

  Note({Key? key, this.text});

  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
          padding: EdgeInsets.only(top: 6.0),
          child: Icon(Icons.lens,
              color: Theme.of(context).accentColor, size: 8.0)),
      Expanded(
          child: Padding(
              padding: EdgeInsets.only(left: 5.0),
              child: Text(text!, style: Theme.of(context).textTheme.bodyText1)))
    ]);
  }
}
