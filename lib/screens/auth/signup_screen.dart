import 'dart:async';

import 'package:Lancelot/screens/auth/signin_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../config/const.dart';
import '../../config/firebase_auth.dart';
import '../../main.dart';
import '../../widget/animation_widget.dart';
import '../../widget/button_widget.dart';
import '../../widget/textField_widget.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  _SignUpScreen createState() => _SignUpScreen();
}

class _SignUpScreen extends State<SignUpScreen> with TickerProviderStateMixin {
  late AnimationController controller1, controller2;
  late Animation<double> animation1, animation2, animation3, animation4;
  final TextEditingController nameController = TextEditingController(),
      emailController = TextEditingController(),
      passwordController = TextEditingController();
  bool signStart = false;

  @override
  void initState() {
    super.initState();
    if (GetIt.I<FirebaseAuth>().currentUser?.uid != null) {
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

    userValidatorSigUp();
  }

   userValidatorSigUp() {
    bool passwordValid = false, nameValid = false, emailValid = false;

    nameController.addListener(() {
      if (nameController.text.length > 2) {
        nameValid = true;
      } else {
        nameValid = false;
      }

      setState(() {});

      emailController.addListener(() {
        emailValid = RegExp(
                r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
            .hasMatch(emailController.text);

        passwordController.addListener(() {
          if (passwordController.text.length > 5) {
            passwordValid = true;
          } else {
            passwordValid = false;
          }

          if (emailValid && passwordValid && nameValid) {
            signStart = true;
          } else {
            signStart = false;
          }

          setState(() {});
        });

        if (emailValid && passwordValid && nameValid) {
          signStart = true;
        } else {
          signStart = false;
        }
      });

      if (emailValid && passwordValid && nameValid) {
        signStart = true;
      } else {
        signStart = false;
      }
      setState(() {});
    });
  }

  sigUpTap(context) {
    FirebaseAuthMethods.signUpWithEmail(
        email: emailController.text,
        password: passwordController.text,
        name: nameController.text[0].toUpperCase() +
            nameController.text.substring(1).toLowerCase(),
        context: context);
  }

  @override
  void dispose() {
    controller1.dispose();
    controller2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: color_blue_90,
      body: ScrollConfiguration(
        behavior: MyBehavior(),
        child: SingleChildScrollView(
          child: SizedBox(
            height: height,
            child: Stack(
              children: [
                Positioned(
                  top: height * (animation2.value + .58),
                  left: width * .21,
                  child: CustomPaint(
                    painter: MyPainter(50),
                  ),
                ),
                Positioned(
                  top: height * .98,
                  left: width * .1,
                  child: CustomPaint(
                    painter: MyPainter(animation4.value - 30),
                  ),
                ),
                Positioned(
                  top: height * .5,
                  left: width * (animation2.value + .8),
                  child: CustomPaint(
                    painter: MyPainter(30),
                  ),
                ),
                Positioned(
                  top: height * animation3.value,
                  left: width * (animation1.value + .1),
                  child: CustomPaint(
                    painter: MyPainter(60),
                  ),
                ),
                Positioned(
                  top: height * .1,
                  left: width * .8,
                  child: CustomPaint(
                    painter: MyPainter(animation4.value),
                  ),
                ),
                Column(
                  children: [
                    Expanded(
                      flex: 4,
                      child: Padding(
                          padding: EdgeInsets.only(top: height * .1),
                          child: animatedText(width / 11, 'Lancelot',
                              Colors.white.withOpacity(.8), 0, 1)),
                    ),
                    const Spacer(flex: 2),
                    Expanded(
                      flex: 10,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          textFieldAuth(
                            controller: nameController,
                            hint: 'Name...',
                            icon: Icons.account_circle_sharp,
                            isPassword: false,
                            length: 10,
                            onSubmitted: (String onTap) => sigUpTap(context),
                          ),
                          textFieldAuth(
                            controller: emailController,
                            hint: 'Email...',
                            icon: Icons.email_outlined,
                            isPassword: false,
                            length: 35,
                            onSubmitted: (String onTap) => sigUpTap(context),
                          ),
                          textFieldAuth(
                            controller: passwordController,
                            hint: 'Password...',
                            icon: Icons.lock_open_outlined,
                            isPassword: true,
                            length: 20,
                            onSubmitted: (String onTap) => sigUpTap(context),
                          ),
                          Container(
                              padding: EdgeInsets.only(
                                  right: height / 22, top: 4, bottom: 4),
                              alignment: Alignment.centerRight,
                              child: animatedText(
                                  height / 66,
                                  'Введите реальную почту',
                                  Colors.white,
                                  500,
                                  1)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              signStart
                                  ? buttonAuthAnimation('Зарегистрироваться',
                                      width / 1.4, 350, () => sigUpTap(context))
                                  : buttonAuth(
                                      'Зарегистрироваться',
                                      width / 1.4,
                                      500,
                                      () => sigUpTap(context)),
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
                          buttonAuth(
                              'Войти в аккаунт',
                              width / 1.4,
                              0,
                              () => Navigator.push(
                                    context,
                                    FadeRouteAnimation(const SignInScreen()),
                                  )),
                          SizedBox(height: height * .05),
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
  Widget buildViewportChrome(BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}
