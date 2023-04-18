import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delayed_display/delayed_display.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

import '../../config/const.dart';
import '../../main.dart';
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
  final auth = GetIt.I<FirebaseAuth>();

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(vsync: this);
    auth.currentUser
        ?.reload()
        .then((_) => auth.currentUser!.sendEmailVerification());
    timer =
        Timer.periodic(const Duration(seconds: 5), (i) => checkEmailVerify());
  }

  @override
  void dispose() {
    animationController.dispose();
    timer.cancel();
    super.dispose();
  }

  sendEmail() {
    auth.currentUser?.reload().then((_) {
      setState(() => isEmail = false);
      auth.currentUser!.sendEmailVerification();
      Future.delayed(const Duration(milliseconds: 8000), () {
        checkEmailVerify();
        isDescriptionEmailTime = true;
        setState(() => isEmail = true);
      });
    });
  }

  checkEmailVerify() {
    auth.currentUser?.reload().then((_) {
      if (auth.currentUser!.emailVerified) {
        animationController.dispose();
        timer.cancel();
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const Manager()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: color_black_88,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            showAnimationVerify(
              animationController: animationController,
              path: 'images/animation_email_send.json',
            ),
            Padding(
              padding: EdgeInsets.only(
                  top: height / 32,
                  bottom: height / 18,
                  left: height / 48,
                  right: height / 48),
              child: DelayedDisplay(
                delay: const Duration(milliseconds: 200),
                child: Text(
                  maxLines: 3,
                  textAlign: TextAlign.center,
                  'Письмо с подтверждением было отправлено на вашу электронную почту ${GetIt.I<FirebaseAuth>().currentUser!.email}',
                  style: GoogleFonts.lato(
                    textStyle: TextStyle(
                        color: Colors.white,
                        fontSize: height / 52,
                        letterSpacing: .6),
                  ),
                ),
              ),
            ),
            if (!isDescriptionEmail && isDescriptionEmailTime)
              ZoomTapAnimation(
                onTap: () => setState(() => isDescriptionEmail = true),
                child: Padding(
                  padding: EdgeInsets.only(
                      bottom: height / 16,
                      left: height / 48,
                      right: height / 48),
                  child: animatedText(height / 54,
                      'Не приходит код подтверждения ?', Colors.white, 400, 3),
                ),
              ),
            if (isDescriptionEmail)
              Padding(
                padding: EdgeInsets.only(
                    bottom: height / 16, left: height / 48, right: height / 48),
                child: animatedText(height / 54,
                    'Посмотрите письмо в разделе спам.', Colors.white, 400, 3),
              ),
            Padding(
              padding: EdgeInsets.only(bottom: height / 32),
              child: isEmail
                  ? buttonUniversal(
                text: 'Отправить повторно',
                      darkColors: true,
                      colorButton: listColorMulticoloured,
                      height: height / 18,
                      width: width / 1.5,
                      sizeText: height / 62,
                      time: 400,
                      onTap: () => sendEmail(),
                    )
                  : buttonUniversalNoState(
                      text: 'Отправить повторно',
                      darkColors: false,
                      colorButton: const [color_black_88, color_black_88],
                      height: height / 18,
                      width: width / 1.5,
                      sizeText: height / 62,
                      time: 400,
                      onTap: () {},
                    ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: height / 14),
              child: buttonUniversalNoState(
                text: 'Другая почта',
                darkColors: false,
                colorButton: const [color_black_88, color_black_88],
                height: height / 18,
                width: width / 1.5,
                sizeText: height / 62,
                time: 400,
                onTap: () async {
                  try {
                    final uid = auth.currentUser?.uid;
                    if (uid != null) {
                      await GetIt.I<FirebaseFirestore>()
                          .collection("User")
                          .doc(uid)
                          .delete();
                      await auth.currentUser!.delete();
                    }
                    await auth.signOut();
                  } catch (e) {
                    await auth.signOut();
                  }
                  auth.signOut();
                  Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => const Manager()));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
