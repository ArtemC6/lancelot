import 'dart:ui';

import 'package:avatar_glow/avatar_glow.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colors_border/flutter_colors_border.dart';
import 'package:like_button/like_button.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

import '../config/const.dart';
import '../config/firestore_operations.dart';
import '../model/user_model.dart';
import '../screens/that_user_screen.dart';
import 'animation_widget.dart';

class buttonAuth extends StatelessWidget {
  String name;
  double width;
  int time;
  VoidCallback voidCallback;

  buttonAuth(this.name, this.width, this.time, this.voidCallback, {super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaY: 15, sigmaX: 15),
        child: InkWell(
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
          onTap: voidCallback,
          child: Container(
              height: size.width / 8,
              width: size.width / width,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.05),
                border: Border.all(color: Colors.white10, width: 0.5),
                borderRadius: BorderRadius.circular(15),
              ),
              child: animatedText(size.width / 34, name,
                  Colors.white.withOpacity(.8), time, 1)),
        ),
      ),
    );
  }
}

Widget buttonUniversal(String name, color, height, onTap) {
  return ZoomTapAnimation(
    enableLongTapRepeatEvent: false,
    longTapRepeatDuration: const Duration(milliseconds: 200),
    begin: 1.0,
    end: 0.94,
    beginDuration: const Duration(milliseconds: 20),
    endDuration: const Duration(milliseconds: 200),
    beginCurve: Curves.decelerate,
    endCurve: Curves.fastOutSlowIn,
    onTap: () {},
    child: SizedBox(
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          boxShadow: const [
            BoxShadow(
              color: Colors.white54,
              blurRadius: 5.0,
              spreadRadius: 0.0,
              offset: Offset(
                0.0,
                1.3,
              ),
            )
          ],
          border: Border.all(width: 0.8, color: Colors.white38),
          gradient: LinearGradient(colors: color),
          borderRadius: BorderRadius.circular(20),
        ),
        child: ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              shadowColor: Colors.transparent,
              backgroundColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
            ),
            child: animatedText(height / 3.5, name, Colors.white, 600, 1)),
      ),
    ),
  );
}

class customIconButton extends StatelessWidget {
  String path;
  double height, width, padding;
  VoidCallback onTap;

