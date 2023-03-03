import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class GetChatDataController extends GetxController {
  dynamic dateTime;
  dynamic lastDateCloseChat;
  dynamic lastDateOpenChat;
  String lastMsg = '';
  dynamic writeLastData;

  void setLastDateCloseChat(lastDateCloseChat) {
    this.lastDateCloseChat = lastDateCloseChat;
    update();
  }

  void setLastDateOpenChat(lastDateOpenChat) {
    this.lastDateOpenChat = lastDateOpenChat;
    update();
  }

  void setLastMsg(lastMsg) {
    this.lastMsg = lastMsg;
    update();
  }

  void setWriteLastData(writeLastData) {
    this.writeLastData = writeLastData;
    update();
  }

  void setDataTime(dateTime) {
    this.dateTime = dateTime;
    update();
  }
}
