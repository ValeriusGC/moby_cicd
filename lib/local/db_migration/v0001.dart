import 'dart:async';

import 'package:mobynote/local/db_migration/v0007_0008.dart';
import 'package:mobynote/local/local_migrator.dart';
import 'package:sqflite/sqflite.dart';

class LocalMigrator0001 extends LocalMigrator{

  @override
  Future<void> changeStruct(Transaction tx) async{
//    print('Mobynote.LocalMigrator0001.changeStruct: START');
    var batch = tx.batch();
    await tx.execute("CREATE TABLE `mn_tbl_users` ("
        "`id` INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "
        "`label` TEXT NOT NULL, "
        "`timestamp` INTEGER NOT NULL)");
    await tx.execute("CREATE TABLE `mn_tbl_notes` ("
        "`id` INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "
        "`note_text` TEXT NOT NULL, "
        "`owner_id` INTEGER NOT NULL, "
        "`iid_authId` INTEGER NOT NULL, "
        "`iid_timestamp` INTEGER NOT NULL, "
        "`ver_ord` INTEGER NOT NULL, "
        "`ver_timestamp` INTEGER NOT NULL, "
        "`flags` INTEGER, "
        "`attrs` TEXT, "
        "`title` TEXT, "
        "FOREIGN KEY(`owner_id`) REFERENCES `mn_tbl_users`(`id`) ON UPDATE NO ACTION ON DELETE NO ACTION , "
        "FOREIGN KEY(`iid_authId`) REFERENCES `mn_tbl_users`(`id`) ON UPDATE NO ACTION ON DELETE NO ACTION )");
    await tx.execute(
        "CREATE UNIQUE INDEX IF NOT EXISTS `index_mn_tbl_users_label_timestamp` "
            "ON `mn_tbl_users` ("
            "`label`,"
            "`timestamp`)");
    await tx.execute(
        "CREATE INDEX IF NOT EXISTS `index_mn_tbl_notes_iid_authId` ON `mn_tbl_notes` (`iid_authId`)");
    await tx.execute(
        "CREATE INDEX IF NOT EXISTS `index_mn_tbl_notes_owner_id` ON `mn_tbl_notes` (`owner_id`)");
    await tx.execute("CREATE INDEX `index_mn_tbl_notes_flags` ON `mn_tbl_notes` (`flags`);");

    // v.8 -> new tables
    LocalMigrator0007_0008.addTablesAndIndices(tx);

//    await tx.execute("CREATE TABLE `mn_tbl_pref` ("
//        "`id` INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "
//        "`suid` TEXT NOT NULL UNIQUE, "   // system global unique identifier
//        "`key` TEXT NOT NULL UNIQUE, "    // verbal key
//        "`value` TEXT NOT NULL, "         // value
//        "`ver_ord` INTEGER NOT NULL, "
//        "`ver_timestamp` INTEGER NOT NULL, "
//        "`timestamp` INTEGER NOT NULL)");
//    await tx.execute(
//        "CREATE UNIQUE INDEX IF NOT EXISTS `index_mn_tbl_pref_key` "
//            "ON `mn_tbl_pref` (`key`)");
//    await tx.execute("CREATE TABLE `mn_tbl_note_history` ("
//        "`id` INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "
//        "`note_id` INTEGER NOT NULL, "
//        "`data` TEXT NOT NULL, "
//        "`ver_ord` INTEGER NOT NULL, "
//        "`ver_timestamp` INTEGER NOT NULL)");
//    await tx.execute(
//        "CREATE UNIQUE INDEX IF NOT EXISTS `index_mn_tbl_history_note_id_ver` "
//            "ON `mn_tbl_note_history` (`note_id`, `ver_ord`)");
//    await tx.execute("CREATE TABLE `mn_tbl_event_log` ("
//        "`id` INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "
//        "`type` INTEGER NOT NULL, "     // type of event
//        "`obj_id` INTEGER NOT NULL, "   // id of object (depends on type)
//        "`desc` TEXT NOT NULL, "   // description
//        "`timestamp` INTEGER NOT NULL)");
//    await tx.execute(
//        "CREATE INDEX IF NOT EXISTS `index_mn_tbl_event_log_type` "
//            "ON `mn_tbl_event_log` (`type`)");
//    await tx.execute(
//        "CREATE INDEX IF NOT EXISTS `index_mn_tbl_event_log_obj_id` "
//            "ON `mn_tbl_event_log` (`obj_id`)");
//    await tx.execute("CREATE TABLE `mn_tbl_undostack` ("
//        "`id` INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "
//        "`cmd_idx` INTEGER NOT NULL UNIQUE, " // where `-1` means whole current state
//        "`field` TEXT NOT NULL, " // where we can place UID as well as identifier of entire Note
//        "`value` TEXT NOT NULL)"); // JSON
    await batch.commit();
  }

  @override
  Future<void> migrateData(Transaction tx) async{
//    return Future.value(null);
  }

}

