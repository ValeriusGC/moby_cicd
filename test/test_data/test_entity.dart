import 'package:mobynote/model/jsonable.dart';
import 'package:mobynote/undo_lib/undo_stack.dart';

/// Sample of [Jsonable] type.
/// Mandatory parts are:
/// - overriden method [toJson] with [super.toJson]
/// - static method [fromJsin(Map<>) : Text]
class Text with Jsonable {
  static const String _TYPE = 'Text';
  static const String KEY_TEXT = 't';
  static const String KEY_POS = 'p';

  final String _text;
  final int _cursorPos;

  String get text => _text;

  int get cursorPos => _cursorPos;

  Text(this._text, this._cursorPos);

  @override
  Map<String, dynamic> toJson() {
    final m = super.toJson();
    m[KEY_TEXT] = _text;
    m[KEY_POS] = _cursorPos;
    return m;
  }

  static Text fromJson(Map<String, dynamic> map) {
    if (map[Jsonable.KEY_TYPE] == _TYPE) {
      return Text(
        map[KEY_TEXT],
        map[KEY_POS] as int,
      );
    } else
      return null;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Text &&
          runtimeType == other.runtimeType &&
          _text == other._text &&
          _cursorPos == other._cursorPos;

  @override
  int get hashCode => _text.hashCode ^ _cursorPos.hashCode;

  @override
  String toString() {
    return 'Text{_text: $_text, _cursorPos: $_cursorPos}';
  }
}

/// Sample of particular [UndoStack].
/// Mandatory parts are:
/// - static factory (or method) fromJson(Map<>) with passing builders to base class.
/// - base CTR
class TextUndoStack extends UndoStack<Text> {
  static const String _TYPE = 'TextUndoStack';

  TextUndoStack(Text obj, {UndoChanged changed}) : super(obj, changed);

  factory TextUndoStack.fromJson(Map<String, dynamic> map) {
    if (map[Jsonable.KEY_TYPE] == _TYPE) {
      return TextUndoStack._fromJson(
        map,
        Text.fromJson,
        {
          ChangeTextCommand._TYPE: ChangeTextCommand.fromJson,
        },
        changed: null,
      );
    } else
      return null;
  }

  TextUndoStack._fromJson(Map<String, dynamic> map, UndoObjectBuilder objectBuilder,
      Map<String, UndoCommandBuilder> commandBuilders,
      {UndoChanged changed})
      : super.fromJson(map, objectBuilder, commandBuilders, changed: changed);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is TextUndoStack && runtimeType == other.runtimeType;

  @override
  int get hashCode => 0;
}

/// Sample of particular [UndoCommand].
/// Mandatory parts are:
/// - overriden method [toJson] with [super.toJson]
/// - static method [fromJson(Map<>) : ]
class ChangeTextCommand extends UndoCommand<TextUndoStack, Text> {
  static const String _TYPE = 'ChangeTextCommand';
  static const String KEY_NEW_TEXT = 'nt';
  static const String KEY_NEW_POS = 'np';
  static const String KEY_OLD_TEXT = 'ot';
  static const String KEY_OLD_POS = 'op';

  final _newText;
  final _newPos;
  String _oldText;
  int _oldPos;

  ChangeTextCommand(this._newText, this._newPos);

  @override
  Text redo(UndoStack<Text> base, Text obj) {
    _oldText = base.obj.text;
    _oldPos = base.obj.cursorPos;
    final t = Text(_newText, _newPos);
    return t;
  }

  @override
  Text undo(UndoStack<Text> base, Text obj) {
    final t = Text(_oldText, _oldPos);
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

  static ChangeTextCommand fromJson(Map<String, dynamic> map) {
    if (map[Jsonable.KEY_TYPE] == _TYPE) {
      return ChangeTextCommand(map[KEY_NEW_TEXT], map[KEY_NEW_POS])
        .._oldText = map[KEY_OLD_TEXT]
        .._oldPos = map[KEY_OLD_POS];
    } else
      return null;
  }
}
