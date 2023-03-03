import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delayed_display/delayed_display.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

import '../../config/const.dart';
import '../../model/interests_model.dart';
import '../../model/user_model.dart';
import '../config/utils.dart';
import '../getx/chat_data_controller.dart';
import '../screens/profile_screen.dart';
import '../screens/settings/edit_profile_screen.dart';
import 'animation_widget.dart';
import 'button_widget.dart';

class slideInterests extends StatelessWidget {
  List<InterestsModel> listStory = [];

  slideInterests(this.listStory, {super.key});

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Column(
      children: [
        Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.all(20),
          child: animatedText(
              height / 62, 'Интересы', Colors.white.withOpacity(0.8), 750, 1),
        ),
        SizedBox(
          height: height / 8,
          child: AnimationLimiter(
            child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(right: 20),
                scrollDirection: Axis.horizontal,
                itemCount: 8,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  int animation = index + 1;
                  return AnimationConfiguration.staggeredList(
                    position: index,
                    delay: const Duration(milliseconds: 400),
                    child: SlideAnimation(
                      duration: const Duration(milliseconds: 1500),
                      horizontalOffset: 160,
                      curve: Curves.ease,
                      child: FadeInAnimation(
                        curve: Curves.easeOut,
                        duration: const Duration(milliseconds: 2000),
                        child: InkWell(
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: () {},
                          child: Container(
                            margin: const EdgeInsets.only(left: 22, right: 4),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                if (listStory.length > index)
                                  Card(
                                    shadowColor: Colors.white30,
                                    color: color_black_88,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(100),
                                        side: const BorderSide(
                                          width: 0.5,
                                          color: Colors.white30,
                                        )),
                                    elevation: 4,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(100),
                                      child: CachedNetworkImage(
                                        errorWidget: (context, url, error) =>
                                            const Icon(Icons.error),
                                        imageBuilder:
                                            (context, imageProvider) =>
                                                Container(
                                          height: height / 12,
                                          width: height / 12,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(100)),
                                            image: DecorationImage(
                                              image: imageProvider,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        progressIndicatorBuilder:
                                            (context, url, progress) => Center(
                                          child: SizedBox(
                                            height: height / 12,
                                            width: height / 12,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 1,
                                              value: progress.progress,
                                            ),
                                          ),
                                        ),
                                        imageUrl: listStory[index].uri,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                if (listStory.length > index)
                                  Padding(
                                    padding: EdgeInsets.only(
                                        left: 0, right: 4, top: height / 160),
                                    child: animatedText(
                                        height / 76,
                                        listStory[index].name,
                                        Colors.white.withOpacity(0.8),
                                        animation * 600,
                                        1),
                                  )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
          ),
        ),
      ],
    );
  }
}

class slideInterestsSettings extends StatelessWidget {
  List<InterestsModel> listStory = [];

  late UserModel userModel;

  slideInterestsSettings(this.listStory, this.userModel, {super.key});

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;

    return Column(
      children: [
        Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.all(20),
          child: animatedText(
              height / 62, 'Интересы', Colors.white.withOpacity(0.8), 750, 1),
        ),
        SizedBox(
          height: height / 8.0,
          child: AnimationLimiter(
            child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(right: 20),
                scrollDirection: Axis.horizontal,
                itemCount: 6,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  int animation = index + 1;
                  return AnimationConfiguration.staggeredList(
                    position: index,
                    delay: const Duration(milliseconds: 400),
                    child: SlideAnimation(
                      duration: const Duration(milliseconds: 1500),
                      horizontalOffset: 160,
                      curve: Curves.ease,
                      child: FadeInAnimation(
                        curve: Curves.easeOut,
                        duration: const Duration(milliseconds: 2000),
                        child: InkWell(
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: () {},
                          child: Container(
                            margin: const EdgeInsets.only(
                              left: 18,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Card(
                                  shadowColor: Colors.white30,
                                  color: color_black_88,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(100),
                                      side: const BorderSide(
                                        width: 0.8,
                                        color: Colors.white30,
                                      )),
                                  elevation: 4,
                                  child: Stack(
                                    alignment: Alignment.bottomRight,
                                    children: [
                                      if (listStory.length > index)
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(100),
                                          child: CachedNetworkImage(
                                            errorWidget:
                                                (context, url, error) =>
                                                    const Icon(Icons.error),
                                            imageBuilder:
                                                (context, imageProvider) =>
                                                    Container(
                                              height: height / 12,
                                              width: height / 12,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    const BorderRadius.all(
                                                        Radius.circular(100)),
                                                image: DecorationImage(
                                                  image: imageProvider,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                            progressIndicatorBuilder:
                                                (context, url, progress) =>
                                                    Center(
                                              child: SizedBox(
                                                height: height / 12,
                                                width: height / 12,
                                                child:
                                                    CircularProgressIndicator(
                                                  color: Colors.white,
                                                  strokeWidth: 1,
                                                  value: progress.progress,
                                                ),
                                              ),
                                            ),
                                            imageUrl: listStory[index].uri,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      if (0 == index)
                                        InkWell(
                                          splashColor: Colors.transparent,
                                          highlightColor: Colors.transparent,
                                          onTap: () {
                                            Navigator.push(
                                                context,
                                                FadeRouteAnimation(
                                                    EditProfileScreen(
                                                  isFirst: false,
                                                  userModel: userModel,
                                                )));
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.all(2),
                                            child: Image.asset(
                                              'images/ic_edit.png',
                                              height: height / 39,
                                              width: height / 39,
                                            ),
                                          ),
                                        ),
                                      if (listStory.length > index &&
                                          index != 0)
                                        customIconButton(
                                            padding: 1,
                                            width: height / 34,
                                            height: height / 34,
                                            path: 'images/ic_remove.png',
                                            onTap: () {
                                              Navigator.push(
                                                  context,
                                                  FadeRouteAnimation(
                                                      EditProfileScreen(
                                                    isFirst: false,
                                                    userModel: userModel,
                                                  )));
                                            }),
                                      if (listStory.length <= index &&
                                          listStory.isNotEmpty)
                                        customIconButton(
                                            padding: 6,
                                            width: height / 36,
                                            height: height / 36,
                                            path: 'images/ic_add.png',
                                            onTap: () {
                                              Navigator.push(
                                                  context,
                                                  FadeRouteAnimation(
                                                      EditProfileScreen(
                                                    isFirst: false,
                                                    userModel: userModel,
                                                  )));
                                            }),
                                    ],
                                  ),
                                ),
                                if (listStory.length > index)
                                  Padding(
                                    padding: EdgeInsets.only(
                                        left: 0, right: 4, top: height / 160),
                                    child: animatedText(
                                        height / 76,
                                        listStory[index].name,
                                        Colors.white.withOpacity(0.8),
                                        animation * 600,
                                        1),
                                  )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
          ),
        ),
      ],
    );
  }
}

class chatBackgroundPanel extends StatelessWidget {
  List<String> listAnimationChatBac = [];

  chatBackgroundPanel(this.listAnimationChatBac, {super.key});

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.only(top: 16, left: 14, right: 14),
          height: height / 5,
          width: width,
          child: AnimationLimiter(
            child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(right: 20),
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                itemCount: listAnimationChatBac.length,
                itemBuilder: (context, index) {
                  return AnimationConfiguration.staggeredList(
                    position: index,
                    delay: const Duration(milliseconds: 500),
                    child: SlideAnimation(
                      duration: const Duration(milliseconds: 1600),
                      horizontalOffset: 160,
                      curve: Curves.ease,
                      child: FadeInAnimation(
                        curve: Curves.easeOut,
                        duration: const Duration(milliseconds: 2200),
                        child: Container(
                          padding: const EdgeInsets.only(left: 10, right: 4),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16)),
                          child: Lottie.asset(
                              height: height / 7, listAnimationChatBac[index]),
                        ),
                      ),
                    ),
                  );
                }),
          ),
        ),
      ],
    );
  }
}

class topPanel extends StatelessWidget {
  const topPanel({
    super.key,
    required this.height,
    required this.text,
    required this.isBack,
    required this.color,
    required this.icon,
  });

  final double height;
  final bool isBack;
  final String text;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (isBack)
            IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white, size: height / 38),
            ),
          animatedText(height / 48, text, Colors.white, 540, 1),
          Container(
            height: height / 34,
            width: height / 34,
            decoration: BoxDecoration(
                color: color, borderRadius: BorderRadius.circular(99)),
            child: Icon(
              icon,
              color: Colors.white,
              size: height / 50,
            ),
          ),
        ],
      ),
    );
  }
}

