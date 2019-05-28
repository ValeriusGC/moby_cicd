import 'dart:async';

import 'package:meta/meta.dart';
import 'package:mobynote/NoteModel.dart';
import 'package:mobynote/app_session.dart';
import 'package:mobynote/note_interactor.dart';
import 'package:rxdart/rxdart.dart';

enum VisibilityFilter { all, active, deleted }

class NoteBloc {
  /// Inputs
  final Sink<FlagAndNote> deleteNote;
  final Sink<FlagAndNote> undeleteNote;
  final Sink<Note> addNote;
  final Sink<Note> updateNote;
//  final Sink<VisibilityFilter> updateFilter;
//  final Sink<SortManager> updateSort;

  // Outputs
  final Stream<List<Note>> visibleTodos;
//  final Stream<VisibilityFilter> activeFilter;
//  final Stream<SortManager> activeSort;

  // Cleanup
  final List<StreamSubscription<dynamic>> _subscriptions;

  factory NoteBloc(NoteInteractor interactor) {
//    print('Mobynote.NoteBloc.NoteBloc: CTR');
    final deleteNoteController = StreamController<FlagAndNote>(sync: true);
    final undeleteNoteController = StreamController<FlagAndNote>(sync: true);
    final addNoteController = StreamController<Note>(sync: true);
    final updateNoteController = StreamController<Note>(sync: true);
//    final updateFilterController = BehaviorSubject<VisibilityFilter>(
//      seedValue: VisibilityFilter.active,
//      sync: true,
//    );
//    final updateSortController = BehaviorSubject<SortManager>(
//      seedValue: SortManager.mk(sortType: SortType.DESC),
//      sync: true,
//    );

    final subscriptions = <StreamSubscription<dynamic>>[
      // When a user removes an item, remove it from the repository
      deleteNoteController.stream.listen(interactor.deleteNote),
      undeleteNoteController.stream.listen(interactor.undeleteNote),
      addNoteController.stream.listen(interactor.addNote),
      updateNoteController.stream.listen(interactor.updateNote),
//      updateSortController.stream.listen(interactor.sort),
    ];

    final visibleNoteController = BehaviorSubject<List<Note>>();

//    Observable.combineLatest2<List<Note>, VisibilityFilter, List<Note>>(
//      interactor.notes,
//      updateFilterController.stream,
//      _filterTodos,
//    ).pipe(visibleNoteController);

    return NoteBloc._(
      deleteNoteController,
      undeleteNoteController,
      addNoteController,
      updateNoteController,
      subscriptions,
      visibleNoteController.stream
    );
  }

  void close() {
    print('Mobynote.NoteBloc.close: DTR');
    deleteNote.close();
    undeleteNote.close();
    addNote.close();
    updateNote.close();
    _subscriptions.forEach((subscription) => subscription.cancel());
  }

  NoteBloc._(
    this.deleteNote,
    this.undeleteNote,
    this.addNote,
    this.updateNote,
    this._subscriptions,
    this.visibleTodos,
  );

  static List<Note> _filterTodos(List<Note> todos, VisibilityFilter filter) {
//    print('Mobynote.NoteBloc._filterTodos: START. todos = $todos');
    print('Mobynote.NoteBloc._filterTodos: START. filter = $filter, todos=${todos}');
    return todos.where((todo) {
      switch (filter) {
        case VisibilityFilter.all:
          return true;
        case VisibilityFilter.active:
          return !todo.attrs.recycledFlag;
        case VisibilityFilter.deleted:
          return todo.attrs.recycledFlag;
      }
    }).toList();
  }
}
