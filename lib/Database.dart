import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mobynote/app_session.dart';
import 'package:mobynote/const.dart';
import 'package:mobynote/local/db_migration/v0001.dart';
import 'package:mobynote/local/db_migration/v0003_0004.dart';
import 'package:mobynote/local/db_migration/v0004_0005.dart';
import 'package:mobynote/local/db_migration/v0005_0006.dart';
import 'package:mobynote/local/db_migration/v0006_0007.dart';
import 'package:mobynote/local/db_migration/v0007_0008.dart';
import 'package:mobynote/local/local_migrator.dart';
import 'package:mobynote/local/note_local_mapper.dart';
import 'package:mobynote/local/user_local_mapper.dart';
import 'package:mobynote/model/vmo.dart';
import 'package:mobynote/note_bloc.dart';
import 'package:mobynote/utils/attrs.dart';
import 'package:mobynote/utils/datetime.dart';
import 'package:rxdart/subjects.dart';
import 'package:uuid/uuid.dart';

import 'package:mobynote/NoteModel.dart';
import 'package:mobynote/user.dart';
import 'package:mobynote/utils/result.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

/// Serves as the service and the provider at the same time:
///   * Service: makes access to DB, migrates data;
///   * Provider: retrieves raw data, prepares them as domain types.
class DBProvider {
  /// 3: - Android
  static const VERSION_3 = 3;

  /// 3->4:
  ///   - from Android to Flutter
  static const VERSION_4 = 4;

  /// 4->5:
  /// Added field Attr
  static const VERSION_5 = 5;

  /// 5->6:
  /// Added index on `flags`
  static const VERSION_6 = 6;

  /// 6->7:
  /// Added index on `flags`
  static const VERSION_7 = 7;

  /// 7->8:
  /// Added table for pref..
  /// ....
  static const VERSION_8 = 8;

  DBProvider._();

  static final DBProvider db = DBProvider._();

  Database _database;

  Future<Database> get database async {
//    print('Mobynote.DBProvider.database: START');
//    return Future.error("DATABASE ERROR");
    if (_database != null) return _database;
    _database = await initDB();
    return _database;
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/create_db.sql');
  }

  Future<String> readCounter() async {
    try {
      final file = await _localFile;
      return await file.readAsString();
    } catch (e) {
      // If encountering an error, return 0
      return "";
    }
  }

  final Map<int, LocalMigrator> migrators = {
    3: LocalMigrator0003_0004(),
    4: LocalMigrator0004_0005(),
    5: LocalMigrator0005_0006(),
    6: LocalMigrator0006_0007(),
    7: LocalMigrator0007_0008(),
  };

