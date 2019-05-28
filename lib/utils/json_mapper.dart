import 'dart:convert';
import 'package:mobynote/utils/result.dart';

Type type<T>() => T;

/// Class to inherit if one want to make object as JSON
//abstract class Jsonable {
//
//  static const String KEY_TYPE = '@@t';
//
//  Map<String, dynamic> toJson() => {
//    KEY_TYPE : this.runtimeType.toString(),
//  };
//}

/// Mappers have the ability to create some objects, but without access to private members
abstract class JsonMapper<T> {
  /// Template method to convert instance of T to JSON.
  /// Calls abstract method [toMap] that consumer should realize on its own.
  String toJson(T obj) {
    return jsonEncode(toMap(obj));
  }

  /// Template method to convert JSON to instance of T.
  /// Calls abstract method [fromMap] that consumer should realize on its own.
  Result<T> fromJson(String json) {
    return fromMap(jsonDecode(json) as Map<String, dynamic>);
  }

  /// Consumer should realize it.
  Map<String, dynamic> toMap(T obj);

  /// Consumer should realize it.
  Result<T> fromMap(Map<String, dynamic> map);
}
