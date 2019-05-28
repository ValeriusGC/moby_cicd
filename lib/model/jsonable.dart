/// Base for JSONing
/// Inheriting gives the ability make json with full access to members.
/// One should override [toJson] and invoke supermethod inside.
abstract class Jsonable {
  static const String KEY_TYPE = '@@t';

  Map<String, dynamic> toJson() => {
        KEY_TYPE: runtimeType.toString(),
      };

}
