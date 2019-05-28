import 'package:mobynote/model/jsonable.dart';

/// Callback to say that [UndoStack]'s state has changed
typedef UndoChanged = Function(UndoStack);

/// Callback to build object
typedef UndoObjectBuilder<O extends Jsonable> = O Function(Map<String, dynamic>);

/// Callback to build [UndoCommand]
typedef UndoCommandBuilder<O extends Jsonable, S extends UndoStack<O>> = UndoCommand<S, O> Function(
    Map<String, dynamic>);

/// Base UndoStack
abstract class UndoStack<O extends Jsonable> with Jsonable {
  static const String KEY_OBJ = 'o';
  static const String KEY_CMDS = 'c';

  O _obj;

  final _commands = List<UndoCommand<UndoStack<O>, O>>();

  int _pos = 0;

  UndoChanged _changed;

  O get obj => _obj;

  int get count => _commands.length;

  UndoStack(this._obj, this._changed);

  UndoStack.fromJson(
      Map<String, dynamic> map,
      UndoObjectBuilder objectBuilder,
      Map<String, UndoCommandBuilder> commandBuilders,
      {UndoChanged changed}) {

    final om = map[KEY_OBJ];
    if(om != null) {
      _obj = objectBuilder(om);
    }

    final lst = map[KEY_CMDS];
    lst.forEach((m) {
      final type = m[Jsonable.KEY_TYPE];
      final f = commandBuilders[Jsonable.KEY_TYPE];
      if (f != null) {
        final c = f(type);
        _commands.add(c);
      }
    });

    _changed = changed;
  }

  void push(UndoCommand cmd) {
//    _obj = cmd.redo(this, obj);
    _commands.add(cmd);
    redo();
//    _pos = count;
//    if (_changed != null) {
//      _changed(this);
//    }
  }

  void undo() {
    if (_pos > 0 && _pos < count + 1) {
      _pos--;
      _obj = _commands[_pos].undo(this, obj);
      if (_changed != null) {
        _changed(this);
      }
    }
  }

  void redo() {
    if (_pos < count) {
      _obj = _commands[_pos].redo(this, obj);
      _pos++;
      if (_changed != null) {
        _changed(this);
      }
    }
  }

  @override
  Map<String, dynamic> toJson() {
    final m = super.toJson();
    m[KEY_OBJ] = _obj.toJson();
    m[KEY_CMDS] = _commands;
    return m;
  }
}

abstract class UndoCommand<S extends UndoStack<O>, O extends Jsonable> with Jsonable {
  O redo(S stack, O obj);

  O undo(S stack, O obj);
}
