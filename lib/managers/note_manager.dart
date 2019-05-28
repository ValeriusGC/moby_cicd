import 'package:mobynote/Database.dart';
import 'package:mobynote/NoteModel.dart';
import 'package:mobynote/app_session.dart';
import 'package:mobynote/managers/home_screen_manager.dart';
import 'package:mobynote/service_locator.dart';
import 'package:mobynote/utils/result.dart';
import 'package:rx_command/rx_command.dart';
import 'package:mobynote/model/vmo.dart';

class NoteManager {
  ///
  RxCommand<Note, Note> updateNote;
  RxCommand<Note, Note> addNote;
  RxCommand<FlagAndNote, List<Note>> recycleNote;
  final showRecycledCmd = RxCommand.createSync<ShowRecycled, ShowRecycled>((s) => s);
  final searchByCmd = RxCommand.createSync<String, String>((s) => s);

  ///
  var pars = VisualMappingOpts();
  var parsTmp = VisualMappingOpts();
  final commandTmp = RxCommand.createSync<VisualMappingOpts, VisualMappingOpts>((b) => b);
  final command = RxCommand.createSync<VisualMappingOpts, VisualMappingOpts>((b) => b);
  RxCommand<VisualMappingOpts, VisualMappingOpts> savePars;
  RxCommand<void, VisualMappingOpts> getPars;

  RxCommand<VisualMappingOpts, List<Note>> getNotes2Cmd;

  // Prepares SortManager from String that was passed.
  RxCommand<String, VisualMappingOpts> searchTextChangedCmd;
  // Switching search process
  RxCommand<bool, bool> switchSearchCmd;
  /// Controls and keeps changing filters/searchers
  RxCommand<VisualMappingOpts, VisualMappingOpts> switchVisualMappingOptionsCmd;


  NoteManager() {
    updateNote = RxCommand.createAsync<Note, Note>(sl<DBProvider>().updateNote);
    addNote = RxCommand.createAsync<Note, Note>(sl<DBProvider>().addNote);
    recycleNote =  RxCommand.createAsync<FlagAndNote, List<Note>>(sl<DBProvider>().recycleNote);
    getNotes2Cmd = RxCommand.createAsync<VisualMappingOpts, List<Note>>(
      sl.get<DBProvider>().getNotes2,
    );
    savePars = RxCommand.createAsync<VisualMappingOpts, VisualMappingOpts>(sl<DBProvider>().savePrefVmo);
    getPars = RxCommand.createAsyncNoParam<VisualMappingOpts>(sl<DBProvider>().getPrefVmo);

    searchTextChangedCmd =
        RxCommand.createSync<String, VisualMappingOpts>((s) => pars.copyWith(searchBy: SearchOpt(value: s)));
    switchSearchCmd = RxCommand.createSync<bool, bool>((b) => b);

    switchVisualMappingOptionsCmd =
        RxCommand.createSync<VisualMappingOpts, VisualMappingOpts>((vmo) => vmo);

    // preparing

    showRecycledCmd.listen((s){
      print('NoteManager.NoteManager.showRecycledCmd.listen: s = $s');
      pars = pars.copyWith(showRecycled: s);
      parsTmp = pars;
      savePars(pars);
      getNotes2Cmd(pars);
    });

    recycleNote.listen((l){
      print('NoteManager.NoteManager.recycleNote.listen: l = $l');
      getNotes2Cmd(pars);
    });

    updateNote.listen((note) {
      print('NoteManager.NoteManager.updateNote.listen: pars = $pars');
      getNotes2Cmd(pars);
    });

    addNote.thrownExceptions.listen((e){
      print('NoteManager.NoteManager: e = $e');
      getNotes2Cmd(pars);
    });

    addNote.listen((note){
      print('NoteManager.NoteManager.addNote.listen');
      getNotes2Cmd(pars);
    });

    commandTmp.listen((p){
      print('NoteManager.NoteManager: commandTmp!!! ${commandTmp.lastResult}');
      parsTmp = commandTmp.lastResult;
    });

    command.listen((p){
      print('NoteManager.NoteManager: command ${p}');
      //pars = command.lastResult;
      pars = pars.copyWith(
        sortByCreating: p.sortByCreating,
        sortByEditing: p.sortByEditing,
        sortByStr: p.sortByStr,
        currentSort: p.sortBy,
        showRecycled: p.showRecycled,
      );
      savePars(pars);
      searchByCmd(pars.searchBy.value);
      showRecycledCmd(pars.showRecycled);
      getNotes2Cmd.execute(pars);
    });

    searchTextChangedCmd
        // Wait for the user to stop typing for 500ms
        .debounceTime(new Duration(milliseconds: 500))
        // Then call the updateWeatherCommand
        .listen((d){
      pars = pars.copyWith(
          searchBy: SearchOpt(value: d.searchBy.value),
      );
      savePars(pars);
      showRecycledCmd(pars.showRecycled);
      searchByCmd(pars.searchBy.value);
      print('NoteManager.NoteManager.searchTextChangedCmd.listen: d=$d, pars=$pars');
      getNotes2Cmd(d);
    });

    switchVisualMappingOptionsCmd
        .listen((p){
      print('NoteManager.NoteManager.switchVisualMappingOptionsCmd.listen: p=$p');
      getNotes2Cmd(pars);
    });

    switchSearchCmd.listen((b){
      print('NoteManager.NoteManager.switchSearchCmd.listen: b=$b, pars=$pars');
//      if(!b) {
//        getPars(pars);
//      }
      //getNotes2Cmd(pars);
      searchByCmd(pars.searchBy.value);
      showRecycledCmd(pars.showRecycled);
    });

    getPars.listen((p) {
      pars = p;
      parsTmp = p;
      searchByCmd(pars.searchBy.value);
      showRecycledCmd(pars.showRecycled);
      print('NoteManager.NoteManager.getPars.listen: p=$p, pars=$pars');
      getNotes2Cmd(p);
      //switchSearchCmd(false);
    });

//    switchVisualMappingOptionsCmd(VisualMappingOpts());
    getPars();
  }
}
