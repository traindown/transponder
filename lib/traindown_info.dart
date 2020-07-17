import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:url_launcher/url_launcher.dart';

class TraindownInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            border: Border.all(width: 2.0, color: Colors.grey[200]),
            color: Colors.grey[100]),
        margin: EdgeInsets.symmetric(vertical: 20.0),
        padding: EdgeInsets.all(20.0),
        child: Column(children: [
          Text(
              'For more information on how to write Traindown, check out the docs on the website:'),
          FlatButton(
              child: Text('https://www.traindown.com',
                  style: TextStyle(color: Colors.blue)),
              onPressed: () => launch('https://www.traindown.com'))
        ]));
  }
}
