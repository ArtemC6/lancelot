import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delayed_display/delayed_display.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get_it/get_it.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

import '../config/const.dart';
import '../config/firebase/firestore_operations.dart';
import '../config/utils.dart';
import '../model/user_model.dart';
import '../widget/animation_widget.dart';
import '../widget/card_widget.dart';
import '../widget/component_widget.dart';
import '../widget/dialog_widget.dart';
import 'chat_user_screen.dart';

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
      if (!isLoadingUser) setState(() => isLoadingUser = true);
      if (scrollController.position.maxScrollExtent ==
          scrollController.offset) {
        setState(() => limit += 4);

        getFuture(600).then((i) => scrollController.animateTo(
              scrollController.position.maxScrollExtent -
                  MediaQuery.of(context).size.height / 10.5,
              duration: const Duration(milliseconds: 1500),
              curve: Curves.fastOutSlowIn,
            ));
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
                text: 'Сообщения',
                isBack: false,
                color: color_black_88,
                icon: Icons.message,
              ),
              StreamBuilder(
                stream: GetIt.I<FirebaseFirestore>()
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
                          imagePath: 'images/animation_user_chat.json',
                          text: 'У вас нет сообщений',
                          animationController: animationController);
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
                                delay: const Duration(milliseconds: 450),
                                child: SlideAnimation(
                                  duration: const Duration(milliseconds: 1000),
                                  verticalOffset: 100,
                                  child: FadeInAnimation(
                                    curve: Curves.easeOut,
                                    duration:
                                        const Duration(milliseconds: 2200),
                                    child: FutureBuilder(
                                      future: readUserFirebase(friendId),
                                      builder: (context, asyncSnapshotUser) {
                                        if (asyncSnapshotUser.hasData) {
                                          return SizedBox(
                                            child: FutureBuilder(
                                              future:
                                                  GetIt.I<FirebaseFirestore>()
                                                      .collection('User')
                                                      .doc(userModelCurrent.uid)
                                                      .collection('messages')
                                                      .doc(friendId)
                                                      .get(),
                                              builder: (context,
                                                  AsyncSnapshot snapshotChat) {
                                                if (snapshotChat.hasData &&
                                                    asyncSnapshotUser.hasData &&
                                                    snapshotFriendId.hasData) {
                                                  final user =
                                                      asyncSnapshotUser.data!;
                                                  var timeLastMessage =
                                                          Timestamp.now(),
                                                      indexAnimation =
                                                          index + 1,
                                                      dataLastWrite,
                                                      isWriteUser = false,
                                                      isLastOpenChat = false,
                                                      isNewMessage = false,
                                                      isReadMessage = false;

                                                  try {
                                                    dataLastWrite = snapshotChat
                                                        .data['writeLastData'];

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
                                                          6) {
                                                        getFuture(5000).then(
                                                            (i) => setState(() =>
                                                                isWriteUser =
                                                                    i));
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
                                                  } catch (e) {}

                                                  return ZoomTapAnimation(
                                                    onLongTap: () =>
                                                        showAlertDialogDeleteChat(
                                                            context: context,
                                                            friendId: friendId,
                                                            friendName:
                                                                user.name,
                                                            isBack: false,
                                                            friendUri:
                                                                user.listImageUri[
                                                                    0],
                                                            height: height,
                                                            uidUser:
                                                                userModelCurrent
                                                                    .uid),
                                                    onTap: () {
                                                      if (user.uid.isNotEmpty) {
                                                        Navigator.push(
                                                          context,
                                                          FadeRouteAnimation(
                                                            ChatUserScreen(
                                                              friendId:
                                                                  friendId,
                                                              friendName:
                                                                  user.name,
                                                              friendImage: user
                                                                  .listImageUri[0],
                                                              userModelCurrent:
                                                                  userModelCurrent,
                                                              token: user.token,
                                                              notification: user
                                                                  .notification,
                                                            ),
                                                          ),
                                                        );
                                                      }
                                                    },
                                                    child: Container(
                                                      height: height / 6.6,
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
                                                                  .circular(18),
                                                          side:
                                                              const BorderSide(
                                                            width: 0.2,
                                                            color:
                                                                Colors.white10,
                                                          ),
                                                        ),
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
                                                            children: [
                                                              Expanded(
                                                                flex: 1,
                                                                child:
                                                                    photoUser(
                                                                  uri: user
                                                                      .listImageUri[0],
                                                                  width:
                                                                      height /
                                                                          11,
                                                                  height:
                                                                      height /
                                                                          11,
                                                                  state: user
                                                                      .state,
                                                                  padding: 0,
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                  width:
                                                                      height /
                                                                          80),
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
                                                                                52,
                                                                            user.name,
                                                                            Colors.white,
                                                                            0,
                                                                            1),
                                                                        const SizedBox(
                                                                          height:
                                                                              2,
                                                                        ),
                                                                        animatedText(
                                                                            height /
                                                                                74,
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
                                                                              child: animatedText(height / 64, snapshotChat.data['last_msg'], Colors.white.withOpacity(.3), indexAnimation * 350 < 2300 ? indexAnimation * 350 : 350, 2),
                                                                            ),
                                                                          ),
                                                                        if (isWriteUser)
                                                                          const showProgressWrite(),
                                                                        if (isNewMessage)
                                                                          DelayedDisplay(
                                                                            delay:
                                                                                const Duration(milliseconds: 450),
                                                                            child:
                                                                                Container(
                                                                              margin: const EdgeInsets.only(top: 6),
                                                                              alignment: Alignment.center,
                                                                              width: height / 47,
                                                                              height: height / 47,
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
                                                                                size: height / 41,
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
                                                                                size: height / 41,
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
                                        }
                                        return const SizedBox();
                                      },
                                    ),
                                  ),
                                ),
                              );
                            } else {
                              if (snapshotFriendId.data.docs.length >= limit) {
                                if (isLoadingUser) {
                                  return const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 30),
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
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
