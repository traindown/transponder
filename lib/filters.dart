import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'traindown_info.dart';

// TODO: Figure out how to not shadow parent state.

class Filters extends StatefulWidget {
  final Set<String>? filterList;
  final Map<String, Set<String>>? metadataByKey;
  final ValueChanged<String>? onAdd;
  final ValueChanged<String>? onRemove;

  Filters(
      {Key? key, this.filterList, this.metadataByKey, this.onAdd, this.onRemove})
      : super(key: key);

  @override
  _Filters createState() => _Filters();
}

class _Filters extends State<Filters> {
  List<String> get keys => widget.metadataByKey!.keys.toList()..sort();

  Widget _instructions() {
    return Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5.0),
            boxShadow: [
              BoxShadow(
                  color: Colors.grey[300]!,
                  offset: Offset(0, 2),
                  blurRadius: 5.0,
                  spreadRadius: 2.0)
            ],
            color: Theme.of(context).cardColor),
        margin: EdgeInsets.all(10.0),
        padding: EdgeInsets.all(10.0),
        child: Column(children: [
          Text(
              "Below are all metadata key/value pairs in all your currently filtered Sessions."),
          Container(
              padding: EdgeInsets.only(top: 10),
              child: Text(
                  "Sessions with matching metadata will be shown in the list when filters are applied."))
        ]));
  }

  Widget _listView() {
    if (widget.metadataByKey!.isEmpty) {
      return Column(children: [
        Container(
            padding: EdgeInsets.only(top: 100.0),
            child: Text("You currently have no Session metadata.",
                style: Theme.of(context).textTheme.headline1,
                textAlign: TextAlign.center)),
        Container(
            padding: EdgeInsets.symmetric(horizontal: 10.0),
            child: TraindownInfo())
      ]);
    }

    return ListView.separated(
        separatorBuilder: (context, index) => Divider(color: Colors.grey),
        itemCount: keys.length,
        itemBuilder: (context, index) {
          String key = keys[index];
          List<String> values = widget.metadataByKey![key]!.toList();
          values.sort((a, b) => a.compareTo(b));

          List<Widget> valueChecks = [];
          for (String value in values) {
            String filterString = '$key:$value';
            valueChecks.add(_renderCheck(filterString, value));
          }

          return Column(children: [
            Center(
                child: Text("# $key:",
                    style: Theme.of(context).textTheme.headline6,
                    textAlign: TextAlign.center)),
            Wrap(spacing: 20.0, children: valueChecks)
          ]);
        });
  }

  Widget _renderCheck(String filterString, String value) {
    return Column(children: [
      Checkbox(
          value: widget.filterList!.contains(filterString),
          onChanged: (bool? checkedValue) {
            if (checkedValue!) {
              setState(() {
                widget.filterList!.add(filterString);
              });
              widget.onAdd!(filterString);
            } else {
              setState(() {
                widget.filterList!.remove(filterString);
              });
              widget.onRemove!(filterString);
            }
          }),
      Text(value),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [_instructions(), Expanded(child: _listView())]);
  }
}