class topPanelChat extends StatefulWidget {
  String friendId, friendImage, friendName;
  UserModel userModelCurrent;

  topPanelChat(
      {Key? key,
      required this.friendId,
      required this.friendImage,
      required this.friendName,
      required this.userModelCurrent})
      : super(key: key);

  @override
  State<topPanelChat> createState() =>
      _topPanelChatState(friendId, friendImage, friendName, userModelCurrent);
}

class _topPanelChatState extends State<topPanelChat> {
  String friendId, friendImage, friendName;
  UserModel userModelCurrent;

  _topPanelChatState(
      this.friendId, this.friendImage, this.friendName, this.userModelCurrent);

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return GetBuilder<GetChatDataController>(
      builder: (GetChatDataController controller) {
        return StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('User')
              .doc(friendId)
              .snapshots(),
          builder: (BuildContext context, AsyncSnapshot asyncSnapshot) {
            if (asyncSnapshot.hasData) {
              var isWriteUser = false, isOnline = false;
              isOnline = asyncSnapshot.data['state'] != 'offline';
              try {
                if (controller.writeLastData != '') {
                  if (DateTime.now()
                          .difference(getDataTime(controller.writeLastData))
                          .inSeconds <
                      3) {
                    getState(3500).then((value) {
                      setState(() => isWriteUser = value);
                    });
                    isWriteUser = true;
                  }
                }
              } catch (e) {}

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      ZoomTapAnimation(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                          size: height / 34,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.only(left: 22, right: 4),
                        child: ZoomTapAnimation(
                          onTap: () {
                            Navigator.push(
                                context,
                                FadeRouteAnimation(ProfileScreen(
                                  userModelPartner: UserModel(
                                      name: '',
                                      uid: '',
                                      myCity: '',
                                      ageTime: Timestamp.now(),
                                      userPol: '',
                                      searchPol: '',
                                      searchRangeStart: 0,
                                      userImageUrl: [],
                                      userImagePath: [],
                                      imageBackground: '',
                                      userInterests: [],
                                      searchRangeEnd: 0,
                                      ageInt: 0,
                                      state: '',
                                      token: '',
                                      notification: true,
                                      description: ''),
                                  isBack: true,
                                  idUser: friendId,
                                  userModelCurrent: userModelCurrent,
                                )));
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: height / 16,
                                height: height / 16,
                                child: Stack(
                                  alignment: Alignment.bottomRight,
                                  children: [
                                    SizedBox(
                                      child: Stack(
                                        alignment: Alignment.bottomRight,
                                        children: [
                                          SizedBox(
                                            height: height / 16,
                                            width: height / 16,
                                            child: Card(
                                              shadowColor: Colors.white30,
                                              color: Colors.transparent,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          100),
                                                  side: const BorderSide(
                                                    width: 0.5,
                                                    color: Colors.white24,
                                                  )),
                                              elevation: 8,
                                              child: Container(
                                                decoration: const BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(50)),
                                                ),
                                                child: CachedNetworkImage(
                                                  errorWidget: (context, url,
                                                          error) =>
                                                      const Icon(Icons.error),
                                                  progressIndicatorBuilder:
                                                      (context, url,
                                                              progress) =>
                                                          Center(
                                                    child: SizedBox(
                                                      height: height / 16,
                                                      width: height / 16,
                                                      child:
                                                          CircularProgressIndicator(
                                                        color: Colors.white,
                                                        strokeWidth: 0.8,
                                                        value:
                                                            progress.progress,
                                                      ),
                                                    ),
                                                  ),
                                                  imageUrl: friendImage,
                                                  imageBuilder: (context,
                                                          imageProvider) =>
                                                      Container(
                                                    height: height / 16,
                                                    width: height / 16,
                                                    decoration: BoxDecoration(
                                                      color: Colors.transparent,
                                                      borderRadius:
                                                          const BorderRadius
                                                                  .all(
                                                              Radius.circular(
                                                                  50)),
                                                      image: DecorationImage(
                                                        image: imageProvider,
                                                        fit: BoxFit.cover,
                                                        alignment:
                                                            Alignment.topCenter,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          if (isOnline)
                                            DelayedDisplay(
                                              delay: const Duration(
                                                  milliseconds: 450),
                                              child: customIconButton(
                                                padding: 0,
                                                width: height / 38,
                                                height: height / 38,
                                                path: 'images/ic_green_dot.png',
                                                onTap: () {},
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.only(left: 8),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        RichText(
                                          text: TextSpan(
                                            text: friendName,
                                            style: GoogleFonts.lato(
                                              textStyle: TextStyle(
                                                  color: Colors.white
                                                      .withOpacity(.9),
                                                  fontSize: height / 60,
                                                  letterSpacing: .5),
                                            ),
                                          ),
                                        ),
                                        if (!isOnline && !isWriteUser)
                                          animatedText(
                                              height / 70,
                                              'был(а) ${filterDate(asyncSnapshot.data['lastDateOnline'])}',
                                              Colors.white.withOpacity(.5),
                                              500,
                                              1),
                                        if (isOnline && !isWriteUser)
                                          animatedText(height / 68, 'в сети',
                                              Colors.green, 500, 1),
                                        if (isWriteUser)
                                          showProgressWrite(height: height)
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            } else {
              return const SizedBox();
            }
          },
        );
      },
    );
  }
}