  Future<Database> initDB() async {
//    print('Mobynote.DBProvider.initDB: START');
//    Directory documentsDirectory = await getApplicationDocumentsDirectory();
//    print('Mobynote.DBProvider.initDB: documentsDirectory = $documentsDirectory');
    final _dbDir = await getDatabasesPath();
    //String path = join(documentsDirectory.path, "TestDB.db");
    final path = join(_dbDir, "notesdb_1");
    //String path = join(documentsDirectory.path, "notesdb4flutter");
    return await openDatabase(path, version: VERSION_8, onOpen: (db) {
//      print('Mobynote.DBProvider.initDB: db IS_OPENED = $path');
    }, onCreate: (Database db, int version) async {
//      print('Mobynote.DBProvider.initDB: ON_CREATE');
      final v = await db.transaction((txn) async {
        LocalMigrator0001().changeStruct(txn);
      }, exclusive: true);
//      print('Mobynote.DBProvider.initDB: db is created = $v');
    }, onUpgrade: (Database db, int a, int b) async {
      var cur = a;
//      print('Mobynote.DBProvider.initDB: try migrate from $cur to $b');
      Fluttertoast.showToast(
        msg: "try migrate from $cur to $b",
        toastLength: Toast.LENGTH_LONG,
        backgroundColor: Colors.red,
      );
      await db.transaction((txn) async {
//        var batch = txn.batch();
        try {
          while (cur < b) {
            if (migrators.containsKey(cur)) {
              await migrators[cur++].upgrade(txn);
            } else {
              return Future.error("migration: version $cur does not exists");
            }
          }
        } catch (e) {
//          print('Mobynote.DBProvider.initDB: CATCH $e');
          return Future.error("upgrading => $e");
        } finally {
//          print('Mobynote.DBProvider.initDB: FINALLY');
//          batch.commit();
        }
      });
    }, onDowngrade: (Database db, int a, int b) {
//      print('Mobynote.DBProvider.initDB: db is downgraded = $a -> $b');
    });
  }

//  newClient(Client newClient) async {
//    final db = await database;
//    //get the biggest id in the table
//    var table = await db.rawQuery("SELECT MAX(id)+1 as id FROM Client");
//    int id = table.first["id"];
//    //insert to the table using the new id
//    var raw = await db.rawInsert(
//        "INSERT Into Client (id,first_name,last_name,blocked)"
//        " VALUES (?,?,?,?)",
//        [id, newClient.firstName, newClient.lastName, newClient.blocked]);
//    return raw;
//  }
//
//  blockOrUnblock(Client client) async {
//    final db = await database;
//    Client blocked = Client(
//        id: client.id,
//        firstName: client.firstName,
//        lastName: client.lastName,
//        blocked: !client.blocked);
//    var res = await db.update("Client", blocked.toMap(),
//        where: "id = ?", whereArgs: [client.id]);
//    return res;
//  }
//
//  updateClient(Client newClient) async {
//    final db = await database;
//    var res = await db.update("Client", newClient.toMap(),
//        where: "id = ?", whereArgs: [newClient.id]);
//    return res;
//  }
//
//  getClient(int id) async {
//    final db = await database;
//    var res = await db.query("Client", where: "id = ?", whereArgs: [id]);
//    return res.isNotEmpty ? Client.fromMap(res.first) : null;
//  }
//
//  Future<List<Client>> getBlockedClients() async {
//    final db = await database;
//
//    print("works");
//    // var res = await db.rawQuery("SELECT * FROM Client WHERE blocked=1");
//    var res = await db.query("Client", where: "blocked = ? ", whereArgs: [1]);
//
//    List<Client> list =
//        res.isNotEmpty ? res.map((c) => Client.fromMap(c)).toList() : [];
//    return list;
//  }
//
//  Future<List<Client>> getAllClients() async {
//    final db = await database;
//    var res = await db.query("Client");
//    List<Client> list =
//        res.isNotEmpty ? res.map((c) => Client.fromMap(c)).toList() : [];
//    return list;
//  }

  Future<List<Note>> getNotesFoolish(String s) async {
    final db = await database;
    try {
      var sql = 'SELECT * FROM `mn_tbl_notes` ';
      var res = await db.rawQuery('$sql;');
      List<Result<Note>> list =
      res.isNotEmpty ? res.map((c) => EisNoteLocalJsonMapper().fromMap(c)).toList() : [];
      List<Note> notes = List();
      list.forEach((e) {
        if (e.data != null) {
          notes.add(e.data);
        }
      });
      print('Mobynote.DBProvider.getNotesFoolish: return = $notes');
      return notes;
    } catch (e) {
      print('Mobynote.DBProvider.getNotesFoolish: ERROR = $e');
      return Future.error(e);
    }
  }

  Future<VisualMappingOpts> getPrefVmo() async {
    print('DBProvider.getPrefVmo');
    final key = 'VMO';
    return await database.then((db) async {
      return db.transaction((tx) async {
        // this return raw map
        final map = await _pref(tx, key);
        print('DBProvider.getPrefVmo: map=${map}');
        final jsonValue = map['value'] ?? jsonEncode(Map());
        final vmo = VmoLocalJsonMapper().fromJson(jsonValue);
        print('DBProvider.getPrefVmo: vmo=${vmo.data}');
        return vmo.data ?? VisualMappingOpts();
      });
    });
  }

  Future<VisualMappingOpts> savePrefVmo(VisualMappingOpts vmo) async {
    final key = 'VMO';
    return await database.then((db) async {
      return db.transaction((tx) async {
        final valueMap = VmoLocalJsonMapper().toJson(vmo);
        final map = {
          'suid': '111',
          'key': key,
          'value': valueMap,
          'ver_ord': 1,
          'ver_timestamp': 2,
          'timestamp': 3,
        };
        print('DBProvider.savePrefVmo: map = $map');
        final existMap = await _pref(tx, key);
        if(existMap.containsKey('id')) {
          int i = await tx.update("`mn_tbl_pref`", map, where: "`key` = ?", whereArgs: [key]);
          print('DBProvider.savePrefVmo: updated = $i');
        }else{
          int i = await tx.insert("`mn_tbl_pref`", map);
          print('DBProvider.savePrefVmo: inserted = $i');
        }


        return Future.value(vmo);
      });
    });
  }

