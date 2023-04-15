import 'package:Lancelot/screens/profile_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delayed_display/delayed_display.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_tindercard/flutter_tindercard.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';

import '../config/const.dart';
import '../config/firebase/firestore_operations.dart';
import '../config/utils.dart';
import '../getx/sympathy_cart_controller.dart';
import '../model/user_model.dart';
import '../widget/animation_widget.dart';
import '../widget/button_widget.dart';
import '../widget/card_widget.dart';

class HomeScreen extends StatefulWidget {
  final UserModel userModelCurrent;

  const HomeScreen({Key? key, required this.userModelCurrent})
      : super(key: key);

  @override
  _HomeScreen createState() => _HomeScreen(userModelCurrent);
}

class _HomeScreen extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late CardController controllerCard;
  int limit = 0, count = 0;
  bool isLoading = false, isWrite = false, isEmptyUser = false;
  List<UserModel> listPartnerSorted = [];
  List<String> listDisLike = [];
  final UserModel userModelCurrent;
  late final AnimationController animationController;
  final init = GetIt.I<FirebaseFirestore>().collection('User');
  final sympathyCar = Get.put(GetSympathyCartController());

  _HomeScreen(this.userModelCurrent);

  Future readFirebase(int setLimit, isReadDislike) async {
    limit += setLimit;

    if (listPartnerSorted.length > 2) listPartnerSorted.clear();

    if (isReadDislike) {
      await readDislikeFirebase(userModelCurrent.uid)
          .then((list) => listDisLike.addAll(list));
    }

    await init
        .where('myPol', isEqualTo: userModelCurrent.searchPol)
        .limit(limit)
        .get()
        .then((QuerySnapshot querySnapshot) async {
      for (var document in querySnapshot.docs) {
        final data = document.data() as Map<String, dynamic>;
        if (userModelCurrent.rangeStart <= ageIntParse(data['ageTime']) &&
            userModelCurrent.rangeEnd >= ageIntParse(data['ageTime']) &&
            data['uid'] != userModelCurrent.uid) {
          bool isDislike = true;
          await Future.forEach(listDisLike, (idUser) {
            if (idUser == data['uid']) isDislike = false;
          }).then((_) async {
            if (!isDislike) return;
            listPartnerSorted.add(UserModel.fromDocument(data));
          });
        }
      }
    }).then((_) {
      if (listPartnerSorted.isEmpty) {
        count++;
        if (count >= 8) {
          listDisLike.clear();
          deleteDislike(userModelCurrent.uid);
          count = 0;
          isEmptyUser = true;
        }
      } else {
        isEmptyUser = false;
      }

      if (listPartnerSorted.length < 3) {
        count++;
        if (count >= 10) {
          listDisLike.clear();
          deleteDislike(userModelCurrent.uid);
          count = 0;
        }
      }

      isWrite = true;
    });

    setState(() => isLoading = true);
  }

  @override
  void initState() {
    animationController = AnimationController(vsync: this);
    readFirebase(
      3,
      true,
    );
    super.initState();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    if (isLoading) {
      return Scaffold(
        backgroundColor: color_black_88,
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: AnimationLimiter(
            child: AnimationConfiguration.staggeredList(
              position: 1,
              child: SlideAnimation(
                duration: const Duration(milliseconds: 2000),
                verticalOffset: 250,
                child: FadeInAnimation(
                  duration: const Duration(seconds: 4),
                  child: Column(
                    children: [
                      if (!isEmptyUser)
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              height: height * 0.66,
                              child: TinderSwapCard(
                                animDuration: 900,
                                totalNum: listPartnerSorted.length + 1,
                                maxWidth: width * 0.98,
                                maxHeight: height * 0.49,
                                minWidth: width * 0.96,
                                minHeight: height * 0.48,
                                cardBuilder: (context, index) {
                                  if (index < listPartnerSorted.length) {
                                    return cardPartner(
                                      userModelPartner:
                                          listPartnerSorted[index],
                                      onTap: () => Navigator.push(
                                        context,
                                        FadeRouteAnimation(
                                          ProfileScreen(
                                            userModelPartner:
                                                listPartnerSorted[index],
                                            isBack: true,
                                            idUser: '',
                                            userModelCurrent: userModelCurrent,
                                          ),
                                        ),
                                      ),
                                    );
                                  } else {
                                    if (isWrite) {
                                      isWrite = false;
                                      readFirebase(12, false);
                                    }

                                    return const cardLoadingHome(
                                      radius: 22,
                                    );
                                  }
                                },
                                cardController: controllerCard =
                                    CardController(),
                                swipeUpdateCallback: (details, align) {
                                  setColorCard(align, sympathyCar);
                                },
                                swipeCompleteCallback:
                                    (orientation, int index) async {
                                  if (orientation.toString() ==
                                      'CardSwipeOrientation.LEFT') {
                                    listDisLike
                                        .add(listPartnerSorted[index].uid);

                                    await createDisLike(userModelCurrent,
                                        listPartnerSorted[index]);
                                    await CachedNetworkImage.evictFromCache(
                                        listPartnerSorted[index]
                                            .listImageUri[0]);
                                  }

                                  if (orientation.toString() ==
                                      'CardSwipeOrientation.RIGHT') {
                                    listDisLike
                                        .add(listPartnerSorted[index].uid);

                                    await createDisLike(userModelCurrent,
                                        listPartnerSorted[index]);

                                    await createSympathy(
                                        listPartnerSorted[index].uid,
                                        userModelCurrent);
                                    if (listPartnerSorted[index].token != '' &&
                                        listPartnerSorted[index].notification) {
                                      await sendFcmMessage(
                                          'Lancelot',
                                          'У вас симпатия',
                                          listPartnerSorted[index].token,
                                          'sympathy',
                                          userModelCurrent.uid,
                                          userModelCurrent.listImageUri[0]);
                                    }
                                    await CachedNetworkImage.evictFromCache(
                                        listPartnerSorted[index]
                                            .listImageUri[0]);
                                  }

                                  sympathyCar.setIndex(0);
                                },
                              ),
                            ),
                            GetBuilder(builder:
                                (GetSympathyCartController controller) {
                              if (controller.colorIndex >= 0.2) {
                                if (!controller.isLike) {
                                  return Container(
                                    height: height / 2.9,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: const AssetImage(
                                            'images/ic_heart.png'),
                                        colorFilter: ColorFilter.mode(
                                          Colors.white.withOpacity(
                                              controller.colorIndex),
                                          BlendMode.modulate,
                                        ),
                                      ),
                                    ),
                                  );
                                } else {
                                  return Container(
                                    height: height / 2.9,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: const AssetImage(
                                            'images/ic_remove.png'),
                                        colorFilter: ColorFilter.mode(
                                          Colors.white.withOpacity(
                                              controller.colorIndex),
                                          BlendMode.modulate,
                                        ),
                                      ),
                                    ),
                                  );
                                }
                              }
                              return const SizedBox();
                            }),
                          ],
                        ),
                      if (isEmptyUser)
                        Column(
                          children: [
                            showAnimationNoUser(
                                animationController: animationController),
                            DelayedDisplay(
                              delay: const Duration(milliseconds: 500),
                              child: Padding(
                                padding: EdgeInsets.only(top: height / 14),
                                child: buttonUniversal(
                                  time: 550,
                                  text: 'Обновить',
                                  sizeText: height / 60,
                                  height: height / 18,
                                  width: height / 5,
                                  darkColors: true,
                                  colorButton: listColorMulticoloured,
                                  onTap: () => readFirebase(
                                    3,
                                    true,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      if (!isEmptyUser)
                        Row(
                          children: [
                            homeAnimationButton(
                              icon: Icons.close,
                              colors: Colors.white,
                              time: 2400,
                              onTap: () => controllerCard.triggerLeft(),
                            ),
                            homeAnimationButton(
                              icon: Icons.favorite,
                              colors: color_red,
                              time: 3000,
                              onTap: () => controllerCard.triggerRight(),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }
    return const loadingCustom();
  }
}
