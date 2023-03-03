import 'dart:async';

import 'package:card_loading/card_loading.dart';
import 'package:delayed_display/delayed_display.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colors_border/flutter_colors_border.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:lottie/lottie.dart';

import '../config/const.dart';

class SlideFadeTransition extends StatefulWidget {
  final Widget child;
  final double offset;
  final Curve curve;
  final Direction direction;
  final Duration delayStart;
  final Duration animationDuration;

  const SlideFadeTransition({
    super.key,
    required this.child,
    this.offset = 1.0,
    this.curve = Curves.easeIn,
    this.direction = Direction.vertical,
    this.delayStart = const Duration(seconds: 0),
    this.animationDuration = const Duration(milliseconds: 800),
  });

  @override
  _SlideFadeTransitionState createState() => _SlideFadeTransitionState();
}

enum Direction { vertical, horizontal }

class _SlideFadeTransitionState extends State<SlideFadeTransition>
    with SingleTickerProviderStateMixin {
  late Animation<Offset> _animationSlide;

  late AnimationController _animationController;

  late Animation<double> _animationFade;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );

    //configure the animation controller as per the direction
    if (widget.direction == Direction.vertical) {
      _animationSlide = Tween<Offset>(
              begin: Offset(0, widget.offset), end: const Offset(0, 0))
          .animate(CurvedAnimation(
        curve: widget.curve,
        parent: _animationController,
      ));
    } else {
      _animationSlide = Tween<Offset>(
              begin: Offset(widget.offset, 0), end: const Offset(0, 0))
          .animate(CurvedAnimation(
        curve: widget.curve,
        parent: _animationController,
      ));
    }

    _animationFade =
        Tween<double>(begin: -1.0, end: 1.0).animate(CurvedAnimation(
      curve: widget.curve,
      parent: _animationController,
    ));

    Timer(widget.delayStart, () {
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animationFade,
      child: SlideTransition(
        position: _animationSlide,
        child: widget.child,
      ),
    );
  }
}

class loadingCustom extends StatelessWidget {
  const loadingCustom({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: color_black_88,
      body: Center(
        child: Lottie.asset(
          'images/animation_loader.json',
          width: MediaQuery.of(context).size.width * 0.66,
          height: MediaQuery.of(context).size.height * 0.66,
          alignment: Alignment.center,
          errorBuilder: (context, error, stackTrace) {
            return LoadingAnimationWidget.dotsTriangle(
              size: 48,
              color: Colors.blueAccent,
            );
          },
        ),
      ),
    );
  }
}

class showProgressWrite extends StatelessWidget {
  const showProgressWrite({
    super.key,
    required this.height,
  });

  final double height;

  @override
  Widget build(BuildContext context) {
    return DelayedDisplay(
      delay: const Duration(milliseconds: 440),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LoadingAnimationWidget.horizontalRotatingDots(
            size: height / 40,
            color: Colors.blueAccent,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 5, bottom: 2),
            child: RichText(
              text: TextSpan(
                text: 'печатает...',
                style: GoogleFonts.lato(
                  textStyle: TextStyle(
                      color: Colors.blueAccent,
                      fontSize: height / 70,
                      letterSpacing: .7),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Padding showCheckMessageAnimation(double height, IconData icon, Color white) {
  return Padding(
    padding: EdgeInsets.only(left: height / 100),
    child: Icon(
      icon,
      color: white,
      size: height / 50,
    ),
  );
}

DelayedDisplay animatedText(double size, String text, color, time, int line) {
  return DelayedDisplay(
    fadeIn: true,
    delay: Duration(milliseconds: time),
    child: Text(
      overflow: TextOverflow.ellipsis,
      maxLines: line,
      text,
      style: GoogleFonts.lato(
        textStyle: TextStyle(color: color, fontSize: size, letterSpacing: .6),
      ),
    ),
  );
}

SizedBox showIfNoData(
  double height,
  String imagePath,
  String text,
  AnimationController animationController,
  double share,
) {
  return SizedBox(
    height: height,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Lottie.asset(alignment: Alignment.center,
            errorBuilder: (context, error, stackTrace) {
          return const SizedBox();
        }, onLoaded: (composition) {
          animationController
            ..duration = composition.duration
            ..repeat();
        },
            controller: animationController,
            height: height / 2.2,
            fit: BoxFit.contain,
            imagePath),
        Padding(
          padding: const EdgeInsets.only(top: 40),
          child: animatedText(height / 48, text, Colors.white, 400, 2),
        ),
        SizedBox(
          height: height / 3.5,
        )
      ],
    ),
  );
}

Column showAnimationNoMessage(
    double height, String path, AnimationController animationController) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Lottie.asset(alignment: Alignment.center,
          errorBuilder: (context, error, stackTrace) {
        return const SizedBox();
      }, onLoaded: (composition) {
        animationController
          ..duration = composition.duration
          ..repeat();
      },
          controller: animationController,
          height: height * 0.38,
          width: height * 0.52,
          path),
      SizedBox(
        height: height * 0.04,
      ),
    ],
  );
}

Column showAnimationVerify(
    double height, String path, AnimationController animationController) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Lottie.asset(alignment: Alignment.center,
          errorBuilder: (context, error, stackTrace) {
        return const SizedBox();
      }, onLoaded: (composition) {
        animationController
          ..duration = composition.duration
          ..repeat();
      },
          controller: animationController,
          height: height * 0.34,
          width: height * 0.48,
          path),
    ],
  );
}

Padding showAnimationNoUser(
    double height, double width, AnimationController animationController) {
  return Padding(
    padding: EdgeInsets.only(left: 10, right: 10, top: height / 8),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Lottie.asset(alignment: Alignment.center,
            errorBuilder: (context, error, stackTrace) {
          return const SizedBox();
        }, onLoaded: (composition) {
          animationController
            ..duration = composition.duration
            ..repeat();
        },
            controller: animationController,
            height: height * 0.50,
            'images/animation_empty.json'),
        DelayedDisplay(
          delay: const Duration(milliseconds: 600),
          child: RichText(
            textAlign: TextAlign.center,
            maxLines: 2,
            text: TextSpan(
              text: 'К сожалению никого не найдено попробуйте позже',
              style: GoogleFonts.lato(
                textStyle: TextStyle(
                  color: Colors.white,
                  fontSize: height / 52,
                  letterSpacing: .0,
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

class loadingPhotoAnimation extends StatelessWidget {
  const loadingPhotoAnimation({
    super.key,
    required this.height,
  });

  final double height;

  @override
  Widget build(BuildContext context) {
    return FlutterColorsBorder(
      animationDuration: 1,
      colors: const [
        Colors.black12,
        Colors.white10,
        Colors.white54,
        Colors.white70,
      ],
      size: Size(height, height),
      boardRadius: 12,
      borderWidth: 0.4,
      child: CardLoading(
        cardLoadingTheme: CardLoadingTheme(
            colorTwo: color_black_88, colorOne: Colors.white.withOpacity(0.12)),
        height: height,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
