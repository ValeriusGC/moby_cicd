import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mobynote/NoteModel.dart';
import 'package:mobynote/generated/i18n.dart';
import 'package:mobynote/keys.dart';
import 'package:mobynote/managers/note_manager.dart';
import 'package:mobynote/model/vmo.dart';
import 'package:mobynote/note_bloc.dart';
import 'package:mobynote/note_bloc_provider.dart';
import 'package:mobynote/screens/add_screen.dart';
import 'package:mobynote/service_locator.dart';
import 'package:mobynote/utils/attrs.dart';
import 'package:mobynote/utils/datetime.dart';
import 'package:mobynote/widgets/filter_button.dart';
import 'package:mobynote/widgets/note_item.dart';
import 'package:rx_widgets/rx_widgets.dart';
import 'package:rflutter_alert/rflutter_alert.dart';


class HomeScreen extends StatefulWidget {

  bool visibleAll;



  @override
  State<StatefulWidget> createState() {
    return HomeScreenState();
  }

}

class HomeScreenState extends State<HomeScreen> {

  Widget _defAppBarTitle;
  List<Widget> _rows;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _rows = List<Widget>.generate(10,
    (int index) => Text('This is row $index',
    key: ValueKey(index), textScaleFactor: 1.5));
  }

  /// 19/05/04 FIXME SUSPICIOUS: i rebuild all widget tree on pressing 'search'. Donno if its good...
  @override
  Widget build(BuildContext context) {
    _defAppBarTitle = Text(S.of(context).title);
    final _nm = sl<NoteManager>();
    final _ctrl = TextEditingController(
        text: _nm.pars.searchBy.value != null ? _nm.pars.searchBy.value : '',
    );

    return Scaffold(
      appBar: AppBar(
        title: WidgetSelector(
          buildEvents: _nm.switchSearchCmd,
          onTrue: Row(
            children: <Widget>[
              Expanded(
                child: StreamBuilder<String>(
                  initialData: _nm.pars.searchBy.value,
                  stream: _nm.searchByCmd,
                  builder: (context, snapshot) {
                    print('HomeScreenState.build.TextField REBUILD: snapshot.data=${snapshot?.data}');
                    print('HomeScreenState.build.TextField REBUILD: _nm.pars=${_nm.pars}');
                    final txt = _nm.pars.searchBy.value;
                    _ctrl.text = txt;
                    print('HomeScreenState.build.TextField REBUILD: _ctrl.text=${_ctrl.text}');
                    return TextField(
                      controller: _ctrl,
                      onChanged: (v){
                        print('HomeScreenState.build.TextField.onChanged = $v');
                        _nm.searchTextChangedCmd(v);
                      },
                      decoration: InputDecoration(
                          hintText: 'Search...'
                      ),
                    );
                  }
                ),
              ),
              IconButton(
//                key: EisKeys.invisibleSearch,
                icon: Icon(Icons.done),
                onPressed: () {
                  _nm.switchSearchCmd(false);
//                  sl<NoteManager>().searchTextChangedCmd('');
                },
              ),
              IconButton(
//                key: EisKeys.invisibleSearch,
                icon: Icon(Icons.close),
                onPressed: () {
                  _nm.searchTextChangedCmd('');
                  _nm.switchSearchCmd(false);
                  //_ctrl.text = '';
                },
              ),
            ],
          ),
          onFalse: Row(
            children: <Widget>[
              Expanded(
                child: _defAppBarTitle,
              ),
              StreamBuilder<String>(
                initialData: _nm.pars.searchBy.value,
                stream: _nm.searchByCmd,
                builder: (context, snapshot) {
                  print('HomeScreenState.build.Icon REBUILD: _nm.pars=${_nm.pars.searchBy.value}');
                  return IconButton(
//                key: EisKeys.visibleSearch,
                    icon: Icon(
                      Icons.search,
                      color: _nm.pars.searchBy.value.isEmpty
                          ? Colors.white
                          : Colors.red,
                    ),
                    onPressed: () {
                      sl.get<NoteManager>().switchSearchCmd(true);
                    },
                  );
                }
              ),
              IconButton(
                icon: Icon(Icons.sort),
                onPressed: (){
                  _onAlertWithCustomContent2Pressed(context);
                },
              ),
//              SortButton(
//                isActive: true,
//                // 19/05/04 FIXME UNUSED? maybe this field is unused?
//                activeSort: sl<HomeScreenManager>().switchVisualMappingOptionsCmd.lastResult
//                    ?? VisualMappingOptions.mk(sortType: SortType.DESC),
//                onSelected: (item){
//                  sl<HomeScreenManager>().switchVisualMappingOptionsCmd(item);
//                },
//              ),
              StreamBuilder<ShowRecycled>(
                initialData: sl<NoteManager>().pars.showRecycled,
                stream: sl<NoteManager>().showRecycledCmd,
                builder: (context, snapshot) {
                  print('HomeScreenState.build.resycled pars=${sl<NoteManager>().pars.showRecycled}, snap=${snapshot.data}');
                  return FilterButton(
                    isActive: true,
                    activeFilter: sl<NoteManager>().pars.showRecycled,
                    onSelected: sl<NoteManager>().showRecycledCmd,
                  );
                }
              ),
            ],
          ),
        ),
//        actions: _buildActions(
//          bloc,
//          snapshot,
//        ),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            key: UniqueKey(),
            child: RxLoader<List<Note>>(
              spinnerKey: EisKeys.homeScreenLoadingSpinner,
              radius: 25.0,
              commandResults: _nm.getNotes2Cmd.results,
              dataBuilder: (context, data) {
                print('HomeScreenState.build REBUILD: ${_nm.getNotes2Cmd.lastResult.length}');
                return ListView.builder(
                  key: EisKeys.homeScreenListView,
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    final item = data[index];
                    return GestureDetector(
                      onLongPress: (){
                        _showMenuDialog(context, item);
                      },
                      child: NoteItem(
                        note: item,
                        onDismissed: (direction) {
                          item.attrs.recycledFlag ? _unremoveTodo(context, [item]) : _removeTodo(context, [item]);
                        },
                        callback: (direction) {
                          if(widget.visibleAll==true){
                            item.attrs.recycledFlag ? _unremoveTodo(context, [item]) : _removeTodo(context, [item]);
                          }
                          return Future.value(widget.visibleAll!=true);
                        },
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) {
                                return AddScreen(
                                  note: item,
//                                  updateNote: bloc.updateNote.add,
//                                  addNote: bloc.addNote.add,
                                  process: _nm.updateNote,
                                  key: EisKeys.addScreen,
                                );
                              },
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
              placeHolderBuilder: (context) {
                return Center(
                    key: EisKeys.homeScreenLoaderPlaceholder, child: Text("No !!Data"));
              },
              errorBuilder: (context, ex) {
                return Center(
                    key: EisKeys.homeScreenLoaderError,
                    child: Text("Error: ${ex.toString()}"));
              }

            ),
          ),
        ],
      ),
      bottomNavigationBar: mk(context),
    );

//    return StreamBuilder<List<Note>>(
//        stream: bloc.visibleTodos,
//        builder: (context, snapshot) {
//          return Scaffold(
//            appBar: AppBar(
//              title: WidgetSelector(
//                buildEvents: sl
//                    .get<HomeScreenManager>()
//                    .updateNoteListCommand
//                    .canExecute,
//                onTrue: Row(
//                  children: <Widget>[
//                    Expanded(
//                      child: TextField(
//                        controller: _controller,
//                        onChanged: sl.get<HomeScreenManager>().searchTextChangedCommand,
//                        decoration: InputDecoration(
//                            hintText: 'Search...'
//                        ),
//                      ),
//                    ),
//                    IconButton(
//                      key: EisKeys.invisibleSearch,
//                      icon: Icon(Icons.close),
//                      onPressed: () {
//                        sl.get<HomeScreenManager>().switchSearch(false);
//                      },
//                    ),
//                  ],
//                ),
//                onFalse: Row(
//                  children: <Widget>[
//                    Expanded(
//                      child: _defAppBarTitle,
//                    ),
//                    IconButton(
//                      key: EisKeys.visibleSearch,
//                      icon: Icon(Icons.search),
//                      onPressed: () {
//                        sl.get<HomeScreenManager>().switchSearch(true);
//                      },
//                    ),
//                  ],
//                ),
//              ),
//              actions: _buildActions(
//                bloc,
//                snapshot,
//              ),
//            ),
//            body: RxLoader<List<Note>>(
//              spinnerKey: EisKeys.homeScreenLoadingSpinner,
//              radius: 25.0,
//              commandResults: sl.get<HomeScreenManager>().updateNoteListCommand.results,
//              dataBuilder: (context, data) {
//                  ListView.builder(
//                    key: EisKeys.homeScreenListView,
//                    itemCount: data.length,
//                    itemBuilder: (context, index) {
//                      print('Mobynote.HomeScreenState.build: data.len=${data.length}');
//                      final item = data[index];
//                      return GestureDetector(
//                        onLongPress: (){
//                          print('Mobynote.HomeScreenState.build: GestureDetector LongPress');
//                          _showMenuDialog(context, item);
//                        },
//                        child: NoteItem(
//                          note: item,
//                          onDismissed: (direction) {
//                            item.attrs.recycledFlag ? _unremoveTodo(context, [item]) : _removeTodo(context, [item]);
//                          },
//                          callback: (direction) {
//                            if(widget.visibleAll==true){
//                              item.attrs.recycledFlag ? _unremoveTodo(context, [item]) : _removeTodo(context, [item]);
//                            }
//                            return Future.value(widget.visibleAll!=true);
//                          },
//                          onTap: () {
//                            Navigator.of(context).push(
//                              MaterialPageRoute(
//                                builder: (_) {
//                                  return AddScreen(
//                                    note: item,
//                                    updateNote: bloc.updateNote.add,
//                                    addNote: bloc.addNote.add,
//                                    key: EisKeys.addScreen,
//                                  );
//                                },
//                              ),
//                            );
//                          },
//                        ),
//                      );
//                    },
//                  );
//                },
//              placeHolderBuilder: (context) =>
//                  Center(
//                      key: EisKeys.homeScreenLoaderPlaceholder, child: Text("No Data")),
//              errorBuilder: (context, ex) =>
//                  Center(
//                      key: EisKeys.homeScreenLoaderError,
//                      child: Text("Error: ${ex.toString()}")),
//
//            ),
//
////            body: StreamBuilder<List<Note>>(
////              stream: bloc.visibleTodos,
////              builder: (context, snapshot) {
////                if (snapshot.hasData) {
////                  return ListView.builder(
////                    itemCount: snapshot.data.length,
////                    itemBuilder: (context, index) {
////                      final item = snapshot.data[index];
////                      return GestureDetector(
////                        onLongPress: (){
////                          print('Mobynote.HomeScreenState.build: GestureDetector LongPress');
////                          _showMenuDialog(context, item);
////                        },
////                        child: NoteItem(
////                          note: item,
////                          onDismissed: (direction) {
////                            item.attrs.recycledFlag ? _unremoveTodo(context, [item]) : _removeTodo(context, [item]);
////                          },
////                          callback: (direction) {
////                            if(widget.visibleAll==true){
////                              item.attrs.recycledFlag ? _unremoveTodo(context, [item]) : _removeTodo(context, [item]);
////                            }
////                            return Future.value(widget.visibleAll!=true);
////                          },
////                          onTap: () {
////                            Navigator.of(context).push(
////                              MaterialPageRoute(
////                                builder: (_) {
////                                  return AddScreen(
////                                    note: item,
////                                    updateNote: bloc.updateNote.add,
////                                    addNote: bloc.addNote.add,
////                                    key: EisKeys.addScreen,
////                                  );
////                                },
////                              ),
////                            );
////                          },
////                        ),
////                      );
////                    },
////                  );
////                } else {
////                  return Center(child: CircularProgressIndicator());
////                }
////              },
////            ),
//            bottomNavigationBar: mk(context),
//          );
//        }
//    );

  }

//  Widget _buildAppBar(BuildContext context, bool asSearcher) {
//
//    return new AppBar(
//      centerTitle: true,
//      title: _appBarTitle,
//      leading: new IconButton(
//        icon: _searchIcon,
//        onPressed: _searchPressed,
//
//      ),
//
//    );
//  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      Widget row = _rows.removeAt(oldIndex);
      _rows.insert(newIndex, row);
    });
  }

  _onAlertWithCustomContent2Pressed(context) {

    final _m = sl<NoteManager>();

    Alert(
        context: context,
        title: S.of(context).dlg_sort_title,
        content: StreamBuilder<VisualMappingOpts>(
            initialData: _m.parsTmp,
            stream: _m.commandTmp,
            builder: (context, snapshot) {
              final _vmo = snapshot.data;
              return _vmo == null
                  ? Text('FUCK')
                  :
              Column(
              children: <Widget>[
                _listTile(
                  1,
                  _m,
                  Text(S.of(context).sort_by_str),
                  _vmo.sortByStr,
                      (v) =>
                          _vmo.copyWith(sortByStr: SortByStr(v), currentSort: SortByStr(v)),
                ),
                  Divider(),
                _listTile(
                  2,
                  _m,
                  Text(S.of(context).sort_by_create),
                  _vmo.sortByCreating,
                      (v) =>
                      _vmo.copyWith(sortByCreating: SortByCreating(v), currentSort: SortByCreating(v)),
                ),
                  Divider(),
                _listTile(
                  3,
                  _m,
                  Text(S.of(context).sort_by_edit),
                  _vmo.sortByEditing,
                      (v) =>
                      _vmo.copyWith(sortByEditing: SortByEditing(v), currentSort: SortByEditing(v)),
                ),
              ],
              );
            }),
        buttons: [
          DialogButton(
            onPressed: () => _makeSorting(context, _m),
            child: Text(
              S.of(context).dlg_sort_apply,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
              ),
            ),
          )
        ]).show();
  }

  void _makeSorting(BuildContext context, NoteManager nm) {
    Navigator.pop(context);
    nm.command.execute(nm.parsTmp);
  }

  Widget _listTile(int idx, NoteManager nm, Text title, SortBy sortBy, VmoFactory factory) {
    final chosen = sortBy.runtimeType == nm.parsTmp.sortBy.runtimeType;
    TextStyle ts = chosen
        ? TextStyle(fontWeight: FontWeight.bold)
        : TextStyle(fontWeight: FontWeight.normal);
    final cb = ListTile(
      selected: chosen,
      key: ValueKey(idx),
      leading: Radio<SortBy>(
        value: sortBy,
        groupValue: nm.parsTmp.sortBy,
        onChanged: (sb){
          final tmp = nm.parsTmp.copyWith(currentSort: sortBy);
          nm.commandTmp(tmp);
        },
      ),
      title: Text(title.data, style: ts,),
      subtitle: sortBy.dir == SortDir.DESC
          ? Text(S.of(context).dlg_sort_desc)
          : Text(S.of(context).dlg_sort_asc),
      dense: true,
      trailing: IconButton(
        icon: sortBy.dir == SortDir.DESC
            ? Icon(Icons.arrow_downward)
            : Icon(Icons.arrow_upward),
        onPressed: () {
          final v = sortBy.dir == SortDir.DESC ? SortDir.ASC : SortDir.DESC;
          final tmp = factory(v);
          nm.commandTmp(tmp);
        },
      ),
    );
    return cb;
  }

  /// Makes [CheckboxListTile] with required parameters.
  Widget _checkboxListTile(NoteManager nm, Text title, SortBy sortBy, VmoFactory factory, Icon icon) {
    CheckboxListTile cb = CheckboxListTile(
      title: title,
      subtitle: Text(sortBy.dir == SortDir.DESC ? 'descendant' : 'ascendant'),
      value: sortBy.dir == SortDir.DESC,
      onChanged: (v) {
        nm.command.execute(factory(!v ? SortDir.ASC : SortDir.DESC));
      },
      secondary: icon,
    );
    return cb;
  }

  Widget _buildAppBar(BuildContext context, String text) {
    return AppBar(title: Text(text),);
  }

  List<Widget> _buildActions(NoteBloc bloc, AsyncSnapshot<List<Note>> snapshot){
   return [
//     WidgetSelector(
//       buildEvents: sl
//           .get<HomeScreenManager>()
//           .updateNoteListCommand
//           .canExecute,
//       onTrue: IconButton(
//         key: EisKeys.visibleSearch,
//         icon: Icon(Icons.search),
//         onPressed: () {
//           sl.get<HomeScreenManager>().switchSearch(false);
//         },
//       ),
//       onFalse: IconButton(
//         key: EisKeys.invisibleSearch,
//         icon: Icon(Icons.close),
//         onPressed: () {
//           sl.get<HomeScreenManager>().switchSearch(true);
//         },
//       ),
//     ),
//     IconButton(
//       icon: Icon(Icons.search),
//       onPressed: () {
//         showSearch(
//           context: context,
//           delegate: CustomSearchDelegate(),
//           query: "",
//         );
//       },
//     ),
//     StreamBuilder<SortManager>(
//       stream: bloc.activeSort,
//       builder: (context, snapshot){
//         return SortButton(
//           isActive: true,
//           activeSort: snapshot.data ?? SortManager.mk(sortType: SortType.ASC),
//           onSelected: (item) {
//             if(item.sortType == SortType.SET){
//                Fluttertoast.showToast(msg: "SET");
//             }else{
//               bloc.updateSort.add(item);
//             }
//           },
//         );
//       },
//     ),
//     StreamBuilder<VisibilityFilter>(
//       stream: bloc.activeFilter,
//       builder: (context, snapshot){
//         widget.visibleAll = snapshot.data == VisibilityFilter.all;
//         print('Mobynote.HomeScreenState._buildActions: widget.f = ${widget.visibleAll}');
//         return FilterButton(
//           isActive: true,
//           activeFilter: snapshot.data ?? VisibilityFilter.all,
//           onSelected: bloc.updateFilter.add,
//         );
//       },
//     ),
   ];
  }

  static _show(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) {
          return AddScreen(
            note: Note(
              noteText: "",
              ownerId: 1,
              iidAuthId: 1,
              iidTimeStamp: timestamp(),
              attrs: Attrs(),
            ),
//            updateNote: NoteBlocProvider.of(context).updateNote.add,
//            addNote: NoteBlocProvider.of(context).addNote.add,
            process: sl<NoteManager>().addNote,
            key: EisKeys.addScreen,
          );
        },
      ),
    );
  }

  Widget mk(BuildContext context) {
    return Container(
      height: 55.0,
      child: BottomAppBar(
        color: Colors.blueAccent,
        //color: Color.fromRGBO(58, 66, 86, 1.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            GestureDetector(
                child: Container(
                  margin: const EdgeInsets.all(8.0),
                  padding: const EdgeInsets.all(8.0),
                  decoration: new BoxDecoration(
                    color: Colors.white24,
                    border: new Border.all(
                      color: Colors.white,
                      width: 2.0,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  ),
                  child: Text(S.of(context).text_hint),
                ),
                onTap: () {
                  _show(context);
                }),
            IconButton(
              icon: Icon(Icons.home, color: Colors.white),
              onPressed: () {
                //_toast();
                sl<NoteManager>().getNotes2Cmd( sl<NoteManager>().pars );
              },
            ),
            IconButton(
              icon: Icon(Icons.blur_on, color: Colors.white),
              onPressed: () {
                _toast();
              },
            ),
            IconButton(
              icon: Icon(Icons.hotel, color: Colors.white),
              onPressed: () {
                _toast();
              },
            ),
            IconButton(
              icon: Icon(Icons.account_box, color: Colors.white),
              onPressed: () {
                _toast();
              },
            )
          ],
        ),
      ),
    );
  }

  void _toast() {
    Fluttertoast.showToast(
      msg: S.of(context).nre,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIos: 1,
      backgroundColor: Colors.red,
      textColor: Colors.white,
    );
  }

  void _removeTodo(BuildContext context, List<Note> notes) {
    print('Mobynote.HomeScreenState._removeTodo: ');
    _showUndoSnackbar(context, notes, true);
    sl<NoteManager>().recycleNote(FlagAndNote(notes, FlagKeys.RECYCLED, true));
//    NoteBlocProvider.of(context).deleteNote.add(FlagAndNote(notes, FlagKeys.RECYCLED, true));
  }

  void _unremoveTodo(BuildContext context, List<Note> notes) {
    print('Mobynote.HomeScreenState._unremoveTodo: ');
    _showUndoSnackbar(context, notes, false);
    sl<NoteManager>().recycleNote(FlagAndNote(notes, FlagKeys.RECYCLED, false));
//    NoteBlocProvider.of(context).undeleteNote.add(FlagAndNote(notes, FlagKeys.RECYCLED, false));
  }

  void _showUndoSnackbar(BuildContext context, List<Note> notes, bool deleting) {
    final snackBar = SnackBar(
      key: EisKeys.snackbar,
      duration: Duration(seconds: 4),
      backgroundColor: deleting ? Colors.red : Colors.green, // Theme.of(context).backgroundColor,
      content: Text(deleting ?
          S.of(context).mark_recycled(notes.length) : S.of(context).mark_unrecycled(notes.length),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      action: SnackBarAction(
        key: EisKeys.snackbarAction(notes.toString()),
        label: S.of(context).undo,
        onPressed: () { deleting
            ? sl<NoteManager>().recycleNote(FlagAndNote(notes, FlagKeys.RECYCLED, false))
            : sl<NoteManager>().recycleNote(FlagAndNote(notes, FlagKeys.RECYCLED, true));
        },
      ),
    );

    Scaffold.of(context).showSnackBar(snackBar);
  }

  _showMenuDialog(BuildContext context, Note item) {
//    print('Mobynote..showAlertDialog: item=$item');
//    final t = item.noteText;

    Alert(
        context: context,
        title: 'Временное решение',
        desc: 'Следует избавляться от контекстного меню, см. Google Keep',
        content: Column(
          children: <Widget>[
            Divider(),
            ListTile(
              title: Text(
                  item.attrs.recycledFlag
                      ? S.of(context).dlg_mark_about_unrecycled
                      : S.of(context).dlg_mark_about_recycled
              ),
              onTap: () {
                Navigator.pop(context);
                item.attrs.recycledFlag
                    ? _unremoveTodo(context, [item])
                    : _removeTodo(context, [item]);
              },
            ),
            Divider(),
          ],
        ),
        buttons: [],
    ).show();


//    // set up the list options
//    Widget optionOne = SimpleDialogOption(
//      child: Text(S.of(context).dlg_mark_about_recycled),
//      onPressed: () {
//        _removeTodo(context, [item]);
//        Navigator.of(context).pop();
//      },
//    );
//    Widget optionTwo = SimpleDialogOption(
//      child: const Text('cow'),
//      onPressed: () {
//        print('cow');
//        Navigator.of(context).pop();
//      },
//    );
//    Widget optionThree = SimpleDialogOption(
//      child: const Text('camel'),
//      onPressed: () {
//        print('camel');
//        Navigator.of(context).pop();
//      },
//    );
//    Widget optionFour = SimpleDialogOption(
//      child: const Text('sheep'),
//      onPressed: () {
//        print('sheep');
//        Navigator.of(context).pop();
//      },
//    );
//    Widget optionFive = SimpleDialogOption(
//      child: const Text('goat'),
//      onPressed: () {
//        print('goat');
//        Navigator.of(context).pop();
//      },
//    );
//
//    // set up the SimpleDialog
//    SimpleDialog dialog = SimpleDialog(
//      title: Text(
//        '${S.of(context).dlg_selected_notes_title}\n"${_someText()}"',
//        maxLines: 3,
//        overflow: TextOverflow.ellipsis,
//      ),
//      children: <Widget>[
//        optionOne,
//        optionTwo,
//        optionThree,
//        optionFour,
//        optionFive,
//      ],
//      backgroundColor: Colors.amber[50],
//    );
//
//    // show the dialog
//    showDialog(
//      context: context,
//      builder: (BuildContext context) {
//        return dialog;
//      },
//    );
  }

}

