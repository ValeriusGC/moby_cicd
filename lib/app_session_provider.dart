import 'dart:async';

import 'package:mobynote/Database.dart';
import 'package:mobynote/app_session.dart';
import 'package:mobynote/utils/datetime.dart';
import 'package:mobynote/utils/result.dart';

class AppSessionProvider {
  static final AppSessionProvider INSTANCE = AppSessionProvider._();

  var current = AppSession.empty();

  /// Finds [last] user in DB.
  Future<AppSession> init() async {
//    print('Mobynote.AppSessionProvider.init: START');
    final session = await DBProvider.db.getUser().then((user) {
//      print('Mobynote.AppSessionProvider.init: user = ${user}');
      current = current.copyWith(currentUser: user, state: AppState.OK, startTime: timestamp());
      return current;
    }).catchError((e) {
      current = current.copyWith(state: AppState.ERROR, msg: e);
      return current;
    }).whenComplete((){
      return current;
    });
//    print('Mobynote.AppSessionProvider.init: session = ${session}');
    return session;

  }

  AppSessionProvider._();
}
