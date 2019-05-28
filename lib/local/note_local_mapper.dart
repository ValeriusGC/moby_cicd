import 'package:mobynote/NoteModel.dart';
import 'package:mobynote/const.dart';
import 'package:mobynote/user.dart';
import 'package:mobynote/utils/attrs.dart';
import 'package:mobynote/utils/json_mapper.dart';
import 'package:mobynote/utils/result.dart';
import 'dart:convert';

/// v.7.0+
class EisNoteLocalJsonMapper extends JsonMapper<Note> {
  static const KEY_ID = "id";
  static const KEY_TEXT = "note_text";
  static const KEY_OWNER_ID = "owner_id";
  static const KEY_IID_AUTH_ID = "iid_authId";
  static const KEY_IID_TS = "iid_timestamp";
  static const KEY_VER_ORD = "ver_ord";
  static const KEY_VER_TS = "ver_timestamp";
  static const KEY_TITLE = "title";
  static const KEY_FLAGS = "flags";

  @override
  Map<String, dynamic> toMap(Note obj) {
    print('Mobynote.EisNoteLocalJsonMapper.toMap: obj=$obj');
    return {
      KEY_ID: obj.id,
      KEY_TEXT: obj.noteText,
      KEY_OWNER_ID: obj.ownerId,
      KEY_IID_AUTH_ID: obj.iidAuthId,
      KEY_IID_TS: obj.iidTimeStamp,
      KEY_VER_ORD: obj.verOrd,
      KEY_VER_TS: obj.verTimeStamp,
      KEY_TITLE: obj.attrs.title,
      KEY_FLAGS: obj.attrs.flags,
    };
  }

  @override
  Result<Note> fromMap(Map<String, dynamic> map) {
//    print('Mobynote.EisNoteLocalJsonMapper.fromMap: map = $map');
    try {
      final id = map[KEY_ID] ?? Exception;
      final text = map[KEY_TEXT] ?? Exception;
      final ownerId = map[KEY_OWNER_ID] ?? Exception;
      final iidAuthId = map[KEY_IID_AUTH_ID] ?? Exception;
      final iidTs = map[KEY_IID_TS] ?? Exception;
      final verOrd = map[KEY_VER_ORD] ?? Exception;
      final verTs = map[KEY_VER_TS] ?? Exception;
      final s = map[KEY_TITLE];
      final f = map[KEY_FLAGS] ?? 0; // we don't want NULL in flags
      final attrs = Attrs();
      attrs.flags = f;
      if(s != null) {
        attrs.title = s;
      }
      return Result.success(Note(
        id: id,
        noteText: text,
        iidAuthId: iidAuthId,
        iidTimeStamp: iidTs,
        ownerId: ownerId,
        verOrd: verOrd,
        verTimeStamp: verTs,
        attrs: attrs,
      ));
    } catch (e) {
//      print('Mobynote.EisNoteLocalJsonMapper.fromMap: catch ${e}');
      return Result.error(Exception(e));
    }
  }
}