/// As the normal switch does not even remember and display its current state
/// we us this one
class AppBarSwitch extends StatefulWidget {

  final bool searchMode;
  final int count;

  AppBarSwitch({this.searchMode, this.count});

  @override
  AppBarSwitchState createState() {
    return AppBarSwitchState(searchMode, count);
  }
}

class AppBarSwitchState extends State<AppBarSwitch> {
  bool searchMode;
  int count;

  AppBarSwitchState(this.searchMode, this.count);

  @override
  Widget build(BuildContext context) {
    return searchMode
        ? Container(
      child: Row(
        children: <Widget>[
          Text("A"),
          AppBar(
            title: Text("Search"),
          ),
        ],
      ),
    ) : AppBar(
      title: Text("Nope"),
    );
  }
}


class CustomSearchDelegate extends SearchDelegate<String> {

  NoteBloc bloc;

  @override
  List<Widget> buildActions(BuildContext context) {
    print('Mobynote.CustomSearchDelegate.buildActions: III');

    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    print('Mobynote.CustomSearchDelegate.buildLeading: III');
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  void showResults(BuildContext context) {
    print('Mobynote.CustomSearchDelegate.showResults: III');
  }


  @override
  void showSuggestions(BuildContext context) {
    print('Mobynote.CustomSearchDelegate.showSuggestions: III');
  }

  @override
  Widget buildResults(BuildContext context) {
    print('Mobynote.CustomSearchDelegate.buildResults: III');

    bloc = NoteBlocProvider.of(context);
    if (query.length < 3) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Center(
            child: Text(
              "Search term must be longer than two letters.",
            ),
          )
        ],
      );
    }

    //Add the search term to the searchBloc.
    //The Bloc will then handle the searching and add the results to the searchResults stream.
    //This is the equivalent of submitting the search term to whatever search service you are using
