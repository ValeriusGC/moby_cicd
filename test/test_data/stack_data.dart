import 'dart:convert';

import 'package:mobynote/model/jsonable.dart';


abstract class Stack<O extends Jsonable> with Jsonable {
  final _list = List<Cmd<O, Stack<O>>>();
  O _obj;

  O get obj => _obj;

  Stack(this._obj, List<Cmd<O, Stack<O>>> initial){
    if(initial != null){
      _list.addAll(initial);
    }
  }

  void push(Cmd<O, Stack<O>> cmd) {
    cmd.redo(this, _obj);
    _list.add(cmd);
  }

  @override
  Map<String, dynamic> toJson() {
    final m = super.toJson();
    m['l'] = _list;
    m['o'] = _obj.toJson();
    return m;
  }

  @override
  String toString() {
    return 'Stack{_list: $_list, obj: $obj}';
  }


}

abstract class Cmd<O extends Jsonable, S extends Stack<O>> with Jsonable {
  O redo(S stack, O obj);
  O undo(S stack, O obj);
}

////////////////////////////////////////////////////////////////////////////////////////////////////

class MyObj with Jsonable {

  final String _title;
  final int _pos;

  MyObj(this._title, this._pos);

  factory MyObj.fromJson(Map<String, dynamic> map) {
    if(map['@@t'] as String == 'MyObj'){
      return MyObj(
        map['t'] as String,
        map['p'] as int,
      );
    } else return null;
  }

  @override
  Map<String, dynamic> toJson() {
    final m = super.toJson();
    m['t'] = title;
    m['p'] = _pos;
    return m;
  }

  String get title => _title;

  int get pos => _pos;

  @override
  String toString() {
    return 'MyObj{_title: $_title, _pos: $_pos}';
  }


}

///
class MyStack extends Stack<MyObj>{

  MyStack(MyObj obj, {List<Cmd<MyObj, Stack<MyObj>>> initial}) : super(obj, initial);

  factory MyStack.fromJson(Map<String, dynamic> map) {
    final om = map['o'];
    MyObj o = MyObj.fromJson(om);
    if(o != null){
      final lst = CmdFactory.build(map['l']);
      return MyStack(o, initial: lst);
    }else  return null;
  }

//  @override
//  Map<String, dynamic> toJson() {
//    final m = super.toJson();
//    return m;
//  }

  @override
  String toString() {
    return 'MyStack{ ${super.toString()} }';
  }

}

class Cmd1 extends Cmd<MyObj, MyStack> {

  final String text;
  final int pos;

  Cmd1(this.text, this.pos);

  factory Cmd1.fromJson(Map<String, dynamic> map) {
    return Cmd1(
      map['t'] as String,
      map['p'] as int,
    );
  }

  @override
  MyObj redo(MyStack stack, MyObj obj) {
    // TODO: implement redo
  }

  @override
  MyObj undo(MyStack stack, MyObj obj) {
    // TODO: implement undo
  }

  @override
  Map<String, dynamic> toJson() {
    final map = super.toJson();
    map['t'] = text;
    map['p'] = pos;
    return map;
  }

  @override
  String toString() {
    return 'Cmd1{text: $text, pos: $pos}';
  }


}

class Cmd2 extends Cmd<MyObj, MyStack> {

  final String text;
  final int pos;

  Cmd2(this.text, this.pos);

  factory Cmd2.fromJson(Map<String, dynamic> map) {
    return Cmd2(
      map['t'] as String,
      map['p'] as int,
    );
  }

  @override
  MyObj redo(MyStack stack, MyObj obj) {
    // TODO: implement redo
  }

  @override
  MyObj undo(MyStack stack, MyObj obj) {
    // TODO: implement undo
  }

  @override
  Map<String, dynamic> toJson() {
    final map = super.toJson();
    map['t'] = text;
    map['p'] = pos;
    return map;
  }

  @override
  String toString() {
    return 'Cmd2{text: $text, pos: $pos}';
  }


}

///
abstract class CmdFactory {

  //static List<Cmd<MyObj, MyStack>> build(List<Map<String, dynamic>> lst){
  static List<Cmd<MyObj, MyStack>> build(List<dynamic> lst){
    final r = List<Cmd<MyObj, MyStack>>();
    lst.forEach((m){
      final type = m['@@t'];
      switch(type){
        case 'Cmd1':
          r.add(Cmd1.fromJson(m));
          break;
        case 'Cmd2':
          r.add(Cmd2.fromJson(m));
          break;
        default:
          print('Mobynote.CmdFactory.build: ERROR');
          return null;
      }
    });
    return r;
  }

}