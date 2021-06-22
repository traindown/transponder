import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:traindown/traindown.dart';

class TraindownEditor extends StatefulWidget {
  final String content;
  final ValueChanged<String> onChange;

  TraindownEditor({Key key, this.content, this.onChange}) : super(key: key);

  @override
  _TraindownEditor createState() => _TraindownEditor();
}

class _TraindownEditor extends State<TraindownEditor> {
  TextEditingController _controller;
  final Formatter formatter = Formatter();

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
    int start = _controller.selection.extentOffset;
    int end = _controller.selection.extentOffset + addition.length;
    _controller.value = _controller.value.copyWith(
        text: _controller.text.replaceRange(start, start, addition),
        selection: TextSelection.collapsed(offset: end));
    widget.onChange(_controller.value.text);
  }

  void _formatText() {
    Parser parser = Parser(_controller.text);
    String text = formatter.format(parser.tokens());

    _controller.value = _controller.value.copyWith(
        text: text, selection: TextSelection.collapsed(offset: text.length));

    widget.onChange(_controller.value.text);
  }

  // TODO: Suggestions
  void _handleTextChange(String text) {
    widget.onChange(text);
  }

  Widget buttonBar() {
    return Positioned(
        bottom: 0.0,
        left: 0.0,
        right: 0.0,
        child: ButtonBar(
          overflowDirection: VerticalDirection.up,
          children: <Widget>[
            TextButton(
              onPressed: () => _addText('# '),
              child: Text('#', style: TextStyle(fontSize: 20.0)),
            ),
            TextButton(
              onPressed: () => _addText('* '),
              child: Text('*', style: TextStyle(fontSize: 24.0)),
            ),
            TextButton(
              onPressed: () => _addText(': '),
              child: Text(':',
                  style:
                      TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
            ),
            TextButton(
              onPressed: () => _addText('+ '),
              child: Text('+', style: TextStyle(fontSize: 20.0)),
            ),
            TextButton(
              onPressed: () => _addText('r '),
              child: Text('r', style: TextStyle(fontSize: 20.0)),
            ),
            TextButton(
              onPressed: () => _addText('s '),
              child: Text('s', style: TextStyle(fontSize: 20.0)),
            ),
            TextButton(
              onPressed: () => _formatText(),
              child: Icon(Icons.photo_filter),
            ),
          ],
        ));
  }

  Widget textArea() {
    return Padding(
      padding: EdgeInsets.fromLTRB(15.0, 25.0, 65.0, 0.0),
      child: EditableText(
        autocorrect: true,
        autocorrectionTextRectColor: Colors.blue[100],
        autofocus: true,
        backgroundCursorColor: Colors.blue,
        cursorColor: Colors.red,
        cursorWidth: 2,
        controller: _controller,
        enableInteractiveSelection: true,
        enableSuggestions: true,
        expands: true,
        focusNode: FocusNode(),
        keyboardType: TextInputType.multiline,
        maxLines: null,
        minLines: null,
        onChanged: (String text) => _handleTextChange(text),
        style: Theme.of(context).textTheme.bodyText1,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
        alignment: AlignmentDirectional.bottomEnd,
        fit: StackFit.expand,
        children: <Widget>[textArea(), buttonBar()]);
  }
}
