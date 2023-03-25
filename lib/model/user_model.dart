import 'package:cloud_firestore/cloud_firestore.dart';

import '../config/utils.dart';

class UserModel {
  final String name;
  final String uid;
  final String myPol;
  final String searchPol;
  final String myCity;
  final String imageBackground;
  final String state;
  final String token;
  final String description;
  final num ageInt;
  final num rangeStart;
  final num rangeEnd;
  final List<String> listInterests;
  final List<String> listImageUri;
  final List<String> listImagePath;
  final Timestamp ageTime;
  final bool notification;

  UserModel(
      {required this.name,
      required this.uid,
      required this.state,
      required this.description,
      required this.myCity,
      required this.ageInt,
      required this.ageTime,
      required this.token,
      required this.notification,
      required this.myPol,
      required this.searchPol,
      required this.rangeStart,
      required this.listImageUri,
      required this.listImagePath,
      required this.imageBackground,
      required this.listInterests,
      required this.rangeEnd});

  factory UserModel.fromDocument(Map<String, dynamic> doc) {
    return UserModel(
        name: doc['name'] ?? '',
        uid: doc['uid'] ?? '',
        state: doc['state'] ?? '',
        description: doc['description'] ?? '',
        myCity: doc['myCity'] ?? '',
        ageInt: ageIntParse(doc['ageTime'] ?? Timestamp.now()) ?? 0,
        ageTime: doc['ageTime'] ?? Timestamp.now(),
        token: doc['token'] ?? '',
        notification: doc['notification'] ?? false,
        myPol: doc['myPol'] ?? '',
        searchPol: doc['searchPol'] ?? '',
        rangeStart: doc['rangeStart'] ?? 0,
        listImageUri: List<String>.from(doc['listImageUri'] ?? []),
        listImagePath: List<String>.from(doc['listImagePath'] ?? []),
        imageBackground: doc['imageBackground'] ?? '',
        listInterests: List<String>.from(doc['listInterests'] ?? []),
        rangeEnd: doc['rangeEnd'] ?? 0);
  }
}
