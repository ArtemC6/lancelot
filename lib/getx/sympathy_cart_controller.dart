import 'package:get/get.dart';

import '../model/user_model.dart';

class GetSympathyCartController extends GetxController {
  double colorIndex = 0.0;
  bool isLike = false;
  List<UserModel> listPartner = [];

  setIndex(double index) {
    colorIndex = index;
    update();
  }

  setLike(bool like) {
    isLike = like;
    update();
  }
}
