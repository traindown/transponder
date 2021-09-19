import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class KvpChip extends StatelessWidget {
  final String? keyLabel;
  final String? valueLabel;

  KvpChip({Key? key, this.keyLabel, this.valueLabel});

  Widget chip() {
    return Chip(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(5.0))),
        labelPadding: EdgeInsets.all(0.0),
        label: Text.rich(TextSpan(
          style: TextStyle(fontSize: 11.0),
          text: '$keyLabel: ',
          children: <TextSpan>[
            TextSpan(
                text: valueLabel,
                style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        )));
  }

  @override
  Widget build(BuildContext context) {
    return chip();
  }
}
