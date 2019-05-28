import 'package:mobynote/utils/json_mapper.dart';
import 'package:mobynote/utils/result.dart';

enum SortDir {
//  NONE, - awhile we make only ASC/DESC for one parameter at a time
  ASC,
  DESC,
}

enum ShowRecycled {
  ONLY_LIVE,
  ONLY_RECYCLED,
  BOTH,
}

abstract class SortBy {
  final SortDir dir;

  const SortBy(this.dir);


  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is SortBy &&
              runtimeType == other.runtimeType &&
              dir == other.dir;

  @override
  int get hashCode => dir.hashCode;

  @override
  String toString() {
    return 'Sort{type: $runtimeType, dir: $dir}';
  }
}

class SortByStr extends SortBy {
  const SortByStr(SortDir dir) : super(dir);
}

class SortByCreating extends SortBy {
  const SortByCreating(SortDir dir) : super(dir);
}

class SortByEditing extends SortBy {
  const SortByEditing(SortDir dir) : super(dir);
}

class SortOpts {
  final SortByStr byStr;
  final SortByCreating byCreating;
  final SortByEditing byEditing;

  SortOpts({SortByStr byStr, SortByCreating byCreating, SortByEditing byEditing})
      : byStr = byStr ?? SortByStr(SortDir.ASC),
        byCreating = byCreating ?? SortByCreating(SortDir.ASC),
        byEditing = byEditing ?? SortByEditing(SortDir.ASC);

  SortOpts copyWith({SortByStr byStr, SortByCreating byCreating, SortByEditing byEditing}) {
    return SortOpts(
      byStr: byStr ?? this.byStr,
      byCreating: byCreating ?? this.byCreating,
      byEditing: byEditing ?? this.byEditing,
    );
  }

  @override
  String toString() {
    return 'SortOpts{byStr: $byStr, byCreating: $byCreating, byEditing: $byEditing}';
  }
}

class SearchOpt {
  final String value;

  SearchOpt({String value}) : value = value ?? '';


  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is SearchOpt &&
              runtimeType == other.runtimeType &&
              value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() {
    return 'SearchOpt{value: $value}';
  }

}

class VisualMappingOpts {
  final SearchOpt searchBy;
  final SortByStr sortByStr;
  final SortByCreating sortByCreating;
  final SortByEditing sortByEditing;
  final ShowRecycled showRecycled;

  SortBy _sortBy;

  SortBy get sortBy => _sortBy;

  set sortBy(SortBy value) {
    _sortBy = value;
  }

  VisualMappingOpts({SearchOpt searchBy,
    SortByStr sortByStr,
    SortByCreating sortByCreating,
    SortByEditing sortByEditing,
    SortBy currentSort,
    ShowRecycled showRecycled,
  })
      : searchBy = searchBy ?? SearchOpt(),
        sortByStr = sortByStr ?? SortByStr(SortDir.ASC),
        sortByCreating = sortByCreating ?? SortByCreating(SortDir.DESC),
        sortByEditing = sortByEditing ?? SortByEditing(SortDir.DESC),
        showRecycled = showRecycled ?? ShowRecycled.ONLY_LIVE
  {
    _sortBy = currentSort ?? this.sortByEditing;
  }

  VisualMappingOpts copyWith(
      { SearchOpt searchBy,
        SortByStr sortByStr,
        SortByCreating sortByCreating,
        SortByEditing sortByEditing,
        SortBy currentSort,
        ShowRecycled showRecycled,
      }) {
    return VisualMappingOpts(
      searchBy: searchBy ?? this.searchBy,
      sortByStr: sortByStr ?? this.sortByStr,
      sortByCreating: sortByCreating ?? this.sortByCreating,
      sortByEditing: sortByEditing ?? this.sortByEditing,
      currentSort: currentSort ?? this.sortBy,
      showRecycled: showRecycled?? this.showRecycled,
    );
  }


  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is VisualMappingOpts &&
              runtimeType == other.runtimeType &&
              searchBy == other.searchBy &&
              sortByStr == other.sortByStr &&
              sortByCreating == other.sortByCreating &&
              sortByEditing == other.sortByEditing &&
              showRecycled == other.showRecycled &&
              _sortBy == other._sortBy;

  @override
  int get hashCode =>
      searchBy.hashCode ^
      sortByStr.hashCode ^
      sortByCreating.hashCode ^
      sortByEditing.hashCode ^
      showRecycled.hashCode ^
      _sortBy.hashCode;

  @override
  String toString() {
    return 'VisualMappingOpts{searchBy: $searchBy, _sortBy: $_sortBy, recycled: $showRecycled}';
  }


}

/// Converter SortBy <--> Json
class SortByJsonMapper extends JsonMapper<SortBy> {

