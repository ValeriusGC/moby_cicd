import 'package:mobynote/const.dart';
import 'package:test/test.dart';

/// Convert T to Type
Type _typeOf<T>() => T;

//1. надо самому понять, как правильно описать потребность в каждом поле и конструкторе базового класса.
//2. Кроме того, есть версия типа домена (структура) и версия информации (история изменения объекта).
//3. Видимо DOMAIN_VER и INFO_VER


abstract class VersionedJsonable {

  /// Key for saving type.
  static const String KEY_TYPE = '@@tp';

  /// Key for saving domain version.
  static const String KEY_DOM_VERSION = '@@dv';

  //------------------------------------------------------------------------------------------------
  // CTRs

  /// Simple constructor for standard descendants' ctrs.
  VersionedJsonable();

  /// Ctr for create from map.
  /// [substDomVersionForTest] just for test sake. Don't use it at all. In test it substitutes
  ///   current [App.DOM_VERSION] to emulate some specific behaviour.
  ///
  /// Algo:
  VersionedJsonable.fromMap(Map<String, dynamic> map) {
    // Protect `map` parameter from nullable
    final _map = map ?? {
      KEY_DOM_VERSION: App.DOM_VERSION,
      KEY_TYPE: '',
    };
    final savedVer = _map[KEY_DOM_VERSION] == null || !(_map[KEY_DOM_VERSION] is int)
        ? App.DOM_VERSION
        : _map[KEY_DOM_VERSION];
    if (savedVer < App.DOM_VERSION) {
      migrate(_map);
    } else {
      init(_map);
    }
  }

  // ~CTRs
  //------------------------------------------------------------------------------------------------

  /// Checks that [map] is not null and keeps appropriate type inside;
  static bool mapHasTypeOf<T extends VersionedJsonable>(Map<String, dynamic> map,
      [String manualType]) {
    return map != null &&
        map[KEY_TYPE] != null &&
        map[KEY_TYPE] == (manualType ?? _typeOf<T>().toString());
  }

  /// [manualType] for case in possible duplicate type names.
  /// [substDomVersionForTest] just for test sake. Don't use it at all. In test it substitutes
  ///   current [App.DOM_VERSION] to emulate some specific behaviour.
  Map<String, dynamic> toMap({String manualType}) => {
        KEY_TYPE: manualType ?? runtimeType.toString(),
        KEY_DOM_VERSION: App.DOM_VERSION,
      };

  /// Calls automatically from [.fromMap] when need to migrate
  /// map already checked to nonnullable!
  void migrate(Map<String, dynamic> map);

  /// Calls automatically from [.fromMap] when no need to migrate
  void init(Map<String, dynamic> map);

}

/// Class for test sake
class JsonableTest extends VersionedJsonable {

  /// JSON keys
  static const String KEY_VALUE = 'v';

  final String value;

  // fields below are for testing [migrate] and [init]

  var migrateOrInit;
  var migrateFrom = App.DOM_VERSION;
  var migrateTo = App.DOM_VERSION;

  // CTRs

  JsonableTest.mk(this.value);

  /// With bad map we can get no instance at all, so it would be correct check it first.
  factory JsonableTest.fromMap(Map<String, dynamic> map, {String manualType, }) {
    if (VersionedJsonable.mapHasTypeOf<JsonableTest>(map, manualType)) {
      final _map = map ?? {VersionedJsonable.KEY_TYPE: _typeOf<JsonableTest>().toString()};
      return JsonableTest._fromMap(_map,);
    }
    return null;
  }


  @override
  Map<String, dynamic> toMap({String manualType}) {
    // mandatory call to super method!
    final map = super.toMap(manualType: manualType);
    map[KEY_VALUE] = value;
    return map;
  }

  // ~CTRs

  @override
  void init(Map<String, dynamic> map) {
    migrateOrInit = 'init';
  }

  @override
  void migrate(Map<String, dynamic> map) {
    migrateOrInit = 'migrate';
    migrateFrom = map[VersionedJsonable.KEY_DOM_VERSION] ?? App.DOM_VERSION;
    migrateTo = App.DOM_VERSION;
  }

  // private

  /// final fields initiated here, and some operation can be made in [init]
  JsonableTest._fromMap(Map<String, dynamic> map, {int substDomVersionForTest})
      : value = map[JsonableTest.KEY_VALUE],
        super.fromMap(map);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is JsonableTest &&
              runtimeType == other.runtimeType &&
              value == other.value;

  @override
  int get hashCode => value.hashCode;

  //


}

abstract class StubClass extends VersionedJsonable{}

