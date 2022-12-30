import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../config/const.dart';
import '../../model/interests_model.dart';
import '../../model/user_model.dart';
import '../config/utils.dart';
import '../screens/profile_screen.dart';
import '../screens/settings/edit_profile_screen.dart';
import '../screens/view_likes_screen.dart';
import 'animation_widget.dart';
import 'button_widget.dart';
import 'card_widget.dart';
import 'dialog_widget.dart';

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
              height / 64, 'Интересы', Colors.white.withOpacity(0.8), 750, 1),
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
                                    padding:  EdgeInsets.only(
                                        left: 0, right: 4, top: height / 160),
                                    child: animatedText(height / 78, listStory[index].name, Colors.white.withOpacity(0.8), animation * 600, 1),)
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
              height / 64, 'Интересы', Colors.white.withOpacity(0.8), 750, 1),
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
                                              'images/edit_icon.png',
                                              height: height / 39,
                                              width:  height / 39,
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
                                    padding:  EdgeInsets.only(
                                        left: 0, right: 4, top: height / 160),
                                    child: animatedText(height / 78, listStory[index].name, Colors.white.withOpacity(0.8), animation * 600, 1),)
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

class infoPanelWidget extends StatelessWidget {
  UserModel userModel;

  infoPanelWidget({Key? key, required this.userModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: height / 40),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              animatedText(
                  height / 52,
                  userModel.userImageUrl.length.toString(),
                  Colors.white.withOpacity(0.9),
                  750,
                  1),
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: animatedText(
                    height / 72, 'Фото', Colors.white.withOpacity(0.7), 800, 1),
              ),
            ],
          ),
          SizedBox(
            height: 24,
            child: VerticalDivider(
              endIndent: 4,
              color: Colors.white.withOpacity(0.7),
              thickness: 1,
            ),
          ),
          InkWell(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () {
              Navigator.push(
                  context,
                  FadeRouteAnimation(ViewLikesScreen(
                    userModelCurrent: userModel,
                  )));
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('User')
                      .doc(userModel.uid)
                      .collection('likes')
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasData) {
                      return SlideFadeTransition(
                          animationDuration: const Duration(milliseconds: 1250),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 500),
                            transitionBuilder: ((child, animation) {
                              return ScaleTransition(
                                  scale: animation, child: child);
                            }),
                            child: RichText(
                              key: ValueKey<int>(snapshot.data!.size),
                              text: TextSpan(
                                text: snapshot.data!.size.toString(),
                                style: GoogleFonts.lato(
                                  textStyle: TextStyle(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: height / 52,
                                      letterSpacing: .5),
                                ),
                              ),
                            ),
                          ));
                    }
                    return const SizedBox();
                  },
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: animatedText(height / 72, 'Лайки',
                      Colors.white.withOpacity(0.7), 1200, 1),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 24,
            child: VerticalDivider(
              endIndent: 4,
              color: Colors.white.withOpacity(0.7),
              thickness: 1,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              animatedText(
                  height / 52,
                  userModel.userInterests.length.toString(),
                  Colors.white.withOpacity(0.9),
                  1350,
                  1),
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: animatedText(height / 72, 'Интересы',
                    Colors.white.withOpacity(0.7), 1400, 1),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Padding topPanel(BuildContext context, String text, IconData icon, Color color,
    bool isBack) {
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
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.white, size: 18),
          ),
        RichText(
          text: TextSpan(
            text: text,
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: .4),
          ),
        ),
        Container(
          height: 25,
          width: 25,
          decoration: BoxDecoration(
              color: color, borderRadius: BorderRadius.circular(99)),
          child: Icon(
            icon,
            color: Colors.white,
            size: 17,
          ),
        ),
      ],
    ),
  );
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
    double width = MediaQuery.of(context).size.width;
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('User')
          .doc(friendId)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot asyncSnapshot) {
        return StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('User')
              .doc(userModelCurrent.uid)
              .collection('messages')
              .doc(friendId)
              .snapshots(),
          builder: (context, AsyncSnapshot snapshot) {
            if (snapshot.hasData && asyncSnapshot.hasData) {
              var isWriteUser = false;
              try {
                if (snapshot.data['writeLastData'] != '') {
                  if (DateTime.now()
                          .difference(
                              getDataTime(snapshot.data['writeLastData']))
                          .inSeconds <
                      3) {
                    getState(3500).then((value) {
                      setState(() {
                        isWriteUser = value;
                      });
                    });
                    isWriteUser = true;
                  }
                }
              } catch (error) {}
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      InkWell(
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child:  Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                          size: height/ 34,
                        ),
                      ),
                      Container(
                        padding:
                            const EdgeInsets.only(left: 22, top: 6, right: 4),
                        child: InkWell(
                          highlightColor: Colors.transparent,
                          splashColor: Colors.transparent,
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
                                      notification: true),
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
                                    photoUser(
                                      uri: friendImage,
                                      width: height / 16,
                                      height: height / 16,
                                      state: 'offline',
                                      padding: 0,
                                    ),
                                    if (asyncSnapshot.data['state'] !=
                                        'offline')
                                      SlideFadeTransition(
                                        animationDuration:
                                            const Duration(milliseconds: 550),
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
                                        if (asyncSnapshot.data['state'] ==
                                                'offline' &&
                                            !isWriteUser)
                                          animatedText(
                                              height / 78,
                                              'был(а) ${filterDate(asyncSnapshot.data['lastDateOnline'])}',
                                              Colors.white.withOpacity(.5),
                                              550,
                                              1),
                                        if (asyncSnapshot.data['state'] !=
                                                'offline' &&
                                            !isWriteUser)
                                          animatedText(height / 78, 'в сети',
                                              Colors.green, 550, 1),
                                        if (isWriteUser) showProgressWrite()
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
                  PopupMenuButton<int>(
                    color: Colors.white.withOpacity(0.07),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(16),
                      ),
                    ),
                    onSelected: (value) {
                      if (value == 0) {
                        showAlertDialogDeleteChat(
                            context, friendId, friendName, true, friendImage);
                      }
                    },
                    itemBuilder: (BuildContext context) {
                      return [
                        PopupMenuItem(
                          value: 0,
                          child: animatedText(height / 58, 'Удалить чат', Colors.white, 550, 1),

                        ),
                        PopupMenuItem(
                          value: 1,
                          child:animatedText(height / 58, 'Изменить цвет', Colors.white, 650, 1)),
                      ];
                    },
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
