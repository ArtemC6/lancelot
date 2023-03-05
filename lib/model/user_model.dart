import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String name;
  final String uid;
  final String userPol;
  final String searchPol;
  final String myCity;
  final String imageBackground;
  final String state;
  final String token;
  final String description;
  final num ageInt;
  final num searchRangeStart;
  final num searchRangeEnd;
  final List<String> userInterests;
  final List<String> userImageUrl;
  final List<String> userImagePath;
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
      required this.userPol,
      required this.searchPol,
      required this.searchRangeStart,
      required this.userImageUrl,
      required this.userImagePath,
      required this.imageBackground,
      required this.userInterests,
      required this.searchRangeEnd});

  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      name: data['name'],
      uid: data['uid'],
      state: data['state'],
      description: data['description'],
      myCity: data['myCity'],
      ageInt: data['ageInt'],
      ageTime: data['ageTime'],
      token: data['token'],
      notification: data['notification'],
      userPol: data['userPol'],
      searchPol: data['searchPol'],
      searchRangeStart: data['searchRangeStart'],
      userImageUrl: data['userImageUrl'],
      userImagePath: data['userImagePath'],
      imageBackground: data['imageBackground'],
      userInterests: data['userInterests'],
      searchRangeEnd: data['searchRangeEnd'],
    );
  }
}
