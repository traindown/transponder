import 'package:flutter/material.dart';

import 'traindown_editor.dart';

class EditorModal extends ModalRoute<void> {
  String content;
  ValueChanged<String> onChange;

  EditorModal({this.content, this.onChange});

  @override
  Color get barrierColor => Colors.black.withOpacity(0.5);

  @override
  bool get barrierDismissible => false;

  @override
  String get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  bool get opaque => true;

  @override
  Duration get transitionDuration => Duration(milliseconds: 100);

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return Material(
        type: MaterialType.canvas,
        child: SafeArea(
            child: Stack(children: [
          TraindownEditor(content: content, onChange: onChange),
          Positioned(right: 20, top: 20, child: CloseButton())
        ])));
  }
}
