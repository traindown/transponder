import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'filters.dart';

class FiltersModal extends ModalRoute<void> {
  final Set<String> filterList;
  final Map<String, Set<String>> metadataByKey;
  final Function onAdd;
  final Function onRemove;

  FiltersModal(
      {this.filterList, this.metadataByKey, this.onAdd, this.onRemove});

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
      Padding(
          padding: EdgeInsets.only(bottom: 40.0),
          child: Filters(
              filterList: filterList,
              metadataByKey: metadataByKey,
              onAdd: onAdd,
              onRemove: onRemove)),
      Positioned.fill(
          bottom: 0,
          child: Align(
              alignment: Alignment.bottomCenter,
              child: ElevatedButton(
                  onPressed: () {
                    Navigator.maybePop(context);
                  },
                  child: Text('Apply Filters'))))
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
