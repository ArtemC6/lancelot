import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delayed_display/delayed_display.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../config/const.dart';
import '../../config/firestore_operations.dart';
import '../../model/interests_model.dart';
import '../../model/user_model.dart';
import '../../widget/animation_widget.dart';
import '../../widget/button_widget.dart';
import '../../widget/component_widget.dart';
import '../../widget/photo_widget.dart';
import '../view_likes_screen.dart';
import 'edit_image_profile_screen.dart';
import 'edit_profile_screen.dart';

class ProfileSettingScreen extends StatefulWidget {
  final UserModel userModel;
  final List<InterestsModel> listInterests;

  ProfileSettingScreen(
      {Key? key, required this.userModel, required this.listInterests})
      : super(key: key);

  @override
  State<ProfileSettingScreen> createState() =>
      _ProfileSettingScreen(userModel, listInterests);
}

class _ProfileSettingScreen extends State<ProfileSettingScreen> {
  bool isLike = false;
  late UserModel userModel;
  final List<InterestsModel> listInterests;

  _ProfileSettingScreen(this.userModel, this.listInterests);

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: color_black_88,
      body: Theme(
        data: ThemeData.light(),
        child: SingleChildScrollView(
          child: AnimationLimiter(
            child: AnimationConfiguration.staggeredList(
              position: 1,
              delay: const Duration(milliseconds: 250),
              child: SlideAnimation(
                duration: const Duration(milliseconds: 2200),
                horizontalOffset: size.width / 2,
                curve: Curves.ease,
                child: FadeInAnimation(
                  curve: Curves.easeOut,
                  duration: const Duration(milliseconds: 2500),
                  child: Stack(
                    children: [
                      Positioned(
                        child: SizedBox(
                          height: size.height * .28,
                          width: size.width,
                          child: CachedNetworkImage(
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                            fit: BoxFit.cover,
                            imageUrl: userModel.imageBackground,
                          ),
                        ),
                      ),
                      Positioned(
                        height: size.height / 10,
                        child: Container(
                          alignment: Alignment.bottomLeft,
                          padding: EdgeInsets.only(
                            left: size.height / 62,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: Colors.white38,
                                  width: 1,
                                ),
                              ),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(
                                  sigmaX: 8,
                                  sigmaY: 8,
                                ),
                                child: SizedBox(
                                  height: size.height / 20,
                                  width: size.height / 20,
                                  child: IconButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    icon: Icon(Icons.arrow_back_ios_new_rounded,
                                        size: size.height / 44),
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        child: Container(
                          padding: EdgeInsets.only(
                              top: size.height / 18, right: size.height / 38),
                          alignment: Alignment.centerRight,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(color: Colors.white12)),
                            child: customIconButton(
                              height: size.height / 35,
                              width: size.height / 35,
                              path: 'images/ic_image.png',
                              padding: 2,
                              onTap: () {
                                Navigator.pushReplacement(
                                  context,
                                  FadeRouteAnimation(
                                    EditImageProfileScreen(
                                      bacImage: userModel.imageBackground,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: size.height * .20),
                        child: Column(
                          children: [
                            Container(
                              margin: const EdgeInsets.only(left: 20),
                              alignment: Alignment.centerLeft,
                              color: Colors.transparent,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Stack(
                                      alignment: Alignment.bottomRight,
                                      children: [
                                        photoProfile(
                                            uri: userModel.userImageUrl[0]),
                                        customIconButton(
                                          path: 'images/ic_edit.png',
                                          width: size.height / 30,
                                          height: size.height / 30,
                                          onTap: () async {
                                            updateFirstImage(
                                                context, userModel, false);
                                          },
                                          padding: 0,
                                        ),
                                      ]),
                                ],
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: EdgeInsets.only(
                                      top: size.height / 44, left: 14),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      animatedText(
                                          size.height / 52,
                                          '${userModel.name}, ${userModel.ageInt}',
                                          Colors.white,
                                          700,
                                          1),
                                      const SizedBox(
                                        height: 1,
                                      ),
                                      animatedText(
                                          size.height / 66,
                                          userModel.myCity,
                                          Colors.white.withOpacity(.8),
                                          750,
                                          1),
                                    ],
                                  ),
                                ),
                                buttonUniversalAnimationColors(
                                  'Редактировать',
                                  [Colors.blueAccent, Colors.purpleAccent],
                                  size.height / 21,
                                  () {
                                    Navigator.push(
                                        context,
                                        FadeRouteAnimation(EditProfileScreen(
                                          isFirst: false,
                                          userModel: userModel,
                                        )));
                                  },
                                  480,
                                ),
                                const SizedBox()
                              ],
                            ),
                            if (userModel.description.toString() != '')
                              Container(
                                alignment: Alignment.centerLeft,
                                padding: EdgeInsets.only(
                                    left: 14,
                                    top: size.height / 48,
                                    right: size.width / 24),
                                child: DelayedDisplay(
                                  fadeIn: true,
                                  delay: const Duration(milliseconds: 600),
                                  child: Text(
                                    textAlign: TextAlign.start,
                                    maxLines: 2,
                                    userModel.description.toString(),
                                    style: GoogleFonts.lato(
                                      textStyle: TextStyle(
                                          color: Colors.white70,
                                          fontSize: size.height / 68,
                                          letterSpacing: .15),
                                    ),
                                  ),
                                ),
                              ),
                            Container(
                              margin: const EdgeInsets.only(top: 20),
                              alignment: Alignment.topLeft,
                              decoration: const BoxDecoration(
                                color: color_black_88,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(22),
                                  topRight: Radius.circular(22),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: height / 40),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            animatedText(
                                                height / 52,
                                                userModel.userImageUrl.length
                                                    .toString(),
                                                Colors.white.withOpacity(0.9),
                                                750,
                                                1),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.only(top: 2),
                                              child: animatedText(
                                                  height / 72,
                                                  'Фото',
                                                  Colors.white.withOpacity(0.7),
                                                  800,
                                                  1),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 24,
                                          child: VerticalDivider(
                                            endIndent: 4,
                                            color:
                                                Colors.white.withOpacity(0.7),
                                            thickness: 1,
                                          ),
                                        ),
                                        InkWell(
                                          splashColor: Colors.transparent,
                                          highlightColor: Colors.transparent,
                                          onTap: () {
                                            Navigator.push(
                                                context,
                                                FadeRouteAnimation(
                                                    ViewLikesScreen(
                                                  userModelCurrent: userModel,
                                                )));
                                          },
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              FutureBuilder(
                                                future: FirebaseFirestore
                                                        .instance
                                                        .collection('User')
                                                        .doc(userModel.uid)
                                                        .collection('likes')
                                                        .get(const GetOptions(
                                                            source:
                                                                Source.cache))
                                                        .toString()
                                                        .isEmpty
                                                    ? FirebaseFirestore.instance
                                                        .collection('User')
                                                        .doc(userModel.uid)
                                                        .collection('likes')
                                                        .get(const GetOptions(
                                                            source:
                                                                Source.cache))
                                                    : FirebaseFirestore.instance
                                                        .collection('User')
                                                        .doc(userModel.uid)
                                                        .collection('likes')
                                                        .get(
                                                          const GetOptions(
                                                              source: Source
                                                                  .server),
                                                        ),
                                                builder: (BuildContext context,
                                                    AsyncSnapshot<QuerySnapshot>
                                                        snapshot) {
                                                  if (snapshot.hasData) {
                                                    return SlideFadeTransition(
                                                        animationDuration:
                                                            const Duration(
                                                                milliseconds:
                                                                    1250),
                                                        child: AnimatedSwitcher(
                                                          duration:
                                                              const Duration(
                                                                  milliseconds:
                                                                      500),
                                                          transitionBuilder:
                                                              ((child,
                                                                  animation) {
                                                            return ScaleTransition(
                                                                scale:
                                                                    animation,
                                                                child: child);
                                                          }),
                                                          child: RichText(
                                                            key: ValueKey<int>(
                                                                snapshot.data!
                                                                    .size),
                                                            text: TextSpan(
                                                              text: snapshot
                                                                  .data!.size
                                                                  .toString(),
                                                              style: GoogleFonts
                                                                  .lato(
                                                                textStyle: TextStyle(
                                                                    color: Colors
                                                                        .white
                                                                        .withOpacity(
                                                                            0.9),
                                                                    fontSize:
                                                                        height /
                                                                            52,
                                                                    letterSpacing:
                                                                        .5),
                                                              ),
                                                            ),
                                                          ),
                                                        ));
                                                  }
                                                  return const SizedBox();
                                                },
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 2),
                                                child: animatedText(
                                                    height / 72,
                                                    'Лайки',
                                                    Colors.white
                                                        .withOpacity(0.7),
                                                    1200,
                                                    1),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          height: 24,
                                          child: VerticalDivider(
                                            endIndent: 4,
                                            color:
                                                Colors.white.withOpacity(0.7),
                                            thickness: 1,
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            animatedText(
                                                height / 52,
                                                userModel.userInterests.length
                                                    .toString(),
                                                Colors.white.withOpacity(0.9),
                                                1350,
                                                1),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.only(top: 2),
                                              child: animatedText(
                                                  height / 72,
                                                  'Интересы',
                                                  Colors.white.withOpacity(0.7),
                                                  1400,
                                                  1),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  slideInterestsSettings(
                                      listInterests, userModel),
                                  photoProfileSettingsGallery(userModel),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
