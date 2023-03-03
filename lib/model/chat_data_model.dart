import 'package:cloud_firestore/cloud_firestore.dart';

class ChatDataModel {
  final String lastMsg;
  final Timestamp lastDateCloseChat;
  final Timestamp lastDateOpenChat;
  final Timestamp dateTime;
  final Timestamp writeLastData;

  ChatDataModel({
    required this.lastDateOpenChat,
    required this.dateTime,
    required this.writeLastData,
    required this.lastMsg,
    required this.lastDateCloseChat,
  });

  static ChatDataModel fromJson(DocumentSnapshot json) {
    return ChatDataModel(
      lastMsg: json['lastMsg'],
      lastDateCloseChat: json['lastDateCloseChat'] == ''
          ? Timestamp.now()
          : json['lastDateCloseChat'],
      lastDateOpenChat: json['lastDateOpenChat'] == ''
          ? Timestamp.now()
          : json['lastDateOpenChat'],
      dateTime: json['dateTime'] == '' ? Timestamp.now() : json['dateTime'],
      writeLastData:
          json['writeLastData'] == '' ? Timestamp.now() : json['writeLastData'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lastMsg': lastMsg,
      'lastDateCloseChat': lastDateCloseChat,
      'lastDateOpenChat': lastDateOpenChat,
      'dateTime': dateTime,
      'writeLastData': writeLastData,
    };
  }
}