  customIconButton(
      {Key? key,
      required this.path,
      required this.height,
      required this.width,
      required this.padding,
      required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(padding),
      child: ZoomTapAnimation(
        enableLongTapRepeatEvent: false,
        longTapRepeatDuration: const Duration(milliseconds: 200),
        begin: 1.0,
        end: 0.90,
        beginDuration: const Duration(milliseconds: 20),
        endDuration: const Duration(milliseconds: 200),
        beginCurve: Curves.decelerate,
        endCurve: Curves.fastOutSlowIn,
        onTap: onTap,
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

  buttonProfileUser(
    this.userModelCurrent,
    this.userModel, {
    super.key,
    Key,
  });

  @override
  State<buttonProfileUser> createState() =>
      _buttonProfileUserState(userModelCurrent, userModel);
}

class _buttonProfileUserState extends State<buttonProfileUser> {
  final UserModel userModelFriend, userModelCurrent;

  _buttonProfileUserState(this.userModelCurrent, this.userModelFriend);

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    Widget buttonLogic(
        bool isMutuallyMy, bool isMutuallyFriend, BuildContext context) {
      if (!isMutuallyMy && isMutuallyFriend) {
        return buttonUniversal('Ожидайте ответа',
            [Colors.blueAccent, Colors.purpleAccent], height / 30, () {
          if (!isMutuallyMy && isMutuallyFriend) {
            deleteSympathyPartner(userModelFriend.uid, userModelCurrent.uid);
          }
        });
      } else if (!isMutuallyMy && !isMutuallyFriend) {
        return buttonUniversal(
            'Оставить симпатию', [color_black_88, color_black_88], height / 30,
            () {
          if (!isMutuallyMy && !isMutuallyFriend) {
            createSympathy(userModelFriend.uid, userModelCurrent).then((value) {
              if (userModelFriend.token != '' && userModelFriend.notification) {
                sendFcmMessage(
                    'tinder',
                    'У вас симпатия',
                    userModelFriend.token,
                    'sympathy',
                    userModelCurrent.uid,
                    userModelCurrent.userImageUrl[0]);
              }
            });
          } else {
            deleteSympathyPartner(userModelFriend.uid, userModelCurrent.uid);
          }
        });
      } else if (isMutuallyMy && !isMutuallyFriend) {
        return buttonUniversal('Принять симпатию',
            [Colors.blueAccent, Colors.purpleAccent], height / 30, () {
          if (isMutuallyMy && !isMutuallyFriend) {
            createSympathy(userModelFriend.uid, userModelCurrent).then((value) {
              if (userModelFriend.token != '' && userModelFriend.notification) {
                sendFcmMessage(
                    'tinder',
                    'У вас взаимная симпатия',
                    userModelFriend.token,
                    'sympathy',
                    userModelCurrent.uid,
                    userModelCurrent.userImageUrl[0]);
              }
            });
          } else {
            deleteSympathyPartner(userModelFriend.uid, userModelCurrent.uid);
          }
        });
      } else {
        return buttonUniversal(
            'Написать',
            [Colors.blueAccent, Colors.purpleAccent, Colors.orangeAccent],
            height / 30, () {
          Navigator.push(
              context,
              FadeRouteAnimation(ChatUserScreen(
                friendId: userModelFriend.uid,
                friendName: userModelFriend.name,
                friendImage: userModelFriend.userImageUrl[0],
                userModelCurrent: userModelCurrent,
                token: userModelFriend.token,
                notification: userModelFriend.notification,
              )));
        });
      }
    }

    return SizedBox(
      height: 40,
      child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('User')
              .doc(userModelCurrent.uid)
              .collection('sympathy')
              .where('uid', isEqualTo: userModelFriend.uid)
              .snapshots(),
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshotMy) {
            if (snapshotMy.hasData) {
              return StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('User')
                      .doc(userModelFriend.uid)
                      .collection('sympathy')
                      .where('uid', isEqualTo: userModelCurrent.uid)
                      .snapshots(),
                  builder:
                      (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                    bool isMutuallyFriend = false, isMutuallyMy = false;
                    try {
                      for (int i = 0; i < snapshot.data.docs.length; i++) {
                        isMutuallyFriend = snapshot.data.docs[i]['uid'] ==
                            userModelCurrent.uid;
                        if (isMutuallyFriend) {
                          break;
                        }
                      }
                      for (int i = 0; i < snapshotMy.data.docs.length; i++) {
                        isMutuallyMy = snapshotMy.data.docs[i]['uid'] ==
                            userModelFriend.uid;
                        if (isMutuallyMy) {
                          break;
                        }
                      }
                    } catch (E) {}
                    if (snapshotMy.hasData && snapshot.hasData) {
                      return SlideFadeTransition(
                          animationDuration: const Duration(milliseconds: 500),
                          child: buttonLogic(
                              isMutuallyMy, isMutuallyFriend, context));
                    }
                    return const SizedBox();
                  });
            }
            return const SizedBox();
          }),
    );
  }
}

