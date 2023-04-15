import 'dart:ui';

import 'package:animator/animator.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delayed_display/delayed_display.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colors_border/flutter_colors_border.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:like_button/like_button.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

import '../config/const.dart';
import '../config/firebase/firestore_operations.dart';
import '../config/utils.dart';
import '../model/user_model.dart';
import '../screens/chat_user_screen.dart';
import 'animation_widget.dart';

class buttonAuth extends StatelessWidget {
  final String name;
  final double width;
  final int time;
  final VoidCallback voidCallback;

  const buttonAuth(this.name, this.width, this.time, this.voidCallback,
      {super.key});

  @override
  Widget build(BuildContext context) {
    final widthScreen = MediaQuery.of(context).size.width;

    return ZoomTapAnimation(
      onTap: voidCallback,
      end: 0.97,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaY: 15, sigmaX: 15),
          child: Container(
              height: widthScreen / 8,
              width: width,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.05),
                border: Border.all(color: Colors.white10, width: 0.5),
                borderRadius: BorderRadius.circular(15),
              ),
              child: animatedText(widthScreen / 28, name,
                  Colors.white.withOpacity(.8), time, 1)),
        ),
      ),
    );
  }
}

class buttonAuthAnimation extends StatelessWidget {
  final String name;
  final double width;
  final int time;
  final VoidCallback voidCallback;

  const buttonAuthAnimation(this.name, this.width, this.time, this.voidCallback,
      {super.key});

