import 'package:meta/meta.dart';
import 'package:mobynote/utils/datetime.dart';

/// v.1.0
@immutable
class EisUser {
  final String uid;
  final int timeCreated;

  factory EisUser.mk({String uid, int timeCreated}) {
    return EisUser._(uid: uid, timeCreated: timeCreated ?? timestamp());
  }

  EisUser copyWith({String uid, int timeCreated}) {
    return EisUser._(uid: uid, timeCreated: timeCreated ?? timestamp());
  }

  EisUser._({this.uid, this.timeCreated});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EisUser &&
          runtimeType == other.runtimeType &&
          uid == other.uid &&
          timeCreated == other.timeCreated;

  @override
  int get hashCode => uid.hashCode ^ timeCreated.hashCode;

  @override
  String toString() {
    return 'EisUser{uid: $uid, timeCreated: $timeCreated}';
  }
}
