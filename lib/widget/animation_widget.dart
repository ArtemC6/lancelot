import 'package:delayed_display/delayed_display.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colors_border/flutter_colors_border.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:lottie/lottie.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

import '../config/const.dart';

class loadingCustom extends StatelessWidget {
  const loadingCustom({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: color_black_88,
      body: Center(
        child: Lottie.asset(
          'images/animation_loader.json',
          width: width * 0.66,
          height: height * 0.66,
          alignment: Alignment.center,
        ),
      ),
    );
  }
}

class showProgressWrite extends StatelessWidget {
  const showProgressWrite({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
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
            child: Text(
              'печатает...',
              style: GoogleFonts.lato(
                textStyle: TextStyle(
                    color: Colors.blueAccent,
                    fontSize: height / 70,
                    letterSpacing: .7),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class showCheckMessageAnimation extends StatelessWidget {
  const showCheckMessageAnimation(this.height, this.icon, this.white,
      {super.key});

  final double height;
  final IconData icon;
  final Color white;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: height / 100),
      child: Icon(
        icon,
        color: white,
        size: height / 50,
      ),
    );
  }
}

class animatedText extends StatelessWidget {
  const animatedText(this.size, this.text, this.color, this.time, this.line,
      {super.key});

  final double size;
  final String text;
  final Color color;
  final int time, line;

  @override
  Widget build(BuildContext context) {
    return DelayedDisplay(
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
}

class showIfNoData extends StatelessWidget {
  const showIfNoData({
    super.key,
    required this.imagePath,
    required this.text,
    required this.animationController,
  });

  final String imagePath, text;
  final AnimationController animationController;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return SizedBox(
      height: height,
      child: Column(
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
}

class showAnimationVerify extends StatelessWidget {
  const showAnimationVerify({
    super.key,
    required this.path,
    required this.animationController,
  });

  final String path;
  final AnimationController animationController;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
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
            height: height * 0.38,
            width: height * 0.50,
            path),
      ],
    );
  }
}

class showAnimationNoUser extends StatelessWidget {
  const showAnimationNoUser({
    super.key,
    required this.animationController,
  });

  final AnimationController animationController;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Padding(
      padding: EdgeInsets.only(left: 10, right: 10, top: height / 10),
      child: Column(
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
              height: height * 0.50,
              'images/animation_empty.json'),
          animatedText(height / 48, 'К сожалению никого не найдено',
              Colors.white, 400, 2),
        ],
      ),
    );
  }
}

class loadingPhotoAnimation extends StatelessWidget {
  const loadingPhotoAnimation({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: FlutterColorsBorder(
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
        child: Shimmer(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: color_black_88,
            ),
          ),
        ),
      ),
    );
  }
}
