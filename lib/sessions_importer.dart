import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:traindown/traindown.dart';

import 'repo.dart';
import 'stored_session.dart';

class SessionsImporter extends StatefulWidget {
  final Repo repo;
  String sessionsText = "";
  bool overwrite = true;

  SessionsImporter({Key? key, required this.repo}) : super(key: key);

  @override
  SessionsImporterState createState() {
    return SessionsImporterState();
  }
}

class SessionsImporterState extends State<SessionsImporter> {
  Future<void> import() async {
    Importer importer = Importer(widget.sessionsText);

    for (String text in importer.sessionTexts) {
      StoredSession storedSession = StoredSession(text.trim(), widget.repo);
      // TODO: Handle the dupers/overwrite
      // TODO: Show confirmatory feedback
      bool saved = await storedSession.save();
    }
  }

  @override
  Widget build(BuildContext context) {
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
        margin: EdgeInsets.symmetric(vertical: 20.0),
        padding: EdgeInsets.all(20.0),
        child: Column(children: [
          Text("Session Importer"),
          Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0),
              child: TextFormField(
                  onChanged: (String text) {
                    setState(() {
                      widget.sessionsText = text;
                    });
                  },
                  maxLines: 50,
                  minLines: 5,
                  decoration: InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: "Paste your Traindown export here"))),
          Row(children: [
            Expanded(
                child: ElevatedButton(
                    onPressed: () => import(), child: Text("Import Sessions"))),
            Expanded(
                child: CheckboxListTile(
                    onChanged: (bool? value) {
                      setState(() {
                        widget.overwrite = !widget.overwrite;
                      });
                    },
                    title: Text("Overwrite existing Sessions?"),
                    value: widget.overwrite))
          ])
        ]));
  }
}
