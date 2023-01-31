import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delayed_display/delayed_display.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:lancelot/screens/chat_user_screen.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

import '../config/const.dart';
import '../config/utils.dart';
import '../model/user_model.dart';
import '../widget/animation_widget.dart';
import '../widget/card_widget.dart';
import '../widget/component_widget.dart';
import '../widget/dialog_widget.dart';

class ChatScreen extends StatefulWidget {
  final UserModel userModelCurrent;

  const ChatScreen({Key? key, required this.userModelCurrent})
      : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState(userModelCurrent);
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final UserModel userModelCurrent;
  final scrollController = ScrollController();
  int limit = 7;
  bool isLoadingUser = false;
  late final AnimationController animationController;

  _ChatScreenState(this.userModelCurrent);

  @override
  void initState() {
    animationController = AnimationController(vsync: this);
    scrollController.addListener(() {
      if (!isLoadingUser) {
        setState(() => isLoadingUser = true);
      }
      if (scrollController.position.maxScrollExtent ==
          scrollController.offset) {
        setState(() {
          limit += 4;
        });

        Future.delayed(const Duration(milliseconds: 600), () {
          scrollController.animateTo(
            scrollController.position.maxScrollExtent -
                MediaQuery.of(context).size.height / 10.5,
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
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: color_black_88,
      body: SafeArea(
        child: SingleChildScrollView(
          controller: scrollController,
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              topPanel(
                context,
                'Сообщения',
                Icons.message,
                color_black_88,
                false,
                height,
              ),
              StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('User')
                      .doc(widget.userModelCurrent.uid)
                      .collection('messages')
                      .limit(limit)
                      .orderBy("date", descending: true)
                      .snapshots(),
                  builder: (context, AsyncSnapshot snapshotFriendId) {
                    if (snapshotFriendId.hasData) {
                      if (snapshotFriendId.data.docs.length <= 0) {
                        return showIfNoData(
                            height,
                            'images/animation_user_chat.json',
                            'У вас нет сообщений',
                            animationController,
                            3.5);
                      } else {
                        return AnimationLimiter(
                          child: ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            scrollDirection: Axis.vertical,
                            itemCount: snapshotFriendId.data.docs.length + 1,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              if (index < snapshotFriendId.data.docs.length) {
                                var friendId =
                                    snapshotFriendId.data.docs[index].id;
                                return AnimationConfiguration.staggeredList(
                                  position: index,
                                  delay: const Duration(milliseconds: 350),
                                  child: SlideAnimation(
                                    duration: const Duration(milliseconds: 950),
                                    verticalOffset: 100,
                                    curve: Curves.ease,
                                    child: FadeInAnimation(
                                      curve: Curves.easeOut,
                                      duration:
                                          const Duration(milliseconds: 2200),
                                      child: FutureBuilder(
                                        future: FirebaseFirestore.instance
                                                .collection('User')
                                                .doc(friendId)
                                                .get(const GetOptions(
                                                    source: Source.cache))
                                                .toString()
                                                .isEmpty
                                            ? FirebaseFirestore.instance
                                                .collection('User')
                                                .doc(friendId)
                                                .get(const GetOptions(
                                                    source: Source.cache))
                                            : FirebaseFirestore.instance
                                                .collection('User')
                                                .doc(friendId)
                                                .get(const GetOptions(
                                                    source: Source.server)),
                                        builder: (context,
                                            AsyncSnapshot asyncSnapshotUser) {
                                          return SizedBox(
                                            child: FutureBuilder(
                                              future: FirebaseFirestore.instance
                                                      .collection('User')
                                                      .doc(userModelCurrent.uid)
                                                      .collection('messages')
                                                      .doc(friendId)
                                                      .get(const GetOptions(
                                                          source: Source.cache))
                                                      .toString()
                                                      .isEmpty
                                                  ? FirebaseFirestore.instance
                                                      .collection('User')
                                                      .doc(userModelCurrent.uid)
                                                      .collection('messages')
                                                      .doc(friendId)
                                                      .get(const GetOptions(
                                                          source: Source.cache))
                                                  : FirebaseFirestore.instance
                                                      .collection('User')
                                                      .doc(userModelCurrent.uid)
                                                      .collection('messages')
                                                      .doc(friendId)
                                                      .get(const GetOptions(
                                                          source:
                                                              Source.server)),
                                              builder: (context,
                                                  AsyncSnapshot snapshotChat) {
                                                if (snapshotChat.hasData &&
                                                    asyncSnapshotUser.hasData &&
                                                    snapshotFriendId.hasData) {
                                                  var timeLastMessage =
                                                          Timestamp.now(),
                                                      lastMsg = '',
                                                      nameUser = '',
                                                      imageUri = '',
                                                      indexAnimation =
                                                          index + 1,
                                                      token = '',
                                                      state = '',
                                                      dataLastWrite,
                                                      isWriteUser = false,
                                                      isLastOpenChat = false,
                                                      isNewMessage = false,
                                                      isReadMessage = false,
                                                      notification = false;

                                                  try {
                                                    dataLastWrite = snapshotChat
                                                        .data['writeLastData'];

                                                    lastMsg = snapshotChat
                                                        .data['last_msg'];
                                                    nameUser = asyncSnapshotUser
                                                        .data['name'];
                                                    imageUri =
                                                        asyncSnapshotUser.data[
                                                            'listImageUri'][0];
                                                    state = asyncSnapshotUser
                                                        .data['state'];
                                                    token = asyncSnapshotUser
                                                        .data['token'];
                                                    notification =
                                                        asyncSnapshotUser.data[
                                                            'notification'];

                                                    timeLastMessage =
                                                        snapshotChat
                                                            .data['date'];
                                                    isLastOpenChat = snapshotChat
                                                                .data[
                                                            'last_date_open_chat'] ==
                                                        '';

                                                    if (dataLastWrite != '') {
                                                      if (DateTime.now()
                                                              .difference(
                                                                  getDataTime(
                                                                      dataLastWrite))
                                                              .inSeconds <
                                                          4) {
                                                        Future.delayed(
                                                            const Duration(
                                                                milliseconds:
                                                                    3500), () {
                                                          getState(4000)
                                                              .then((value) {
                                                            setState(() {
                                                              isWriteUser =
                                                                  value;
                                                            });
                                                          });
                                                        });
                                                        isWriteUser = true;
                                                        if (isLastOpenChat) {
                                                          isNewMessage = true;
                                                        }
                                                      }
                                                    }

                                                    if (isLastOpenChat) {
                                                      isNewMessage = true;
                                                    }

                                                    if (snapshotChat.data[
                                                            'last_date_close_chat'] ==
                                                        '') {
                                                      isReadMessage = true;
                                                    } else {
                                                      if (getDataTime(snapshotChat
                                                                      .data[
                                                                  'last_date_close_chat'])
                                                              .difference(
                                                                  getDataTime(
                                                                      timeLastMessage))
                                                              .inSeconds >=
                                                          1) {
                                                        isReadMessage = true;
                                                      }
                                                    }
                                                  } catch (errro) {}

                                                  return ZoomTapAnimation(
                                                    enableLongTapRepeatEvent:
                                                        false,
                                                    longTapRepeatDuration:
                                                        const Duration(
                                                            milliseconds: 200),
                                                    begin: 1.0,
                                                    end: 0.95,
                                                    beginDuration:
                                                        const Duration(
                                                            milliseconds: 20),
                                                    endDuration: const Duration(
                                                        milliseconds: 200),
                                                    beginCurve:
                                                        Curves.decelerate,
                                                    endCurve:
                                                        Curves.fastOutSlowIn,
                                                    onLongTap: () {
                                                      showAlertDialogDeleteChat(
                                                          context,
                                                          friendId,
                                                          nameUser,
                                                          false,
                                                          imageUri,
                                                          height);
                                                    },
                                                    onTap: () {
                                                      Navigator.push(
                                                        context,
                                                        FadeRouteAnimation(
                                                          ChatUserScreen(
                                                            friendId: friendId,
                                                            friendName:
                                                                nameUser,
                                                            friendImage:
                                                                imageUri,
                                                            userModelCurrent:
                                                                userModelCurrent,
                                                            token: token,
                                                            notification:
                                                                notification,
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                    child: Container(
                                                      height: height / 6.6,
                                                      width: width,
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8),
                                                      child: Card(
                                                        shadowColor: Colors
                                                            .white
                                                            .withOpacity(.08),
                                                        color: color_black_88,
                                                        shape:
                                                            RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            18),
                                                                side:
                                                                    const BorderSide(
                                                                  width: 0.2,
                                                                  color: Colors
                                                                      .white10,
                                                                )),
                                                        elevation: 16,
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  left: 4,
                                                                  bottom: 4,
                                                                  top: 4,
                                                                  right: 24),
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Expanded(
                                                                flex: 1,
                                                                child:
                                                                    photoUser(
                                                                  uri: imageUri,
                                                                  width:
                                                                      height /
                                                                          11,
                                                                  height:
                                                                      height /
                                                                          11,
                                                                  state: state,
                                                                  padding: 0,
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                  width: 10),
                                                              Expanded(
                                                                flex: 3,
                                                                child: Column(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .spaceBetween,
                                                                      children: [
                                                                        animatedText(
                                                                            height /
                                                                                54,
                                                                            nameUser,
                                                                            Colors.white,
                                                                            0,
                                                                            1),
                                                                        const SizedBox(
                                                                          height:
                                                                              2,
                                                                        ),
                                                                        animatedText(
                                                                            height /
                                                                                78,
                                                                            filterDate(timeLastMessage),
                                                                            Colors.white.withOpacity(.5),
                                                                            400,
                                                                            1),
                                                                      ],
                                                                    ),
                                                                    const SizedBox(
                                                                      height: 7,
                                                                    ),
                                                                    Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .spaceBetween,
                                                                      children: [
                                                                        if (!isWriteUser)
                                                                          Expanded(
                                                                            child:
                                                                                Padding(
                                                                              padding: const EdgeInsets.only(right: 10),
                                                                              child: animatedText(height / 68, lastMsg, Colors.white.withOpacity(.3), indexAnimation * 350 < 2300 ? indexAnimation * 350 : 350, 2),
                                                                            ),
                                                                          ),
                                                                        if (isWriteUser)
                                                                          showProgressWrite(
                                                                              height),
                                                                        if (isNewMessage)
                                                                          DelayedDisplay(
                                                                            delay:
                                                                                const Duration(milliseconds: 450),
                                                                            child:
                                                                                Container(
                                                                              margin: const EdgeInsets.only(top: 6),
                                                                              alignment: Alignment.center,
                                                                              width: height / 48,
                                                                              height: height / 48,
                                                                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(50), color: Colors.deepPurpleAccent),
                                                                              child: animatedText(height / 68, '1', Colors.white, 0, 1),
                                                                            ),
                                                                          ),
                                                                        if (isReadMessage &&
                                                                            !isNewMessage)
                                                                          DelayedDisplay(
                                                                            delay:
                                                                                Duration(milliseconds: indexAnimation * 250 < 2300 ? indexAnimation * 250 : 250),
                                                                            child:
                                                                                Padding(
                                                                              padding: EdgeInsets.only(left: height / 86),
                                                                              child: Icon(
                                                                                Icons.done_all,
                                                                                color: Colors.deepPurpleAccent,
                                                                                size: height / 46,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        if (!isReadMessage &&
                                                                            !isNewMessage)
                                                                          DelayedDisplay(
                                                                            delay:
                                                                                Duration(milliseconds: indexAnimation * 350 < 2300 ? indexAnimation * 350 : 350),
                                                                            child:
                                                                                Padding(
                                                                              padding: EdgeInsets.only(left: height / 86),
                                                                              child: Icon(
                                                                                Icons.check_rounded,
                                                                                color: Colors.white,
                                                                                size: height / 46,
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
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                );
                              } else {
                                if (snapshotFriendId.data.docs.length >=
                                    limit) {
                                  if (isLoadingUser) {
                                    return const Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 30),
                                      child: Center(
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
                                return const SizedBox();
                              }
                            },
                          ),
                        );
                      }
                    }
                    return const SizedBox();
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