  static const KEY_TYPE = "@@t";
  static const KEY_DIR = "dir";
  static const _DIR_ASC = "asc";
  static const _DIR_DESC = "desc";

  @override
  Result<SortBy> fromMap(Map<String, dynamic> map) {
    if(map == null) {
      return Result.error(Exception('map is null'));
    }
    String dirStr = map[KEY_DIR] ?? _DIR_ASC;
    SortDir dir;
    switch(dirStr) {
      case _DIR_DESC:
        dir = SortDir.DESC;
        break;
      default:
        dir = SortDir.ASC;
    }
    SortBy sortBy;
    String typeStr = map[KEY_TYPE] ??  type<SortByStr>().toString();
    if(typeStr == type<SortByStr>().toString()){
      sortBy = SortByStr(dir);
    }else if(typeStr == type<SortByCreating>().toString()){
      sortBy = SortByCreating(dir);
    }else if(typeStr == type<SortByEditing>().toString()){
      sortBy = SortByEditing(dir);
    }else{
      sortBy = SortByStr(dir);
    }

    return Result.success(sortBy);
  }

  @override
  Map<String, dynamic> toMap(SortBy obj) {
    return {
      KEY_TYPE: obj.runtimeType.toString(),
      KEY_DIR: obj.dir == SortDir.ASC ? _DIR_ASC : _DIR_DESC,
    };
  }

}

/// Converter VisualMappingOpts <--> Json
class VmoLocalJsonMapper extends JsonMapper<VisualMappingOpts> {

  static const KEY_SEARCH_STR = "srch_str";
  static const KEY_CURRENT_SORT_BY = "curr_sort_by";
  static const KEY_SORT_BY_STR = "sort_by_str";
  static const KEY_SORT_BY_CRE = "sort_by_cre";
  static const KEY_SORT_BY_ED = "sort_by_ed";
  static const KEY_SHOW_RECYCLED = "show_recycled";


  @override
  Result<VisualMappingOpts> fromMap(Map<String, dynamic> map) {
    try {
      final searchOpt = SearchOpt(value: map[KEY_SEARCH_STR]);

      final sortByString = SortByJsonMapper().fromMap(map[KEY_SORT_BY_STR]).data as SortByStr;
      final sortByCreation = SortByJsonMapper().fromMap(map[KEY_SORT_BY_CRE]).data as SortByCreating;
      final sortByEditing = SortByJsonMapper().fromMap(map[KEY_SORT_BY_ED]).data as SortByEditing;
      final currentSortBy = SortByJsonMapper().fromMap(map[KEY_CURRENT_SORT_BY]).data;
      final showRecycledAsInt = map[KEY_SHOW_RECYCLED] as int ?? ShowRecycled.ONLY_LIVE.index;
      final showRecycled = showRecycledAsInt == ShowRecycled.BOTH.index
          ? ShowRecycled.BOTH
          : showRecycledAsInt == ShowRecycled.ONLY_RECYCLED.index
          ? ShowRecycled.ONLY_RECYCLED : ShowRecycled.ONLY_LIVE;


      final vmo = VisualMappingOpts(
        searchBy: searchOpt,
        currentSort: currentSortBy,
        sortByStr: sortByString,
        sortByCreating: sortByCreation,
        sortByEditing: sortByEditing,
        showRecycled: showRecycled,
      );
      return Result.success(vmo);
    }catch(e){
      return Result.error(e);
    }
  }

  @override
  Map<String, dynamic> toMap(VisualMappingOpts vmo) {
    final search = vmo.searchBy.value ?? '';
//    final sortBy = vmo.sortBy is SortByStr ? _SORTBY_STR
//        : vmo.sortBy is SortByCreating ? _SORTBY_CRE
//        : _SORTBY_ED;
//    final dir = vmo.sortBy.dir == SortDir.ASC ? _DIR_ASC : _DIR_DESC;
    final currentSortBy = SortByJsonMapper().toMap(vmo.sortBy);
    final sortByStr = SortByJsonMapper().toMap(vmo.sortByStr);
    final sortByCre = SortByJsonMapper().toMap(vmo.sortByCreating);
    final sortByEd = SortByJsonMapper().toMap(vmo.sortByEditing);
    return {
      KEY_SEARCH_STR: search,
      KEY_CURRENT_SORT_BY: currentSortBy,
      KEY_SORT_BY_STR: sortByStr,
      KEY_SORT_BY_CRE: sortByCre,
      KEY_SORT_BY_ED: sortByEd,
      KEY_SHOW_RECYCLED: vmo.showRecycled.index,
    };
  }

}

/// This factory should return [VisualMappingOpts] object by parameter of type [SortDir]
typedef VmoFactory = VisualMappingOpts Function(SortDir);
