import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lancelot/screens/auth/signup_screen.dart';
import 'package:lancelot/widget/animation_widget.dart';

import '../../config/const.dart';
import '../../config/firebase_auth.dart';
import '../../main.dart';
import '../../widget/button_widget.dart';
import '../../widget/textField_widget.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  _SignInScreen createState() => _SignInScreen();
}

class _SignInScreen extends State<SignInScreen> with TickerProviderStateMixin {
  late AnimationController controller1, controller2;
  late Animation<double> animation1, animation2, animation3, animation4;
  final TextEditingController emailController = TextEditingController(),
      passwordController = TextEditingController();
  bool signStart = false;

  @override
  void initState() {
    super.initState();
    if (FirebaseAuth.instance.currentUser?.uid != null) {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const Manager()));
    }
    controller1 = AnimationController(
      vsync: this,
      duration: const Duration(
        seconds: 5,
      ),
    );
    animation1 = Tween<double>(begin: .1, end: .15).animate(
      CurvedAnimation(
        parent: controller1,
        curve: Curves.easeInOut,
      ),
    )
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          controller1.reverse();
        } else if (status == AnimationStatus.dismissed) {
          controller1.forward();
        }
      });

    animation2 = Tween<double>(begin: .02, end: .04).animate(
      CurvedAnimation(
        parent: controller1,
        curve: Curves.easeInOut,
      ),
    )..addListener(() {
        setState(() {});
      });

    controller2 = AnimationController(
      vsync: this,
      duration: const Duration(
        seconds: 5,
      ),
    );

    animation3 = Tween<double>(begin: .41, end: .38).animate(CurvedAnimation(
      parent: controller2,
      curve: Curves.easeInOut,
    ))
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          controller2.reverse();
        } else if (status == AnimationStatus.dismissed) {
          controller2.forward();
        }
      });
    animation4 = Tween<double>(begin: 170, end: 190).animate(
      CurvedAnimation(
        parent: controller2,
        curve: Curves.easeInOut,
      ),
    )..addListener(() {
        setState(() {});
      });

    Timer(const Duration(milliseconds: 1500), () {
      controller1.forward();
    });

    controller2.forward();
    userValidatorSigIn();
  }

  void userValidatorSigIn() {
    bool passwordValid = false;
    emailController.addListener(() {
      final bool emailValid = RegExp(
              r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
          .hasMatch(emailController.text);

      passwordController.addListener(() {
        if (passwordController.text.length > 5) {
          passwordValid = true;
        } else {
          passwordValid = false;
        }

        if (emailValid && passwordValid) {
          setState(() {
            signStart = true;
          });
        } else {
          setState(() {
            signStart = false;
          });
        }
      });

      if (emailValid && passwordValid) {
        setState(() {
          signStart = true;
        });
      } else {
        setState(() {
          signStart = false;
        });
      }
    });
  }

  @override
  void dispose() {
    controller1.dispose();
    controller2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: color_blue_90,
      body: ScrollConfiguration(
        behavior: MyBehavior(),
        child: SingleChildScrollView(
          child: SizedBox(
            height: size.height,
            child: Stack(
              children: [
                Positioned(
                  top: size.height * (animation2.value + .58),
                  left: size.width * .21,
                  child: CustomPaint(
                    painter: MyPainter(50),
                  ),
                ),
                Positioned(
                  top: size.height * .98,
                  left: size.width * .1,
                  child: CustomPaint(
                    painter: MyPainter(animation4.value - 30),
                  ),
                ),
                Positioned(
                  top: size.height * .5,
                  left: size.width * (animation2.value + .8),
                  child: CustomPaint(
                    painter: MyPainter(30),
                  ),
                ),
                Positioned(
                  top: size.height * animation3.value,
                  left: size.width * (animation1.value + .1),
                  child: CustomPaint(
                    painter: MyPainter(60),
                  ),
                ),
                Positioned(
                  top: size.height * .1,
                  left: size.width * .8,
                  child: CustomPaint(
                    painter: MyPainter(animation4.value),
                  ),
                ),
                Column(
                  children: [
                    Expanded(
                      flex: 5,
                      child: Padding(
                          padding: EdgeInsets.only(top: size.height * .1),
                          child: animatedText(width / 11, 'Lancelot',
                              Colors.white.withOpacity(.8), 0, 1)),
                    ),
                    Expanded(
                      flex: 6,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          textFieldAuth('Email...', emailController,
                              Icons.email_outlined, size, false, 35, context),
                          textFieldAuth(
                              'Password...',
                              passwordController,
                              Icons.lock_open_outlined,
                              size,
                              true,
                              20,
                              context),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              signStart
                                  ? buttonAuthAnimation('Войти', 2.4, 350, () {
                                      FirebaseAuthMethods.loginWithEmail(
                                          email: emailController.text,
                                          password: passwordController.text,
                                          context: context);
                                    })
                                  : buttonAuth('Войти', 2.4, 500, () {
                                      FirebaseAuthMethods.loginWithEmail(
                                          email: emailController.text,
                                          password: passwordController.text,
                                          context: context);
                                    }),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 6,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          buttonAuth('Зарегистрировать аккаунт', 1.8, 0, () {
                            Navigator.push(
                              context,
                              FadeRouteAnimation(const SignUpScreen()),
                            );
                          }),
                          SizedBox(height: size.height * .05),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MyPainter extends CustomPainter {
  final double radius;

  MyPainter(this.radius);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = const LinearGradient(
              colors: [Color(0xffFD5E3D), Color(0xffC43990)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight)
          .createShader(Rect.fromCircle(
        center: const Offset(0, 0),
        radius: radius,
      ));

    canvas.drawCircle(Offset.zero, radius, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class MyBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}
