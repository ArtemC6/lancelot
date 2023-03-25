import 'dart:async';

import 'package:bubble/bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delayed_display/delayed_display.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

import '../config/firebase/firestore_operations.dart';
import '../config/utils.dart';
import '../getx/chat_data_controller.dart';
import '../getx/firs_message_controller.dart';
import '../model/user_model.dart';
import 'animation_widget.dart';

class MessagesItem extends StatelessWidget {
  final String messageText, friendImage, friendId;
  final bool isMyMassage;
  final Timestamp dataMessage;
  final UserModel userModelCurrent;

  const MessagesItem(this.messageText, this.isMyMassage, this.dataMessage,
      this.friendImage, this.friendId, this.userModelCurrent,
      {super.key});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return GetBuilder<GetChatDataController>(
      builder: (GetChatDataController controller) {
        bool isCheck = false;
        try {
          if (controller.lastDateCloseChat == '') isCheck = true;
          if (controller.lastDateCloseChat != '') {
            if (getDataTime(controller.lastDateCloseChat)
                    .difference(getDataTime(dataMessage))
                    .inSeconds >=
                1) isCheck = true;
          }
        } catch (e) {}

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
                          ? formMessageMy(
                              messageText: messageText,
                              dataMessage: dataMessage,
                              isCheck: isCheck)
                          : formMessageFriend(
                              messageText: messageText,
                              dataMessage: dataMessage),
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

class formMessageFriend extends StatelessWidget {
  const formMessageFriend({
    super.key,
    required this.messageText,
    required this.dataMessage,
  });

  final String messageText;
  final Timestamp dataMessage;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Bubble(
      nip: BubbleNip.leftBottom,
      stick: true,
      shadowColor: Colors.transparent,
      color: Colors.transparent,
      borderWidth: 1.5,
      radius: const Radius.circular(10),
      borderColor: Colors.white.withOpacity(.4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Text(
            messageText.length < 12
                ? '$messageText               '
                : messageText,
            style: GoogleFonts.lato(
              textStyle: TextStyle(
                  color: Colors.white.withOpacity(.9),
                  fontSize: height / 62,
                  letterSpacing: .2),
            ),
          ),
          Text(
            filterDate(dataMessage),
            style: GoogleFonts.lato(
              textStyle: TextStyle(
                  color: Colors.white.withOpacity(.8),
                  fontSize: height / 85,
                  letterSpacing: .5),
            ),
          ),
        ],
      ),
    );
  }
}

class formMessageMy extends StatelessWidget {
  const formMessageMy({
    super.key,
    required this.messageText,
    required this.dataMessage,
    required this.isCheck,
  });

  final String messageText;
  final Timestamp dataMessage;
  final bool isCheck;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Bubble(
      nip: BubbleNip.rightBottom,
      stick: true,
      shadowColor: Colors.transparent,
      color: Colors.transparent,
      borderWidth: 1,
      radius: const Radius.circular(10),
      borderColor: Colors.white.withOpacity(.4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Text(
            messageText.length < 12
                ? '$messageText                      '
                : messageText,
            style: GoogleFonts.lato(
              textStyle: TextStyle(
                  color: Colors.white.withOpacity(.9),
                  fontSize: height / 60,
                  letterSpacing: .5),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                filterDate(dataMessage),
                style: GoogleFonts.lato(
                  textStyle: TextStyle(
                      color: Colors.white.withOpacity(.8),
                      fontSize: height / 82,
                      letterSpacing: .2),
                ),
              ),
              if (isCheck)
                DelayedDisplay(
                  delay: const Duration(milliseconds: 300),
                  child: showCheckMessageAnimation(
                      height, Icons.done_all, Colors.blueAccent),
                )
              else
                DelayedDisplay(
                  delay: const Duration(milliseconds: 300),
                  child: showCheckMessageAnimation(
                      height, Icons.check_rounded, Colors.white),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class MessageTextField extends StatefulWidget {
  final UserModel currentUser;
  final String friendId, token, friendName;
  final bool notification;

  const MessageTextField(this.currentUser, this.friendId, this.token,
      this.friendName, this.notification,
      {super.key});

  @override
  _MessageTextFieldState createState() => _MessageTextFieldState(
      currentUser, friendId, token, friendName, notification);
}

class _MessageTextFieldState extends State<MessageTextField> {
  final String friendId, token, friendName;
  final bool notification;
  final UserModel currentUser;
  final _controllerMessage = TextEditingController();
  bool isWrite = true;

  _MessageTextFieldState(this.currentUser, this.friendId, this.token,
      this.friendName, this.notification);

  startTimer() {
    Timer.periodic(
      const Duration(seconds: 6),
      (Timer timer) {
        setState(() => isWrite = true);
        timer.cancel();
      },
    );
  }

  @override
  void initState() {
    _controllerMessage.addListener(() {
      if (_controllerMessage.text.isNotEmpty) {
        if (!isWrite) return;
        startTimer();
        putUserWrites(currentUser.uid, friendId).then((i) => isWrite = false);
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return GetBuilder<GetFirsMessageChatController>(
      builder: (GetFirsMessageChatController controller) {
        return Padding(
          padding: EdgeInsets.only(bottom: 16, left: height / 48, right: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: width / 1.32,
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(
                  horizontal: 2,
                ),
                child: TextFormField(
                  textCapitalization: TextCapitalization.sentences,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(650),
                  ],
                  controller: _controllerMessage,
                  minLines: 1,
                  maxLines: 7,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(26),
                        borderSide:
                            const BorderSide(color: Colors.white70, width: 1.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(26),
                        borderSide:
                            const BorderSide(color: Colors.white70, width: 1.5),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(26),
                        borderSide:
                            const BorderSide(color: Colors.white70, width: 1.5),
                      ),
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                          vertical: height / 94, horizontal: 16),
                      counterStyle: const TextStyle(color: Colors.white),
                      hintStyle:
                          TextStyle(color: Colors.white.withOpacity(0.9)),
                      hintText: "Сообщение..."),
                  style: GoogleFonts.lato(
                    textStyle: TextStyle(
                        color: Colors.white,
                        fontSize: height / 58,
                        letterSpacing: .5),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(right: width / 100),
                child: ZoomTapAnimation(
                  child: Image.asset(
                    'images/ic_send.png',
                    height: width / 11,
                    width: width / 11,
                  ),
                  onTap: () async => await sendMessage(
                      isFirstMessage: controller.firsMessage.value,
                      controllerMessage: _controllerMessage,
                      friendId: friendId,
                      token: token,
                      notification: notification,
                      currentUser: currentUser),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
