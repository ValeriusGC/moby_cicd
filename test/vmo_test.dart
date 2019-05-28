import 'package:mobynote/NoteModel.dart';
import 'package:mobynote/app_session.dart';
import 'package:mobynote/model/jsonable.dart';
import 'package:mobynote/model/undo_note_model.dart';
import 'package:test/test.dart';
import 'package:mobynote/model/vmo.dart';
import 'test_data/stack_data.dart';
import 'test_data/test_entity.dart';
import 'dart:convert';
import 'dart:collection';

//enum SortDir {ASC, DESC,}
//
//abstract class SortBy{
//  final SortDir dir;
//  const SortBy(this.dir);
//
//  @override
//  String toString() {
//    return 'Sort{dir: $dir}';
//  }
//}
//class SortByStr extends SortBy{
//  const SortByStr(SortDir dir) : super(dir);
//}
//class SortByCreating extends SortBy{
//  const SortByCreating(SortDir dir) : super(dir);
//}
//class SortByEditing extends SortBy{
//  const SortByEditing(SortDir dir) : super(dir);
//}
//
//class SortOpts {
//
//  final SortByStr byStr;
//  final SortByCreating byCreating;
//  final SortByEditing byEditing;
//
//  SortOpts({SortByStr byStr, SortByCreating byCreating, SortByEditing byEditing}) :
//        byStr = byStr ?? SortByStr(SortDir.ASC),
//        byCreating = byCreating ?? SortByCreating(SortDir.ASC),
//        byEditing = byEditing ?? SortByEditing(SortDir.ASC);
//
//  SortOpts copyWith({SortByStr byStr, SortByCreating byCreating, SortByEditing byEditing}) {
//    return SortOpts(
//      byStr: byStr ?? this.byStr,
//      byCreating: byCreating ?? this.byCreating,
//      byEditing: byEditing ?? this.byEditing,
//    );
//  }
//
//  @override
//  String toString() {
//    return 'SortOpts{byStr: $byStr, byCreating: $byCreating, byEditing: $byEditing}';
//  }
//
//}
//
//class SearchOpt {
//  final String value;
//  SearchOpt({String value}) : value = value ?? '';
//}
//
//class VisualMappingOpts {
//  final SearchOpt searchBy;
//  final SortOpts sortBy;
//
//  VisualMappingOpts({SearchOpt searchBy, SortOpts sortBy}) :
//      searchBy = searchBy ?? SearchOpt(),
//      sortBy = sortBy ?? SortOpts();
//
//  VisualMappingOpts copyWith({SearchOpt searchBy, SortOpts sortBy}) {
//    return VisualMappingOpts(
//      searchBy: searchBy ?? this.searchBy,
//      sortBy: sortBy ?? this.sortBy,
//    );
//  }
//}

