import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delayed_display/delayed_display.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lancelot/screens/chat_user_screen.dart';
import 'package:lancelot/screens/profile_screen.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

import '../config/const.dart';
import '../config/firestore_operations.dart';
import '../config/utils.dart';
import '../model/user_model.dart';
import '../widget/animation_widget.dart';
import '../widget/button_widget.dart';
import '../widget/card_widget.dart';
import '../widget/component_widget.dart';

class SympathyScreen extends StatefulWidget {
  final UserModel userModelCurrent;

  const SympathyScreen({Key? key, required this.userModelCurrent})
      : super(key: key);

  @override
  // ignore: no_logic_in_create_state
  State<SympathyScreen> createState() => _SympathyScreenState(userModelCurrent);
}

class _SympathyScreenState extends State<SympathyScreen> with TickerProviderStateMixin{
  final UserModel userModelCurrent;
  final scrollController = ScrollController();
  int limit = 5;
  bool isLoadingUser = false;
  late final AnimationController animationController;

  _SympathyScreenState(this.userModelCurrent);

  @override
  void initState() {
    // Future.delayed(const Duration(milliseconds: 1300), () {
    //   setState(() => isLoadingUser = true);
    // });

    animationController = AnimationController(vsync: this);
    scrollController.addListener(() {
      if (!isLoadingUser) {
        setState(() => isLoadingUser = true);
      }
      if (scrollController.position.maxScrollExtent ==
          scrollController.offset) {
        setState(() => limit += 3);

        Future.delayed(const Duration(milliseconds: 600), () {
          scrollController.animateTo(
            scrollController.position.maxScrollExtent -
                MediaQuery.of(context).size.height / 7,
            duration: const Duration(milliseconds: 1500),
            curve: Curves.fastOutSlowIn,
          );
        });
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: color_black_88,
      body: SafeArea(
        child: SingleChildScrollView(
          controller: scrollController,
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              topPanel(context, 'Симпатии', Icons.favorite, color_red, false,
                  height),
              StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('User')
                    .doc(userModelCurrent.uid)
                    .collection('sympathy')
                    .orderBy("time", descending: true)
                    .limit(limit)
                    .snapshots(),
                builder: (context, AsyncSnapshot snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data.docs.length <= 0) {
                      return showIfNoData(height, 'images/animation_heart.json',
                          'У вас нет симпатий', animationController, 3);
                    } else {
                      return AnimationLimiter(
                        child: ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          scrollDirection: Axis.vertical,
                          itemCount: snapshot.data.docs.length + 1,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            if (index < snapshot.data.docs.length) {
                              var name = '',
                                  age = 0,
                                  indexAnimation = index + 1,
                                  imageUri = '',
                                  idDoc = '',
                                  city = '',
                                  state = '',
                                  uid = '',
                                  isMutuallyMy = false,
                                  isStart = true,
                                  token = '';
                              try {
                                uid = snapshot.data.docs[index]['uid'];
                                idDoc = snapshot.data.docs[index]['id_doc'];
                              } catch (E) {}

                              return AnimationConfiguration.staggeredList(
                                position: index,
                                delay: const Duration(milliseconds: 250),
                                child: SlideAnimation(
                                  duration: const Duration(milliseconds: 1500),
                                  verticalOffset: 220,
                                  curve: Curves.ease,
                                  child: FadeInAnimation(
                                    curve: Curves.easeOut,
                                    duration:
                                        const Duration(milliseconds: 3200),
                                    child: StreamBuilder(
                                      stream: FirebaseFirestore.instance
                                          .collection('User')
                                          .doc(uid)
                                          .snapshots(),
                                      builder: (context,
                                          AsyncSnapshot asyncSnapshotUser) {
                                        if (asyncSnapshotUser.hasData) {
                                          try {
                                            name =
                                                asyncSnapshotUser.data['name'];

                                            age = DateTime.now()
                                                    .difference(getDataTime(
                                                        asyncSnapshotUser
                                                            .data['ageTime']))
                                                    .inDays ~/
                                                365;

                                            state =
                                                asyncSnapshotUser.data['state'];
                                            city = asyncSnapshotUser
                                                .data['myCity'];
                                            imageUri = asyncSnapshotUser
                                                .data['listImageUri'][0];
                                            token =
                                                asyncSnapshotUser.data['token'];
                                          } catch (E) {}

                                          return SizedBox(
                                            child: StreamBuilder(
                                              stream: FirebaseFirestore.instance
                                                  .collection('User')
                                                  .doc(uid)
                                                  .collection('sympathy')
                                                  .where('uid',
                                                      isEqualTo:
                                                          userModelCurrent.uid)
                                                  .snapshots(),
                                              builder: (context,
                                                  AsyncSnapshot asyncSnapshot) {
                                                if (asyncSnapshot.hasData) {
                                                  getState(150).then((value) {
                                                    isMutuallyMy = false;
                                                  });

                                                  try {
                                                    for (int i = 0;
                                                        i <
                                                            asyncSnapshot.data
                                                                .docs.length;
                                                        i++) {
                                                      isMutuallyMy =
                                                          asyncSnapshot.data
                                                                      .docs[i]
                                                                  ['uid'] ==
                                                              userModelCurrent
                                                                  .uid;
                                                      if (isMutuallyMy) {
                                                        break;
                                                      }
                                                    }
                                                  } catch (E) {}

                                                  return ZoomTapAnimation(
                                                    end: 0.999,
                                                    onTap: () {
                                                      Navigator.push(
                                                          context,
                                                          FadeRouteAnimation(
                                                              ProfileScreen(
                                                                userModelPartner: UserModel(
                                                                    name: '',
                                                                uid: '',
                                                                myCity: '',
                                                                ageTime:
                                                                    Timestamp
                                                                        .now(),
                                                                userPol: '',
                                                                searchPol: '',
                                                                searchRangeStart:
                                                                    0,
                                                                userImageUrl: [],
                                                                userImagePath: [],
                                                                imageBackground:
                                                                    '',
                                                                userInterests: [],
                                                                searchRangeEnd:
                                                                    0,
                                                                ageInt: 0,
                                                                state: '',
                                                                token: '',
                                                                notification:
                                                                    true,
                                                                description:
                                                                    ''),
                                                            isBack: true,
                                                            idUser: uid,
                                                            userModelCurrent:
                                                                userModelCurrent,
                                                          )));
                                                    },
                                                    child: Container(
                                                      height: height / 4.5,
                                                      width: size.width,
                                                      padding: EdgeInsets.all(
                                                          height / 74),
                                                      child: Card(
                                                        shadowColor: Colors
                                                            .white
                                                            .withOpacity(.10),
                                                        color: color_black_88,
                                                        shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                                30),
                                                            side:
                                                            const BorderSide(
                                                              width: 0.8,
                                                              color: Colors
                                                                  .white10,
                                                            )),
                                                        elevation: 14,
                                                        child: Padding(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                              horizontal:
                                                              height /
                                                                  58,
                                                              vertical:
                                                              height /
                                                                  46),
                                                          child: Row(
                                                            mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                            children: [
                                                              Expanded(
                                                                flex: 1,

                                                                // width: width / 3.2,
                                                                child:
                                                                photoUser(
                                                                  uri: imageUri,
                                                                  width:
                                                                  height /
                                                                      8.2,
                                                                  height:
                                                                  height /
                                                                      8.2,
                                                                  state: state,
                                                                  padding: 5,
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                  width:
                                                                  height /
                                                                      77),
                                                              Expanded(
                                                                flex: 2,
                                                                child: Column(
                                                                  mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceEvenly,
                                                                  children: [
                                                                    Row(
                                                                      mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                      children: [
                                                                        DelayedDisplay(
                                                                          delay:
                                                                          Duration(milliseconds: indexAnimation * 350 < 2000 ? indexAnimation * 350 : 350),
                                                                          child:
                                                                          Column(
                                                                            crossAxisAlignment:
                                                                            CrossAxisAlignment.start,
                                                                            children: [
                                                                              RichText(
                                                                                text: TextSpan(
                                                                                  text: '${name.trim()}, $age',
                                                                                  style: GoogleFonts.lato(
                                                                                    textStyle: TextStyle(color: Colors.white, fontSize: height / 52, letterSpacing: .9),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              RichText(
                                                                                text: TextSpan(
                                                                                  text: city,
                                                                                  style: GoogleFonts.lato(
                                                                                    textStyle: TextStyle(color: Colors.white.withOpacity(.8), fontSize: height / 70, letterSpacing: .5),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                        Container(
                                                                          margin: EdgeInsets.only(
                                                                              bottom: height / 76,
                                                                              left: 10),
                                                                          alignment:
                                                                          Alignment.topRight,
                                                                          child:
                                                                          IconButton(
                                                                            onPressed:
                                                                                () async {
                                                                              deleteSympathy(idDoc, userModelCurrent.uid);
                                                                              await CachedNetworkImage.evictFromCache(imageUri);
                                                                            },
                                                                            icon:
                                                                            Icon(Icons.close, size: height / 40),
                                                                            color:
                                                                            Colors.white,
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    Row(
                                                                      mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceAround,
                                                                      children: [
                                                                        if (!isMutuallyMy)
                                                                          buttonUniversalAnimationColors(
                                                                              'Принять симпатию',
                                                                              [
                                                                                color_black_88,
                                                                                color_black_88
                                                                              ],
                                                                              height / 22,
                                                                              () {
                                                                            if (!isMutuallyMy) {
                                                                              createSympathy(uid, userModelCurrent).then((value) async {
                                                                                setState(() {});
                                                                                if (token != '' && asyncSnapshotUser.data['notification']) {
                                                                                  await sendFcmMessage('Lancelot', 'У вас взаимная симпатия', token, 'sympathy', userModelCurrent.uid, userModelCurrent.userImageUrl[0]);
                                                                                }
                                                                              });
                                                                            }
                                                                          }, indexAnimation * 300 < 1000 ? indexAnimation * 300 : 300),
                                                                        if (isMutuallyMy)
                                                                          buttonUniversal(
                                                                              'У вас взаимно',
                                                                              [
                                                                                Colors.blueAccent,
                                                                                Colors.purpleAccent,
                                                                                Colors.orangeAccent
                                                                              ],
                                                                              height / 22,
                                                                              () {
                                                                            deleteSympathyPartner(uid, userModelCurrent.uid).then((value) {
                                                                              Future.delayed(const Duration(milliseconds: 250), () {
                                                                                setState(() {});
                                                                              });
                                                                            });
                                                                          }, indexAnimation * 300 < 1000 ? indexAnimation * 300 : 300),
                                                                        customIconButton(
                                                                          onTap:
                                                                              () {
                                                                            Navigator.of(context).push(MaterialPageRoute(
                                                                                builder: (context) => ChatUserScreen(
                                                                                      friendId: uid,
                                                                                      friendName: name,
                                                                                      friendImage: imageUri,
                                                                                      userModelCurrent: userModelCurrent,
                                                                                      token: token,
                                                                                      notification: asyncSnapshotUser.data['notification'],
                                                                                        )));
                                                                          },
                                                                          path:
                                                                          'images/ic_send.png',
                                                                          height:
                                                                          height / 28,
                                                                          width:
                                                                          height / 28,
                                                                          padding:
                                                                          4,
                                                                        )
                                                                      ],
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                }
                                                return const SizedBox();
                                              },
                                            ),
                                          );
                                        }
                                        return const SizedBox();
                                      },
                                    ),
                                  ),
                                ),
                              );
                            } else {
                              if (snapshot.data.docs.length >= limit) {
                                if (isLoadingUser) {
                                  return Padding(
                                    padding: EdgeInsets.symmetric(
                                        vertical: height / 16),
                                    child: const Center(
                                      child: SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 0.8,
                                        ),
                                      ),
                                    ),
                                  );
                                }
                                // else {
                                //   return cardLoadingWidget(size, .18, .09);
                                // }
                              }
                            }

                            return const SizedBox();
                          },
                        ),
                      );
                    }
                  }
                  return const SizedBox();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

