
import 'package:meta/meta.dart';
import 'package:mobynote/model/jsonable.dart';
import 'package:mobynote/utils/datetime.dart';

@immutable
class Version with Jsonable{
  static const String _TYPE = 'Version';
  static const String KEY_ORD = 'o';
  static const String KEY_TS = 't';

  final int ord;
  final int ts;

  factory Version.mk({int ord, int ts}) {
    return Version._(
      ord: ord != null && ord > 1 ? ord : 1,
      ts: ts != null && ts > 0 ? ts : timestamp(),
    );
  }

  Version inc(int ts) {
    return Version._(
      ord: this.ord + 1,
      ts: ts > this.ts ? ts : timestamp(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final map = super.toJson();
    map[KEY_ORD] = ord;
    map[KEY_TS] = ts;
    return map;
  }

  static Version fromJson(Map<String, dynamic> map) {
    if (map[Jsonable.KEY_TYPE] == _TYPE) {
      return Version.mk(ord: map[KEY_ORD], ts: map[KEY_TS]);
    } else
      return null;
  }

  Version._({this.ord, this.ts});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Version &&
              runtimeType == other.runtimeType &&
              ord == other.ord &&
              ts == other.ts;

  @override
  int get hashCode =>
      ord.hashCode ^
      ts.hashCode;

}

@immutable
abstract class Traceable with Jsonable {
  static const String KEY_SUID = 'suid';
  static const String KEY_TS = 'ts';
  static const String KEY_VER = 'ver';

  final String suid;
  final int timestamp;
  final Version version;

  Traceable(this.suid, this.timestamp, this.version);

  Traceable.fromMap(Map<String, dynamic> map) :
        suid = map[KEY_SUID] ?? '',
        timestamp = map[KEY_TS] ?? 0, version = Version.fromJson(map[KEY_VER]){}

  @override
  Map<String, dynamic> toJson() {
    final map = super.toJson();
    map[KEY_SUID] = suid;
    map[KEY_TS] = timestamp;
    map[KEY_VER] = version.toJson();
    return map;
  }

}