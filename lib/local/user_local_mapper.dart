import 'package:mobynote/user.dart';
import 'package:mobynote/utils/json_mapper.dart';
import 'package:mobynote/utils/result.dart';

/// v.1.0+
class EisUserLocalJsonMapper extends JsonMapper<EisUser> {
  static const KEY_UID = "label";
  static const KEY_TS = "timestamp";

  @override
  Map<String, dynamic> toMap(EisUser obj) {
    return {
      KEY_UID: obj.uid,
      KEY_TS: obj.timeCreated,
    };
  }

  @override
  Result<EisUser> fromMap(Map<String, dynamic> map) {
//    print("EisUserLocalJsonMapper.fromMap: $map");
    try {
      final uid = map[KEY_UID] ?? Exception;
      final ts = map[KEY_TS] ?? Exception;
      return Result.success(EisUser.mk(uid: uid, timeCreated: ts));
    } catch (e) {
      return Result.error(Exception(e));
    }
  }
}
