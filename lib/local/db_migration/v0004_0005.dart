import 'dart:async';
import 'dart:convert';

import 'package:mobynote/NoteModel.dart';
import 'package:mobynote/const.dart';
import 'package:mobynote/local/db_migration/v0003_0004.dart';
import 'package:mobynote/local/local_migrator.dart';
import 'package:mobynote/local/note_local_mapper.dart';
import 'package:mobynote/utils/attrs.dart';
import 'package:mobynote/utils/result.dart';
import 'package:sqflite/sqflite.dart';

class LocalMigrator0004_0005 extends LocalMigrator {
  @override
  Future<void> changeStruct(Transaction tx) async {
//    print('Mobynote.LocalMigrator0004_0005.changeStruct: ');
    var batch = tx.batch();
    await tx.execute("ALTER TABLE `mn_tbl_notes` ADD COLUMN `flags` INT;");
    await tx.execute("ALTER TABLE `mn_tbl_notes` ADD COLUMN `attrs` TEXT;");
    await batch.commit();
//    print('Mobynote.LocalMigrator0004_0005.changeStruct: FINISH');
  }

  @override
  Future<void> migrateData(Transaction tx) async {
    var batch = tx.batch();
//    print('Mobynote.LocalMigrator0004_0005.migrateData: START');
    final e = await tx.query("mn_tbl_notes");
//    print('Mobynote.LocalMigrator0004_0005.migrateData: e=$e');

    final List<Result<Note>> rs =
        e.isNotEmpty ? e.map((c) => _fromMap(c)).toList() : [];
    final List<Note> ns = rs.map((r) {
      if (r.data != null) {
        final n = r.data;
        return n;
      }
    }).toList();
//    print('Mobynote.LocalMigrator0004_0005.migrateData: ns = $ns');
    await Future.forEach(ns, (n)async {
      final mapa = _toMap(n);
//      print('Mobynote.LocalMigrator0004_0005.migrateData: mapa = $mapa');
      final i = await tx.update("`mn_tbl_notes`", mapa, where: "`id` = ?", whereArgs: [n.id]);
      final e2 = await tx.query("mn_tbl_notes");
//      print('Mobynote.LocalMigrator0004_0005.migrateData: back e2 = $e2');
    });
//    print('Mobynote.LocalMigrator0004_0005.migrateData: FINISH');
    batch.commit();
  }

  ///
  static const KEY_ID = "id";
  static const KEY_TEXT = "note_text";
  static const KEY_OWNER_ID = "owner_id";
  static const KEY_IID_AUTH_ID = "iid_authId";
  static const KEY_IID_TS = "iid_timestamp";
  static const KEY_VER_ORD = "ver_ord";
  static const KEY_VER_TS = "ver_timestamp";
  static const KEY_ATTRS = "attrs";

  Map<String, dynamic> _toMap(Note obj) {
//    print('Mobynote.EisNoteLocalJsonMapper.toMap: obj=$obj');
    return {
      KEY_ID: obj.id,
      KEY_TEXT: obj.noteText,
      KEY_OWNER_ID: obj.ownerId,
      KEY_IID_AUTH_ID: obj.iidAuthId,
      KEY_IID_TS: obj.iidTimeStamp,
      KEY_VER_ORD: obj.verOrd,
      KEY_VER_TS: obj.verTimeStamp,
      KEY_ATTRS: json.encode(obj.attrs),
    };
  }

  @override
  Result<Note> _fromMap(Map<String, dynamic> map) {
//    print('Mobynote.LocalMigrator0006_0007._fromMap: $map');
//    print('Mobynote.EisNoteLocalJsonMapper.fromMap: map = $map');
    try {
      final id = map[KEY_ID] ?? Exception;
      final t = map[KEY_TEXT] ?? Exception;
      final ownerId = map[KEY_OWNER_ID] ?? Exception;
      final iidAuthId = map[KEY_IID_AUTH_ID] ?? Exception;
      final iidTs = map[KEY_IID_TS] ?? Exception;
      final verOrd = map[KEY_VER_ORD] ?? Exception;
      final verTs = map[KEY_VER_TS] ?? Exception;

      // text to text and title
      final ss = t.split("\n");
      String title = "";
      String text = "";
      switch (ss.length) {
        case 0:
          break;
        case 1:
          text = ss[0];
          break;
        default:
          title = ss[0];
          text = t.substring(title.length + 1, t.length);
      }
      final attrs = Attrs();
      attrs.title = title;
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
