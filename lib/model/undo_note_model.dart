import 'package:mobynote/NoteModel.dart';
import 'package:mobynote/model/jsonable.dart';
import 'package:mobynote/undo_lib/undo_stack.dart';

///
class NoteUndoStack extends UndoStack<Note> {
  static const String _TYPE = 'NoteUndoStack';

  NoteUndoStack(Note obj, {UndoChanged changed}) : super(obj, changed);

  factory NoteUndoStack.fromJson(Map<String, dynamic> map) {
    if (map[Jsonable.KEY_TYPE] == _TYPE) {
      return NoteUndoStack._fromJson(
        map,
        Note.fromJson,
        {
          ChangeNoteTextCommand._TYPE: ChangeNoteTextCommand.fromJson,
        },
        changed: null,
      );
    } else
      return null;
  }

  NoteUndoStack._fromJson(Map<String, dynamic> map, UndoObjectBuilder objectBuilder,
      Map<String, UndoCommandBuilder> commandBuilders,
      {UndoChanged changed})
      : super.fromJson(map, objectBuilder, commandBuilders, changed: changed);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is NoteUndoStack && runtimeType == other.runtimeType;

  @override
  int get hashCode => 0;
}

///
class ChangeNoteTextCommand extends UndoCommand<NoteUndoStack, Note> {
  static const String _TYPE = 'ChangeNoteTextCommand';
  static const String KEY_NEW_TEXT = 'nt';
  static const String KEY_NEW_POS = 'np';
  static const String KEY_OLD_TEXT = 'ot';
  static const String KEY_OLD_POS = 'op';

  final _newText;
  final _newPos;
  String _oldText;
  int _oldPos;

  ChangeNoteTextCommand(this._newText, this._newPos);

  @override
  Note redo(UndoStack<Note> base, Note obj) {
    _oldText = base.obj.noteText;
    final p = base.obj.attrs.textCursorPos;
    print('Mobynote.ChangeNoteTextCommand.redo: pos=$p');
    _oldPos = p is int && p > -1 && p < _oldText.length ? p : _oldText.length;
    obj.attrs.textCursorPos = _newPos;
    obj.noteText = _newText;
    final t = obj.copyWith();
    return t;
  }

  @override
  Note undo(UndoStack<Note> base, Note obj) {
    obj.attrs.textCursorPos = _oldPos;
    obj.noteText = _oldText;
    final t = obj.copyWith();
    return t;
  }

  @override
  Map<String, dynamic> toJson() {
    final m = super.toJson();
    m[KEY_NEW_TEXT] = _newText;
    m[KEY_NEW_POS] = _newPos;
    m[KEY_OLD_TEXT] = _oldText;
    m[KEY_OLD_POS] = _oldPos;
    return m;
  }

  static ChangeNoteTextCommand fromJson(Map<String, dynamic> map) {
    if (map[Jsonable.KEY_TYPE] == _TYPE) {
      return ChangeNoteTextCommand(map[KEY_NEW_TEXT], map[KEY_NEW_POS])
        .._oldText = map[KEY_OLD_TEXT]
        .._oldPos = map[KEY_OLD_POS];
    } else
      return null;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChangeNoteTextCommand &&
          runtimeType == other.runtimeType &&
          _newText == other._newText &&
          _newPos == other._newPos &&
          _oldText == other._oldText &&
          _oldPos == other._oldPos;

  @override
  int get hashCode => _newText.hashCode ^ _newPos.hashCode ^ _oldText.hashCode ^ _oldPos.hashCode;
}
