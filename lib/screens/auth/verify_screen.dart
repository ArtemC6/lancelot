import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lancelot/main.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

import '../../config/const.dart';
import '../../widget/animation_widget.dart';
import '../../widget/button_widget.dart';

class VerifyScreen extends StatefulWidget {
  const VerifyScreen({Key? key}) : super(key: key);

  @override
  _VerifyScreen createState() => _VerifyScreen();
}

class _VerifyScreen extends State<VerifyScreen> with TickerProviderStateMixin {
  late final AnimationController animationController;
  bool isEmail = true,
      isDescriptionEmail = false,
      isDescriptionEmailTime = false;
  late Timer timer;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(vsync: this);
    FirebaseAuth.instance.currentUser?.reload().then((value) {
      FirebaseAuth.instance.currentUser!.sendEmailVerification();
    });
    timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      checkEmailVerify();
    });
  }

  @override
  void dispose() {
    animationController.dispose();
    timer.cancel();
    super.dispose();
  }

  Future sendEmail() async {
    FirebaseAuth.instance.currentUser?.reload().then((value) {
      setState(() => isEmail = false);
      FirebaseAuth.instance.currentUser!.sendEmailVerification();
      Future.delayed(const Duration(milliseconds: 8000), () {
        checkEmailVerify();
        setState(() {
          isEmail = true;
          isDescriptionEmailTime = true;
        });
      });
    });
  }

  Future checkEmailVerify() async {
    FirebaseAuth.instance.currentUser?.reload().then((value) {
      if (FirebaseAuth.instance.currentUser!.emailVerified) {
        animationController.dispose();
        timer.cancel();
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const Manager()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: color_black_88,
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            showAnimationVerify(size.height, 'images/animation_email_send.json',
                animationController),
            Padding(
              padding: EdgeInsets.only(
                  bottom: size.height / 22,
                  left: size.height / 48,
                  right: size.height / 48),
              child: SlideFadeTransition(
                animationDuration: const Duration(milliseconds: 200),
                child: Text(
                  maxLines: 3,
                  textAlign: TextAlign.center,
                  'Письмо с подтверждением было отправлено на вашу электронную почту ${FirebaseAuth.instance.currentUser!.email}',
                  style: GoogleFonts.lato(
                    textStyle: TextStyle(
                        color: Colors.white,
                        fontSize: size.height / 60,
                        letterSpacing: .6),
                  ),
                ),
              ),
            ),
            if (!isDescriptionEmail && isDescriptionEmailTime)
              ZoomTapAnimation(
                onTap: () {
                  setState(() {
                    isDescriptionEmail = true;
                  });
                },
                child: Padding(
                  padding: EdgeInsets.only(
                      bottom: size.height / 22,
                      left: size.height / 48,
                      right: size.height / 48),
                  child: SlideFadeTransition(
                    animationDuration: const Duration(milliseconds: 400),
                    child: Text(
                      maxLines: 3,
                      textAlign: TextAlign.center,
                      'Не приходит код подтверждения ?',
                      style: GoogleFonts.lato(
                        textStyle: TextStyle(
                            color: Colors.white,
                            fontSize: size.height / 60,
                            letterSpacing: .6),
                      ),
                    ),
                  ),
                ),
              ),
            if (isDescriptionEmail)
              Padding(
                padding: EdgeInsets.only(
                    bottom: size.height / 22,
                    left: size.height / 48,
                    right: size.height / 48),
                child: SlideFadeTransition(
                  animationDuration: const Duration(milliseconds: 450),
                  child: Text(
                    maxLines: 3,
                    textAlign: TextAlign.center,
                    'Посмотрите письмо в разделе спам.',
                    style: GoogleFonts.lato(
                      textStyle: TextStyle(
                          color: Colors.white,
                          fontSize: size.height / 60,
                          letterSpacing: .6),
                    ),
                  ),
                ),
              ),
            Padding(
              padding: EdgeInsets.only(bottom: size.height / 32),
              child: isEmail
                  ? buttonUniversalAnimationColors(
                      'Отправить повторно',
                      [
                        Colors.blueAccent,
                        Colors.purpleAccent,
                        Colors.orangeAccent
                      ],
                      size.height / 20, () {
                      sendEmail();
                    }, 400)
                  : buttonUniversalAnimationColors(
                      'Отправить повторно',
                      [color_black_88, color_black_88],
                      size.height / 20,
                      () {},
                      400),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: size.height / 14),
              child: buttonUniversalAnimationColors('Другая почта',
                  [color_black_88, color_black_88], size.height / 20, () async {
                    if (FirebaseAuth.instance.currentUser?.uid != null) {
                  await FirebaseFirestore.instance
                      .collection("User")
                      .doc(FirebaseAuth.instance.currentUser!.uid)
                      .delete();
                  await FirebaseAuth.instance.currentUser!.delete();
                  Future.delayed(const Duration(seconds: 3), () async {
                    await FirebaseAuth.instance.signOut();
                  });
                } else {
                      await FirebaseAuth.instance.signOut();
                }

                Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const Manager()));
              }, 400),
            ),
          ],
        ),
      ),
    );
  }
}
