import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Filters extends StatelessWidget {
  final ScrollController controller;
  final Set<String> filterList;
  final Map<String, Set<String>> metadataByKey;
  final ValueChanged<String> onAdd;
  final ValueChanged<String> onRemove;

  Filters(
      {Key key,
      this.controller,
      this.filterList,
      this.metadataByKey,
      this.onAdd,
      this.onRemove})
      : super(key: key);

  List<String> get keys => metadataByKey.keys.toList()..sort();

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        padding: EdgeInsets.fromLTRB(5.0, 20.0, 5.0, 10.0),
        child: ListView.separated(
            controller: controller,
            separatorBuilder: (context, index) => Divider(color: Colors.grey),
            itemCount: keys.length,
            itemBuilder: (context, index) {
              String key = keys[index];
              List<String> values = metadataByKey[key].toList();
              values.sort((a, b) => a.compareTo(b));

              List<Widget> valueChecks = [];
              for (String value in values) {
                String filterString = '$key:$value';

                valueChecks.add(Column(children: [
                  Checkbox(
                      value: filterList.contains(filterString),
                      onChanged: (bool checkedValue) {
                        if (checkedValue) {
                          onAdd(filterString);
                        } else {
                          onRemove(filterString);
                        }
                      }),
                  Text(value),
                ]));
              }

              return Column(children: [
                Row(children: [
                  Container(
                      padding: EdgeInsets.only(left: 15.0),
                      child: Text.rich(TextSpan(
                          text: key,
                          style: Theme.of(context).textTheme.headline6)))
                ]),
                Wrap(spacing: 8.0, children: valueChecks)
              ]);
            }));
  }
}
