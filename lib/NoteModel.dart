import 'dart:convert';

import 'package:mobynote/const.dart';
import 'package:collection/collection.dart';
import 'package:mobynote/model/jsonable.dart';
import 'package:mobynote/utils/attrs.dart';

//Note clientFromJson(String str) {
//  final jsonData = json.decode(str);
//  return Note.fromMap(jsonData);
//}
//
//String clientToJson(Note data) {
//  final dyn = data.toMap();
//  return json.encode(dyn);
//}

//class Attr {
//  final String key;
//  final dynamic value;
//
//  Attr({this.key, this.value});
//}

class FlagAndNote {
  final List<Note> notes;
  final FlagKeys flag;
  final bool value;

  FlagAndNote(this.notes, this.flag, this.value);

  @override
  String toString() {
    return 'FlagAndNote{notes: $notes, flag: $flag, value: $value}';
  }
}

class Note with Jsonable {
  static const String _TYPE = 'Note';
  static const KEY_ID = "id";
  static const KEY_TEXT = "txt";
  static const KEY_OWNER_ID = "oid";
  static const KEY_IID_AUTH_ID = "iidaid";
  static const KEY_IID_TS = "iidts";
  static const KEY_VER_ORD = "vo";
  static const KEY_VER_TS = "vts";
  static const KEY_ATTR = "attr";

  int id;
  String noteText;
  int ownerId;
  int iidAuthId;
  int iidTimeStamp;
  int verOrd;
  int verTimeStamp;
  var attrs = Attrs();

  Note({
    this.id,
    this.noteText,
    this.ownerId,
    this.iidAuthId,
    this.iidTimeStamp,
    this.verOrd,
    this.verTimeStamp,
    Attrs attrs,
  }) {
    if (attrs != null) {
      this.attrs = attrs;
    }
    if(verOrd == null) {
      verOrd = 1;
    }
    if(verTimeStamp == null) {
      verTimeStamp = iidTimeStamp;
    }
  }

//  bool attrExists(String key) => attrs.containsKey(key);
//
//  void removeAttr(String key) => attrs.remove(key);
//
//  void setAttr(String key, dynamic value) => attrs[key] = value;
//
//  bool isEmpty() => getTitle().isEmpty && noteText.isEmpty;
//
//  void setTitle(String value) {
////    print('Mobynote.Note.setTitle: value=$value');
//    attrs[Attrs.TITLE] = value;
////    print('Mobynote.Note.setTitle: ATTRS=$attrs');
//  }
//
//  String getTitle() {
//    return attrExists(Attrs.TITLE) ? attrs[Attrs.TITLE] : null;
//  }
//
//  int get textCursorPos => attrExists(Attrs.TEXT_CURSOR_POS) ? attrs[Attrs.TEXT_CURSOR_POS] as int : 0;
//
//  set textCursorPos(int value) => attrs[Attrs.TEXT_CURSOR_POS] = value;
//
//  void setFlag(FlagKeys key, bool value) {
////    print('Mobynote.Note.setFlag: ATTR=$key, value=$value');
//    int flags = attrExists(Attrs.FLAGS) ? attrs[Attrs.FLAGS] : 0;
////    print('Mobynote.Note.setFlag: FLAGS[$key] = ${FLAGS[key]}');
//    flags = value ? flags | FLAGS[key] : (flags & ~FLAGS[key]);
////    print('Mobynote.Note.setFlag: flags = ${flags}');
//    attrs[Attrs.FLAGS] = flags;
////    print('Mobynote.Note.setFlag: ATTRS=$attrs');
//  }
//
//  bool isFlag(FlagKeys key) {
//    final flags = attrExists(Attrs.FLAGS) ? attrs[Attrs.FLAGS] : 0;
//    return flags & FLAGS[key] == FLAGS[key];
//  }

  @override
  Map<String, dynamic> toJson() {
    final m = super.toJson();
    m[KEY_ID] = id;
    m[KEY_TEXT] = noteText;
    m[KEY_OWNER_ID] = this.ownerId;
    m[KEY_IID_AUTH_ID] = this.iidAuthId;
    m[KEY_IID_TS] = this.iidTimeStamp;
    m[KEY_VER_ORD] = this.verOrd;
    m[KEY_VER_TS] = this.verTimeStamp;
    m[KEY_ATTR] = this.attrs.toJson();
    return m;
  }

  Note copyWith({Map<String, dynamic> newAttrs}) {
      return Note(
        id: id,
        noteText: noteText,
        ownerId: ownerId,
        iidAuthId: iidAuthId,
        iidTimeStamp: iidTimeStamp,
        verOrd: verOrd,
        verTimeStamp: verTimeStamp,
        attrs: newAttrs ?? attrs,
      );
  }

  static Note fromJson(Map<String, dynamic> map) {
    if (map[Jsonable.KEY_TYPE] == _TYPE) {
      return Note(
        id: map[KEY_ID],
        noteText: map[KEY_TEXT],
        ownerId: map[KEY_OWNER_ID],
        iidAuthId: map[KEY_IID_AUTH_ID],
        iidTimeStamp: map[KEY_IID_TS],
        verOrd: map[KEY_VER_ORD],
        verTimeStamp: map[KEY_VER_TS],
        attrs: Attrs.fromJson(map[KEY_ATTR]),
      );
    } else
      return null;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Note &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          noteText == other.noteText &&
          ownerId == other.ownerId &&
          iidAuthId == other.iidAuthId &&
          iidTimeStamp == other.iidTimeStamp &&
          verOrd == other.verOrd &&
          verTimeStamp == other.verTimeStamp &&
          attrs == other.attrs;
          //MapEquality().equals(attrs, other.attrs);

  @override
  int get hashCode =>
      id.hashCode ^
      noteText.hashCode ^
      ownerId.hashCode ^
      iidAuthId.hashCode ^
      iidTimeStamp.hashCode ^
      verOrd.hashCode ^
      verTimeStamp.hashCode ^
      attrs.hashCode;

  @override
  String toString() {
    return 'Note{id: $id, title/text: ${attrs.title}/$noteText, verOrd: $verOrd, attrs: $attrs}';
    //return 'Note{id: $id, noteText: $noteText, verOrd: $verOrd, attrs: $attrs}';
  }
}

//bool isDeleted(Note note) => note.attrs.deleted;
bool withoutAnyText(Note note) => note.noteText.isEmpty && note.attrs.title.isEmpty;