  /// Returns notes according filters
  Future<List<Note>> getNotes(VisualMappingOptions sortFilter) async {
    print('DBProvider.getNotes');

    final db = await database;
    final v = FLAG_MAP[FlagKeys.RECYCLED];
    try {

      var sql = 'SELECT * FROM `mn_tbl_notes` ';

      if (sortFilter != null) {

        if(sortFilter.searchStr != "") {
          final ss = sortFilter.searchStr;
          sql += ' WHERE `note_text` like \'%$ss%\' OR `title` like \'%$ss%\' ';
        }

        if(sortFilter.sortType == SortType.ASC){
          sql += ' ORDER BY `iid_timestamp` ASC ';
//          sql += ' ORDER BY `title` ASC, `note_text` ASC';
        }else{
          sql += ' ORDER BY `iid_timestamp` DESC ';
//          sql += ' ORDER BY `title` DESC, `note_text` DESC';
        }
      } else {
        sql += ' ORDER BY `iid_timestamp` DESC ';
      }
//      print('Mobynote.DBProvider.getNotes: sql=$sql');

      var res = await db.rawQuery('$sql;');

//      var res = await db.rawQuery(
//          'SELECT * FROM `mn_tbl_notes` WHERE (`flags` NOTNULL AND  `flags` & $v != $v) OR (`flags` IS NULL);');
      List<Result<Note>> list =
      res.isNotEmpty ? res.map((c) => EisNoteLocalJsonMapper().fromMap(c)).toList() : [];
      List<Note> notes = List();
      list.forEach((e) {
        if (e.data != null) {
          notes.add(e.data);
        }
      });
      print('Mobynote.DBProvider.getNotes: notes = $notes');
      return notes;
    } catch (e) {
//      print('Mobynote.DBProvider.getNotes: ERROR = $e');
      return Future.error(e);
    }
  }

  Future<List<Note>> getNotes2(VisualMappingOpts opts) async {
    // вот так можно объединить текстовые поля
    // SELECT *, (a.`title` || " " || a.`note_text`) as FullText FROM `mn_tbl_notes` AS a ORDER BY FullText ASC

    final v = FLAG_MAP[FlagKeys.RECYCLED];

    final db = await database;
    try {
//      var res = await db.rawQuery(
//          'SELECT * FROM `mn_tbl_notes` WHERE (`flags` NOTNULL AND  `flags` & $v != $v) OR (`flags` IS NULL);');
      //var sql = 'SELECT * FROM `mn_tbl_notes` ';
      var sql = 'SELECT *, (a.`title` || a.`note_text`) as FullText FROM `mn_tbl_notes` AS a ';
      if (opts != null) {
        if(opts.searchBy.value != '') {
          final ss = opts.searchBy.value;
          sql += ' WHERE (`note_text` like \'%$ss%\' OR `title` like \'%$ss%\') ';

          // + second WHERE
          if(opts.showRecycled == ShowRecycled.ONLY_LIVE) {
            sql += ' AND ((`flags` NOTNULL AND  `flags` & $v != $v) OR (`flags` IS NULL)) ';
          }else if(opts.showRecycled == ShowRecycled.ONLY_RECYCLED) {
            sql += ' AND ((`flags` NOTNULL AND  `flags` & $v == $v) OR (`flags` IS NULL)) ';
          }
        } else {
          if(opts.showRecycled == ShowRecycled.ONLY_LIVE) {
            sql += ' WHERE ((`flags` NOTNULL AND  `flags` & $v != $v) OR (`flags` IS NULL)) ';
          }else if(opts.showRecycled == ShowRecycled.ONLY_RECYCLED) {
            sql += ' WHERE ((`flags` NOTNULL AND  `flags` & $v == $v) OR (`flags` IS NULL)) ';
          }

        }


        var orderBy = "";
        switch(opts.sortBy.runtimeType) {
          case SortByStr:
            orderBy = ' ORDER BY `FullText` ${opts.sortBy.dir == SortDir.ASC ? 'ASC' : 'DESC'} ';
            break;
          case SortByCreating:
            orderBy = ' ORDER BY `iid_timestamp` ${opts.sortBy.dir == SortDir.ASC ? 'ASC' : 'DESC'} ';
            break;
          case SortByEditing:
            orderBy = ' ORDER BY `ver_timestamp` ${opts.sortBy.dir == SortDir.ASC ? 'ASC' : 'DESC'} ';
            break;
        }
        sql += orderBy;
      } else {
        sql += ' ORDER BY `iid_timestamp` DESC ';
      }

      print('Mobynote.DBProvider.getNotes2: sql=$sql');

      var res = await db.rawQuery('$sql;');

//      var res = await db.rawQuery(
//          'SELECT * FROM `mn_tbl_notes` WHERE (`flags` NOTNULL AND  `flags` & $v != $v) OR (`flags` IS NULL);');
      List<Result<Note>> list =
      res.isNotEmpty ? res.map((c) => EisNoteLocalJsonMapper().fromMap(c)).toList() : [];
      List<Note> notes = List();
      list.forEach((e) {
        if (e.data != null) {
          notes.add(e.data);
        }
      });
      print('Mobynote.DBProvider.getNotes2: cnt = ${notes.length}');
      return notes;
    } catch (e) {
//      print('Mobynote.DBProvider.getNotes: ERROR = $e');
      return Future.error(e);
    }
  }


