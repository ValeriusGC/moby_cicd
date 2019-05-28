import 'package:meta/meta.dart';
import 'package:mobynote/model/jsonable.dart';
import 'package:mobynote/user.dart';

enum AppState { UNDEFINED, START, INIT, OK, ERROR }

enum SortType {ASC, DESC, DEF, SET}

// 19/04/10 todo rename to RetrieveOptons
@immutable
class VisualMappingOptions with Jsonable{

  static const String _TYPE = 'VisualMappingOptions';
  static const String KEY_SORT_TYPE = 'st';
  static const String KEY_SEARCH_STR = 'ss';

  final SortType sortType;
  final String searchStr;

  VisualMappingOptions._(this.sortType, this.searchStr);

  factory VisualMappingOptions.mk({SortType sortType, String searchStr}) {
    return VisualMappingOptions._(
      sortType != null ? sortType : SortType.ASC,
      searchStr != null ? searchStr : "",
    );
  }

  VisualMappingOptions copyWith({SortType sortType, String searchStr}) {
    return VisualMappingOptions._(
      sortType != null ? sortType : this.sortType,
      searchStr != null ? searchStr : this.searchStr,
    );
  }


  @override
  Map<String, dynamic> toJson() {
    final m = super.toJson();
    m[KEY_SORT_TYPE] = sortType.index;
    m[KEY_SEARCH_STR] = searchStr;
    return m;
  }

  static VisualMappingOptions fromJson(Map<String, dynamic> map) {
    if (map[Jsonable.KEY_TYPE] == _TYPE) {
      return VisualMappingOptions._(SortType.values[map[KEY_SORT_TYPE]], map[KEY_SEARCH_STR]);
    } else
      return null;
  }


  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is VisualMappingOptions &&
              runtimeType == other.runtimeType &&
              sortType == other.sortType &&
              searchStr == other.searchStr;

  @override
  int get hashCode =>
      sortType.hashCode ^
      searchStr.hashCode;

  @override
  String toString() {
    return 'VMO{sortType: $sortType, searchStr: $searchStr}';
  }


}

@immutable
class AppSession {
  final EisUser currentUser;
  final EisUser candidateUser;
  final AppState state;
  final String msg;
  final int startTime;

//  var sm = VisualMappingOptions.mk(searchStr: '');

  factory AppSession.mk(
      {EisUser currentUser,
      EisUser candidateUser,
      AppState state,
      String msg,
      int startTime}) {
    return AppSession._(
        currentUser: currentUser,
        candidateUser: candidateUser,
        state: state,
        msg: msg,
        startTime: startTime);
  }

  factory AppSession.empty() {
    return AppSession._(
        currentUser: null,
        candidateUser: null,
        state: AppState.UNDEFINED,
        msg: "",
        startTime: null);
  }

  AppSession copyWith(
      {EisUser currentUser,
      EisUser candidateUser,
      AppState state,
      String msg,
      int startTime}) {
    return AppSession._(
        currentUser: currentUser != null ? currentUser : this.currentUser,
        candidateUser:
            candidateUser != null ? candidateUser : this.candidateUser,
        state: state != null ? state : this.state,
        msg: msg != null ? msg : this.msg,
        startTime: startTime != null ? startTime : this.startTime);
  }

  AppSession._(
      {this.currentUser, this.candidateUser, this.state, this.msg, this.startTime});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppSession &&
          runtimeType == other.runtimeType &&
          currentUser == other.currentUser &&
          candidateUser == other.candidateUser &&
          state == other.state &&
          msg == other.msg &&
          startTime == other.startTime;

  @override
  int get hashCode =>
      currentUser.hashCode ^
      candidateUser.hashCode ^
      state.hashCode ^
      msg.hashCode ^
      startTime.hashCode;

  @override
  String toString() {
    return 'AppSession{currentUser: $currentUser, candidateUser: $candidateUser, state: $state, startTime: $startTime}';
  }
}
