import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobynote/Database.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:mobynote/NoteModel.dart';
import 'package:mobynote/app.dart';
import 'package:mobynote/generated/i18n.dart';
import 'package:mobynote/service_locator.dart';

void main() {
  setUpServiceLocator();
  runApp( MobynoteApp(
  ));
}
