import 'dart:async';
import 'dart:ui';

import 'package:Lancelot/getx/firs_message_controller.dart';
import 'package:bottom_sheet/bottom_sheet.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colors_border/flutter_colors_border.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

import '../config/const.dart';
import '../config/firebase/firebase_chat_data.dart';
import '../config/firebase/firestore_operations.dart';
import '../getx/chat_data_controller.dart';
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
  double chatBlur = 0, chatBlackout = 1, chatBlackoutFinal = 0.2;
  bool isLoading = false, isWrite = true;
  final getChatDataController = Get.put(GetChatDataController());

  _ChatUserScreenState(this.friendId, this.friendName, this.friendImage,
      this.userModelCurrent, this.token, this.notification);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    readUser();

    ChatDataFirebase().readChatDataFirebase(
        userModelCurrent.uid, friendId, getChatDataController);

    scrollController.addListener(() {
      if (scrollController.position.maxScrollExtent ==
          scrollController.offset) {
        setState(() => limit += 10);

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
        setState(() => isWrite = true);
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
          ChatDataFirebase().closeChatDataFirebase();
          createLastOpenChat(widget.friendId, userModelCurrent.uid);
          createLastCloseChat(
              userModelCurrent.uid, widget.friendId, DateTime.now());
        }
        break;
      case AppLifecycleState.resumed:
        if (isWrite) {
          startTimer();
          isWrite = false;
          ChatDataFirebase().readChatDataFirebase(
              userModelCurrent.uid, friendId, getChatDataController);
          createLastOpenChat(widget.friendId, userModelCurrent.uid);
          createLastCloseChat(userModelCurrent.uid, widget.friendId, '');
        }
        break;
      case AppLifecycleState.inactive:
        if (isWrite) {
          startTimer();
          isWrite = false;
          ChatDataFirebase().closeChatDataFirebase();
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
    if (friendName.isEmpty && friendImage.isEmpty && token.isEmpty) {
      await readUserFirebase(friendId).then((user) {
        friendName = user.name;
        friendImage = user.listImageUri[0];
        token = user.token;
        notification = user.notification;
      });
    }

    await getDataChat().then((i) => setState(() => isLoading = true));
  }

  Future getDataChat() async {
    final prefs = await SharedPreferences.getInstance();

    chatBackground =
        prefs.getString('chatBackground') ?? 'images/animation_chat_bac_2.json';
    chatBlur = prefs.getDouble('chatBlur') ?? 0;
    chatBlackoutFinal = prefs.getDouble('chatBlackout') ?? 0.2;

    if (chatBlackoutFinal < 1.0) {
      chatBlackout = double.parse(chatBlackoutFinal.toString().substring(2, 3));
    } else {
      chatBlackout = 10;
    }

    isLoading = true;
  }

  Future setBackgroundChat(String listAnimationChatBac) async {
    await SharedPreferences.getInstance()
        .then((i) => i.setString('chatBackground', listAnimationChatBac));

    setState(() => chatBackground = listAnimationChatBac);
  }

  Future setBlur(value) async {
    await SharedPreferences.getInstance()
        .then((i) => i.setDouble('chatBlur', value));
    setState(() => chatBlur = value);
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

    setState(() => chatBlackoutFinal = result);
  }

  @override
  void dispose() {
    ChatDataFirebase().closeChatDataFirebase();
    createLastOpenChat(widget.friendId, userModelCurrent.uid);
    createLastCloseChat(userModelCurrent.uid, widget.friendId, DateTime.now());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final getChatController = Get.put(GetFirsMessageChatController());

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
                        top: statusBarHeight,
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
                                showAlertDialogDeleteChat(
                                    context: context,
                                    friendId: friendId,
                                    friendName: friendName,
                                    isBack: true,
                                    friendUri: friendImage,
                                    height: height);
                              } else if (value == 1) {
                                showBottomSheetChat(context, height, width);
                              }
                            },
                            itemBuilder: (BuildContext context) {
                              return [
                                PopupMenuItem(
                                  value: 0,
                                  child: animatedText(height / 58,
                                      'Удалить чат', Colors.white, 400, 1),
                                ),
                                PopupMenuItem(
                                  value: 1,
                                  child: animatedText(
                                      height / 58,
                                      'Изменить фон чата',
                                      Colors.white,
                                      450,
                                      1),
                                ),
                              ];
                            },
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: StreamBuilder(
                        stream: GetIt.I<FirebaseFirestore>()
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
                            if (snapshotMy.data.docs.length != 0) {
                              getChatController.setFirsMessage(true);
                            } else {
                              getChatController.setFirsMessage(false);
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
                                                child: GestureDetector(
                                                  onLongPress: () async {
                                                    bool isLastMes = false;
                                                    int indexRevers = index == 0
                                                        ? lengthDoc
                                                        : index;
                                                    if (indexRevers ==
                                                        lengthDoc) {
                                                      isLastMes = true;
                                                    }

                                                    showAlertDialogDeleteMessage(
                                                        context: context,
                                                        friendId: friendId,
                                                        myId: userModelCurrent
                                                            .uid,
                                                        friendName: friendName,
                                                        idDoc: snapshotMy.data
                                                                .docs[index]
                                                            ['idDoc'],
                                                        snapshotMy: snapshotMy,
                                                        index: index + 1,
                                                        isLastMessage:
                                                            isLastMes);
                                                  },
                                                  child: MessagesItem(
                                                    snapshotMy.data.docs[index]
                                                        ['message'],
                                                    snapshotMy.data.docs[index]
                                                        ['senderId'],
                                                    snapshotMy.data.docs[index]
                                                        ['date'],
                                                    friendImage,
                                                    friendId,
                                                    userModelCurrent,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        } else {
                                          if (snapshotMy.data.docs.length >=
                                              limit) {
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
                                MessageTextField(userModelCurrent, friendId,
                                    token, friendName, notification),
                                const SizedBox(
                                  width: .05,
                                )
                              ],
                            );
                          }
                          return const Center(
                            child: SizedBox(
                              height: 26,
                              width: 26,
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

    return const loadingCustom();
  }

  Future<dynamic> showBottomSheetChat(
      BuildContext context, double height, double width) {
    return showFlexibleBottomSheet(
      bottomSheetColor: Colors.transparent,
      duration: const Duration(milliseconds: 800),
      context: context,
      builder: (
        BuildContext context,
        ScrollController scrollController,
        double bottomSheetOffset,
      ) {
        return StatefulBuilder(builder: (context, setState) {
          return Container(
            height: height / 2.6,
            padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.only(top: 2, left: 8),
                  child: Row(
                    children: [
                      SizedBox(
                          width: width / 4.2,
                          child: animatedText(
                              height / 62, 'Размытие', Colors.white, 0, 1)),
                      Container(
                        width: width / 1.5,
                        padding: const EdgeInsets.only(right: 8, left: 4),
                        child: SfSlider(
                          activeColor: Colors.blue,
                          min: 0,
                          max: 20,
                          value: chatBlur,
                          stepSize: 1,
                          enableTooltip: false,
                          onChanged: (dynamic value) {
                            setState(() => chatBlur = value);
                            setBlur(value);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(bottom: 10, left: 8),
                  child: Row(
                    children: [
                      SizedBox(
                        width: width / 4.2,
                        child: animatedText(
                            height / 62, 'Затемнение', Colors.white, 0, 1),
                      ),
                      Container(
                        padding: const EdgeInsets.only(right: 8, left: 4),
                        width: width / 1.5,
                        child: SfSlider(
                          activeColor: Colors.blue,
                          min: 0,
                          max: 10,
                          value: chatBlackout,
                          stepSize: 1,
                          enableTooltip: false,
                          onChanged: (dynamic value) {
                            setState(() => chatBlackout = value);
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
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.only(right: 20),
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      itemCount: listAnimationChatBac.length,
                      itemBuilder: (context, index) {
                        return AnimationConfiguration.staggeredList(
                          position: index,
                          delay: const Duration(milliseconds: 450),
                          child: SlideAnimation(
                            duration: const Duration(milliseconds: 1500),
                            horizontalOffset: 160,
                            child: FadeInAnimation(
                              curve: Curves.easeOut,
                              duration: const Duration(milliseconds: 2000),
                              child: ZoomTapAnimation(
                                onTap: () => setBackgroundChat(
                                    listAnimationChatBac[index]),
                                end: 0.990,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.only(left: 10, right: 4),
                                  child: FlutterColorsBorder(
                                    animationDuration: 5,
                                    colors: listColorsAnimation,
                                    size: Size(height / 10, height / 5.65),
                                    boardRadius: 0,
                                    borderWidth: 0.6,
                                    child: Lottie.asset(
                                        listAnimationChatBac[index]),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        });
      },
    );
  }
}
