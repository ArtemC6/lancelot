import 'dart:async';

import 'package:Lancelot/screens/profile_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delayed_display/delayed_display.dart';
import 'package:drop_shadow/drop_shadow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

import '../config/const.dart';
import '../config/firebase/firestore_operations.dart';
import '../config/utils.dart';
import '../model/user_model.dart';
import '../widget/animation_widget.dart';
import '../widget/button_widget.dart';
import '../widget/card_widget.dart';
import '../widget/component_widget.dart';
import 'chat_user_screen.dart';

class SympathyScreen extends StatefulWidget {
  final UserModel userModelCurrent;

  const SympathyScreen({Key? key, required this.userModelCurrent})
      : super(key: key);

  @override
  State<SympathyScreen> createState() => _SympathyScreenState(userModelCurrent);
}

class _SympathyScreenState extends State<SympathyScreen>
    with TickerProviderStateMixin {
  final UserModel userModelCurrent;
  final scrollController = ScrollController();
  final Map<String, dynamic> data = {};
  int limit = 5;
  bool isLoadingUser = false;
  late final AnimationController animationController;
  late QuerySnapshot<Map<String, dynamic>> query;

  _SympathyScreenState(this.userModelCurrent);

  @override
  void initState() {
    animationController = AnimationController(vsync: this);
    scrollController.addListener(() {
      if (!isLoadingUser) setState(() => isLoadingUser = true);

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
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: color_black_88,
      body: SafeArea(
        child: SingleChildScrollView(
          controller: scrollController,
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              topPanel(
                height: height,
                text: 'Симпатии',
                isBack: false,
                color: color_red,
                icon: Icons.favorite,
              ),
              FutureBuilder(
                future: readSympathyFirebase(limit, userModelCurrent.uid),
                builder: (context, AsyncSnapshot snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data.docs.length <= 0) {
                      return showIfNoData(
                          imagePath: 'images/animation_heart.json',
                          text: 'У вас нет симпатий',
                          animationController: animationController);
                    } else {
                      return AnimationLimiter(
                        child: ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          itemCount: snapshot.data.docs.length + 1,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            if (index < snapshot.data.docs.length) {
                              int aIndex = index + 1,
                                  timeAnim =
                                      aIndex * 300 < 1000 ? aIndex * 300 : 300;
                              bool isMySym = false;
                              String uid = snapshot.data.docs[index]['uid'],
                                  idDoc = snapshot.data.docs[index]['id_doc'];
                              return AnimationConfiguration.staggeredList(
                                position: index,
                                delay: const Duration(milliseconds: 400),
                                child: SlideAnimation(
                                  duration: const Duration(milliseconds: 1500),
                                  verticalOffset: 220,
                                  child: FadeInAnimation(
                                    curve: Curves.easeOut,
                                    duration:
                                        const Duration(milliseconds: 3200),
                                    child: FutureBuilder(
                                      future: readUserFirebase(uid),
                                      builder: (context, userFriend) {
                                        if (userFriend.hasData) {
                                          final friend = userFriend.data!;
                                          return FutureBuilder(
                                            future: readSympathyFriendFirebase(
                                                uid,
                                                userModelCurrent.uid,
                                                limit),
                                            builder: (context, snap) {
                                              if (snap.hasData) {
                                                getFuture(70).then(
                                                    (i) => isMySym = false);

                                                for (var data
                                                    in snap.data!.docs) {
                                                  isMySym = data['uid'] ==
                                                      userModelCurrent.uid;
                                                }
                                                return GestureDetector(
                                                  onTap: () => Navigator.push(
                                                    context,
                                                    FadeRouteAnimation(
                                                      ProfileScreen(
                                                        userModelPartner:
                                                            UserModel
                                                                .fromDocument(
                                                                    data),
                                                        isBack: true,
                                                        idUser: uid,
                                                        userModelCurrent:
                                                            userModelCurrent,
                                                      ),
                                                    ),
                                                  ),
                                                  child: Container(
                                                    height: height / 4.5,
                                                    padding: EdgeInsets.all(
                                                        height / 72),
                                                    child: Card(
                                                      shadowColor: Colors.white
                                                          .withOpacity(.10),
                                                      color: color_black_88,
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(30),
                                                        side: const BorderSide(
                                                          width: 0.8,
                                                          color: Colors.white10,
                                                        ),
                                                      ),
                                                      elevation: 14,
                                                      child: Padding(
                                                        padding: EdgeInsets.all(
                                                            height / 58),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Flexible(
                                                              child: photoUser(
                                                                uri: friend
                                                                    .listImageUri[0],
                                                                width: height /
                                                                    8.2,
                                                                height: height /
                                                                    8.2,
                                                                state: friend
                                                                    .state,
                                                                padding: 2.2,
                                                              ),
                                                            ),
                                                            SizedBox(
                                                                width: height /
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
                                                                      Padding(
                                                                        padding:
                                                                            EdgeInsets.only(bottom: height / 72),
                                                                        child:
                                                                            DelayedDisplay(
                                                                              delay:
                                                                              Duration(milliseconds: timeAnim),
                                                                          child:
                                                                              Column(
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.start,
                                                                            children: [
                                                                              Text(
                                                                                '${friend.name.trim()}, ${friend.ageInt}',
                                                                                style: GoogleFonts.lato(
                                                                                  textStyle: TextStyle(color: Colors.white, fontSize: height / 49, letterSpacing: .9),
                                                                                ),
                                                                              ),
                                                                              Text(
                                                                                friend.myCity,
                                                                                style: GoogleFonts.lato(
                                                                                  textStyle: TextStyle(color: Colors.white.withOpacity(.8), fontSize: height / 67, letterSpacing: .5),
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Container(
                                                                        margin:
                                                                            EdgeInsets.only(
                                                                          bottom:
                                                                              height / 120,
                                                                          right:
                                                                              height / 120,
                                                                        ),
                                                                        alignment:
                                                                            Alignment.topRight,
                                                                        child:
                                                                            GestureDetector(
                                                                              onTap:
                                                                              () {
                                                                            deleteSympathy(idDoc,
                                                                                userModelCurrent.uid);
                                                                            setState(() {});
                                                                            CachedNetworkImage.evictFromCache(friend.listImageUri[0]);
                                                                          },
                                                                          child:
                                                                              Icon(
                                                                            Icons.close,
                                                                            size:
                                                                                width / 18,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceAround,
                                                                    children: [
                                                                      if (!isMySym)
                                                                        buttonUniversalNoState(
                                                                          text:
                                                                              'Принять симпатию',
                                                                          darkColors:
                                                                              false,
                                                                          colorButton: const [
                                                                            color_black_88,
                                                                            color_black_88
                                                                          ],
                                                                          height:
                                                                              width / 9.9,
                                                                          width:
                                                                              width / 2.6,
                                                                          sizeText:
                                                                              width / 35,
                                                                          time:
                                                                              timeAnim,
                                                                          onTap:
                                                                              () {
                                                                                createSympathy(uid, userModelCurrent).then((i) {
                                                                              setState(() {});
                                                                              if (friend.token.isNotEmpty && friend.notification) {
                                                                                sendFcmMessage('Lancelot', 'У вас взаимная симпатия', friend.token, 'sympathy', userModelCurrent.uid, userModelCurrent.listImageUri[0]);
                                                                              }
                                                                            });
                                                                          },
                                                                        ),
                                                                      if (isMySym)
                                                                        buttonUniversal(
                                                                          text:
                                                                              'У вас взаимно',
                                                                          darkColors:
                                                                              true,
                                                                          colorButton:
                                                                              listColorMulticoloured,
                                                                          height:
                                                                              width / 10.2,
                                                                          width:
                                                                              width / 3.2,
                                                                          sizeText:
                                                                              width / 34.5,
                                                                          time:
                                                                              timeAnim,
                                                                          onTap: () =>
                                                                              deleteSympathyPartner(uid, userModelCurrent.uid).then((i) => setState(() {})),
                                                                        ),
                                                                      DropShadow(
                                                                        blurRadius:
                                                                            2.5,
                                                                        spread:
                                                                            0.1,
                                                                        opacity:
                                                                            1,
                                                                        child:
                                                                            ZoomTapAnimation(
                                                                          onTap: () =>
                                                                              Navigator.of(context).push(
                                                                            MaterialPageRoute(
                                                                              builder: (context) => ChatUserScreen(
                                                                                friendId: uid,
                                                                                friendName: friend.name,
                                                                                friendImage: friend.listImageUri[0],
                                                                                userModelCurrent: userModelCurrent,
                                                                                token: friend.token,
                                                                                notification: friend.notification,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          child:
                                                                              Padding(
                                                                            padding: EdgeInsets.only(
                                                                                bottom: height / 74,
                                                                                top: height / 140,
                                                                                left: height / 100,
                                                                                right: height / 120),
                                                                            child:
                                                                                Image.asset(
                                                                              'images/ic_send.png',
                                                                              height: height / 23,
                                                                              width: height / 23,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
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
