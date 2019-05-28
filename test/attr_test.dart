import 'package:mobynote/NoteModel.dart';
import 'package:mobynote/model/jsonable.dart';
import 'package:mobynote/model/undo_note_model.dart';
import 'package:mobynote/utils/attrs.dart';
import 'package:mobynote/utils/result.dart';
import 'package:test/test.dart';
import 'test_data/stack_data.dart';
import 'test_data/test_entity.dart';
import 'dart:convert';

class Host {
  final attrs = Attrs();
}

void main() {

  test('attributes in simple Map', (){

    final attrs = {
      's' : 'one',
      'i' : 10,
//      'null' : NoAttr.make(),
    };

    expect(attrs['s'], 'one');
    expect(attrs['i'], 10);
//    expect(attrs['null'].runtimeType, NoAttr);

  });

  test('attributes as class', (){

    final host = Host();
    expect(host.attrs.count(), 1);
    expect(host.attrs.existsTitle(), false);
    expect(host.attrs.existsCursorPos(), false);
    expect(host.attrs.title, Attrs.NOT_ASSIGNED);
    expect(host.attrs.title == null, true);
    expect(host.attrs.title == 'ttt', false);
    expect(host.attrs.textCursorPos, Attrs.NOT_ASSIGNED);
    //
    host.attrs.textCursorPos = 10;
    expect(host.attrs.count(), 2);
    expect(host.attrs.existsTitle(), false);
    expect(host.attrs.existsCursorPos(), true);
    expect(host.attrs.title, Attrs.NOT_ASSIGNED);
    expect(host.attrs.textCursorPos.runtimeType, int);
    expect(host.attrs.textCursorPos, 10);
    expect(host.attrs.title == null, true);
    host.attrs.textCursorPos = 11;
    expect(host.attrs.textCursorPos, 11);
    host.attrs.removeCursorPos();
    expect(host.attrs.count(), 1);
    expect(host.attrs.existsCursorPos(), false);
    expect(host.attrs.textCursorPos, Attrs.NOT_ASSIGNED);
    //
    host.attrs.title = 'title';
    expect(host.attrs.count(), 2);
    expect(host.attrs.existsTitle(), true);
    expect(host.attrs.existsCursorPos(), false);
    expect(host.attrs.title.runtimeType, String);
    expect(host.attrs.textCursorPos, Attrs.NOT_ASSIGNED);
    expect(host.attrs.title, 'title');
    host.attrs.title = 'nnn';
    expect(host.attrs.title, 'nnn');
    //
    host.attrs.clear();
    expect(host.attrs.count(), 1);
    expect(host.attrs.textCursorPos, Attrs.NOT_ASSIGNED);
    expect(host.attrs.title, Attrs.NOT_ASSIGNED);
    expect(host.attrs.title, Attrs.NOT_ASSIGNED);
    expect(host.attrs.textCursorPos, Attrs.NOT_ASSIGNED);
    //
    host.attrs.flags = 0;
    expect(host.attrs.count(), 1);
    expect(host.attrs.recycledFlag, false);
    host.attrs.recycledFlag = true;
    expect(host.attrs.recycledFlag, true);
    expect(host.attrs.flags, 1);


  });


}