void main() {

  ///
  test('SortOpts: CTRs', () {

    var so = SortOpts();
    expect(so.byStr.dir, SortDir.ASC);
    expect(so.byCreating.dir, SortDir.ASC);
    expect(so.byEditing.dir, SortDir.ASC);

    so = SortOpts(byStr: SortByStr(SortDir.DESC));
    expect(so.byStr.dir, SortDir.DESC);
    expect(so.byCreating.dir, SortDir.ASC);
    expect(so.byEditing.dir, SortDir.ASC);

    so = SortOpts(byCreating: SortByCreating(SortDir.DESC));
    expect(so.byStr.dir, SortDir.ASC);
    expect(so.byCreating.dir, SortDir.DESC);
    expect(so.byEditing.dir, SortDir.ASC);

    so = SortOpts(byEditing: SortByEditing(SortDir.DESC));
    expect(so.byStr.dir, SortDir.ASC);
    expect(so.byCreating.dir, SortDir.ASC);
    expect(so.byEditing.dir, SortDir.DESC);


  });

  test('SortOpts: copyWith', () {

    var so = SortOpts();
    var so1 = so.copyWith(byStr: SortByStr(SortDir.DESC));
    expect(so1.byStr.dir, SortDir.DESC);
    expect(so1.byCreating.dir, SortDir.ASC);
    expect(so1.byEditing.dir, SortDir.ASC);
    so1 = so1.copyWith(byCreating: SortByCreating(SortDir.DESC));
    expect(so1.byStr.dir, SortDir.DESC);
    expect(so1.byCreating.dir, SortDir.DESC);
    expect(so1.byEditing.dir, SortDir.ASC);
    so1 = so1.copyWith(byEditing: SortByEditing(SortDir.DESC));
    expect(so1.byStr.dir, SortDir.DESC);
    expect(so1.byCreating.dir, SortDir.DESC);
    expect(so1.byEditing.dir, SortDir.DESC);

    var so2 = so1.copyWith(byStr: SortByStr(SortDir.ASC));
    expect(so2.byStr.dir, SortDir.ASC);
    expect(so2.byCreating.dir, SortDir.DESC);
    expect(so2.byEditing.dir, SortDir.DESC);

  });

  test('new VMO: CTRS', () {
    var vmo = VisualMappingOpts();
    expect(vmo.searchBy.value, '');

    vmo = VisualMappingOpts(searchBy: SearchOpt(value: 'str'));
    expect(vmo.searchBy.value, 'str');

  });

  test('new VMO: copy', () {
    var vmo = VisualMappingOpts(
        searchBy: SearchOpt(value: 'str'));
    expect(vmo.searchBy.value, 'str');

    var vmo2 = vmo.copyWith();
    expect(vmo2.searchBy.value, 'str');

    var vmo3 = vmo2.copyWith(searchBy: SearchOpt(value: 'newstr'));
    expect(vmo3.searchBy.value, 'newstr');

    var vmo4 = VisualMappingOpts();
    expect(vmo4.searchBy.value, '');
  });

  test('VMO jsonable', () {
    {
      // default values
      final vmo = VisualMappingOptions.mk();
      expect(vmo.searchStr, '');
      expect(vmo.sortType, SortType.ASC);
      final json = jsonEncode(vmo.toJson());
      print('Mobynote.test.VMO.main: json=$json');
      final vmoBack = VisualMappingOptions.fromJson(jsonDecode(json));
      expect(vmoBack, vmo);
    }

    {
      // non default values
      final vmo =
          VisualMappingOptions.mk().copyWith(sortType: SortType.DESC).copyWith(searchStr: 'TEST');
      expect(vmo.searchStr, 'TEST');
      expect(vmo.sortType, SortType.DESC);
      final json = jsonEncode(vmo.toJson());
      print('Mobynote.test.VMO.main: json=$json');
      final vmoBack = VisualMappingOptions.fromJson(jsonDecode(json));
      expect(vmoBack, vmo);
    }
  });

  test('VMO JSON external', (){
    {
      // default
      final vmo = VisualMappingOpts();
      final map = VmoLocalJsonMapper().toMap(vmo);
      print('main map: $map');
      final json = jsonEncode(map);
      print('main json: $json');
      final vmoBack = VmoLocalJsonMapper().fromJson(json).data;
      print('main vmoBack: $vmoBack');
      final vmoBack2 = VmoLocalJsonMapper().fromMap(map).data;
      print('main vmoBack2: $vmoBack2');
      expect(vmo, vmoBack);
      expect(vmo, vmoBack2);
    }
    print('-------------------------------');
    {
      // parameters 1
      final vmo = VisualMappingOpts(
          searchBy: SearchOpt(value: 'searching'),
      );
      final map = VmoLocalJsonMapper().toMap(vmo);
      print('main map: $map');
      final json = jsonEncode(map);
      print('main json: $json');
      final vmoBack = VmoLocalJsonMapper().fromJson(json).data;
      print('main vmoBack: $vmoBack');
      final vmoBack2 = VmoLocalJsonMapper().fromMap(map).data;
      print('main vmoBack2: $vmoBack2');
      expect(vmo, vmoBack);
      expect(vmo, vmoBack2);
    }
    print('-------------------------------');
    {
      // parameters 2
      final vmo = VisualMappingOpts(
          searchBy: SearchOpt(value: 'searching'),
          sortByStr: SortByStr(SortDir.ASC),
          sortByCreating: SortByCreating(SortDir.DESC),
          sortByEditing: SortByEditing(SortDir.ASC),
          currentSort: SortByStr(SortDir.ASC),
          showRecycled: ShowRecycled.BOTH,
      );
      final map = VmoLocalJsonMapper().toMap(vmo);
      print('main map: $map');
      final json = jsonEncode(map);
      print('main json: $json');
      final vmoBack = VmoLocalJsonMapper().fromJson(json).data;
      print('main vmoBack: $vmoBack');
      final vmoBack2 = VmoLocalJsonMapper().fromMap(map).data;
      print('main vmoBack2: $vmoBack2');
      expect(vmo, vmoBack);
      expect(vmo, vmoBack2);
    }
  });
}