  Future<List<Note>> getAllNotes({VisualMappingOptions sortFilter}) async {
    return getNotes(sortFilter.copyWith(searchStr: ''));
//    print('Mobynote.DBProvider.getAllNotes: START');

//    return await database
//        .then((db) => db.transaction((tx) async {
//          print('Mobynote.DBProvider.getAllNotes: in transaction');
//          final v = FLAGS[FlagKeys.DEL];
//          return await db.rawQuery(
//              'SELECT * FROM `mn_tbl_notes` WHERE (`flags` NOTNULL AND  `flags` & $v != $v) OR (`flags` IS NULL);');
//        }))
//        .then((v) {
//      print('Mobynote.DBProvider.getAllNotes: v = $v');
//      List<Result<Note>> list =
//      v.isNotEmpty ? v.map((c) => EisNoteLocalJsonMapper().fromMap(c)).toList() : [];
//      List<Note> notes = List();
//      list.forEach((e) {
//        if (e.data != null) {
//          notes.add(e.data);
//        }
//      });
//      print('Mobynote.DBProvider.getAllNotes: return $notes');
//      return notes;
//    }).catchError((e) {
//      print('Mobynote.DBProvider.getAllNotes: ERROR $e');
//      return Future.error(e);
//    });




//    final db = await database;
//    final v = FLAG_MAP[FlagKeys.RECYCLED];
////    print('Mobynote.DBProvider.getAllNotes: v = $v');
//    try {
//
//      var sql = 'SELECT * FROM `mn_tbl_notes` ';
//
//      if (sortFilter != null) {
//
//        if(sortFilter.searchStr != "") {
//          final ss = sortFilter.searchStr;
//          sql += ' WHERE `note_text` like \'$ss\' OR `title` like \'$ss\' ';
//        }
//
//        if(sortFilter.sortType == SortType.ASC){
//          sql += ' ORDER BY `iid_timestamp` ASC ';
////          sql += ' ORDER BY `title` ASC, `note_text` ASC';
//        }else{
//          sql += ' ORDER BY `iid_timestamp` DESC ';
////          sql += ' ORDER BY `title` DESC, `note_text` DESC';
//        }
//      } else {
//        sql += ' ORDER BY `iid_timestamp` DESC ';
//      }
//      print('Mobynote.DBProvider.getAllNotes: sql=$sql');
//
//      var res = await db.rawQuery('$sql;');
//
////      var res = await db.rawQuery(
////          'SELECT * FROM `mn_tbl_notes` WHERE (`flags` NOTNULL AND  `flags` & $v != $v) OR (`flags` IS NULL);');
//      List<Result<Note>> list =
//          res.isNotEmpty ? res.map((c) => EisNoteLocalJsonMapper().fromMap(c)).toList() : [];
//      List<Note> notes = List();
//      list.forEach((e) {
//        if (e.data != null) {
//          notes.add(e.data);
//        }
//      });
//      return notes;
//    } catch (e) {
//      return Future.error(e);
//    }
  }

  /// v.1.0:
  /// 1. Searching first rec in table
  /// 2. If not - creates
  /// 3. Returns
  Future<EisUser> getUser() async {
//    print('Mobynote.DBProvider.getUser: START');
    return await database.then((db) {
      return db.transaction((tx) async {
        final qrySelect =
            "SELECT * FROM `mn_tbl_users` WHERE `id` = (SELECT MIN(`id`) FROM `mn_tbl_users`)";
        var list = await _rawQuery(tx, qrySelect);
//        print('Mobynote.DBProvider.getUser: list = $list');
        if (list.length == 0) {
          // try to insert one
          await tx.rawInsert("INSERT INTO `mn_tbl_users`(`label`, `timestamp`) VALUES (?,?)",
              [Uuid().v4(), timestamp()]);
          list = await _rawQuery(tx, qrySelect);
          if (list.length < 1) {
            // error to create user
            return Future.error("error to create user");
          }
        }
        final res = EisUserLocalJsonMapper().fromMap(list[0]);
//        print('Mobynote.DBProvider.getUser: return res = $res');
        return res.data == null ? Future.error(res.ex) : res.data;
      });
    }).catchError((e) {
//      print('Mobynote.DBProvider.getUser: return ERROR = $e');
      return Future.error(e);
    });
  }