// Start tests
void main() {

  // If no or bad type in map - return false
  test('VJsonable.mapHasTypeOf', () {

    {
      // null map
      expect(VersionedJsonable.mapHasTypeOf<JsonableTest>(null), isFalse);
      // empty map
      expect(VersionedJsonable.mapHasTypeOf<JsonableTest>({}), isFalse);
      // wrong map
      final wrongMap = {VersionedJsonable.KEY_TYPE: _typeOf<StubClass>().toString()};
      expect(VersionedJsonable.mapHasTypeOf<StubClass>(wrongMap), isTrue);
      expect(VersionedJsonable.mapHasTypeOf<JsonableTest>(wrongMap), isFalse);
      // correct map
      final correctMap = {VersionedJsonable.KEY_TYPE: _typeOf<JsonableTest>().toString()};
      expect(VersionedJsonable.mapHasTypeOf<JsonableTest>(correctMap), isTrue);
    }

  });

  // If no map or map with bad type was passed - null
  test('VJsonable.fromMap', () {
    {
      // no map
      final jt = JsonableTest.fromMap(null);
      expect(jt, isNull);
    }
    {
      // empty map
      final jt = JsonableTest.fromMap({});
      expect(jt, isNull);
    }
    {
      // map with wrong type
      final jt = JsonableTest.fromMap({VersionedJsonable.KEY_TYPE: _typeOf<StubClass>().toString()});
      expect(jt, isNull);
    }
    {
      // map with correct type
      final jt = JsonableTest.fromMap({VersionedJsonable.KEY_TYPE: _typeOf<JsonableTest>().toString()});
      expect(jt, isNotNull);
      expect(jt.value, null);
    }
    {
      // map with correct type and values
      final jt = JsonableTest.fromMap({
        VersionedJsonable.KEY_TYPE: _typeOf<JsonableTest>().toString(),
        JsonableTest.KEY_VALUE: 'some_value',
      });
      expect(jt, isNotNull);
      expect(jt.value, 'some_value');
    }
    {
      // map with lower version goes to migration (check migrate.print!)
      final jt = JsonableTest.fromMap({
        VersionedJsonable.KEY_TYPE: _typeOf<JsonableTest>().toString(),
        VersionedJsonable.KEY_DOM_VERSION: 1,
        JsonableTest.KEY_VALUE: 'some_value',
      });
      expect(jt, isNotNull);
    }
    {
      // map with the same or higher version goes to init (check init.print!)
      final jt = JsonableTest.fromMap({
        VersionedJsonable.KEY_TYPE: _typeOf<JsonableTest>().toString(),
        VersionedJsonable.KEY_DOM_VERSION: App.DOM_VERSION,
        JsonableTest.KEY_VALUE: 'some_value',
      });
      expect(jt, isNotNull);
    }
    {
      // map with bad version goes to init (check init.print!)
      final jt = JsonableTest.fromMap({
        VersionedJsonable.KEY_TYPE: _typeOf<JsonableTest>().toString(),
        VersionedJsonable.KEY_DOM_VERSION: 'BAD',
        JsonableTest.KEY_VALUE: 'some_value',
      });
      expect(jt, isNotNull);
    }

  });

  // tests toMap makes good Map
  test('VJsonable.toMap', () {

    {
      const value = 'my value';
      final jt = JsonableTest.mk(value);
      final map = jt.toMap();
      // base fields wrote down and are correct
      expect(map.containsKey(VersionedJsonable.KEY_TYPE), isTrue);
      expect(map.containsKey(VersionedJsonable.KEY_DOM_VERSION), isTrue);
      expect(map[VersionedJsonable.KEY_TYPE], jt.runtimeType.toString());
      expect(map[VersionedJsonable.KEY_DOM_VERSION], App.DOM_VERSION);
      // type fields wrote down and are correct
      expect(map.containsKey(JsonableTest.KEY_VALUE), isTrue);
      expect(map[JsonableTest.KEY_VALUE], value);
    }

    {
      const value = 'my value';
      final jt = JsonableTest.mk(value);
      final map = jt.toMap();
      final jtBack = JsonableTest.fromMap(map);
      expect(jtBack, jt);

    }
  });

  ///
  test('VJsonable.migrate', () {
    final jt = JsonableTest.fromMap({
      VersionedJsonable.KEY_TYPE: _typeOf<JsonableTest>().toString(),
      VersionedJsonable.KEY_DOM_VERSION: 1,
    });
    expect(jt.migrateOrInit, 'migrate');
    expect(jt.migrateFrom, 1);
    expect(jt.migrateTo, App.DOM_VERSION);
  });

  test('VJsonable.init', () {
    final jt = JsonableTest.fromMap({
      VersionedJsonable.KEY_TYPE: _typeOf<JsonableTest>().toString(),
    });
    expect(jt.migrateOrInit, 'init');
  });

}
