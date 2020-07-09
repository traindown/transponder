import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

// Create a Form widget.
class Settings extends StatefulWidget {
  final SharedPreferences sharedPreferences;

  Settings({Key key, @required this.sharedPreferences})
      : assert(sharedPreferences != null),
        super(key: key);

  @override
  SettingsState createState() {
    return SettingsState();
  }
}

class SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return Form(
      autovalidate: true,
      onChanged: () {
        Form.of(primaryFocus.context).save();
      },
      child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 50.0, vertical: 5.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Center(
                  child: Text('Settings',
                      style: TextStyle(
                          fontSize: 20.0, fontWeight: FontWeight.bold))),
              TextFormField(
                decoration: const InputDecoration(
                  hintText: 'Unit like lbs or kgs',
                  labelText: 'Default session unit',
                ),
                // TODO: Constantize the keys
                initialValue:
                    widget.sharedPreferences.getString('defaultUnit') ??
                        'fucks',
                onSaved: (String value) {
                  if (value == null || value.isEmpty) {
                    value = 'lbs';
                  }
                  widget.sharedPreferences.setString('defaultUnit', value);
                },
                validator: (value) {
                  if (value.isEmpty) {
                    return 'You need to specify a default unit like lbs or kgs';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(
                  hintText: 'heavy@weights.com',
                  labelText: 'Send to email',
                ),
                onSaved: (String value) {
                  if (value == null || value.isEmpty) {
                    widget.sharedPreferences.remove('sendToEmail');
                  } else {
                    widget.sharedPreferences.setString('sendToEmail', value);
                  }
                },
                validator: (value) {
                  if (value.isNotEmpty &&
                      (!value.contains('@') || !value.contains('.'))) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
            ],
          )),
    );
  }
}
