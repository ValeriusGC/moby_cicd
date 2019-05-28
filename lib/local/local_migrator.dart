import 'package:sqflite/sqflite.dart';

abstract class LocalMigrator {
  Future<void> upgrade(Transaction tx) async {
    await saveData(tx);
    await changeStruct(tx);
    await migrateData(tx);
  }

  Future<void> saveData(Transaction tx){
//    print('Mobynote.LocalMigrator.saveData: STUB');
  }
  Future<void> changeStruct(Transaction tx);
  Future<void> migrateData(Transaction tx);
}