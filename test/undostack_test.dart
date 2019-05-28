import 'package:mobynote/NoteModel.dart';
import 'package:mobynote/model/jsonable.dart';
import 'package:mobynote/model/undo_note_model.dart';
import 'package:test/test.dart';
import 'test_data/stack_data.dart';
import 'test_data/test_entity.dart';
import 'dart:convert';


void main() {

  test('Test inheritance', (){

    {
      //  1. turn object to Map
      final obj = MyObj('a', 10);
      final stack = MyStack(obj);
//      print('Mobynote.test.main.stack: $stack');
      final Map m = stack.toJson();
//      print('Mobynote.test.main.m.type: ${m.runtimeType}');
//      print('Mobynote.test.main.m: $m');
//      print('Mobynote.test.main: sub is Jsonable: ${stack is Jsonable}');
      //
      stack.push(Cmd1('cmd1', 10));
      stack.push(Cmd2('cmd2', -33));
//      print('Mobynote.test.main.stack: $stack');
      //  2. turn Map to JSON
      final json = jsonEncode(m);
//      print('Mobynote.test.main -> json: $json');
      ///////////////////////////
      //  1. turn JSON to Map
      final map = jsonDecode(json);
//      print('Mobynote.test.main -> map: $map');
      final Stack stackBack = MyStack.fromJson(map);
//      print('Mobynote.test.main.stackBack: $stackBack');
      //  2. turn Map to object
    }

  });

  test("SELF", (){
    final txt = Text("a", 1);
    final textJson = txt.toJson();
//    print('Mobynote.textJson: $textJson');
    final txtBack = Text.fromJson(textJson);
    expect(txt, txtBack);

    final stack = TextUndoStack(txt);
    final stackJson = jsonEncode(stack);
//    print('Mobynote.stackJson_B: $stackJson');
    
    final map = jsonDecode(stackJson);
//    print('Mobynote.jsonBack: $map');
    final stackBack = TextUndoStack.fromJson(map);
//    print('Mobynote.stackBack: $stackBack');
    expect(stack, stackBack);
  });


  /// Checks Test class creation
  test('Check Text class', () {
    {
      final text = Text(null, 0);
      expect(text.text, null);
      expect(text.cursorPos, 0);
    }
    {
      final text = Text("a", 0);
      expect(text.text, "a");
      expect(text.cursorPos, 0);
    }
    {
      final text = Text("a", 1);
      expect(text.text, "a");
      expect(text.cursorPos, 1);
    }
  });

  /// Simple undo/redo
  test('Simple undo/redo', () {

    final text = Text("a", 1);

    final stack = TextUndoStack(Text("a", 1));
    expect(stack.obj.text, "a");
    expect(stack.obj.cursorPos, 1);

    expect(stack.count, 0);
    stack.push(ChangeTextCommand("ab", 2));
    expect(stack.count, 1);
    expect(stack.obj.text, "ab");
    expect(stack.obj.cursorPos, 2);

    stack.undo();
    expect(text.text, "a");
    expect(text.cursorPos, 1);

  });

  /// Simple serialization
  test('Simple serialization', () {

    final stack = TextUndoStack(Text("a", 13), changed: (s){
      print('Mobynote.test.main: STACK IS CHANGED -> ${s.obj}');
    });

    expect(stack.obj.text, "a");
    expect(stack.obj.cursorPos, 13);

    expect(stack.count, 0);
    stack.push(ChangeTextCommand("ab", 2));
    expect(stack.count, 1);
    expect(stack.obj.text, "ab");
    expect(stack.obj.cursorPos, 2);

    final String json = jsonEncode(stack);
//    print('Mobynote.test.main: json=$json');

    stack.undo();

  });

  test('test Note model', (){
    final stack = NoteUndoStack(
      Note(
        id: 100,
        noteText: 'started text',
      ),
      changed: (s) {
        print('Mobynote.test.main: NOTESTACK IS CHANGED -> ${s.obj}');
      },
    );
    print('Mobynote.test.main: note=${stack.obj}');

    // pushing
    stack.push(ChangeNoteTextCommand('started text1', 10));
    expect(stack.obj.noteText, 'started text1');
    expect(stack.obj.attrs.textCursorPos, 10);
    stack.push(ChangeNoteTextCommand('started text11', 11));
    expect(stack.obj.noteText, 'started text11');
    expect(stack.obj.attrs.textCursorPos, 11);
    // redo should do no effect
    stack.redo();
    expect(stack.obj.noteText, 'started text11');
    expect(stack.obj.attrs.textCursorPos, 11);

    // undo
    stack.undo();
    expect(stack.obj.noteText, 'started text1', );
    expect(stack.obj.attrs.textCursorPos, 10, );
    stack.undo();
    expect(stack.obj.noteText, 'started text', );
    expect(stack.obj.attrs.textCursorPos, 12, );
    stack.undo(); // no change
    expect(stack.obj.noteText, 'started text', );
    expect(stack.obj.attrs.textCursorPos, 12, );

  });

}
