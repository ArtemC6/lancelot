import 'dart:async';
import 'dart:ui';

import 'package:bottom_sheet/bottom_sheet.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colors_border/flutter_colors_border.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

import '../config/const.dart';
import '../config/firestore_operations.dart';
import '../model/user_model.dart';
import '../widget/animation_widget.dart';
import '../widget/component_widget.dart';
import '../widget/dialog_widget.dart';
import '../widget/message_widget.dart';

class ChatUserScreen extends StatefulWidget {
  final String friendName, friendId, friendImage, token;
  final bool notification;
  final UserModel userModelCurrent;

  const ChatUserScreen({
    super.key,
    required this.friendId,
    required this.token,
    required this.friendName,
    required this.notification,
    required this.friendImage,
    required this.userModelCurrent,
  });

  @override
  State<ChatUserScreen> createState() => _ChatUserScreenState(
      friendId, friendName, friendImage, userModelCurrent, token, notification);
}

class _ChatUserScreenState extends State<ChatUserScreen>
    with WidgetsBindingObserver {
  String friendId,
      friendName,
      friendImage,
      token,
      chatBackground = 'images/animation_chat_bac_2.json';

  bool notification;
  final UserModel userModelCurrent;
  final scrollController = ScrollController();
  int limit = 20;
  double chatBlur = 0, chatBlackout = 2, chatBlackoutFinal = 0.2;
  bool isLoading = false, isWrite = true;

  _ChatUserScreenState(this.friendId, this.friendName, this.friendImage,
      this.userModelCurrent, this.token, this.notification);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    readUser();
    scrollController.addListener(() {
      if (scrollController.position.maxScrollExtent ==
          scrollController.offset) {
        setState(() {
          limit += 10;
        });

        Future.delayed(const Duration(milliseconds: 600), () {
          scrollController.animateTo(
            scrollController.position.maxScrollExtent -
                MediaQuery.of(context).size.height / 6,
            duration: const Duration(milliseconds: 1500),
            curve: Curves.fastOutSlowIn,
          );
        });
      }
    });
    createLastOpenChat(widget.friendId, userModelCurrent.uid);
    createLastCloseChat(userModelCurrent.uid, widget.friendId, '');
  }

  void startTimer() {
    Timer.periodic(
      const Duration(seconds: 1),
      (Timer timer) {
        setState(() {
          isWrite = true;
        });
        timer.cancel();
      },
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.paused:
        if (isWrite) {
          startTimer();
          isWrite = false;
          createLastOpenChat(widget.friendId, userModelCurrent.uid);
          createLastCloseChat(
              userModelCurrent.uid, widget.friendId, DateTime.now());
        }
        break;
      case AppLifecycleState.resumed:
        if (isWrite) {
          startTimer();
          isWrite = false;
          createLastOpenChat(widget.friendId, userModelCurrent.uid);
          createLastCloseChat(userModelCurrent.uid, widget.friendId, '');
        }
        break;
      case AppLifecycleState.inactive:
        if (isWrite) {
          startTimer();
          isWrite = false;
          createLastOpenChat(widget.friendId, userModelCurrent.uid);
          createLastCloseChat(
              userModelCurrent.uid, widget.friendId, DateTime.now());
        }
        break;
      case AppLifecycleState.detached:
        if (isWrite) {
          startTimer();
          isWrite = false;
          createLastOpenChat(widget.friendId, userModelCurrent.uid);
          createLastCloseChat(
              userModelCurrent.uid, widget.friendId, DateTime.now());
        }
        break;
    }
  }

  Future readUser() async {
    final prefs = await SharedPreferences.getInstance();
    if (friendName.isEmpty && friendImage.isEmpty && token.isEmpty) {
      await readUserFirebase(friendId).then((user) {
        setState(() {
          friendName = user.name;
          friendImage = user.userImageUrl[0];
          token = user.token;
          notification = user.notification;
        });
        isLoading = true;
      });
    }

    setState(() {
      chatBackground = prefs.getString('chatBackground') ??
          'images/animation_chat_bac_2.json';

      chatBlur = prefs.getDouble('chatBlur') ?? 0;
      chatBlackoutFinal = prefs.getDouble('chatBlackout') ?? 0.2;

      if (chatBlackoutFinal < 1.0) {
        chatBlackout =
            double.parse(chatBlackoutFinal.toString().substring(2, 3));
      } else {
        chatBlackout = 10;
      }

      isLoading = true;
    });
  }

  Future setBackground(String listAnimationChatBac) async {
    await SharedPreferences.getInstance()
        .then((i) => i.setString('chatBackground', listAnimationChatBac));

    setState(() {
      chatBackground = listAnimationChatBac;
    });
  }

  Future setBlur(value) async {
    await SharedPreferences.getInstance()
        .then((i) => i.setDouble('chatBlur', value));
    setState(() {
      chatBlur = value;
    });
  }

  Future setBlackout(double value) async {
    double result;
    if (value < 10.0) {
      result = double.parse('0.${value.toInt()}');
    } else {
      result = 1;
    }

    await SharedPreferences.getInstance()
        .then((i) => i.setDouble('chatBlackout', result));

    setState(() {
      chatBlackoutFinal = result;
    });
  }

  @override
  void dispose() {
    createLastOpenChat(widget.friendId, userModelCurrent.uid);
    createLastCloseChat(userModelCurrent.uid, widget.friendId, DateTime.now());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    if (isLoading) {
      return Scaffold(
        backgroundColor: color_black_88,
        body: Stack(
          children: [
            Lottie.asset(
                width: width, height: height, fit: BoxFit.fill, chatBackground),
            BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: chatBlur,
                sigmaY: chatBlur,
              ),
              child: Container(
                color: Colors.black.withOpacity(chatBlackoutFinal),
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                        top: height / 26,
                        left: 14,
                        right: 14,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          topPanelChat(
                            userModelCurrent: userModelCurrent,
                            friendId: friendId,
                            friendImage: friendImage,
                            friendName: friendName,
                          ),
                          PopupMenuButton<int>(
                            enabled: true,
                            icon: Icon(
                              Icons.more_vert,
                              size: height / 38,
                              color: Colors.white,
                            ),
                            color: Colors.transparent,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(16),
                              ),
                              side:
                                  BorderSide(color: Colors.white38, width: 0.7),
                            ),
                            onSelected: (value) {
                              if (value == 0) {
                                showAlertDialogDeleteChat(context, friendId,
                                    friendName, true, friendImage, height);
                              } else if (value == 1) {
                                showFlexibleBottomSheet(
                                  bottomSheetColor: Colors.transparent,
                                  duration: const Duration(milliseconds: 800),
                                  context: context,
                                  builder: (
                                    BuildContext context,
                                    ScrollController scrollController,
                                    double bottomSheetOffset,
                                  ) {
                                    return StatefulBuilder(
                                        builder: (context, setState) {
                                      return Container(
                                        height: height / 2.6,
                                        padding: const EdgeInsets.only(
                                            top: 10, left: 10, right: 10),
                                        child: Column(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.only(
                                                  top: 2, left: 8),
                                              child: Row(
                                                children: [
                                                  SizedBox(
                                                    width: width / 4.2,
                                                    child: RichText(
                                                      text: TextSpan(
                                                        text: 'Размытие',
                                                        style: GoogleFonts.lato(
                                                          textStyle: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize:
                                                                  height / 62,
                                                              letterSpacing:
                                                                  .9),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Container(
                                                    width: width / 1.5,
                                                    padding:
                                                        const EdgeInsets.only(
                                                            right: 8, left: 4),
                                                    child: SfSlider(
                                                      activeColor: Colors.blue,
                                                      min: 0,
                                                      max: 20,
                                                      value: chatBlur,
                                                      stepSize: 1,
                                                      enableTooltip: false,
                                                      onChanged:
                                                          (dynamic value) {
                                                        setState(() {
                                                          chatBlur = value;
                                                        });
                                                        setBlur(value);
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.only(
                                                  bottom: 10, left: 8),
                                              child: Row(
                                                children: [
                                                  SizedBox(
                                                    width: width / 4.2,
                                                    child: RichText(
                                                      text: TextSpan(
                                                        text: 'Затемнение',
                                                        style: GoogleFonts.lato(
                                                          textStyle: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize:
                                                                  height / 62,
                                                              letterSpacing:
                                                                  .9),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            right: 8, left: 4),
                                                    width: width / 1.5,
                                                    child: SfSlider(
                                                      activeColor: Colors.blue,
                                                      min: 0,
                                                      max: 10,
                                                      value: chatBlackout,
                                                      stepSize: 1,
                                                      enableTooltip: false,
                                                      onChanged:
                                                          (dynamic value) {
                                                        setState(() {
                                                          chatBlackout = value;
                                                        });
                                                        setBlackout(value);
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(
                                              height: height / 5.5,
                                              child: AnimationLimiter(
                                                child: ListView.builder(
                                                    physics:
                                                        const BouncingScrollPhysics(),
                                                    padding:
                                                        const EdgeInsets.only(
                                                            right: 20),
                                                    scrollDirection:
                                                        Axis.horizontal,
                                                    shrinkWrap: true,
                                                    itemCount:
                                                        listAnimationChatBac
                                                            .length,
                                                    itemBuilder:
                                                        (context, index) {
                                                      return AnimationConfiguration
                                                          .staggeredList(
                                                        position: index,
                                                        delay: const Duration(
                                                            milliseconds: 450),
                                                        child: SlideAnimation(
                                                          duration:
                                                              const Duration(
                                                                  milliseconds:
                                                                      1500),
                                                          horizontalOffset: 160,
                                                          curve: Curves.ease,
                                                          child:
                                                              FadeInAnimation(
                                                            curve:
                                                                Curves.easeOut,
                                                            duration:
                                                                const Duration(
                                                                    milliseconds:
                                                                        2000),
                                                            child:
                                                                ZoomTapAnimation(
                                                              onTap: () async {
                                                                setBackground(
                                                                    listAnimationChatBac[
                                                                        index]);
                                                              },
                                                              end: 0.990,
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .only(
                                                                        left:
                                                                            10,
                                                                        right:
                                                                            4),
                                                                child:
                                                                    FlutterColorsBorder(
                                                                  animationDuration:
                                                                      5,
                                                                  colors:
                                                                      listColorsAnimation,
                                                                  size: Size(
                                                                      height /
                                                                          10,
                                                                      height /
                                                                          5.65),
                                                                  boardRadius:
                                                                      0,
                                                                  borderWidth:
                                                                      0.6,
                                                                  child: Lottie.asset(
                                                                      listAnimationChatBac[
                                                                          index]),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                    }),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    });
                                  },
                                );
                              }
                            },
                            itemBuilder: (BuildContext context) {
                              return [
                                PopupMenuItem(
                                  value: 0,
                                  child: Container(
                                    child: animatedText(height / 58,
                                        'Удалить чат', Colors.white, 450, 1),
                                  ),
                                ),
                                PopupMenuItem(
                                    value: 1,
                                    child: animatedText(
                                        height / 58,
                                        'Изменить фон чата',
                                        Colors.white,
                                        500,
                                        1)),
                              ];
                            },
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection("User")
                            .doc(userModelCurrent.uid)
                            .collection('messages')
                            .doc(friendId)
                            .collection('chats')
                            .limit(limit)
                            .orderBy("date", descending: true)
                            .snapshots(),
                        builder: (context, AsyncSnapshot snapshotMy) {
                          if (snapshotMy.hasData) {
                            int lengthDoc = snapshotMy.data.docs.length;
                            bool isFirstMessage = false;
                            if (snapshotMy.data.docs.length == 0) {
                              isFirstMessage = false;
                            } else {
                              isFirstMessage = true;
                            }

                            return Column(
                              children: [
                                Expanded(
                                  child: AnimationLimiter(
                                    child: ListView.builder(
                                      physics: const BouncingScrollPhysics(),
                                      scrollDirection: Axis.vertical,
                                      controller: scrollController,
                                      itemCount: lengthDoc + 1,
                                      reverse: true,
                                      shrinkWrap: true,
                                      itemBuilder: (context, index) {
                                        if (index <
                                            snapshotMy.data.docs.length) {
                                          var myIdMessage = '',
                                              message = '',
                                              date = Timestamp.now(),
                                              isMe = false;
                                          try {
                                            myIdMessage = snapshotMy
                                                .data.docs[index]['idDoc'];
                                            message = snapshotMy
                                                .data.docs[index]['message'];
                                            date = snapshotMy.data.docs[index]
                                                ['date'];
                                            isMe = snapshotMy.data.docs[index]
                                                    ['senderId'] ==
                                                userModelCurrent.uid;
                                          } catch (E) {}
                                          return AnimationConfiguration
                                              .staggeredList(
                                            position: index,
                                            delay: const Duration(
                                                milliseconds: 100),
                                            child: SlideAnimation(
                                              duration: const Duration(
                                                  milliseconds: 1400),
                                              horizontalOffset: 200,
                                              curve: Curves.ease,
                                              child: FadeInAnimation(
                                                curve: Curves.easeOut,
                                                duration: const Duration(
                                                    milliseconds: 2200),
                                                child: InkWell(
                                                  onLongPress: () async {
                                                    bool isLastMessage = false;
                                                    int indexRevers = index == 0
                                                        ? lengthDoc
                                                        : index;
                                                    if (indexRevers ==
                                                        lengthDoc) {
                                                      isLastMessage = true;
                                                    }

                                                    await FirebaseFirestore
                                                        .instance
                                                        .collection("User")
                                                        .doc(friendId)
                                                        .collection('messages')
                                                        .doc(userModelCurrent
                                                            .uid)
                                                        .collection('chats')
                                                        .where('message',
                                                            isEqualTo: message)
                                                        .where('date',
                                                            isEqualTo: date)
                                                        .get()
                                                        .then(
                                                      (QuerySnapshot
                                                          querySnapshot) async {
                                                        for (var document
                                                            in querySnapshot
                                                                .docs) {
                                                          Map<String, dynamic>
                                                              data =
                                                              document.data()
                                                                  as Map<String,
                                                                      dynamic>;
                                                          showAlertDialogDeleteMessage(
                                                              context,
                                                              friendId,
                                                              userModelCurrent
                                                                  .uid,
                                                              friendName,
                                                              myIdMessage,
                                                              data['idDoc'],
                                                              snapshotMy,
                                                              index + 1,
                                                              isLastMessage);
                                                        }
                                                      },
                                                    );
                                                  },
                                                  child: MessagesItem(
                                                    message,
                                                    isMe,
                                                    date,
                                                    friendImage,
                                                    friendId,
                                                    userModelCurrent,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        } else {
                                          bool isLimitMax =
                                              snapshotMy.data.docs.length >=
                                                  limit;
                                          if (isLimitMax) {
                                            return const Padding(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 20),
                                              child: Center(
                                                child: SizedBox(
                                                  height: 24,
                                                  width: 24,
                                                  child:
                                                      CircularProgressIndicator(
                                                    color: Colors.white,
                                                    strokeWidth: 0.8,
                                                  ),
                                                ),
                                              ),
                                            );
                                          } else {
                                            return const SizedBox();
                                          }
                                        }
                                      },
                                    ),
                                  ),
                                ),
                                MessageTextField(
                                    userModelCurrent,
                                    friendId,
                                    token,
                                    friendName,
                                    notification,
                                    isFirstMessage),
                                const SizedBox(
                                  width: .05,
                                )
                              ],
                            );
                          }
                          return const Center(
                            child: SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 0.8,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }
    return const Center(
      child: SizedBox(
        height: 24,
        width: 24,
        child: CircularProgressIndicator(
          color: Colors.white,
          strokeWidth: 0.8,
        ),
      ),
    );
  }
}
