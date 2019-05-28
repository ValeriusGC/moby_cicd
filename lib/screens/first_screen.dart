import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:mobynote/app_session.dart';
import 'package:mobynote/app_session_provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mobynote/generated/i18n.dart';
import 'package:mobynote/routes.dart';
import 'package:mobynote/screens/home_screen.dart';
import 'package:mobynote/utils/datetime.dart';

class FirstScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return FirstScreenState();
  }
}

class FirstScreenState extends State<FirstScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<AppSession>(
        future: AppSessionProvider.INSTANCE.init(),
        builder: (context, snapshot) {
//          print(
//              'Mobynote.FirstScreenState.build: snapshot: ${snapshot.hasData}, ${snapshot.data}, ${snapshot.error}');
          if (snapshot.hasData) {
            final session = snapshot.data;
            switch (session.state) {
              case AppState.UNDEFINED:
//                print('Mobynote.FirstScreenState.build: AppState.UNDEFINED');
                break;
              case AppState.START:
//                print('Mobynote.FirstScreenState.build: AppState.START');
                break;
              case AppState.INIT:
//                print('Mobynote.FirstScreenState.build: AppState.INIT');
                break;
              case AppState.OK:
//                print('Mobynote.FirstScreenState.build: AppState.OK');
                final dateString = toDate(session.startTime, S.of(context).date_format);
//                Fluttertoast.showToast(msg: "started ${dateString}");

                Future.delayed(const Duration(milliseconds: 10), () {
                  Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(
                    builder: (context) {
                      return HomeScreen();
                    },
                  ), (Route<dynamic> route) => false);
                });

                return Center(
                  child: Text("${S.of(context).title}: $dateString"),
                );

                break;
              case AppState.ERROR:
//                print('Mobynote.FirstScreenState.build: AppState.ERROR');
                Fluttertoast.showToast(
                  msg: "ERROR ${snapshot.data.msg}",
                  backgroundColor: Colors.red,
                  toastLength: Toast.LENGTH_LONG,
                );
                SystemChannels.platform.invokeMethod('SystemNavigator.pop');
                return Container();
                break;
            }
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
