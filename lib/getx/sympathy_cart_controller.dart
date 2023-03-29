import 'package:get/get.dart';

class GetSympathyCartController extends GetxController {
  double colorIndex = 0.0;
  bool isLike = false;

  setIndex(double index) {
    colorIndex = index;
    update();
  }

  setLike(bool like) {
    isLike = like;
    update();
  }
}
