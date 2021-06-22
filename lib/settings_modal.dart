import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'settings.dart';

class SettingsModal extends ModalRoute<void> {
  final SharedPreferences sharedPreferences;
  final Function onExport;

  SettingsModal({this.sharedPreferences, this.onExport});

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
          Settings(
              sharedPreferences: sharedPreferences, exportCallback: onExport),
          Positioned(right: 20, top: 20, child: CloseButton())
        ])));
  }
}
