import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_tindercard/flutter_tindercard.dart';
import 'package:lancelot/screens/profile_screen.dart';

// import 'package:flutter_colors_border/flutter_colors_border.dart';

import '../config/const.dart';
import '../config/firestore_operations.dart';
import '../config/utils.dart';
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
  double colorIndex = 0;
  int limit = 0, count = 0;
  bool isLike = false,
      isLook = false,
      isLoading = false,
      isReadDislike = false,
      isWrite = false,
      isEmptyUser = false;
  List<UserModel> userModelPartner = [];
  List<String> listDisLike = [];
  final UserModel userModelCurrent;
  final scrollController = ScrollController();
  late final AnimationController animationController;

  _HomeScreen(this.userModelCurrent);

  Future readFirebase(int setLimit, bool isReadDislike) async {
    limit += setLimit;

    if (userModelPartner.length > 2) {
      userModelPartner.clear();
    }

    if (isReadDislike) {
      await readDislikeFirebase(userModelCurrent.uid).then((list) {
        listDisLike.addAll(list);
      });
    }

    await FirebaseFirestore.instance
        .collection('User')
        .where('myPol', isEqualTo: userModelCurrent.searchPol)
        // .where('myCity', isEqualTo: userModelCurrent.myCity)
        .limit(limit)
        .get()
        .then((QuerySnapshot querySnapshot) async {
      for (var document in querySnapshot.docs) {
        Map<String, dynamic> data = document.data() as Map<String, dynamic>;
        if (userModelCurrent.searchRangeStart <= ageInt(data) &&
            userModelCurrent.searchRangeEnd >= ageInt(data) &&
            data['uid'] != userModelCurrent.uid) {
          bool isDislike = true;
          await Future.forEach(listDisLike, (idUser) {
            if (idUser == data['uid']) {
              isDislike = false;
            }
          }).then((value) async {
            if (isDislike) {
              userModelPartner.add(UserModel(
                  name: data['name'],
                  uid: data['uid'],
                  ageTime: Timestamp.now(),
                  userPol: data['myPol'],
                  searchPol: '',
                  searchRangeStart: 0,
                  userInterests: List<String>.from(data['listInterests']),
                  userImagePath: [],
                  userImageUrl: List<String>.from(data['listImageUri']),
                  searchRangeEnd: 0,
                  myCity: data['myCity'],
                  imageBackground: data['imageBackground'],
                  ageInt: ageInt(data),
                  state: data['state'],
                  token: data['token'],
                  notification: data['notification'],
                  description: data['description']));
            }
          });
        }
      }
    }).then((value) async {
      userModelPartner.toSet();

      setState(() {
        if (userModelPartner.isEmpty) {
          count++;
          if (count >= 6) {
            listDisLike.clear();
            deleteDislike(userModelCurrent.uid);
            count = 0;
            isEmptyUser = true;
          }
        } else {
          isEmptyUser = false;
        }

        if (userModelPartner.length < 3) {
          count++;
          if (count >= 10) {
            listDisLike.clear();
            deleteDislike(userModelCurrent.uid);
            count = 0;
          }
        }

        isWrite = true;
        isLoading = true;
      });
    });
  }

  @override
  void initState() {
    animationController = AnimationController(vsync: this);
    super.initState();
    readFirebase(
      10,
      true,
    );
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    var size = MediaQuery.of(context).size;

    if (isLook) {
      Future.delayed(const Duration(milliseconds: 5000), () {
        setState(() {
          isLook = false;
        });
      });
    }

    if (isLoading) {
      return Scaffold(
        backgroundColor: color_black_88,
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: AnimationLimiter(
              child: AnimationConfiguration.staggeredList(
                position: 1,
                delay: const Duration(milliseconds: 200),
                child: SlideAnimation(
                  duration: const Duration(milliseconds: 2000),
                  verticalOffset: 250,
                  curve: Curves.ease,
                  child: FadeInAnimation(
                    curve: Curves.easeOut,
                    duration: const Duration(milliseconds: 3700),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        if (!isEmptyUser)
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                height: height * 0.68,
                                child: TinderSwapCard(
                                  animDuration: 850,
                                  swipeUp: false,
                                  swipeDown: false,
                                  orientation: AmassOrientation.BOTTOM,
                                  allowVerticalMovement: true,
                                  totalNum: userModelPartner.length + 1,
                                  stackNum: 3,
                                  swipeEdge: 3.0,
                                  maxWidth: width * 0.98,
                                  maxHeight: height * 0.52,
                                  minWidth: width * 0.96,
                                  minHeight: height * 0.44,
                                  cardBuilder: (context, index) {
                                    if (index < userModelPartner.length) {
                                      return SizedBox(
                                        child: InkWell(
                                          splashColor: Colors.transparent,
                                          highlightColor: Colors.transparent,
                                          onTap: () {
                                            Navigator.push(
                                                context,
                                                FadeRouteAnimation(
                                                    ProfileScreen(
                                                  userModelPartner:
                                                      userModelPartner[index],
                                                  isBack: true,
                                                  idUser: '',
                                                  userModelCurrent:
                                                      userModelCurrent,
                                                )));
                                          },
                                          child: cardPartner(index,
                                              userModelPartner, size, context),
                                        ),
                                      );
                                    } else {
                                      if (isWrite) {
                                        isWrite = false;
                                        readFirebase(14, false);
                                      }
                                      return cardLoading(size, 22);
                                    }
                                  },
                                  cardController: controllerCard =
                                      CardController(),
                                  swipeUpdateCallback:
                                      (DragUpdateDetails details,
                                          Alignment align) {
                                    setState(() {
                                      if (align.x < 0) {
                                        int incline = int.parse(align.x
                                            .toStringAsFixed(1)
                                            .substring(1, 2));

                                        if (incline <= 10 && incline > 3) {
                                          colorIndex =
                                              double.parse('0.$incline');
                                          isLike = true;
                                          isLook = true;
                                        } else {
                                          isLook = false;
                                        }
                                      } else if (align.x > 0) {
                                        if (align.y.toDouble() < 1 &&
                                            align.y.toDouble() > 0.3) {
                                          colorIndex = double.parse(
                                              '0.${align.x.toInt()}');
                                          isLook = true;
                                          isLike = false;
                                        } else {
                                          isLook = false;
                                        }
                                      }
                                    });
                                  },
                                  swipeCompleteCallback:
                                      (CardSwipeOrientation orientation,
                                          int index) async {
                                    setState(() {
                                      if (orientation.toString() ==
                                          'CardSwipeOrientation.LEFT') {
                                        isLook = false;
                                        listDisLike
                                            .add(userModelPartner[index].uid);

                                        createDisLike(userModelCurrent,
                                                userModelPartner[index])
                                            .then((value) {
                                          CachedNetworkImage.evictFromCache(
                                              userModelPartner[index]
                                                  .userImageUrl[0]);
                                        });
                                      }

                                      if (orientation.toString() ==
                                          'CardSwipeOrientation.RIGHT') {
                                        isLook = false;

                                        listDisLike
                                            .add(userModelPartner[index].uid);

                                        createDisLike(userModelCurrent,
                                            userModelPartner[index]);

                                        createSympathy(
                                                userModelPartner[index].uid,
                                                userModelCurrent)
                                            .then((value) async {
                                          if (userModelPartner[index].token !=
                                                  '' &&
                                              userModelPartner[index]
                                                  .notification) {
                                            await sendFcmMessage(
                                                'Lancelot',
                                                'У вас симпатия',
                                                userModelPartner[index].token,
                                                'sympathy',
                                                userModelCurrent.uid,
                                                userModelCurrent
                                                    .userImageUrl[0]);
                                          }
                                          CachedNetworkImage.evictFromCache(
                                              userModelPartner[index]
                                                  .userImageUrl[0]);
                                        });
                                      }
                                    });
                                  },
                                ),
                              ),
                              if (isLook && !isLike)
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      isLook = false;
                                    });
                                  },
                                  child: Container(
                                    alignment: Alignment.center,
                                    width: width,
                                    height: height / 2.9,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: const AssetImage(
                                            'images/ic_heart.png'),
                                        colorFilter: ColorFilter.mode(
                                          Colors.white.withOpacity(colorIndex),
                                          BlendMode.modulate,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              if (isLook && isLike)
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      isLook = false;
                                    });
                                  },
                                  child: Container(
                                    alignment: Alignment.center,
                                    width: width,
                                    height: height / 2.9,
                                    decoration: BoxDecoration(
                                        image: DecorationImage(
                                            image: const AssetImage(
                                                'images/ic_remove.png'),
                                            colorFilter: ColorFilter.mode(
                                              Colors.white
                                                  .withOpacity(colorIndex),
                                              BlendMode.modulate,
                                            ))),
                                  ),
                                ),
                            ],
                          ),
                        if (isEmptyUser)
                          Column(
                            children: [
                              showAnimationNoUser(
                                  height, width, animationController),
                              SlideFadeTransition(
                                animationDuration:
                                    const Duration(milliseconds: 700),
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 60),
                                  child: buttonUniversalAnimationColors(
                                      'Обновить',
                                      [
                                        Colors.blueAccent,
                                        Colors.purpleAccent,
                                        Colors.orangeAccent
                                      ],
                                      height / 21, () {
                                    readFirebase(
                                      10,
                                      true,
                                    );
                                  }, 750),
                                ),
                              ),
                            ],
                          ),
                        if (!isEmptyUser)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              homeAnimationButton(height, width, () {
                                controllerCard.triggerLeft();
                              }, Colors.white, Icons.close, 1800),
                              homeAnimationButton(height, width, () {
                                controllerCard.triggerRight();
                              }, color_red, Icons.favorite, 2400),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    } else {
      return const loadingCustom();
    }
  }
}
