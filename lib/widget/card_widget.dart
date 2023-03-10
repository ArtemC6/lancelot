import 'dart:ui';

import 'package:animate_gradient/animate_gradient.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:delayed_display/delayed_display.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colors_border/flutter_colors_border.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

import '../config/const.dart';
import '../model/user_model.dart';
import '../screens/profile_screen.dart';
import 'animation_widget.dart';
import 'button_widget.dart';

class photoUser extends StatelessWidget {
  final String uri, state;
  final double height, width, padding;

  const photoUser(
      {Key? key,
      required this.uri,
      required this.height,
      required this.width,
      required this.padding,
      required this.state})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final heightScreen = MediaQuery.of(context).size.height;
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        SizedBox(
          height: height,
          width: width,
          child: Card(
            shadowColor: Colors.white30,
            color: color_black_88,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100),
              side: const BorderSide(
                width: 0.5,
                color: Colors.white24,
              ),
            ),
            elevation: 8,
            child: Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(100)),
              ),
              child: CachedNetworkImage(
                errorWidget: (context, url, error) => const Icon(Icons.error),
                progressIndicatorBuilder: (context, url, progress) => Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: Shimmer(
                      child: SizedBox(
                        height: height,
                        width: width,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 0.8,
                          value: progress.progress,
                        ),
                      ),
                    ),
                  ),
                ),
                imageUrl: uri,
                imageBuilder: (context, imageProvider) => Container(
                  height: height,
                  width: width,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: const BorderRadius.all(Radius.circular(100)),
                    image: DecorationImage(
                      image: imageProvider,
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        if (state == 'online')
          DelayedDisplay(
            delay: const Duration(milliseconds: 500),
            child: customIconButton(
                padding: padding,
                width: heightScreen / 28,
                height: heightScreen / 28,
                path: 'images/ic_green_dot.png',
                onTap: () {}),
          ),
      ],
    );
  }
}

class itemUserLike extends StatelessWidget {
  final UserModel userModelCurrent, userModelLike;
  final int indexAnimation;

  const itemUserLike(
      this.userModelLike, this.userModelCurrent, this.indexAnimation,
      {super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return ZoomTapAnimation(
      end: 0.97,
      onTap: () {
        Navigator.push(
          context,
          FadeRouteAnimation(
            ProfileScreen(
              userModelPartner: userModelLike,
              isBack: true,
              idUser: '',
              userModelCurrent: userModelCurrent,
            ),
          ),
        );
      },
      child: Container(
        height: height / 7.3,
        padding: EdgeInsets.only(
            left: width / 30, top: 0, right: width / 30, bottom: width / 30),
        child: Card(
          color: color_black_88,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: const BorderSide(
                width: 0.1,
                color: Colors.white10,
              )),
          shadowColor: Colors.white12,
          elevation: 14,
          child: Container(
            padding:
                const EdgeInsets.only(left: 8, top: 8, bottom: 8, right: 14),
            child: Row(
              children: [
                SizedBox(
                  width: height / 12,
                  height: height / 12,
                  child: photoUser(
                    uri: userModelLike.userImageUrl[0],
                    width: height / 12,
                    height: height / 12,
                    state: userModelLike.state,
                    padding: 0,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      DelayedDisplay(
                        delay: Duration(
                            milliseconds: indexAnimation * 300 < 2700
                                ? indexAnimation * 300
                                : 300),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                              text: TextSpan(
                                text:
                                    '${userModelLike.name}, ${userModelLike.ageInt}',
                                style: GoogleFonts.lato(
                                  textStyle: TextStyle(
                                      color: Colors.white,
                                      fontSize: height / 56,
                                      letterSpacing: .5),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 3,
                            ),
                            RichText(
                              maxLines: 1,
                              text: TextSpan(
                                text: userModelLike.myCity,
                                style: GoogleFonts.lato(
                                  textStyle: TextStyle(
                                      color: Colors.white.withOpacity(.6),
                                      fontSize: height / 67,
                                      letterSpacing: .5),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      customIconButton(
                        onTap: () {},
                        path: 'images/ic_send.png',
                        height: height / 28,
                        width: height / 28,
                        padding: 4,
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class cardLoadingHome extends StatelessWidget {
  const cardLoadingHome({
    super.key,
    required this.radius,
  });

  final double radius;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Shimmer(
        color: Colors.white10,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white.withOpacity(0.12), width: 1),
            borderRadius: BorderRadius.circular(radius),
            color: color_black_88,
          ),
          height: height,
          width: height,
        ),
      ),
    );
  }
}

class cardPartner extends StatelessWidget {
  const cardPartner({
    super.key,
    required this.userModelPartner,
    required this.onTap,
  });

  final UserModel userModelPartner;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return ZoomTapAnimation(
      onTap: onTap,
      end: 0.995,
      child: Card(
        color: color_black_88,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        elevation: 2,
        child: FlutterColorsBorder(
          animationDuration: 7,
          colors: const [
            Colors.white10,
            Colors.white70,
          ],
          size: Size(height, height),
          boardRadius: 22,
          borderWidth: 1,
          child: Stack(
            fit: StackFit.expand,
            alignment: Alignment.bottomLeft,
            children: [
              CachedNetworkImage(
                  fadeOutDuration: const Duration(milliseconds: 1500),
                  fadeInDuration: const Duration(milliseconds: 700),
                  imageBuilder: (context, imageProvider) => Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.cover,
                            alignment: Alignment.topCenter,
                          ),
                        ),
                      ),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                  progressIndicatorBuilder: (context, url, progress) =>
                      const loadingPhotoAnimation(),
                  imageUrl: userModelPartner.userImageUrl[0],
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                  width: width),
              Positioned(
                height: height / 12.5,
                child: Container(
                  alignment: Alignment.bottomLeft,
                  padding: EdgeInsets.only(
                    left: height / 72,
                    bottom: height / 82,
                  ),
                  child: FlutterColorsBorder(
                    animationDuration: 5,
                    colors: listColorsAnimation,
                    size: Size(height / 9.0 + userModelPartner.name.length * 4,
                        height / 12),
                    boardRadius: 14,
                    borderWidth: 0.8,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.white60,
                            width: 1,
                          ),
                        ),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(
                            sigmaX: 12,
                            sigmaY: 12,
                          ),
                          child: AnimateGradient(
                            primaryBegin: Alignment.topLeft,
                            primaryEnd: Alignment.bottomLeft,
                            secondaryBegin: Alignment.bottomLeft,
                            secondaryEnd: Alignment.topRight,
                            primaryColors: [
                              Colors.white.withOpacity(0.01),
                              Colors.black12
                            ],
                            secondaryColors: [
                              Colors.white.withOpacity(0.01),
                              Colors.black26
                            ],
                            child: Container(
                              alignment: Alignment.bottomLeft,
                              padding: EdgeInsets.all(
                                height / 120,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  animatedText(
                                      height / 54,
                                      '${userModelPartner.name}, '
                                      '${userModelPartner.ageInt}',
                                      Colors.white,
                                      600,
                                      1),
                                  Row(
                                    children: [
                                      animatedText(
                                          height / 66,
                                          userModelPartner.myCity,
                                          Colors.white,
                                          550,
                                          1),
                                      if (userModelPartner.state == 'online')
                                        Padding(
                                          padding: EdgeInsets.only(
                                            left: height / 160,
                                          ),
                                          child: Container(
                                            height: height / 86,
                                            width: height / 86,
                                            decoration: const BoxDecoration(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(100)),
                                                color: Color(0xff00DC35)),
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
