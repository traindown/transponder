// Flutter code sample for TextField

// This sample shows how to get a value from a TextField via the [onSubmitted]
// callback.
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:traindown/traindown.dart";

void main() => runApp(Transponder());

/// This Widget is the main application widget.
class Transponder extends StatelessWidget {
  static const String _title = "Traindown Transponder";

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      home: TraindownEditor(),
    );
  }
}

class TraindownEditor extends StatefulWidget {
  TraindownEditor({Key key}) : super(key: key);

  @override
  _TraindownEditor createState() => _TraindownEditor();
}

class _TraindownEditor extends State<TraindownEditor> {
  TextEditingController _controller;

  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addText(String addition) {
    int start = _controller.selection.extentOffset;
    int end = _controller.selection.extentOffset + addition.length;
    _controller.value = _controller.value.copyWith(
        text: _controller.text.replaceRange(start, start, addition),
        selection: TextSelection.collapsed(offset: end));
  }

  void _formatText() {
    Formatter formatter = Formatter.for_string(_controller.text);
    formatter.format();
    String text = formatter.output.toString();

    _controller.value = _controller.value.copyWith(
        text: text, selection: TextSelection.collapsed(offset: text.length));
  }

  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 40.0),
              child: EditableText(
                autocorrect: false,
                autofocus: true,
                backgroundCursorColor: Colors.blue,
                cursorColor: Colors.red,
                cursorWidth: 5,
                controller: _controller,
                enableSuggestions: false,
                expands: true,
                focusNode: FocusNode(),
                scrollPadding: EdgeInsets.all(20.0),
                keyboardType: TextInputType.multiline,
                maxLines: null,
                style: TextStyle(
                    color: Colors.black.withOpacity(0.8),
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
          ButtonBar(
            alignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              FlatButton(
                child: Text("Meta"),
                onPressed: () => _addText("\n# "),
              ),
              FlatButton(
                child: Text("Colon"),
                onPressed: () => _addText(": "),
              ),
              FlatButton(
                child: Text("Note"),
                onPressed: () => _addText("\n* "),
              ),
              FlatButton(
                child: Text("Superset"),
                onPressed: () => _addText("\n+ "),
              ),
              FlatButton(
                child: Text("Date"),
                onPressed: () => _addText("@ "),
              ),
            ],
          ),
          ButtonBar(
              alignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                FlatButton(
                  child: Text("Clean"),
                  onPressed: () => _formatText(),
                ),
              ])
        ]));
  }
}
