import 'dart:ui';

import 'package:Lancelot/screens/settings/edit_profile_screen.dart';
import 'package:Lancelot/screens/settings/settiongs_profile_screen.dart';
import 'package:Lancelot/screens/view_likes_screen.dart';
import 'package:animator/animator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delayed_display/delayed_display.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:like_button/like_button.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

import '../config/const.dart';
import '../config/firestore_operations.dart';
import '../model/interests_model.dart';
import '../model/user_model.dart';
import '../widget/animation_widget.dart';
import '../widget/button_widget.dart';
import '../widget/component_widget.dart';
import '../widget/photo_widget.dart';

class ProfileScreen extends StatefulWidget {
  final UserModel userModelCurrent, userModelPartner;
  final bool isBack;
  final String idUser;

  ProfileScreen(
      {super.key,
      required this.userModelPartner,
      required this.isBack,
      required this.idUser,
      required this.userModelCurrent});

  @override
  State<ProfileScreen> createState() =>
      _ProfileScreen(userModelPartner, isBack, idUser, userModelCurrent);
}

class _ProfileScreen extends State<ProfileScreen> {
  bool isLoading = false, isLike = false, isBack, isProprietor = false;
  UserModel userModelPartner, userModelCurrent;
  final String idUser;
  List<InterestsModel> listStory = [];
  final FirebaseStorage storage = FirebaseStorage.instance;

  _ProfileScreen(
      this.userModelPartner, this.isBack, this.idUser, this.userModelCurrent);

  Future sortingList() async {
    await readInterestsFirebase().then((map) {
      for (var elementMain in userModelPartner.userInterests) {
        map.forEach((key, value) {
          if (elementMain == key) {
            if (userModelPartner.userInterests.length != listStory.length) {
              listStory.add(InterestsModel(name: key, id: '', uri: value));
            }
          }
        });
      }
    });
  }

  Future readFirebase() async {
    try {
      if (userModelPartner.uid == '' && idUser != '') {
        await readUserFirebase(idUser).then((user) {
          setState(() {
            userModelPartner = UserModel(
                name: user.name,
                uid: user.uid,
                ageTime: user.ageTime,
                userPol: user.userPol,
                searchPol: user.searchPol,
                searchRangeStart: user.searchRangeStart,
                userInterests: user.userInterests,
                userImagePath: user.userImagePath,
                userImageUrl: user.userImageUrl,
                searchRangeEnd: user.searchRangeEnd,
                myCity: user.myCity,
                imageBackground: user.imageBackground,
                ageInt: user.ageInt,
                state: user.state,
                token: user.token,
                notification: user.notification,
                description: user.description);
            isLoading = true;
          });
        });
        await sortingList();
      } else {
        await sortingList();
      }

      putLike(userModelCurrent, userModelPartner, false).then((value) {
        setState(() {
          if (userModelCurrent.uid == userModelPartner.uid) {
            isProprietor = true;
          } else {
            isProprietor = false;
          }
          isLike = !value;
          isLoading = true;
        });
      });
    } catch (error) {}
  }

