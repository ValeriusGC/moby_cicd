import 'package:mobynote/NoteModel.dart';
import 'package:mobynote/const.dart';
import 'package:mobynote/undo_lib/undo_stack.dart';
import 'package:test/test.dart';
import 'test_data/test_entity.dart';
import 'dart:convert';

void main() {
  /// Checks Test class creation
  test('Check Text class', () {
    final map = {
      // Key:    Value
      'first': 'partridge',
      'second': 'turtledoves',
      'fifth': 'golden rings'
    };

    String jsonStr = json.encode(map);
    print('main: jsonStr=$jsonStr');
    final mapBack = json.decode(jsonStr);
    print('main: mapBack=$mapBack');
  });

  test('bitwise ops', () {
    final F_01 = 1 << 0;
    final F_02 = 1 << 1;
    final F_03 = 1 << 2;
    final F_04 = 1 << 3;
    print('$F_01 $F_02 $F_03 $F_04');

    int flags = 0;

    expect(false, flags & F_01 == F_01);
    expect(false, flags & F_02 == F_02);
    expect(false, flags & F_03 == F_03);
    expect(false, flags & F_04 == F_04);
    flags = flags | F_03;
    flags = flags | F_03;
    flags = flags | F_03;
    flags = flags | F_03;
    print('Mobynote.test.flags: $flags');
    expect(flags, F_03);
    expect(false, flags & F_01 == F_01);
    expect(false, flags & F_02 == F_02);
    expect(true, flags & F_03 == F_03);
    expect(false, flags & F_04 == F_04);
    flags = flags | F_04;
    print('Mobynote.test.flags: $flags');
    expect(flags, F_03 | F_04);
    flags = flags | F_02;
    print('Mobynote.test.flags: $flags');
    expect(flags, F_02 | F_03 | F_04);
    flags = flags | F_01;
    print('Mobynote.test.flags: $flags');
    expect(flags, F_01 | F_02 | F_03 | F_04);
    //
    flags = flags ^= F_01;
    print('Mobynote.test.flags: $flags');
    expect(flags, F_02 | F_03 | F_04);
    flags = flags ^= F_02;
    print('Mobynote.test.flags: $flags');
    expect(flags, F_03 | F_04);
    flags = flags ^= F_04;
    print('Mobynote.test.flags: $flags');
    expect(flags, F_03);
    flags = flags & ~F_03;
    flags = flags & ~F_03;
    print('Mobynote.test.flags: $flags');
    expect(flags, 0);
  });

  test('Test flags in note', () {
    final note = Note(
      id: 1000,
      noteText: "text",
      verTimeStamp: 1001,
      verOrd: 1,
      iidTimeStamp: 1002,
      iidAuthId: 1003,
      ownerId: 1004,
    );
    print('Mobynote.TEST.main: noteJson=${note.toJson()}');

    // by default note has attr `flags`
    expect(1, note.attrs.count());
    expect(false, note.attrs.existsTitle());

//    // test on empty attrs
//    expect(false, note.attrs.deleted);
//    // after setting attrs created
//    note.attrs.deleted = false;
//    expect(false, note.isFlag(FlagKeys.DEL));
//    expect(false, note.isFlag(FlagKeys.REZERV_01));
//    expect(false, note.isFlag(FlagKeys.REZERV_02));
//    expect(true, note.attrExists(Attrs.FLAGS));
//    // to true
//    note.setFlag(FlagKeys.DEL, true);
//    expect(true, note.isFlag(FlagKeys.DEL));
//    expect(false, note.isFlag(FlagKeys.REZERV_01));
//    expect(false, note.isFlag(FlagKeys.REZERV_02));


  });

  test('Test attrs in note', () {
    final note = Note(
      id: 2,
      noteText: "text2",
      verTimeStamp: 22,
      verOrd: 2,
      iidTimeStamp: 102,
      iidAuthId: 103,
      ownerId: 104,
    );
    note.attrs.title = "TITLE";
    note.attrs.textCursorPos = 12;
    print('Mobynote.TEST.main: noteJson=${note.toJson()}');
    final noteBack = Note.fromJson(note.toJson());
    print('Mobynote.TEST.main: noteBackJson=${noteBack.toJson()}');
//    expect(noteBack, note);
    expect(noteBack, note);

    // check that attr changing works well
    noteBack.attrs.textCursorPos++;
    expect(noteBack, isNot(note));
    noteBack.attrs.textCursorPos--;
    expect(noteBack, note);
    noteBack.attrs.title = "ANOTHER TITLE";
    expect(noteBack, isNot(note));
    noteBack.attrs.title = "TITLE";
    expect(noteBack, note);
    noteBack.attrs.flags = 10;
    expect(noteBack, isNot(note));
    noteBack.attrs.flags = 0;
    expect(noteBack, note);

  });
}
