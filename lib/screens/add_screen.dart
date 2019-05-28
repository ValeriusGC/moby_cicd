import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mobynote/NoteModel.dart';
import 'package:mobynote/generated/i18n.dart';
import 'package:mobynote/keys.dart';
import 'package:mobynote/utils/attrs.dart';
import 'package:rx_command/rx_command.dart';
import 'package:rxdart/rxdart.dart';

class TextEditingControllerWorkaroud extends TextEditingController {
  TextEditingControllerWorkaroud({String text}) : super(text: text);

  void setTextAndPosition(String newText, {int caretPosition}) {
    int offset = caretPosition != null ? caretPosition : newText.length;
    value = value.copyWith(
        text: newText,
        selection: TextSelection.collapsed(offset: offset),
        composing: TextRange.empty);
  }
}

class AddScreen extends StatefulWidget {
  final Note note;
  final Function(Note) addNote;
  final Function(Note) updateNote;
  final RxCommand<Note, Note> process;

  AddScreen({
    Key key,
    this.note,
    this.addNote,
    this.updateNote,
    this.process,
  }) : super(key: key ?? EisKeys.addScreen);

  @override
  _AddScreenState createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  static final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String title;
  String text;

  TextEditingControllerWorkaroud _textController;
  FocusNode _textFocus;

  _AddScreenState() {}

  @override
  void initState() {
//    print('_AddScreenState.initState: initState');
    _parse();
    _textController = new TextEditingControllerWorkaroud(text: text);
    _textFocus = new FocusNode();
    // you can have different listner functions if you wish
     _textController.addListener(onChangeText);
     _textFocus.addListener(onChangeText);
  }

  void onChangeText() {
    String text = _textController.text;
    var pos = _textController.selection;
    TextSelection ts;
    bool hasFocus = _textFocus.hasFocus;
    print('_AddScreenState.onChange: $text, $pos');

//    //do your text transforming
//    _controller.text = newText;
//    _controller.selection = new TextSelection(
//        baseOffset: newText.length,
//        extentOffset: newText.length
//    );
  }

  @override
  Widget build(BuildContext context) {
//    print('_AddScreenState.build: build');
    return WillPopScope(
      onWillPop: _requestPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text(S.of(context).add_title),
        ),
        body: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: formKey,
            autovalidate: false,
            onWillPop: () {
              return Future(() => true);
            },
            child: Column(
              children: <Widget>[
                TextFormField(
                  initialValue: title ?? "",
                  key: EisKeys.titleField,
                  autofocus: false,
                  style: Theme.of(context).textTheme.headline,
                  decoration: InputDecoration(
                    hintText: S.of(context).title_hint,
                  ),
                  onSaved: (value) => title = value,
                ),
                // Expanded - because we are in Column, expand the
                //            contained row's height
                new Expanded(
                  child: new Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Expanded(
                        child:  Container(
                          margin: EdgeInsets.only(bottom: 22.0),
                          child: TextFormField(
                            controller: _textController,
                            focusNode: _textFocus,
                            key: EisKeys.textField,
                            maxLines: 30,
                            style: Theme.of(context).textTheme.subhead,
                            decoration: InputDecoration(
                              hintText: S.of(context).text_hint,
                            ),
                            onSaved: (value) => text = value,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                _mkBottomNavBar(context),
              ],
            ),
          ),
        ),
        //bottomSheet: _mkBottomNavBar(context),
      ),
    );
  }

  ///
  Future<bool> _requestPop() {
    final form = formKey.currentState;
//    print('Mobynote._AddScreenState._requestPop: form: $form');

    if (form.validate()) {
      form.save();
      final tryText = '${title.trim()}${text.trim()}';
      if (tryText.isEmpty) {
//      print('Mobynote._AddScreenState._requestPop: ver = ${widget.note.verOrd}');
//      if (widget.note.verOrd < 1) {
        Fluttertoast.showToast(
          msg: S.of(context).empty_note_deleted,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIos: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
        widget.process(null);
        return new Future.value(true);
//      }
//      else{
//        widget.note.noteText = S.of(context).empty_note;
//      }
      }else{
        widget.note.attrs.title = title;
        widget.note.noteText = text;
      }
//      print('Mobynote._AddScreenState._requestPop: widget.note.title: ${widget.note.getTitle()}');
    }
//    print(
//        'Mobynote._AddScreenState._requestPop: start, widget.note.text = ${widget.note.noteText}');

//    if (withoutAnyText(widget.note)) {
////      print('Mobynote._AddScreenState._requestPop: ver = ${widget.note.verOrd}');
////      if (widget.note.verOrd < 1) {
//        Fluttertoast.showToast(
//          msg: S.of(context).empty_note_deleted,
//          toastLength: Toast.LENGTH_SHORT,
//          gravity: ToastGravity.CENTER,
//          timeInSecForIos: 1,
//          backgroundColor: Colors.red,
//          textColor: Colors.white,
//        );
////        return new Future.value(true);
////      }
////      else{
////        widget.note.noteText = S.of(context).empty_note;
////      }
//    }

    if (widget.note.verOrd < 1) {
      widget.note.verOrd = 0;
    }
    print('Mobynote._AddScreenState._requestPop: widget.note=${widget.note}');
    widget.process(widget.note);

//    if (widget.note.verOrd == 0) {
//      widget.addNote(widget.note);
//    } else {
//      widget.updateNote(widget.note);
//    }

    return new Future.value(true);
  }

  void _parse() {
    title = castTo(widget.note.attrs.title, "");
    text = widget.note.noteText;
//    var strs = widget.note.noteText.split("\n");
//    switch(strs.length){
//      case 0:
//      case 1:
//        title = widget.note.getTitle();
//        text = widget.note.noteText;
//        break;
//      default:
//        title = strs.removeAt(0);
//        text = strs.join("\n");
//    }
  }

  Widget _mkBottomNavBar(BuildContext context) {
    return Container(
      height: 55.0,
      child: BottomAppBar(
        color: Colors.blueAccent,
        //color: Color.fromRGBO(58, 66, 86, 1.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                _toast(context);
              },
            ),
            IconButton(
              icon: Icon(Icons.undo, color: Colors.white),
              onPressed: () {
                _toast(context);
              },
            ),
            IconButton(
              icon: Icon(Icons.redo, color: Colors.white),
              onPressed: () {
                _toast(context);
              },
            ),
            IconButton(
              icon: Icon(Icons.arrow_forward, color: Colors.white),
              onPressed: () {
                _toast(context);
              },
            )
          ],
        ),
      ),
    );
  }

  void _toast(BuildContext context) {
    Fluttertoast.showToast(
      msg: S.of(context).nre,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIos: 1,
      backgroundColor: Colors.red,
      textColor: Colors.white,
    );
  }

}
