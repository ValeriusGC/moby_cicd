import 'dart:async';
import 'package:mobynote/Database.dart';
import 'package:mobynote/NoteModel.dart';
import 'package:mobynote/app_session.dart';
import 'package:mobynote/local_repo.dart';
import 'package:mobynote/note_bloc.dart';
import 'package:mobynote/utils/datetime.dart';
import 'package:mobynote/utils/result.dart';
import 'package:rxdart/subjects.dart';

class NoteInteractor {

  final LocalRepo repo;

  NoteInteractor(this.repo) {
//    print('Mobynote.NoteInteractor.NoteInteractor: CTR');
  }

//  Future<Result<String>> openRepo(String id) {
//    return Future.error(Result.error(Exception("open repo $id")));
//  }
//
//  Future<Result<String>> closeRepo(String id) {
//    return Future.error(Result.error(Exception("close repo $id")));
//  }
//
//  Future<Result<String>> currentRepo() {
//    return Future.error(Result.error(Exception("current repo")));
//  }

  // 19/03/12 TODO  Этот метод работает. Следует делать дальше и проверять удаление и Dismissible
  Stream<List<Note>> get notes {
//    print('Mobynote.NoteInteractor.notes: START');
    return repo.notes();
  }
  
  Future<void> deleteNote(FlagAndNote note) async {
    await repo.delete(note);
  }

  Future<void> undeleteNote(FlagAndNote note) async {
    await repo.undelete(note);
  }

  Future<Note> addNote(Note candidate) async {
    if(candidate.verTimeStamp == 0){
      candidate.verTimeStamp = timestamp();
    }
    candidate.verOrd = 1;
    return repo.addNew(candidate);
  }

  Future<Note> updateNote(Note note) async {
    await repo.update(note);
    return null;
  }

  Future<void> sort(VisualMappingOptions sortFilter) async {
    await repo.sort(sortFilter);
  }

}