  @override
  Widget build(BuildContext context) {
    final widthScreen = MediaQuery.of(context).size.width;

    return ZoomTapAnimation(
      onTap: voidCallback,
      end: 0.97,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaY: 15, sigmaX: 15),
          child: Shimmer(
            colorOpacity: 0.4,
            color: Colors.white60,
            child: FlutterColorsBorder(
              animationDuration: 5,
              colors: const [Colors.black12, Colors.white],
              size: Size(width, widthScreen / 8),
              boardRadius: 15,
              borderWidth: 0.7,
              child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.05),
                    border: Border.all(color: Colors.white10, width: 0.5),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: animatedText(
                      widthScreen / 28, name, Colors.white, time, 1)),
            ),
          ),
        ),
      ),
    );
  }
}

 buttonUniversal({
  required text,
  required colorButton,
  required height,
  required width,
  required sizeText,
  required time,
  required darkColors,
  required onTap,
}) {
  return ZoomTapAnimation(
    onTap: onTap,
    child: Container(
      decoration: BoxDecoration(
        boxShadow: darkColors
            ? [
                const BoxShadow(
                    spreadRadius: 1.5,
                    blurRadius: 5,
                    offset: Offset(-3, 0),
                    color: Colors.blueAccent),
                const BoxShadow(
                    spreadRadius: 1,
                    blurRadius: 8,
                    offset: Offset(3, 0),
                    color: Colors.purpleAccent),
              ]
            : [
                const BoxShadow(
                    spreadRadius: 1.5,
                    blurRadius: 6,
                    offset: Offset(-3, 0),
                    color: Colors.white12),
                const BoxShadow(
                    spreadRadius: 1,
                    blurRadius: 8,
                    offset: Offset(3, 0),
                    color: Colors.white12),
              ],
        border: Border.all(width: 0.8, color: Colors.white54),
        gradient: LinearGradient(colors: colorButton),
        borderRadius: BorderRadius.circular(20),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Shimmer(
          colorOpacity: 0.4,
          duration: const Duration(milliseconds: 2500),
          child: FlutterColorsBorder(
            animationDuration: 4,
            colors: const [
              Colors.white10,
              Colors.white70,
            ],
            size: Size(width, height),
            boardRadius: 20,
            borderWidth: 0.6,
            child: Align(
              alignment: Alignment.center,
              child: ElevatedButton(
                  onPressed: onTap,
                  style: ElevatedButton.styleFrom(
                    shadowColor: Colors.transparent,
                    backgroundColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                  child: animatedText(sizeText, text, Colors.white, time, 1)),
            ),
          ),
        ),
      ),
    ),
  );
}

buttonUniversalNoState({
  required text,
  required colorButton,
  required height,
  required width,
  required sizeText,
  required time,
  required darkColors,
  required onTap,
}) {
  return ZoomTapAnimation(
    onTap: onTap,
    child: Container(
      decoration: BoxDecoration(
        boxShadow: darkColors
            ? [
                const BoxShadow(
                    spreadRadius: 1.5,
                    blurRadius: 5,
                    offset: Offset(-3, 0),
                    color: Colors.blueAccent),
                const BoxShadow(
                    spreadRadius: 1,
                    blurRadius: 8,
                    offset: Offset(3, 0),
                    color: Colors.purpleAccent),
              ]
            : [
                const BoxShadow(
                    spreadRadius: 1.5,
                    blurRadius: 5,
                    offset: Offset(-3, 0),
                    color: Colors.white12),
                const BoxShadow(
                    spreadRadius: 1,
                    blurRadius: 8,
                    offset: Offset(3, 0),
                    color: Colors.white12),
              ],
        border: Border.all(width: 0.8, color: Colors.white54),
        gradient: LinearGradient(colors: colorButton),
        borderRadius: BorderRadius.circular(20),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Shimmer(
          colorOpacity: 0.4,
          duration: const Duration(milliseconds: 2500),
          child: FlutterColorsBorder(
            animationDuration: 4,
            colors: const [
              Colors.white10,
              Colors.white70,
            ],
            size: Size(width, height),
            boardRadius: 20,
            borderWidth: 0.6,
            child: Align(
              alignment: Alignment.center,
              child: ElevatedButton(
                onPressed: onTap,
                style: ElevatedButton.styleFrom(
                  shadowColor: Colors.transparent,
                  backgroundColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                ),
                child: DelayedDisplay(
                  delay: Duration(milliseconds: time),
                  child: Text(
                    text,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: GoogleFonts.lato(
                      textStyle: TextStyle(
                          color: Colors.white,
                          fontSize: sizeText,
                          letterSpacing: .6),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class customIconButton extends StatelessWidget {
  final String path;
  final double height, width, padding;
  final VoidCallback onTap;

  const customIconButton(
      {Key? key,
      required this.path,
      required this.height,
      required this.width,
      required this.padding,
      required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ZoomTapAnimation(
      end: 0.95,
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Image.asset(
          path,
          height: height,
          width: width,
        ),
      ),
    );
  }
}

class buttonProfileUser extends StatefulWidget {
  final UserModel userModel, userModelCurrent;

  const buttonProfileUser(
    this.userModelCurrent,
    this.userModel, {
    super.key,
  });

  @override
  State<buttonProfileUser> createState() =>
      _buttonProfileUserState(userModelCurrent, userModel);
}

class _buttonProfileUserState extends State<buttonProfileUser> {
  final UserModel userModelFriend, userModelCurrent;

  final init = GetIt.I<FirebaseFirestore>().collection('User');

  _buttonProfileUserState(this.userModelCurrent, this.userModelFriend);

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    Widget buttonLogic(
        bool isMutuallyMy, bool isMutuallyFriend, BuildContext context) {
      if (!isMutuallyMy && isMutuallyFriend) {
        return buttonUniversalNoState(
          text: 'Ожидайте ответа',
          darkColors: false,
          colorButton: const [Colors.blueAccent, Colors.purpleAccent],
          height: height / 20,
          width: height / 4.8,
          sizeText: height / 66,
          time: 400,
          onTap: () async {
            if (!isMutuallyMy && isMutuallyFriend) {
              await deleteSympathyPartner(
                  userModelFriend.uid, userModelCurrent.uid);
              setState(() {});
            }
          },
        );
      } else if (!isMutuallyMy && !isMutuallyFriend) {
        return buttonUniversal(
          text: 'Оставить симпатию',
          darkColors: false,
          colorButton: const [color_black_88, color_black_88],
          height: height / 20,
          width: height / 4.8,
          sizeText: height / 66,
          time: 400,
          onTap: () async {
            if (!isMutuallyMy && !isMutuallyFriend) {
              await createSympathy(userModelFriend.uid, userModelCurrent);
              if (userModelFriend.token.isNotEmpty &&
                  userModelFriend.notification) {
                sendFcmMessage(
                    'Lancelot',
                    'У вас симпатия',
                    userModelFriend.token,
                    'sympathy',
                    userModelCurrent.uid,
                    userModelCurrent.listImageUri[0]);
              }
            } else {
              await deleteSympathyPartner(
                  userModelFriend.uid, userModelCurrent.uid);
            }
            setState(() {});
          },
        );
      } else if (isMutuallyMy && !isMutuallyFriend) {
        return buttonUniversal(
          darkColors: false,
          text: 'Принять симпатию',
          colorButton: const [Colors.blueAccent, Colors.purpleAccent],
          height: height / 20,
          width: height / 4.8,
          sizeText: height / 66,
          time: 400,
          onTap: () async {
            if (isMutuallyMy && !isMutuallyFriend) {
              await createSympathy(userModelFriend.uid, userModelCurrent);
              if (userModelFriend.token.isNotEmpty &&
                  userModelFriend.notification) {
                sendFcmMessage(
                    'Lancelot',
                    'У вас взаимная симпатия',
                    userModelFriend.token,
                    'sympathy',
                    userModelCurrent.uid,
                    userModelCurrent.listImageUri[0]);
              }
            } else {
              await deleteSympathyPartner(
                  userModelFriend.uid, userModelCurrent.uid);
            }

            setState(() {});
          },
        );
      } else {
        return buttonUniversalNoState(
          text: 'Написать',
          darkColors: true,
          colorButton: listColorMulticoloured,
          height: height / 20,
          width: height / 5.6,
          sizeText: height / 64,
          time: 400,
          onTap: () => Navigator.push(
            context,
            FadeRouteAnimation(
              ChatUserScreen(
                friendId: userModelFriend.uid,
                friendName: userModelFriend.name,
                friendImage: userModelFriend.listImageUri[0],
                userModelCurrent: userModelCurrent,
                token: userModelFriend.token,
                notification: userModelFriend.notification,
              ),
            ),
          ),
        );
      }
    }

    return FutureBuilder(
      future: init
          .doc(userModelCurrent.uid)
          .collection('sympathy')
          .where('uid', isEqualTo: userModelFriend.uid)
          .get(),
      builder: (context, snapshotMy) {
        return FutureBuilder(
          future: init
              .doc(userModelFriend.uid)
              .collection('sympathy')
              .where('uid', isEqualTo: userModelCurrent.uid)
              .get(),
          builder: (context, snapshot) {
            if (snapshotMy.hasData && snapshot.hasData) {
              bool isMutuallyFriend = false, isMutuallyMy = false;
              getFuture(50).then((_) {
                isMutuallyFriend = false;
                isMutuallyMy = false;
              });

              for (var data in snapshot.data!.docs) {
                isMutuallyFriend = data['uid'] == userModelCurrent.uid;
              }

              for (var data in snapshotMy.data!.docs) {
                isMutuallyMy = data['uid'] == userModelFriend.uid;
              }

              return DelayedDisplay(
                  delay: const Duration(milliseconds: 400),
                  child: buttonLogic(isMutuallyMy, isMutuallyFriend, context));
            }

            return const SizedBox();
          },
        );
      },
    );
  }
}

class buttonLike extends StatelessWidget {
  final bool isLike;
  final UserModel userModelFriend, userModelCurrent;

  const buttonLike(
      {Key? key,
      required this.isLike,
      required this.userModelCurrent,
      required this.userModelFriend})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return ZoomTapAnimation(
      child: Container(
        margin: const EdgeInsets.only(right: 30),
        child: LikeButton(
          isLiked: isLike,
          size: height * 0.04,
          circleColor:
              const CircleColor(start: Colors.pinkAccent, end: Colors.red),
          bubblesColor: const BubblesColor(
            dotPrimaryColor: Colors.pink,
            dotSecondaryColor: Colors.deepPurpleAccent,
            dotLastColor: Colors.yellowAccent,
            dotThirdColor: Colors.deepPurpleAccent,
          ),
          likeBuilder: (bool isLiked) {
            return SizedBox(
              height: height * 0.07,
              width: height * 0.07,
              child: Animator<double>(
                duration: const Duration(milliseconds: 2000),
                cycles: 0,
                curve: Curves.elasticIn,
                tween: Tween<double>(begin: 20.0, end: 25.0),
                builder: (context, animatorState, child) => Icon(
                  isLiked
                      ? Icons.favorite_outlined
                      : Icons.favorite_border_sharp,
                  size: animatorState.value * 1.6,
                  color: isLiked ? color_red : Colors.white,
                ),
              ),
            );
          },
          onTap: (isLiked) => putLike(
            userModelCurrent,
            userModelFriend,
            true,
          ),
        ),
      ),
    );
  }
}

class homeAnimationButton extends StatelessWidget {
  const homeAnimationButton({
    super.key,
    required this.onTap,
    required this.colors,
    required this.icon,
    required this.time,
  });

  final VoidCallback onTap;
  final Color colors;
  final IconData icon;
  final int time;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return ZoomTapAnimation(
      onTap: onTap,
      end: 0.88,
      child: SizedBox(
        height: height * 0.23,
        width: width / 2,
        child: AvatarGlow(
          glowColor: Colors.blueAccent,
          endRadius: height * 0.1,
          repeatPauseDuration: const Duration(milliseconds: 500),
          duration: Duration(milliseconds: time),
          curve: Curves.easeOutQuad,
          child: FlutterColorsBorder(
            animationDuration: 5,
            colors: const [
              Colors.yellowAccent,
              Colors.purpleAccent,
              Colors.deepPurpleAccent,
              Colors.pinkAccent,
            ],
            size: Size(height * 0.162, height * 0.162),
            boardRadius: 120,
            borderWidth: 1,
            child: Container(
              height: height * 0.17,
              width: height * 0.17,
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(120)),
              child: SizedBox(
                height: height * 0.9,
                width: height * 0.9,
                child: Animator<double>(
                  duration: const Duration(milliseconds: 2000),
                  cycles: 0,
                  curve: Curves.elasticIn,
                  tween: Tween<double>(begin: 20.0, end: 25.0),
                  builder: (context, animatorState, child) => Icon(
                    icon,
                    size: animatorState.value * 2.6,
                    color: colors,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