//    InheritedBlocs.of(context)
//        .searchBloc
//        .searchTerm
//        .add(query);

//    bloc.updateSort.add(AppSessionProvider.INSTANCE.current.sm.copyWith(searchStr: query));

    return Column(

        children: <Widget>[
        //Build the results based on the searchResults stream in the searchBloc
        StreamBuilder<List<Note>>(
          stream: bloc.visibleTodos,
          builder: (context, AsyncSnapshot<List<Note>> snapshot) {
            if (!snapshot.hasData) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Center(child: CircularProgressIndicator()),
                ],
              );
            } else if (snapshot.data.length == 0) {
              return Column(
                children: <Widget>[
                  Text(
                    "No Results Found.",
                  ),
                ],
              );
            } else {
              var results = snapshot.data;
              return ListView.builder(
                itemCount: results.length,
                itemBuilder: (context, index) {
                  var result = results[index];
                  return ListTile(
                    title: Text(result.noteText),
                  );
                },
              );
            }
          },
        ),
      ],
    );

  }

  @override
  Widget buildSuggestions(BuildContext context) {
    print('Mobynote.CustomSearchDelegate.buildSuggestions: query=$query');

    //bloc.updateSort.add(AppSessionProvider.INSTANCE.current.sm.copyWith(searchStr: query));

    return Column();
  }

}

