// Copyright 2018 The Flutter Architecture Sample Authors. All rights reserved.
// Use of this source code is governed by the MIT license that can be found
// in the LICENSE file.

import 'dart:async';
import 'dart:core';

import 'package:mobynote/NoteModel.dart';
import 'package:mobynote/app_session.dart';
import 'package:mobynote/note_bloc.dart';

///
abstract class BaseNoteRepo {

  Future<void> open();
  Future<void> close();
  bool isOpened();

  Future<Note> addNew(Note candidate);

  Future<List<Note>> delete(FlagAndNote flagNote);

  Future<List<Note>> undelete(FlagAndNote flagNote);

  Stream<List<Note>> notes();

  Future<Note> update(Note note);
  Future<void> sort(VisualMappingOptions sortFilter);
}
