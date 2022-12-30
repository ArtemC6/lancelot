import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String name;
  String uid;
  String userPol;
  String searchPol;
  String myCity;
  String imageBackground;
  String state;
  String token;
  num ageInt;
  num searchRangeStart;
  num searchRangeEnd;
  List<String> userInterests;
  List<String> userImageUrl;
  List<String> userImagePath;
  Timestamp ageTime;
  bool notification;

  UserModel(
      {required this.name,
      required this.uid,
      required this.state,
      required this.myCity,
      required this.ageInt,
      required this.ageTime,
      required this.token,
      required this.notification,
      required this.userPol,
      required this.searchPol,
      required this.searchRangeStart,
      required this.userImageUrl,
      required this.userImagePath,
      required this.imageBackground,
      required this.userInterests,
      required this.searchRangeEnd});
}
