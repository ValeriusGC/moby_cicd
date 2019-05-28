import 'package:mobynote/NoteModel.dart';
import 'package:mobynote/app_session.dart';
import 'package:mobynote/model/jsonable.dart';
import 'package:mobynote/model/traceable.dart';
import 'package:mobynote/model/undo_note_model.dart';
import 'package:test/test.dart';
import 'test_data/stack_data.dart';
import 'test_data/test_entity.dart';
import 'dart:convert';

class Spec extends Traceable {
  static const String _TYPE = 'Spec';
  static const String KEY_KEY = 'k';
  static const String KEY_VAL = 'v';

  final String key;
  final String value;

  Spec({String key, String value, String suid, int timestamp, Version version})
      :  key = key, value = value, super(suid, timestamp, version);

  static Spec fromJson(Map<String, dynamic> map) {
    return Spec.fromMap(map);
  }

  Spec.fromMap(Map<String, dynamic> map) :
        key = map[KEY_KEY] ?? '',
        value = map[KEY_VAL] ?? '',
        super.fromMap(map);

  Spec copyWith({String key, String value, String suid, int timestamp, Version version}) {
    return Spec(
      key: key ?? this.key,
      value: value ?? this.value,
      suid: suid ?? this.suid,
      timestamp: timestamp ?? this.timestamp,
      version: version ?? this.version,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final map = super.toJson();
    map[KEY_KEY] = key;
    map[KEY_VAL] = value;
    return map;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Spec &&
              runtimeType == other.runtimeType &&
              key == other.key &&
              value == other.value;

  @override
  int get hashCode =>
      key.hashCode ^
      value.hashCode;

}

void main() {
  test('Traceable', () {

    {
      // non default values
      final ver = Version.mk();
      final spec =  Spec(suid: 'suid', timestamp: 10, version: ver, key: 'key', value: 'value');
      expect(spec.key, 'key');
      expect(spec.value, 'value');
      expect(spec.suid, 'suid');
      expect(spec.timestamp, 10);
      expect(spec.version, ver);

      final json = jsonEncode(spec.toJson());
      print('Mobynote.Test.main: json = $json');

      final specBack = Spec.fromJson(jsonDecode(json));
      expect(specBack, spec);

      expect(specBack.copyWith(suid: 'new_suid').suid, 'new_suid');
      expect(specBack.copyWith(timestamp: 200).timestamp, 200);
      expect(specBack.copyWith(version: Version.mk(ord: 2, ts: 222)).version.ord, 2);
      expect(specBack.copyWith(version: Version.mk(ord: 2, ts: 222)).version.ts, 222);
      expect(specBack.copyWith(key: 'new_key').key, 'new_key');
      expect(specBack.copyWith(value: 'new_value').value, 'new_value');

    }
  });
}
