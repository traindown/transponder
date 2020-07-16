import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:traindown/traindown.dart';

class TraindownEditor extends StatefulWidget {
  final String content;
  final ValueChanged<String> onChange;
  final ScrollController scrollController;

  TraindownEditor({Key key, this.content, this.onChange, this.scrollController})
      : super(key: key);

  @override
  _TraindownEditor createState() => _TraindownEditor();
}

class _TraindownEditor extends State<TraindownEditor> {
  TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.content);
  }

  @override
  void dispose() {
    _formatText();
    _controller.dispose();
    super.dispose();
  }

  void _addText(String addition) {
    addition = addition.isEmpty ? '' : addition;
    int start = _controller.selection.extentOffset;
    int end = _controller.selection.extentOffset + addition.length;
    _controller.value = _controller.value.copyWith(
        text: _controller.text.replaceRange(start, start, addition),
        selection: TextSelection.collapsed(offset: end));
    widget.onChange(_controller.value.text);
  }

  void _formatText() {
    Formatter formatter = Formatter.for_string(_controller.text);
    formatter.format();
    String text = formatter.output.toString();

    _controller.value = _controller.value.copyWith(
        text: text, selection: TextSelection.collapsed(offset: text.length));

    widget.onChange(_controller.value.text);
  }

  // TODO: Suggestions
  void _handleTextChange(String text) {
    widget.onChange(text);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
        //crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.fromLTRB(15.0, 0.0, 15.0,
                (MediaQuery.of(context).viewInsets.bottom) + 50.0),
            child: EditableText(
              autocorrect: true,
              autofocus: true,
              backgroundCursorColor: Colors.blue,
              cursorColor: Colors.red,
              cursorWidth: 2,
              controller: _controller,
              enableInteractiveSelection: true,
              enableSuggestions: true,
              expands: true,
              focusNode: FocusNode(),
              onChanged: (String text) => _handleTextChange(text),
              scrollController: widget.scrollController,
              keyboardType: TextInputType.multiline,
              maxLines: null,
              style: TextStyle(
                  color: Colors.black.withOpacity(0.8),
                  fontSize: 20,
                  fontWeight: FontWeight.normal),
            ),
          ),
          Positioned(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 0.0,
              right: 0.0,
              child: ButtonBar(
                alignment: MainAxisAlignment.center,
                buttonHeight: 10.0,
                buttonMinWidth: 10.0,
                buttonPadding: EdgeInsets.all(1.0),
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  FlatButton(
                    child: Text('Meta'),
                    onPressed: () => _addText('# '),
                  ),
                  FlatButton(
                    child: Text('Colon'),
                    onPressed: () => _addText(': '),
                  ),
                  FlatButton(
                    child: Text('Note'),
                    onPressed: () => _addText('* '),
                  ),
                  FlatButton(
                    child: Text('Superset'),
                    onPressed: () => _addText('+ '),
                  ),
                  FlatButton(
                    child: Text('Date'),
                    onPressed: () => _addText('@ '),
                  ),
                  FlatButton(
                    child: Text('Tidy'),
                    onPressed: () => _formatText(),
                  ),
                ],
              )),
        ]);
  }
}
