import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

import '../config/const.dart';
import '../config/firestore_operations.dart';
import '../config/utils.dart';
import '../model/user_model.dart';
import 'animation_widget.dart';

class MessagesItem extends StatelessWidget {
  final String message_text, friendImage, friendId;
  final bool isMyMassage;
  final Timestamp dataMessage;
  final UserModel userModelCurrent;

  late StreamSubscription streamSubscription;

  MessagesItem(this.message_text, this.isMyMassage, this.dataMessage,
      this.friendImage, this.friendId, this.userModelCurrent,
      {super.key});

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    Future<bool> checkStatusNetwork() async {
      bool isFiresState = false;
      streamSubscription = Connectivity().onConnectivityChanged.listen(
        (ConnectivityResult result) {
          if (result.name == 'wifi') {
            isFiresState = true;
          } else if (result.name == 'mobile') {
            isFiresState = true;
          } else {
            isFiresState = false;
          }
        },
      );

      return isFiresState;
    }

    Container formMessageMy(String isCheck) {
      return Container(
        decoration: BoxDecoration(
            color: Colors.white.withOpacity(.01),
            borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                topLeft: Radius.circular(20)),
            border: Border.all(color: Colors.white10, width: 0.9)),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            RichText(
              text: TextSpan(
                text: message_text.length < 12
                    ? '$message_text                      '
                    : message_text,
                style: GoogleFonts.lato(
                  textStyle: TextStyle(
                      color: Colors.white.withOpacity(.9),
                      fontSize: height / 62,
                      letterSpacing: .5),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                RichText(
                  text: TextSpan(
                    text: filterDate(dataMessage),
                    style: GoogleFonts.lato(
                      textStyle: TextStyle(
                          color: Colors.white.withOpacity(.9),
                          fontSize: height / 82,
                          letterSpacing: .5),
                    ),
                  ),
                ),
                if (isCheck == '')
                  SlideFadeTransition(
                    animationDuration: const Duration(milliseconds: 400),
                    child: showCheckMessageAnimation(
                        height, Icons.access_time_outlined, Colors.white),
                  ),
                if (isCheck == 'read')
                  SlideFadeTransition(
                    animationDuration: const Duration(milliseconds: 400),
                    child: showCheckMessageAnimation(
                        height, Icons.done_all, Colors.blueAccent),
                  )
                else
                  SlideFadeTransition(
                    animationDuration: const Duration(milliseconds: 400),
                    child: showCheckMessageAnimation(
                        height, Icons.check_rounded, Colors.white),
                  ),
              ],
            ),
          ],
        ),
      );
    }

    Widget formMessageFriend() {
      return Container(
        margin: const EdgeInsets.only(left: 10),
        decoration: BoxDecoration(
            color: Colors.white.withOpacity(.01),
            borderRadius: const BorderRadius.only(
                bottomRight: Radius.circular(20),
                bottomLeft: Radius.circular(20),
                topRight: Radius.circular(20)),
            border: Border.all(color: Colors.white10, width: 0.9)),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            RichText(
              text: TextSpan(
                text: message_text.length < 12
                    ? '$message_text               '
                    : message_text,
                style: GoogleFonts.lato(
                  textStyle: TextStyle(
                      color: Colors.white.withOpacity(.9),
                      fontSize: height / 62,
                      letterSpacing: .5),
                ),
              ),
            ),
            RichText(
              text: TextSpan(
                text: filterDate(dataMessage),
                style: GoogleFonts.lato(
                  textStyle: TextStyle(
                      color: Colors.white.withOpacity(.9),
                      fontSize: height / 82,
                      letterSpacing: .5),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('User')
          .doc(userModelCurrent.uid)
          .collection('messages')
          .doc(friendId)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot asyncSnapshot) {
        if (asyncSnapshot.hasData) {
          var isLastMessage = 'not read';

          try {
            if (asyncSnapshot.data['last_date_close_chat'] == '') {
              isLastMessage = 'read';
            } else {
              if (getDataTime(asyncSnapshot.data['last_date_close_chat'])
                      .difference(getDataTime(dataMessage))
                      .inSeconds >=
                  1) {
                isLastMessage = 'read';
              }
            }
            // checkStatusNetwork().then((result) {
            //   print(result);
            //   // if (!result) {
            //   //   isLastMessage = '';
            //   // }
            // });
          } catch (error) {}

          return Padding(
            padding: EdgeInsets.all(height / 78),
            child: Column(
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  textDirection:
                      isMyMassage ? TextDirection.rtl : TextDirection.ltr,
                  children: <Widget>[
                    SizedBox(
                      width: MediaQuery.of(context).size.width * .75,
                      child: Align(
                        alignment: isMyMassage
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: isMyMassage
                            ? formMessageMy(isLastMessage)
                            : formMessageFriend(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 4,
                ),
              ],
            ),
          );
        }
        return Padding(
          padding: EdgeInsets.all(height / 78),
          child: Column(
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                textDirection:
                    isMyMassage ? TextDirection.rtl : TextDirection.ltr,
                children: <Widget>[
                  SizedBox(
                    width: MediaQuery.of(context).size.width * .75,
                    child: Align(
                      alignment: isMyMassage
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: isMyMassage
                          ? formMessageMy('not read')
                          : formMessageFriend(),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 4,
              ),
            ],
          ),
        );
      },
    );
  }
}

class MessageTextField extends StatefulWidget {
  final UserModel currentUser;
  final String friendId, token, friendName;
  final bool notification, isFirstMessage;

  const MessageTextField(this.currentUser, this.friendId, this.token,
      this.friendName, this.notification, this.isFirstMessage,
      {super.key});

  @override
  _MessageTextFieldState createState() => _MessageTextFieldState(
      currentUser, friendId, token, friendName, notification, isFirstMessage);
}

class _MessageTextFieldState extends State<MessageTextField> {
  final String friendId, token, friendName;
  final bool notification, isFirstMessage;
  final UserModel currentUser;
  final TextEditingController _controllerMessage = TextEditingController();
  bool isWrite = true;

  _MessageTextFieldState(this.currentUser, this.friendId, this.token,
      this.friendName, this.notification, this.isFirstMessage);

  void startTimer() {
    Timer.periodic(
      const Duration(seconds: 5),
      (Timer timer) {
        setState(() {
          isWrite = true;
        });
        timer.cancel();
      },
    );
  }

  @override
  void initState() {
    _controllerMessage.addListener(() {
      if (_controllerMessage.text.isNotEmpty) {
        if (isWrite) {
          startTimer();
          isWrite = false;
          putUserWrites(currentUser.uid, friendId);
        }
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Padding(
        padding: const EdgeInsets.only(bottom: 20, left: 14, right: 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
          Container(
            width: width / 1.35,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [
                Colors.pinkAccent,
                Colors.purpleAccent,
                Colors.blueAccent,
              ]),
              borderRadius: BorderRadius.circular(26),
            ),
            child: Padding(
              padding: const EdgeInsets.all(
                1.2,
              ),
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(
                  horizontal: 2,
                ),
                decoration: BoxDecoration(
                  color: color_black_88,
                  border: Border.all(color: color_black_88),
                  borderRadius: BorderRadius.circular(26),
                ),
                child: TextFormField(
                  textCapitalization: TextCapitalization.words,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(550),
                  ],
                  controller: _controllerMessage,
                  minLines: 1,
                  maxLines: 4,
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                          vertical: height / 52, horizontal: 15),
                      counterStyle: const TextStyle(color: Colors.white),
                      hintStyle:
                          TextStyle(color: Colors.white.withOpacity(0.9)),
                      hintText: "Сообщение..."),
                  style: GoogleFonts.lato(
                      textStyle: TextStyle(
                          color: Colors.white,
                          fontSize: height / 58,
                          letterSpacing: .5)),
                ),
              ),
            ),
          ),
          ZoomTapAnimation(
            onTap: () async {
              if (_controllerMessage.text.trim().isNotEmpty) {
                String messageText = _controllerMessage.text.trim();
                _controllerMessage.clear();
                if (notification && token != '') {
                  sendFcmMessage(
                      'Lancelot',
                      '${currentUser.name}: $messageText',
                      token,
                      'chat',
                      currentUser.uid);
                }
                final dateCurrent = DateTime.now();

                final docMessage = FirebaseFirestore.instance
                    .collection('User')
                    .doc(widget.currentUser.uid)
                    .collection('messages')
                    .doc(widget.friendId)
                    .collection('chats')
                    .doc();

                await docMessage
                    .set(({
                  "senderId": currentUser.uid,
                  "idDoc": docMessage.id,
                  "receiverId": widget.friendId,
                  "message": messageText,
                  "date": dateCurrent,
                }))
                    .then((value) {
                  final docUser = FirebaseFirestore.instance
                      .collection('User')
                      .doc(currentUser.uid)
                      .collection('messages')
                      .doc(widget.friendId);

                  if (isFirstMessage) {
                    docUser.update({
                      'last_msg': messageText,
                      'date': dateCurrent,
                      'writeLastData': '',
                      // 'last_date_open_chat': '',
                    });
                  } else {
                    docUser.set({
                      'last_msg': messageText,
                      'date': dateCurrent,
                      'writeLastData': '',
                      'last_date_open_chat': '',
                    });
                  }
                });

                final docMessageFriend = FirebaseFirestore.instance
                    .collection('User')
                    .doc(widget.friendId)
                    .collection('messages')
                    .doc(currentUser.uid)
                    .collection("chats")
                    .doc();
                docMessageFriend.set({
                  "idDoc": docMessageFriend.id,
                  "senderId": currentUser.uid,
                  "receiverId": widget.friendId,
                  "message": messageText,
                  "date": dateCurrent,
                }).then((value) {
                  final docUser = FirebaseFirestore.instance
                      .collection('User')
                      .doc(widget.friendId)
                      .collection('messages')
                      .doc(currentUser.uid);

                  if (isFirstMessage) {
                    docUser.update({
                      'last_msg': messageText,
                      'date': dateCurrent,
                      'writeLastData': '',
                      'last_date_open_chat': '',
                    });
                  } else {
                    docUser.set({
                      'last_msg': messageText,
                      'date': dateCurrent,
                      'writeLastData': '',
                      'last_date_open_chat': '',
                    });
                  }
                });
              }
            },
            child: Padding(
              padding: EdgeInsets.only(left: width / 66),
              child: Image.asset(
                'images/ic_send.png',
                height: width / 11,
                width: width / 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
