import 'dart:ui';

import 'package:animate_gradient/animate_gradient.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:card_loading/card_loading.dart';
import 'package:delayed_display/delayed_display.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colors_border/flutter_colors_border.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

import '../config/const.dart';
import '../model/user_model.dart';
import '../screens/profile_screen.dart';
import 'animation_widget.dart';
import 'button_widget.dart';

class photoUser extends StatelessWidget {
  String uri, state;
  double height, width, padding;

  photoUser(
      {Key? key,
      required this.uri,
      required this.height,
      required this.width,
      required this.padding,
      required this.state})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    double heightScreen = MediaQuery.of(context).size.height;
    return SizedBox(
      child: Stack(
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
                  )),
              elevation: 8,
              child: Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(50)),
                ),
                child: CachedNetworkImage(
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                  progressIndicatorBuilder: (context, url, progress) => Center(
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
                  imageUrl: uri,
                  imageBuilder: (context, imageProvider) => Container(
                    height: height,
                    width: width,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: const BorderRadius.all(Radius.circular(50)),
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
      ),
    );
  }
}

class itemUserLike extends StatelessWidget {
  final UserModel userModelCurrent, userModelLike;
  final int indexAnimation;

  itemUserLike(this.userModelLike, this.userModelCurrent, this.indexAnimation,
      {super.key});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return ZoomTapAnimation(
      child: Container(
        height: height / 7.3,
        width: width,
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
            child: InkWell(
              highlightColor: Colors.transparent,
              splashColor: Colors.transparent,
              onTap: () {
                Navigator.push(
                    context,
                    FadeRouteAnimation(ProfileScreen(
                      userModelPartner: userModelLike,
                      isBack: true,
                      idUser: '',
                      userModelCurrent: userModelCurrent,
                    )));
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
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
                  // SizedBox(
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
                          onTap: () {
                            Navigator.push(
                                context,
                                FadeRouteAnimation(ProfileScreen(
                                  userModelPartner: userModelLike,
                                  isBack: true,
                                  idUser: '',
                                  userModelCurrent: userModelCurrent,
                                )));
                          },
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
      ),
    );
  }
}

SizedBox cardLoadingWidget(Size size, double heightCard, double heightAvatar) {
  return SizedBox(
    height: size.height,
    child: ListView.builder(
      itemCount: 10,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (BuildContext context, int index) {
        return Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(alignment: Alignment.centerLeft, children: [
                CardLoading(
                  cardLoadingTheme: CardLoadingTheme(
                      colorTwo: color_black_88,
                      colorOne: Colors.white.withOpacity(0.10)),
                  height: size.height * heightCard,
                  borderRadius: const BorderRadius.all(Radius.circular(15)),
                  margin: const EdgeInsets.only(bottom: 10),
                ),
                Positioned(
                  left: 22,
                  child: CardLoading(
                    cardLoadingTheme: CardLoadingTheme(
                        colorTwo: color_black_88,
                        colorOne: Colors.white.withOpacity(0.14)),
                    height: size.height * heightAvatar,
                    width: size.height * heightAvatar,
                    borderRadius: const BorderRadius.all(Radius.circular(50)),
                    margin: const EdgeInsets.only(bottom: 10),
                  ),
                ),
              ]),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: CardLoading(
                      cardLoadingTheme: CardLoadingTheme(
                          colorTwo: color_black_88,
                          colorOne: Colors.white.withOpacity(0.10)),
                      height: 30,
                      width: 200,
                      borderRadius: const BorderRadius.all(Radius.circular(15)),
                      margin: const EdgeInsets.only(bottom: 10),
                    ),
                  ),
                  const Expanded(child: SizedBox()),
                  Expanded(
                    flex: 1,
                    child: CardLoading(
                      cardLoadingTheme: CardLoadingTheme(
                          colorTwo: color_black_88,
                          colorOne: Colors.white.withOpacity(0.10)),
                      height: 30,
                      width: 200,
                      borderRadius: const BorderRadius.all(Radius.circular(15)),
                      margin: const EdgeInsets.only(bottom: 10),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    ),
  );
}

Widget cardLoading(Size size, double radius) {
  return CardLoading(
    cardLoadingTheme: CardLoadingTheme(
        colorTwo: color_black_88, colorOne: Colors.white.withOpacity(0.12)),
    height: size.height,
    width: size.width,
    borderRadius: BorderRadius.circular(radius),
  );
}

Widget cardPartner(int index, List<UserModel> userModelPartner, Size size,
    BuildContext context) {
  return ZoomTapAnimation(
    enableLongTapRepeatEvent: false,
    longTapRepeatDuration: const Duration(milliseconds: 200),
    begin: 1.0,
    end: 0.995,
    beginDuration: const Duration(milliseconds: 20),
    endDuration: const Duration(milliseconds: 200),
    beginCurve: Curves.decelerate,
    endCurve: Curves.fastOutSlowIn,
    child: Card(
      shadowColor: Colors.white30,
      color: color_black_88,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
      ),
      elevation: 10,
      child: FlutterColorsBorder(
        animationDuration: 7,
        colors: const [
          Colors.white10,
          Colors.white70,
        ],
        size: Size(size.height, size.height),
        boardRadius: 22,
        borderWidth: 1,
        child: Stack(
          fit: StackFit.expand,
          alignment: Alignment.bottomLeft,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: CachedNetworkImage(
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                  useOldImageOnUrlChange: false,
                  progressIndicatorBuilder: (context, url, progress) =>
                      loadingPhotoAnimation(size.height),
                  imageUrl: userModelPartner[index].userImageUrl[0],
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                  width: MediaQuery.of(context).size.width),
            ),
            Positioned(
              height: size.height / 12.5,
              child: Container(
                alignment: Alignment.bottomLeft,
                padding: EdgeInsets.only(
                  left: size.height / 72,
                  bottom: size.height / 82,
                ),
                child: FlutterColorsBorder(
                  animationDuration: 5,
                  colors: listColorsAnimation,
                  size: Size(
                      size.height / 9.0 +
                          userModelPartner[index].name.length * 4,
                      size.height / 12),
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
                              size.height / 120,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                animatedText(
                                    size.height / 54,
                                    '${userModelPartner[index].name}, '
                                    '${userModelPartner[index].ageInt}',
                                    Colors.white,
                                    600,
                                    1),
                                Row(
                                  children: [
                                    animatedText(
                                        size.height / 66,
                                        userModelPartner[index].myCity,
                                        Colors.white,
                                        550,
                                        1),
                                    if (userModelPartner[index].state ==
                                        'online')
                                      SizedBox(
                                        height: size.height / 41,
                                        width: size.height / 41,
                                        child: Image.asset(
                                          'images/ic_green_dot.png',
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
