import 'package:collection/collection.dart';
import 'package:mobynote/model/jsonable.dart';

/// to avoid mistyping we protect attributes from direct changing
/// For every attrs we do:
/// - static accessor key (KEY_XXX)
/// - getter
/// - setter
/// - checker `existsXXX` (ex. flags)
/// - remover `removeXXX` (ex. flags)
class Attrs with Jsonable {

  /// marker for absent attribute
  static const dynamic NOT_ASSIGNED = null;

  static const String _TYPE = 'Attrs';

  /// accessor key for [title]
  static const String KEY_TITLE = 'ttl';

  /// accessor key for [textCursorPos]
  static const String KEY_TEXT_CURSOR_POS = 'tcp';

  /// accessor key for flags
  static const String KEY_FLAGS = 'f';

  final Map<String, dynamic> _items = {
    // Flags always exist
    KEY_FLAGS : 0,
  };

  /// getter for all flags
  /// flags can not be NO_ATTR
  int get flags => _exists(KEY_FLAGS) ? _get(KEY_FLAGS) : 0;

  set flags(int value) => _set(KEY_FLAGS, value);

  /// getter for [recycledFlag]
  /// As [flags] always exists we can return [bool]
  bool get recycledFlag => _isFlag(FlagKeys.RECYCLED);

  /// setter for [recycledFlag]
  set recycledFlag(bool value) => _setFlag(FlagKeys.RECYCLED, value);

  /// getter for [title]
  /// As [title] can be missed we can not return [String] but dynamic
  String get title => _get(KEY_TITLE) as String;

  /// setter for [title]
  set title(String value) => _set(KEY_TITLE, value);

  /// exister for [title]
  bool existsTitle() => _exists(KEY_TITLE);

  /// remover for [title]
  void removeTitle() => _remove(KEY_TITLE);

  /// getter for [textCursorPos]
  /// As [textCursorPos] can be missed we can not return [int] but dynamic
  int get textCursorPos => _get(KEY_TEXT_CURSOR_POS) as int;

  /// setter for [textCursorPos]
  set textCursorPos(int value) => _set(KEY_TEXT_CURSOR_POS, value);

  /// exister for [textCursorPos]
  bool existsCursorPos() => _exists(KEY_TEXT_CURSOR_POS);

  /// remover for [textCursorPos]
  void removeCursorPos() => _remove(KEY_TEXT_CURSOR_POS);

  //
  // Common methods

  void clear() {
    _items.clear();
    // ! always add required ones attributes
    _items[KEY_FLAGS] = 0;
  }

  int count() => _items.length;

  @override
  Map<String, dynamic> toJson() {
    final m = super.toJson();
    m[KEY_TITLE] = _get(KEY_TITLE);
    m[KEY_TEXT_CURSOR_POS] = _get(KEY_TEXT_CURSOR_POS);
    m[KEY_FLAGS] = _get(KEY_FLAGS);
    return m;
  }

  static Attrs fromJson(Map<String, dynamic> map) {
    if (map[Jsonable.KEY_TYPE] == _TYPE) {
      var attrs = Attrs();
      attrs.title = map[KEY_TITLE];
      attrs.flags = map[KEY_FLAGS];
      attrs.textCursorPos = map[KEY_TEXT_CURSOR_POS];
      return attrs;
    } else
      return null;
  }

  dynamic _get(String key) => _items.containsKey(key) ? _items[key] : NOT_ASSIGNED;

  void _set(String key, dynamic value) => _items[key] = value;

  bool _exists(String key) => _items.containsKey(key);

  void _remove(String key) => _items.remove(key);

  void _setFlag(FlagKeys key, bool value) {
    int flags = _exists(Attrs.KEY_FLAGS) ? _get(Attrs.KEY_FLAGS) : 0;
    flags = value ? flags | FLAG_MAP[key] : (flags & ~FLAG_MAP[key]);
    _set(Attrs.KEY_FLAGS, flags);
  }

  bool _isFlag(FlagKeys key) {
    final flags = _exists(Attrs.KEY_FLAGS) ? _get(Attrs.KEY_FLAGS) : 0;
    return flags & FLAG_MAP[key] == FLAG_MAP[key];
  }

  // ~

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Attrs &&
              runtimeType == other.runtimeType &&
              MapEquality().equals(_items, other._items);


  @override
  int get hashCode => _items.hashCode;

  @override
  String toString() {
    return 'Attrs{_items: $_items}';
  }

}

enum FlagKeys {
  RECYCLED,
  REZERV_01,
  REZERV_02,
}

final FLAG_MAP = {
  FlagKeys.RECYCLED: 1 << FlagKeys.RECYCLED.index,
  FlagKeys.REZERV_01: 1 << FlagKeys.REZERV_01.index,
  FlagKeys.REZERV_02: 1 << FlagKeys.REZERV_02.index,
};

/// Safe casting [value] to required type [T].
T castTo<T>(dynamic value, T defaultValue) => value is T ? value : defaultValue;