  Future<List<Note>> recycleNote(FlagAndNote flagNote) async {
    return await database.then((db) =>
        db.transaction((tx) async {
          return flagNote.notes.map((n) {
            n.attrs.recycledFlag = flagNote.value;
            final v = n.attrs.flags;
            final params = {'flags': v};
            try {
              final res = tx.update('`mn_tbl_notes`', params, where: 'id=?', whereArgs: [n.id]);
              if (res != 0) {
                return n;
              }
            } catch (e) {
              return null;
            }
          }).where((res) => res != null).toList();
        }));
      // 19/03/18 FIXME Требуется возвращать как-то и ошибки, может вернуться к Result<List<...>>
//              flagNote.note.setFlag(flagNote.flag, flagNote.value);
//              final v = flagNote.note.attrs[Attrs.FLAGS];
//              final map = {'flags': v};
//              final i = await tx.update('`mn_tbl_notes`', map, where: 'id = ?', whereArgs: [flagNote.note.id]);
//              return i;
//        .then((v) => v != 0 ? flagNote.note : Future.error("ERROR to delete -> i==0"))
//        .catchError((e) => Future.error("error delete note: $e"));
  }

  Future<Note> addNote(Note candidate) async {
    if(candidate == null) {
      return Future.error("candidate == NULL");
    }
    return await database
        .then((db) =>
        db.transaction((tx) {
          final mapa = EisNoteLocalJsonMapper().toMap(candidate);
          print('DBProvider.addNote: mapa $mapa');
          return tx.insert('`mn_tbl_notes`', mapa);
        }))
        .then((v) {
      if (v != 0) {
        print('DBProvider.addNote: v $v');
        candidate.id = v;
        return candidate;
      } else {
        print('DBProvider.addNote: ERROR to insert');
        return Future.error("ERROR to insert");
      }
    }).catchError((e) {
      print('DBProvider.addNote: error add note: $e');
      return Future.error("error add note: $e");
    } );
  }

  Future<Note> updateNote(Note note) async {
    //print('Mobynote.DBProvider.updateNote: START with $note');
    if(note == null) {
      return Future.value(null);
    }
    return await database.then((db) {
      return db.transaction((tx) async {
        return await _getNote(tx, note.id).then((origin) async {
          if (origin != note) {
            note.verTimeStamp = timestamp();
            note.verOrd++;
            final mapa = EisNoteLocalJsonMapper().toMap(note);
            final i =
                await tx.update("`mn_tbl_notes`", mapa, where: "`id` = ?", whereArgs: [note.id]);
            if (i != 0) {
              print('Mobynote.DBProvider.updateNote: ret=$note');
              return Future.value(note);
            } else {
              return Future.error("UPDATE FAILED");
            }
          } else {
            return Future.value(origin);
          }
        }).catchError((e) {
          return Future.error(e);
        });
      });
    }).catchError((e) {
      return Future.error(e);
    });
  }

  /// Transactional query.
  Future<List<Map<String, dynamic>>> _rawQuery(Transaction tx, String query) async =>
      tx.rawQuery(query);

  Future<Note> _getNote(Transaction tx, int id) async {
    return await tx.query("`mn_tbl_notes`", where: "`id` = ?", whereArgs: [id]).then((lst) {
//      print('Mobynote.DBProvider._getNote: lst = ${lst}');
      if (lst.length != 1) {
        return Future.error("more then one record");
      } else {
        final res = EisNoteLocalJsonMapper().fromMap(lst[0]);
        return res.data != null ? Future.value(res.data) : Future.error(res.ex);
      }
    }).catchError((e) {
      return Future.error(e);
    });
  }

  Future<Map<String, dynamic>> _pref(Transaction tx, String key) async {
    return tx.query('mn_tbl_pref', where: 'key = ?', whereArgs: [key])
        .then((lst){
          return lst.length == 0 ? Map() : lst[0];
    });
  }

}