  @override
  void initState() {
    readFirebase();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    double height = MediaQuery.of(context).size.height;

    if (isLoading) {
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
                    duration: const Duration(milliseconds: 3000),
                    child: Stack(
                      alignment:
                          isProprietor ? Alignment.topRight : Alignment.topLeft,
                      children: [
                        Positioned(
                          child: SizedBox(
                            height: size.height * .28,
                            width: size.width,
                            child: CachedNetworkImage(
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.error),
                              fit: BoxFit.cover,
                              imageUrl: userModelPartner.imageBackground,
                            ),
                          ),
                        ),
                        if (isBack)
                          Positioned(
                            height: size.height / 10,
                            child: Container(
                              alignment: Alignment.bottomLeft,
                              padding: EdgeInsets.only(
                                left: size.height / 50,
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
                                    icon: Icon(
                                        Icons.arrow_back_ios_new_rounded,
                                        size: size.height / 44),
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    if (isProprietor)
                      Positioned(
                            height: size.height / 9,
                            child: Container(
                              alignment: Alignment.bottomRight,
                              padding: EdgeInsets.only(
                                right: size.height / 54,
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    border: Border.all(
                                      color: Colors.white54,
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
                                      Navigator.push(
                                          context,
                                          FadeRouteAnimation(
                                              ProfileSettingScreen(
                                            userModel: userModelPartner,
                                            listInterests: listStory,
                                          )));
                                    },
                                    icon: Icon(Icons.settings, size: size.height / 36),
                                    color: Colors.white,
                                  ),
                                ),
                              ),
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
                                    photoProfile(
                                        uri: userModelPartner.userImageUrl[0]),
                                    ZoomTapAnimation(
                                      child: Container(
                                        margin:
                                            EdgeInsets.only(right: height / 38),
                                        child: LikeButton(
                                          animationDuration: const Duration(
                                              milliseconds: 1300),
                                          isLiked: isLike,
                                          size: size.height * 0.05,
                                          circleColor: const CircleColor(
                                              start: Colors.pinkAccent,
                                              end: Colors.red),
                                          bubblesColor: const BubblesColor(
                                            dotPrimaryColor: Colors.pink,
                                            dotSecondaryColor:
                                                Colors.deepPurpleAccent,
                                            dotLastColor: Colors.yellowAccent,
                                            dotThirdColor:
                                                Colors.deepPurpleAccent,
                                          ),
                                          likeBuilder: (bool isLiked) {
                                            return SizedBox(
                                              height: size.height * 0.07,
                                              width: size.height * 0.07,
                                              child: Animator<double>(
                                                duration: const Duration(
                                                    milliseconds: 1600),
                                                cycles: 0,
                                                curve: Curves.elasticIn,
                                                tween: Tween<double>(
                                                    begin: 20.0, end: 25.0),
                                                builder: (context,
                                                        animatorState, child) =>
                                                    Icon(
                                                  isLiked
                                                      ? Icons.favorite_outlined
                                                      : Icons
                                                          .favorite_border_sharp,
                                                  size:
                                                      animatorState.value * 1.6,
                                                  color: isLiked
                                                      ? color_red
                                                      : Colors.white,
                                                ),
                                              ),
                                            );
                                          },
                                          onTap: (isLiked) {
                                            Future.delayed(
                                                isLike
                                                    ? const Duration(
                                                        milliseconds: 0)
                                                    : const Duration(
                                                        milliseconds: 350), () {
                                              setState(() {
                                                isLike = !isLike;
                                              });
                                            });
                                            return putLike(
                                              userModelCurrent,
                                              userModelPartner,
                                              true,
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                            '${userModelPartner.name}, ${userModelPartner.ageInt}',
                                            Colors.white,
                                            700,
                                            1),
                                        const SizedBox(
                                          height: 1,
                                        ),
                                        animatedText(
                                            size.height / 66,
                                            userModelPartner.myCity,
                                            Colors.white.withOpacity(.8),
                                            750,
                                            1),
                                      ],
                                    ),
                                  ),
                                  if (isProprietor)
                                    buttonUniversalAnimationColors(
                                        'Редактировать',
                                        [
                                          Colors.blueAccent,
                                          Colors.purpleAccent
                                        ],
                                        size.height / 21, () {
                                      Navigator.push(
                                          context,
                                          FadeRouteAnimation(EditProfileScreen(
                                            isFirst: false,
                                            userModel: userModelCurrent,
                                          )));
                                    }, 480),
                                  if (!isProprietor)
                                    buttonProfileUser(
                                      userModelCurrent,
                                      userModelPartner,
                                    ),
                                  const SizedBox()
                                ],
                              ),
                              if (userModelPartner.description.toString() != '')
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
                                      userModelPartner.description.toString(),
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
                                margin: EdgeInsets.only(top: size.height / 32),
                                alignment: Alignment.topLeft,
                                decoration: const BoxDecoration(
                                    color: color_black_88,
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(22),
                                        topRight: Radius.circular(22))),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
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
                                                  userModelPartner
                                                      .userImageUrl.length
                                                      .toString(),
                                                  Colors.white.withOpacity(0.9),
                                                  750,
                                                  1),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 2),
                                                child: animatedText(
                                                    height / 72,
                                                    'Фото',
                                                    Colors.white
                                                        .withOpacity(0.7),
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
                                                    userModelCurrent:
                                                        userModelPartner,
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
                                                          .doc(userModelPartner
                                                              .uid)
                                                          .collection('likes')
                                                          .get(const GetOptions(
                                                              source:
                                                                  Source.cache))
                                                          .toString()
                                                          .isEmpty
                                                      ? FirebaseFirestore
                                                          .instance
                                                          .collection('User')
                                                          .doc(userModelPartner
                                                              .uid)
                                                          .collection('likes')
                                                          .get(const GetOptions(
                                                              source:
                                                                  Source.cache))
                                                      : FirebaseFirestore
                                                          .instance
                                                          .collection('User')
                                                          .doc(userModelPartner
                                                              .uid)
                                                          .collection('likes')
                                                          .get(
                                                            const GetOptions(
                                                                source: Source
                                                                    .server),
                                                          ),
                                                  builder:
                                                      (BuildContext context,
                                                          AsyncSnapshot<
                                                                  QuerySnapshot>
                                                              snapshot) {
                                                    if (snapshot.hasData) {
                                                      return SlideFadeTransition(
                                                          animationDuration:
                                                              const Duration(
                                                                  milliseconds:
                                                                      1250),
                                                          child:
                                                              AnimatedSwitcher(
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
                                                              key: ValueKey<
                                                                      int>(
                                                                  snapshot.data!
                                                                      .size),
                                                              text: TextSpan(
                                                                text: snapshot
                                                                    .data!.size
                                                                    .toString(),
                                                                style:
                                                                    GoogleFonts
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
                                                  padding:
                                                      const EdgeInsets.only(
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
                                                  userModelPartner
                                                      .userInterests.length
                                                      .toString(),
                                                  Colors.white.withOpacity(0.9),
                                                  1350,
                                                  1),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 2),
                                                child: animatedText(
                                                    height / 72,
                                                    'Интересы',
                                                    Colors.white
                                                        .withOpacity(0.7),
                                                    1400,
                                                    1),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    slideInterests(listStory),
                                    photoProfileGallery(
                                        userModelPartner.userImageUrl),
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
    return const loadingCustom();
  }
}
