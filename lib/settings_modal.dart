import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'settings.dart';

class SettingsModal extends ModalRoute<void> {
  final SharedPreferences sharedPreferences;
  final Function onExport;
  final Function onLogs;

  SettingsModal({this.sharedPreferences, this.onExport, this.onLogs});

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
    return Material(
        type: MaterialType.canvas,
        child: SafeArea(
            child: Stack(children: [
          Settings(
              sharedPreferences: sharedPreferences,
              exportCallback: onExport,
              logsCallback: onLogs),
          Positioned(right: 20, top: 20, child: CloseButton())
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
