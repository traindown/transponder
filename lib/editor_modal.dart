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
  Duration get transitionDuration => Duration(milliseconds: 200);

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return Scaffold(
        body: SafeArea(
            child: Stack(children: [
      TraindownEditor(content: content, onChange: onChange),
      Positioned(right: 22, top: 15, child: CloseButton())
    ])));
  }

  // TODO: DRY
  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0.0, 1.0),
        end: Offset.zero,
      ).animate(animation),
      child: child,
    );
  }
}
