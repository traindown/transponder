import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'repo.dart';
import 'sessions_importer.dart';
import 'traindown_info.dart';

class Settings extends StatefulWidget {
  final Repo repo;
  final SharedPreferences sharedPreferences;
  final Function? exportCallback;
  final Function? logsCallback;
  bool sessionsImporterOpen = false;

  Settings(
      {Key? key,
      required this.repo,
      required this.sharedPreferences,
      this.exportCallback,
      this.logsCallback})
      : super(key: key);

  @override
  SettingsState createState() {
    return SettingsState();
  }
}

class SettingsState extends State<Settings> {
  Widget renderSessionsImporter() {
    if (!widget.sessionsImporterOpen) return SizedBox.shrink();

    return Padding(
        padding: EdgeInsets.symmetric(vertical: 10.0),
        child: SessionsImporter(repo: widget.repo));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Column(children: [
      Form(
        autovalidateMode: AutovalidateMode.always,
        onChanged: () {
          Form.of(primaryFocus!.context!)!.save();
        },
        child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 50.0, vertical: 5.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
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
                          'lbs',
                  onSaved: (String? value) {
                    if (value == null || value.isEmpty) {
                      value = 'lbs';
                    }
                    widget.sharedPreferences.setString('defaultUnit', value);
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'You need to specify a default unit like lbs or kgs';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    hintText: 'heavy@weights.com, you@rad.com',
                    labelText: 'Send to email(s)',
                  ),
                  initialValue:
                      widget.sharedPreferences.getString('sendToEmails'),
                  onSaved: (String? value) {
                    if (value == null || value.isEmpty) {
                      widget.sharedPreferences.remove('sendToEmails');
                    } else {
                      widget.sharedPreferences.setString('sendToEmails', value);
                    }
                  },
                  validator: (value) {
                    if (value!.isNotEmpty &&
                        (!value.contains('@') || !value.contains('.'))) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                TraindownInfo(),
                Table(
                    border: TableBorder(
                        horizontalInside: BorderSide(
                            color: Theme.of(context).dividerColor, width: 1)),
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    children: [
                      TableRow(children: [
                        TableCell(
                            child: Padding(
                                padding: EdgeInsets.all(20.0),
                                child: Text(
                                    "Send an email that contains your entire Session history."))),
                        TableCell(
                            child: Padding(
                                padding: EdgeInsets.all(20.0),
                                child: ElevatedButton(
                                    onPressed: widget.exportCallback as void
                                        Function()?,
                                    child: Text('Export All Data')))),
                      ]),
                      TableRow(children: [
                        TableCell(
                            child: Padding(
                                padding: EdgeInsets.all(20.0),
                                child: Text(
                                    "Should you have any issues, please send me an email"
                                    " containing your logs using the button below."))),
                        TableCell(
                            child: Padding(
                                padding: EdgeInsets.all(20.0),
                                child: ElevatedButton(
                                    onPressed:
                                        widget.logsCallback as void Function()?,
                                    child: Text('Email Crash Logs')))),
                      ]),
                      TableRow(children: [
                        TableCell(
                            child: Padding(
                                padding: EdgeInsets.all(20.0),
                                child: Text(
                                    "Need to sync your Sessions between Transponder"
                                    " and the Base Station?"
                                    " Click the button!"))),
                        TableCell(
                            child: Padding(
                                padding: EdgeInsets.all(20.0),
                                child: ElevatedButton(
                                    onPressed: () => setState(() {
                                          widget.sessionsImporterOpen =
                                              !widget.sessionsImporterOpen;
                                        }),
                                    child: Text(widget.sessionsImporterOpen
                                        ? "Close Importer"
                                        : "Open Importer"))))
                      ])
                    ]),
                renderSessionsImporter(),
              ],
            )),
      )
    ]));
  }
}
