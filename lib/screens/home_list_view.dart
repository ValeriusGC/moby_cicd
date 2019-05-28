import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobynote/NoteModel.dart';
import 'package:mobynote/keys.dart';


//class WeatherListView extends StatelessWidget {
//
//  final List<Note> data;
//
//  WeatherListView(this.data, {Key key}) : super(key: key);
//
//  @override
//  Widget build(BuildContext context) {
//    return ListView.builder(
//              key: EisKeys.homeScreenListView,
//              itemCount: data.length,
//              itemBuilder: (BuildContext context, int index) =>
//                               WeatherItem(entry: data[index]),
//            );
//   }
//}
//
//class WeatherItem extends StatelessWidget {
//  final Note entry;
//
//  WeatherItem({Key key, @required this.entry}) : super(key: key);
//
//  @override
//  Widget build(BuildContext context) {
////    return ListTile(
////                  leading: Icon(_weatherIdToIcon(entry.weatherId), size: 28.0,),
////                  title: Text(entry.cityName),
////                  subtitle: Text(entry.description, style: TextStyle(fontStyle: FontStyle.italic),),
////                  trailing: Text('${entry.temperature.round()} °', style: TextStyle(fontSize: 20.0),
////                  ),
////    );
//  }
//}
