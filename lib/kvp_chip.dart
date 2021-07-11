import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class KvpChip extends StatelessWidget {
  final String? keyLabel;
  final String? valueLabel;

  KvpChip({Key? key, this.keyLabel, this.valueLabel});

  Widget chip() {
    return Chip(
        label: Text.rich(TextSpan(
      text: '$keyLabel: ',
      children: <TextSpan>[
        TextSpan(
            text: valueLabel, style: TextStyle(fontWeight: FontWeight.normal)),
      ],
    )));
  }

  @override
  Widget build(BuildContext context) {
    return chip();
  }
}
