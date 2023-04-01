import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';

import '../../getx/chat_data_controller.dart';

class ChatDataFirebase {
  static late StreamSubscription listenerChatData;

  Future readChatDataFirebase(
    String uid,
    String friendId,
    GetChatDataController getChatDataController,
  ) async {
    listenerChatData = GetIt.I<FirebaseFirestore>()
        .collection('User')
        .doc(uid)
        .collection('messages')
        .doc(friendId)
        .snapshots()
        .listen((snapshot) {
      try {
        final data = snapshot.data() as Map<String, dynamic>;

        final lastDateCloseChat = data['last_date_close_chat'];
        final lastDateOpenChat = data['last_date_open_chat'];
        final writeLastData = data['writeLastData'];
        final lastMsg = data['lastMsg'];
        final dateTime = data['date'];

        if (lastDateCloseChat != null) {
          getChatDataController
              .setLastDateCloseChat(data['last_date_close_chat']);
        }

        if (lastDateOpenChat != null) {
          getChatDataController
              .setLastDateOpenChat(data['last_date_open_chat']);
        }

        if (writeLastData != null) {
          getChatDataController.setWriteLastData(data['writeLastData']);
        }

        if (lastMsg != null) {
          getChatDataController.setLastMsg(data['lastMsg']);
        }
        if (dateTime != null) {
          getChatDataController.setDataTime(data['date']);
        }
      } catch (e) {}
    });
  }

  closeChatDataFirebase() {
    try {
      listenerChatData.cancel();
    } catch (e) {}
  }
}
