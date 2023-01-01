import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lancelot/main.dart';

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
  bool isEmail = true;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(vsync: this);
    sendEmail();
    // print(FirebaseAuth.instance.currentUser?.onAuthStateChanged);
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  Future sendEmail() async {
    setState(() => isEmail = false);
    FirebaseAuth.instance.currentUser!.sendEmailVerification().then((value) {
      Future.delayed(const Duration(milliseconds: 8000), () {
        setState(() => isEmail = true);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: color_black_88,
      body: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            print(snapshot.data!.emailVerified);
            if (snapshot.hasData) {
              if (!snapshot.data!.emailVerified) {
                print('Noooo');
                return Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      showAnimationVerify(
                          size.height,
                          'images/animation_email_send.json',
                          animationController),
                      Padding(
                        padding: EdgeInsets.only(
                            bottom: size.height / 22,
                            left: size.height / 48,
                            right: size.height / 48),
                        child: SlideFadeTransition(
                          animationDuration: const Duration(milliseconds: 60),
                          child: Text(
                            maxLines: 2,
                            textAlign: TextAlign.center,
                            'Письмо с подтверждением было отправлено на вашу электронную почту',
                            style: GoogleFonts.lato(
                              textStyle: TextStyle(
                                  color: Colors.white,
                                  fontSize: size.height / 52,
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
                              })
                            : buttonUniversalAnimationColors(
                                'Отправить повторно',
                                [color_black_88, color_black_88],
                                size.height / 20,
                                () {}),
                      ),
                      Padding(
                        padding: EdgeInsets.only(bottom: size.height / 14),
                        child: buttonUniversalAnimationColors(
                            'Отмена',
                            [color_black_88, color_black_88],
                            size.height / 20, () {
                          FirebaseAuth.instance.currentUser
                              ?.delete()
                              .then((value) {});
                        }),
                      ),
                    ],
                  ),
                );
              } else {
                print('EEEEEE');
                return const Manager();
              }
            }
            return const SizedBox();
          }),
    );
  }
}
