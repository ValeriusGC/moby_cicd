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


// 19/03/25 FIXME Need to add table for history and logs

/// Migration 7 --> 8
class LocalMigrator0007_0008 extends LocalMigrator {
  @override
  Future<void> changeStruct(Transaction tx) async {
//    print('Mobynote.LocalMigrator0006_0007.changeStruct: ');
//    print('Mobynote.LocalMigrator0006_0007.changeStruct: FINISH');
    // all changes in `migrateData`!!!
  }


  @override
  Future<void> migrateData(Transaction tx) async {
    print('Mobynote.LocalMigrator0007_0008.migrateData: ');
    var batch = tx.batch();
    addTablesAndIndices(tx);
//    await tx.execute("CREATE TABLE `mn_tbl_pref` ("
//        "`id` INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "
//        "`key` TEXT NOT NULL, "
//        "`value` TEXT NOT NULL, "
//        "`ver_ord` INTEGER NOT NULL, "
//        "`ver_timestamp` INTEGER NOT NULL, "
//        "`timestamp` INTEGER NOT NULL)");
//    await tx.execute(
//        "CREATE UNIQUE INDEX IF NOT EXISTS `index_mn_tbl_pref_key` "
//            "ON `mn_tbl_pref` ("
//            "`key`)");
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

  //  - mn_tbl_pref: for preferences and session settings
  //  - mn_tbl_note_history: for history records
  //  - mn_tbl_event_log: for event log
  //  - mn_tbl_undostack: for undostack // 19/03/26 FIXME это сделаем потом
  static Future<void> addTablesAndIndices(Transaction tx) async {

    /// table for preferences (settings)
    /// `id` - table key;
    /// `suid` - system GUID for this entity;
    /// `key` - key of preference;
    /// `value` - value of preference;
    /// `ver_ord` - ordinal value of preference' Version;
    /// `ver_timestamp` - timestamp of preference' Version;
    /// `timestamp` - creation timestamp of preference;
    await tx.execute("CREATE TABLE `mn_tbl_pref` ("
        "`id` INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "
        "`suid` TEXT NOT NULL UNIQUE, "   // system global unique identifier
        "`key` TEXT NOT NULL UNIQUE, "    // verbal key
        "`value` TEXT NOT NULL, "         // value
        "`ver_ord` INTEGER NOT NULL, "
        "`ver_timestamp` INTEGER NOT NULL, "
        "`timestamp` INTEGER NOT NULL)");
    await tx.execute(
        "CREATE UNIQUE INDEX IF NOT EXISTS `index_mn_tbl_pref_key` "
            "ON `mn_tbl_pref` (`key`)");

    /// table for all events in system (for future)
    /// `id` - table key;
    /// `type` - event type;
    /// `suid` - system GUID for this entity;
    /// `desc` - description;
    /// `timestamp` - creation timestamp;
    await tx.execute("CREATE TABLE `mn_tbl_event_log` ("
        "`id` INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "
        "`type` INTEGER NOT NULL, "     // type of event
        "`suid` TEXT NOT NULL, "   // id of object (depends on type)
        "`desc` TEXT NOT NULL, "   // description
        "`timestamp` INTEGER NOT NULL)");
    await tx.execute(
        "CREATE INDEX IF NOT EXISTS `index_mn_tbl_event_log_type` "
            "ON `mn_tbl_event_log` (`type`)");
    await tx.execute(
        "CREATE INDEX IF NOT EXISTS `index_mn_tbl_event_log_suid` "
            "ON `mn_tbl_event_log` (`suid`)");

    /// table for caching Note (or some other versioned entity) when editing
    /// `id` - table key;
    /// `obj_type` - entity type;
    /// `suid` - system GUID for this entity;
    /// `data` - entity in JSON form;
    /// `last_timestamp` - last cached timestamp;
    await tx.execute("CREATE TABLE `mn_tbl_cache` ("
        "`id` INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "
        "`obj_type` INTEGER NOT NULL, "   // type of cache (note, pref, etc)
        "`suid` TEXT NOT NULL UNIQUE, "   // suid object being cached
        "`data` TEXT NOT NULL, "          // JSON
        "`last_timestamp` INTEGER NOT NULL)"); // last cached ts
    await tx.execute(
        "CREATE INDEX IF NOT EXISTS `index_mn_tbl_cache_obj_type` "
            "ON `mn_tbl_cache` (`obj_type`)");

    /// table for Undo suids (fast access to undo strings)
    /// `id` - table key;
    /// `suid` - system GUID for this entity;
    /// `last_timestamp` - last cached timestamp;
    await tx.execute("CREATE TABLE `mn_tbl_undostack_suid` ("
        "`id` INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "
        "`suid` TEXT NOT NULL UNIQUE, " //
        "`last_timestamp` INTEGER NOT NULL)");

    /// table for Undo data
    /// `id` - table key;
    /// `fk_suid` - foreign key to `mn_tbl_undostack_suid`;
    /// `cmd_idx` - index of undo command;
    /// `field` - some place to Note suid (fasten access to it);
    /// `value` - undo command in JSON form;
    await tx.execute("CREATE TABLE `mn_tbl_undostack_data` ("
        "`id` INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "
        "`fk_suid` INTEGER NOT NULL, "
        "`cmd_idx` INTEGER NOT NULL, " //
        "`field` TEXT NOT NULL, " // where we can place UID as well as identifier of entire Note
        "`value` TEXT NOT NULL, " // JSON
        "FOREIGN KEY(`fk_suid`) REFERENCES `mn_tbl_undostack_suid`(`id`) "
        "ON UPDATE CASCADE ON DELETE CASCADE )");
    await tx.execute(
        "CREATE INDEX IF NOT EXISTS `index_mn_tbl_undostack_data_fk_suid` "
            "ON `mn_tbl_undostack_data` (`fk_suid`)");

    /// table for History suids
    /// `id` - table key;
    /// `suid` - system GUID for this entity;
    await tx.execute("CREATE TABLE `mn_tbl_history_suid` ("
        "`id` INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "
        "`suid` TEXT NOT NULL UNIQUE)");

    /// table for History data
    /// `id` - table key;
    /// `fk_suid` - foreign key to `mn_tbl_history_suid`;
    /// `value` - history data in JSON form;
    /// `ver_ord` - ordinal value of Version;
    /// `ver_timestamp` - timestamp of Version;
    await tx.execute("CREATE TABLE `mn_tbl_history_data` ("
        "`id` INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "
        "`fk_suid` INTEGER NOT NULL, "
        "`data` TEXT NOT NULL, "
        "`ver_ord` INTEGER NOT NULL, "
        "`ver_timestamp` INTEGER NOT NULL, "
        "FOREIGN KEY(`fk_suid`) REFERENCES `mn_tbl_history_suid`(`id`) "
        "ON UPDATE CASCADE ON DELETE CASCADE )");
    await tx.execute(
        "CREATE UNIQUE INDEX IF NOT EXISTS `index_mn_tbl_history_data_fk_suid` "
            "ON `mn_tbl_history_data` (`fk_suid`)");

  }

}