class _SuggestionList extends StatelessWidget {
  const _SuggestionList({this.suggestions, this.query, this.onSelected});

  final List<String> suggestions;
  final String query;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (BuildContext context, int i) {
        final String suggestion = suggestions[i];
        return ListTile(
          leading: query.isEmpty ? const Icon(Icons.history) : const Icon(null),
          title: RichText(
            text: TextSpan(
              text: suggestion.substring(0, query.length),
              style: theme.textTheme.subhead.copyWith(fontWeight: FontWeight.bold),
              children: <TextSpan>[
                TextSpan(
                  text: suggestion.substring(query.length),
                  style: theme.textTheme.subhead,
                ),
              ],
            ),
          ),
          onTap: () {
            onSelected(suggestion);
          },
        );
      },
    );
  }
}

class ColumnExample2 extends StatefulWidget {
  @override
  _ColumnExample2State createState() => _ColumnExample2State();
}

class _ColumnExample2State extends State<ColumnExample2> {
  List<Widget> _rows;

  @override
  void initState() {
    super.initState();
    _rows = List<Widget>.generate(
    10,
    (int index) => Text('This is row $index',
    key: ValueKey(index), textScaleFactor: 1.5));
  }

  @override
  Widget build(BuildContext context) {
    void _onReorder(int oldIndex, int newIndex) {
      setState(() {
        Widget row = _rows.removeAt(oldIndex);
        _rows.insert(newIndex, row);
      });
    }

    Widget reorderableColumn = IntrinsicWidth(
        child: Column(
//        crossAxisAlignment: CrossAxisAlignment.start,
          children: _rows,
        ));

    return Transform(
      transform: Matrix4.rotationZ(0),
      alignment: FractionalOffset.topLeft,
      child: Material(
        child: Card(child: reorderableColumn),
        elevation: 6.0,
        color: Colors.transparent,
        borderRadius: BorderRadius.zero,
      ),
    );
  }
}
