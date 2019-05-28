import 'dart:async';

import 'package:mobynote/NoteModel.dart';
import 'package:mobynote/const.dart';
import 'package:mobynote/local/db_migration/v0003_0004.dart';
import 'package:mobynote/local/db_migration/v0004_0005.dart';
import 'package:mobynote/local/local_migrator.dart';
import 'package:mobynote/local/note_local_mapper.dart';
import 'package:mobynote/utils/result.dart';
import 'package:sqflite/sqflite.dart';

class LocalMigrator0005_0006 extends LocalMigrator {
  @override
  Future<void> changeStruct(Transaction tx) async {
//    print('Mobynote.LocalMigrator0005_0006.changeStruct: ');
    var batch = tx.batch();
    await tx.execute("CREATE INDEX \"index_mn_tbl_notes_flags\" ON `mn_tbl_notes` (\"flags\");");
    await batch.commit();
//    print('Mobynote.LocalMigrator0005_0006.changeStruct: FINISH');
  }

  @override
  Future<void> migrateData(Transaction tx) async {
//    print('Mobynote.LocalMigrator0005_0006.migrateData: ');
//    print('Mobynote.LocalMigrator0005_0006.migrateData: ');
//    print('Mobynote.LocalMigrator0005_0006.migrateData: FINISH');
  }
}
