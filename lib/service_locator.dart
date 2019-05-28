import 'package:get_it/get_it.dart';
import 'package:mobynote/Database.dart';
import 'package:mobynote/managers/home_screen_manager.dart';
import 'package:mobynote/managers/note_manager.dart';
import 'package:sqflite/sqflite.dart';

GetIt sl = GetIt();

void setUpServiceLocator() {
  sl.registerSingleton<DBProvider>(DBProvider.db);

  // Managers

  sl.registerSingleton<HomeScreenManager>(HomeScreenManager());

  sl.registerSingleton<NoteManager>(NoteManager());

  // ~Managers
}
