import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'const.dart';

class Utils {
  static Future<String> downloadFile(String uri, String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/$fileName';
    final response = await http.get(Uri.parse(uri));
    final file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
    return filePath;
  }
}

DateTime getDataTime(Timestamp startDate) {
  DateTime dateTimeStart = startDate.toDate();
  return dateTimeStart;
}

String filterDate(lastDateOnline) {
  String time = '';
  try {
    if (DateTime.now().difference(getDataTime(lastDateOnline)).inDays >= 1) {
      time = '${getDataTime(lastDateOnline).day} '
          '${months[getDataTime(lastDateOnline).month - 1]} в ${getDataTime(lastDateOnline).hour}: ${getDataTime(lastDateOnline).minute}';
    } else {
      time =
      '${getDataTime(lastDateOnline).hour}: ${getDataTime(lastDateOnline).minute}';
    }
  } catch (error) {}
  return time;
}

Future<bool> getState(time) async {
  bool isWriteUser = true;
  await Future.delayed(Duration(milliseconds: time), () {
    isWriteUser = false;
  });
  return isWriteUser;
}

Future<void> setValueSharedPref(String key, int value) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt(key, value);
}

// Future checkStatusNetwork(StreamSubscription streamSubscription) async {
//   bool isFiresState = false;
//   streamSubscription =
//       Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
//     if (isFiresState) {
//       if (result.name == 'wifi') {
//         setStateFirebase('online');
//       } else if (result.name == 'mobile') {
//         setStateFirebase('online');
//       } else {
//         setStateFirebase('offline');
//       }
//     }
//     isFiresState = true;
//   });
// }