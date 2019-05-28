import 'package:mobynote/Database.dart';
import 'package:mobynote/NoteModel.dart';
import 'package:mobynote/app_session.dart';
import 'package:mobynote/service_locator.dart';
import 'package:rx_command/rx_command.dart';

class HomeScreenManager {
//  // Switching search process
//  RxCommand<bool, bool> switchSearchCmd;
//
//  /// Controls and keeps changing filters/searchers
//  RxCommand<VisualMappingOptions, VisualMappingOptions> switchVisualMappingOptionsCmd;

  // Start searching
  // RxCommand<VisualMappingOptions, List<Note>> getNotesCmd;


  HomeScreenManager() {
//    switchSearchCmd = RxCommand.createSync<bool, bool>((b) => b);
//
//    switchVisualMappingOptionsCmd =
//        RxCommand.createSync<VisualMappingOptions, VisualMappingOptions>((vmo) => vmo);

//    getNotesCmd = RxCommand.createAsync<VisualMappingOptions, List<Note>>(
//      sl.get<DBProvider>().getNotes,
//    );

    // Will be called on every change of the search field
//    searchTextChangedCmd =
//        RxCommand.createSync<String, VisualMappingOptions>((s) => VisualMappingOptions.mk(searchStr: s));

    // When the user starts typing
//    searchTextChangedCmd
//        // Wait for the user to stop typing for 500ms
//        .debounce(new Duration(milliseconds: 500))
//        // Then call the updateWeatherCommand
//        .listen(getNotesCmd);
//
//    switchVisualMappingOptionsCmd
//        .listen(getNotesCmd);

    // Update data on startup
//    switchVisualMappingOptionsCmd(VisualMappingOptions.mk());
//    switchSearchCmd(false);
  }
}
