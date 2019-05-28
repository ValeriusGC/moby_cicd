import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mobynote/Database.dart';
import 'package:mobynote/generated/i18n.dart';
import 'package:mobynote/local_repo.dart';
import 'package:mobynote/main.dart';
import 'package:mobynote/note_bloc.dart';
import 'package:mobynote/note_bloc_provider.dart';
import 'package:mobynote/note_interactor.dart';
import 'package:mobynote/routes.dart';
import 'package:mobynote/screens/add_screen.dart';
import 'package:mobynote/screens/first_screen.dart';
import 'package:mobynote/screens/home_screen.dart';

class MobynoteApp extends StatefulWidget {
  MobynoteApp();

  @override
  State<StatefulWidget> createState() {
    return MobynoteAppState();
  }
}

class MobynoteAppState extends State<MobynoteApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return NoteBlocProvider(
      bloc: NoteBloc(NoteInteractor(LocalRepo(DBProvider.db))),
      child: MaterialApp(
        localizationsDelegates: [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          DefaultCupertinoLocalizations.delegate,
        ],
        supportedLocales: S.delegate.supportedLocales,
        home: HomeScreen(),
//        routes: {
//          Routes.first: (context) {
//            return FirstScreen();
//          },
//          Routes.home: (context) {
//            return HomeScreen();
//          },
//          Routes.addTodo: (context) {
//            return AddScreen();
//          },
//        },
      ),
    );
  }

  ///
  ///
  void _init() {}
}
