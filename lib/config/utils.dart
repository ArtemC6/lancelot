import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:rive/rive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../getx/sympathy_cart_controller.dart';
import 'const.dart';

DateTime getDataTime(Timestamp startDate) => startDate.toDate();

String filterDate(lastDateOnline) {
  String time = '';
  try {
    if (DateTime.now().difference(getDataTime(lastDateOnline)).inDays >= 1) {
      time = '${getDataTime(lastDateOnline).day} '
          '${months[getDataTime(lastDateOnline).month - 1]} ${getDataTime(lastDateOnline).hour}: ${getDataTime(lastDateOnline).minute}';
    } else {
      time =
          '${getDataTime(lastDateOnline).hour}: ${getDataTime(lastDateOnline).minute}';
    }
  } catch (error) {}
  return time;
}

Future<bool> getFuture(time) async =>
    await Future.delayed(Duration(milliseconds: time));

Future<void> setValueSharedPref(String key, int value) async =>
    await SharedPreferences.getInstance().then((i) => i.setInt(key, value));

int ageIntParse(Timestamp time) =>
    DateTime.now().difference(getDataTime(time)).inDays ~/ 365;

Future<void> launchUrlEmail(String uri) async {
  String? encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((MapEntry<String, String> e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }

  final Uri emailLaunchUri = Uri(
    scheme: 'mailto',
    path: uri,
    query: encodeQueryParameters(<String, String>{
      'subject': '',
    }),
  );

  launchUrl(emailLaunchUri);
}

Future<void> clearAllNotification() async {
  try {
    await const MethodChannel('clear_all_notifications').invokeMethod('clear');
  } catch (e) {}
}

getRiveController(Artboard art, {stateMachineName = "State Machine 1"}) {
  final controller = StateMachineController.fromArtboard(art, stateMachineName);
  art.addController(controller!);
  return controller;
}

setColorCard(Alignment align, GetSympathyCartController sympathyCar) {
  if (align.x < 0) {
    final incline = int.parse(align.x.toStringAsFixed(1).substring(1, 2));
    if (incline <= 10) {
      sympathyCar.setIndex(double.parse('0.$incline'));
      sympathyCar.setLike(true);
    } else {
      sympathyCar.setIndex(0);
    }
  } else if (align.x > 0) {
    if (align.y.toDouble() < 1) {
      sympathyCar.setIndex(double.parse('0.${align.x.toInt()}'));
      sympathyCar.setLike(false);
    } else {
      sympathyCar.setIndex(0);
    }
  }
}
