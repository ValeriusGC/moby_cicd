import 'dart:async';
import 'dart:convert';

import 'package:mobynote/NoteModel.dart';
import 'package:mobynote/const.dart';
import 'package:mobynote/local/db_migration/v0003_0004.dart';
import 'package:mobynote/local/db_migration/v0004_0005.dart';
import 'package:mobynote/local/local_migrator.dart';
import 'package:mobynote/local/note_local_mapper.dart';
import 'package:mobynote/utils/attrs.dart';
import 'package:mobynote/utils/result.dart';
import 'package:sqflite/sqflite.dart';

/// Migration 6 --> 7
/// Here i make all migration in one method `migrateData`
class LocalMigrator0006_0007 extends LocalMigrator {
  @override
  Future<void> changeStruct(Transaction tx) async {
//    print('Mobynote.LocalMigrator0006_0007.changeStruct: ');
//    print('Mobynote.LocalMigrator0006_0007.changeStruct: FINISH');
    // all changes in `migrateData`!!!
  }

  @override
  Future<void> migrateData(Transaction tx) async {
//    print('Mobynote.LocalMigrator0006_0007.migrateData: ');
    var batch = tx.batch();
    await tx.execute("ALTER TABLE `mn_tbl_notes` ADD COLUMN `title` TEXT;");

    final e = await tx.query("mn_tbl_notes");
    final List<Result<Note>> rs =
    e.isNotEmpty ? e.map((c) => _fromMap(c)).toList() : [];
    final List<Note> ns = rs.map((r) {
      if (r.data != null) {
        final n = r.data;
        return n;
      }
    }).toList();
    await Future.forEach(ns, (n){
      final mapa = EisNoteLocalJsonMapper().toMap(n);
//      print('Mobynote.LocalMigrator0006_0007.migrateData: mapa = $mapa');
      final i = tx.update("`mn_tbl_notes`", mapa, where: "`id` = ?", whereArgs: [n.id]);
      // 19/03/14 FIXME SQLITE does not drop column via ALTER TABLE so i just reset it.
      tx.rawQuery("UPDATE `mn_tbl_notes` SET `attrs` = NULL");
//      final e = tx.query("mn_tbl_notes");
    });

    // does not work!
    // await tx.execute("ALTER TABLE `mn_tbl_notes` DROP COLUMN `attrs`;");
    await batch.commit();
//    print('Mobynote.LocalMigrator0006_0007.migrateData: FINISH');
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

  @override
  Result<Note> _fromMap(Map<String, dynamic> map) {
//    print('Mobynote.LocalMigrator0006_0007._fromMap: $map');
//    print('Mobynote.EisNoteLocalJsonMapper.fromMap: map = $map');
    try {
      final id = map[KEY_ID] ?? Exception;
      final text = map[KEY_TEXT] ?? Exception;
      final ownerId = map[KEY_OWNER_ID] ?? Exception;
      final iidAuthId = map[KEY_IID_AUTH_ID] ?? Exception;
      final iidTs = map[KEY_IID_TS] ?? Exception;
      final verOrd = map[KEY_VER_ORD] ?? Exception;
      final verTs = map[KEY_VER_TS] ?? Exception;
      final s = map[KEY_ATTRS];
//      print('EisNoteLocalJsonMapper.fromMap: map[KEY_ATTRS] = ${map[KEY_ATTRS]}');
      var attrs = Attrs();
      try {
        attrs = s != null ? json.decode(map[KEY_ATTRS]) : Map<String, dynamic>();
      }catch(e) {
        attrs = Attrs();
      }
//      print('Mobynote.LocalMigrator0006_0007._fromMap: attrs = ${attrs}');

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
//      print('Mobynote.EisNoteLocalJsonMapper.fromMap: CATCH ${e}');
      return Result.error(Exception(e));
    }

  }

}
