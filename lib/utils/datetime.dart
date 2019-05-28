import 'package:intl/intl.dart';

String toDate(int timestamp, [String format]) {
  var df = new DateFormat(format ?? 'HH:mm a');
  var date = new DateTime.fromMillisecondsSinceEpoch(timestamp);
  return df.format(date);
}

/// Shortener for timestamp
int timestamp() => DateTime.now().millisecondsSinceEpoch;
