import 'package:cloud_firestore/cloud_firestore.dart';

class SympathyModel {
  String name;
  String uid;
  String id_doc;
  String city;
  String uri;
  Timestamp time;
  num age;

  SympathyModel(
      {required this.name,
      required this.id_doc,
      required this.uid,
      required this.city,
      required this.uri,
      required this.age,
      required this.time});
}
