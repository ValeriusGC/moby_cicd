// Copyright 2018 The Flutter Architecture Sample Authors. All rights reserved.
// Use of this source code is governed by the MIT license that can be found
// in the LICENSE file.

import 'dart:async';
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mobynote/Database.dart';
import 'package:mobynote/NoteModel.dart';
import 'package:mobynote/app_session.dart';
import 'package:mobynote/base_note_repo.dart';
import 'package:mobynote/note_bloc.dart';
import 'package:rxdart/subjects.dart';

///
class LocalRepo extends BaseNoteRepo {

  final DBProvider dbProv;
  bool _isOpened;
  final BehaviorSubject<List<Note>> _subject;
  bool _loaded = false;

  LocalRepo(this.dbProv) : this._subject = BehaviorSubject<List<Note>>(seedValue: []) {
//    print('Mobynote.LocalRepo.LocalRepo: dbProv=$dbProv');
  }

  @override
  Future<void> close() async {
    _isOpened = false;
    final db = await dbProv.database;
    return db.close();
  }

  @override
  bool isOpened() {
    return _isOpened;
  }

  @override
  Future<void> open() async {
    dbProv.database.then((db) {
      _isOpened = db.isOpen;
    }).catchError((e) {
      _isOpened = false;
      return Future.error(e);
    });
  }

  @override
  Future<Note> addNew(Note candidate) async {
    // 19/03/13 TODO Необходимо обрабатывать и выводить ошибки!
    final v = await dbProv.addNote(candidate);
    _subject.add(List.unmodifiable([]
      ..addAll(_subject.value ?? [])
      ..add(candidate)));
    return Future.value(v);
  }

  @override
  Future<List<Note>> delete(FlagAndNote flagNote) async {
    // 19/03/13 TODO Необходимо обрабатывать и выводить ошибки!
    // _subject.add([]);

    // 19/03/18 FIXME Мы пока не используем возвращаемое значение, а впоследствии надо возвращать правильно!
    try{
      await dbProv.recycleNote(flagNote);
      final l = await dbProv.getAllNotes();
      _subject.add(List<Note>.unmodifiable([]..addAll(l)));
//      _subject.add(List.unmodifiable([]
//        ..addAll(_subject.value ?? [])
//        ..add(flagNote.note)));
    }catch(e){
      print('Mobynote.LocalRepo.undelete: ERROR $e');
      _subject.add(_subject.value ?? []);
    }
    return Future.value(flagNote.notes);
  }

  @override
  Future<List<Note>> undelete(FlagAndNote flagNote) async {
    // 19/03/13 TODO Необходимо обрабатывать и выводить ошибки!
    // _subject.add([]);
    try{
      await dbProv.recycleNote(flagNote);
//      _subject.add(List.unmodifiable([]
//        ..addAll(_subject.value ?? [])
//        ..add(flagNote.note)));
      final l = await dbProv.getAllNotes();
      _subject.add(List<Note>.unmodifiable([]..addAll(l)));
    }catch(e){
      print('Mobynote.LocalRepo.undelete: ERROR $e');
      _subject.add(_subject.value ?? []);
    }
    return Future.value(flagNote.notes);
  }

  @override
  Stream<List<Note>> notes() {
    if (!_loaded) {
      try{
        _load();
      }catch(e){
        print('Mobynote.LocalRepo.undelete: ERROR $e');
        return Stream.empty();
      }
    }
    return _subject.stream;
  }

  @override
  Future<Note> update(Note note) async {
    final v = await dbProv.updateNote(note);
    final l = await dbProv.getAllNotes();
    _subject.add(List<Note>.unmodifiable([]..addAll(l)));
    return Future.value(v);
  }

  @override
  Future<void> sort(VisualMappingOptions sortFilter) async{
    final l = await dbProv.getAllNotes(sortFilter: sortFilter);
    _subject.add(List<Note>.unmodifiable([]..addAll(l)));
  }

  void _load()  {
    _loaded = true;
//    dbProv.getAllNotes().then((values) {
//      _subject.add(List<Note>.unmodifiable([]..addAll(_subject.value ?? [])..addAll(values)));
//    }).catchError((e){
//      print('Mobynote.LocalRepo._load: ERROR = $e');
//      Fluttertoast.showToast(msg: e.toString(), backgroundColor: Colors.red);
//      return Exception(e);
//    });
//    print('Mobynote.LocalRepo._load: FINISH');
  }

}
