import 'package:get/get.dart';

class GetFirsMessageChatController extends GetxController {
  final firsMessage = false.obs;

  void setFirsMessage(bool firsMessage) => this.firsMessage.value = firsMessage;
}