// class buttonProfileMy extends StatelessWidget {
//   UserModel userModel;
//
//   buttonProfileMy(this.userModel, {super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return SlideFadeTransition(
//       animationDuration: const Duration(milliseconds: 800),
//       child: Container(
//         padding: const EdgeInsets.only(right: 20),
//         height: 40,
//         child: DecoratedBox(
//           decoration: BoxDecoration(
//             boxShadow: const [
//               BoxShadow(
//                 color: Colors.white38,
//                 blurRadius: 5.0,
//                 spreadRadius: 0.0,
//                 offset: Offset(
//                   0.0,
//                   1.5,
//                 ),
//               )
//             ],
//             border: Border.all(width: 0.7, color: Colors.white30),
//             gradient: const LinearGradient(
//                 colors: [Colors.blueAccent, Colors.purpleAccent]),
//             borderRadius: BorderRadius.circular(20),
//           ),
//           child: ElevatedButton(
//             onPressed: () {
//               Navigator.push(
//                   context,
//                   FadeRouteAnimation(EditProfileScreen(
//                     isFirst: false,
//                     userModel: userModel,
//                   )));
//             },
//             style: ElevatedButton.styleFrom(
//               shadowColor: Colors.transparent,
//               backgroundColor: Colors.transparent,
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(20)),
//             ),
//             child: RichText(
//               text: TextSpan(
//                 text: 'Редактировать',
//                 style: GoogleFonts.lato(
//                   textStyle: const TextStyle(
//                       color: Colors.white, fontSize: 11, letterSpacing: .1),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

class buttonLike extends StatelessWidget {
  bool isLike;
  UserModel userModelFriend, userModelCurrent;

  buttonLike(
      {Key? key,
      required this.isLike,
      required this.userModelCurrent,
      required this.userModelFriend})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ZoomTapAnimation(
      enableLongTapRepeatEvent: false,
      longTapRepeatDuration: const Duration(milliseconds: 200),
      begin: 1.0,
      end: 0.93,
      beginDuration: const Duration(milliseconds: 20),
      endDuration: const Duration(milliseconds: 200),
      beginCurve: Curves.decelerate,
      endCurve: Curves.fastOutSlowIn,
      child: Container(
        margin: const EdgeInsets.only(right: 30),
        child: LikeButton(
          isLiked: isLike,
          size: 32,
          circleColor:
              const CircleColor(start: Colors.pinkAccent, end: Colors.red),
          bubblesColor: const BubblesColor(
            dotPrimaryColor: Colors.pink,
            dotSecondaryColor: Colors.deepPurpleAccent,
          ),
          likeBuilder: (bool isLiked) {
            return Icon(
              isLiked ? Icons.favorite_outlined : Icons.favorite_border_sharp,
              color: isLiked ? color_red : Colors.white,
              size: 32,
            );
          },
          onTap: (isLiked) {
            return putLike(
              userModelCurrent,
              userModelFriend,
              true,
            );
          },
        ),
      ),
    );
  }
}

ZoomTapAnimation homeAnimationButton(
    double height, double width, onTap, Color colors, IconData icon, int time) {
  return ZoomTapAnimation(
    enableLongTapRepeatEvent: false,
    longTapRepeatDuration: const Duration(milliseconds: 200),
    begin: 1.0,
    end: 0.88,
    beginDuration: const Duration(milliseconds: 20),
    endDuration: const Duration(milliseconds: 200),
    beginCurve: Curves.decelerate,
    endCurve: Curves.fastOutSlowIn,
    onTap: onTap,
    child: SizedBox(
      height: height * 0.17,
      width: width / 2,
      child: AvatarGlow(
        glowColor: Colors.blueAccent,
        endRadius: height * 0.08,
        repeatPauseDuration: const Duration(milliseconds: 500),
        duration: Duration(milliseconds: time),
        repeat: true,
        showTwoGlows: true,
        curve: Curves.easeOutQuad,
        child: FlutterColorsBorder(
          animationDuration: 5,
          colors: const [
            Colors.amberAccent,
            Colors.red,
            // Colors.purpleAccent,
            Colors.deepPurpleAccent,
          ],
          size: Size(height * 0.10, height * 0.10),
          boardRadius: 50,
          borderWidth: 0.8,
          child: Container(
            height: height * 0.10,
            width: height * 0.10,
            decoration: BoxDecoration(
                color: Colors.transparent, borderRadius: BorderRadius.circular(99)),
            child: Icon(
              icon,
              color: colors,
              size: height * 0.05,
            ),
          ),
        ),
      ),
    ),
  );
}
