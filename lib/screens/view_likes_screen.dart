import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../config/const.dart';
import '../config/utils.dart';
import '../model/user_model.dart';
import '../widget/animation_widget.dart';
import '../widget/card_widget.dart';
import '../widget/component_widget.dart';

class ViewLikesScreen extends StatefulWidget {
  final UserModel userModelCurrent;

  const ViewLikesScreen({Key? key, required this.userModelCurrent})
      : super(key: key);

  @override
  State<ViewLikesScreen> createState() =>
      _ViewLikesScreenState(userModelCurrent);
}

class _ViewLikesScreenState extends State<ViewLikesScreen>
    with TickerProviderStateMixin {
  final UserModel userModelCurrent;

  _ViewLikesScreenState(this.userModelCurrent);

  List<String> listLike = [];
  bool isLoadingNewUser = false;
  late final AnimationController animationController;
  final scrollController = ScrollController();
  int limit = 9;

  @override
  void initState() {
    animationController = AnimationController(vsync: this);
    scrollController.addListener(() {
      if (!isLoadingNewUser) setState(() => isLoadingNewUser = true);
      if (scrollController.position.maxScrollExtent ==
          scrollController.offset) {
        setState(() => limit += 6);

        Future.delayed(const Duration(milliseconds: 600), () {
          scrollController.animateTo(
            scrollController.position.maxScrollExtent -
                MediaQuery.of(context).size.height / 7,
            duration: const Duration(milliseconds: 1500),
            curve: Curves.fastOutSlowIn,
          );
        });
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    animationController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: color_black_88,
      body: SafeArea(
        child: SingleChildScrollView(
          controller: scrollController,
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              topPanel(
                height: height,
                text: 'Отметки \'Нравится\'',
                isBack: true,
                color: Colors.red,
                icon: Icons.favorite_outlined,
              ),
              FutureBuilder(
                future: FirebaseFirestore.instance
                        .collection('User')
                        .doc(userModelCurrent.uid)
                        .collection('likes')
                        .limit(limit)
                        .get(const GetOptions(source: Source.cache))
                        .toString()
                        .isEmpty
                    ? FirebaseFirestore.instance
                        .collection('User')
                        .doc(userModelCurrent.uid)
                        .collection('likes')
                        .limit(limit)
                        .get(const GetOptions(source: Source.cache))
                    : FirebaseFirestore.instance
                        .collection('User')
                        .doc(userModelCurrent.uid)
                        .collection('likes')
                        .limit(limit)
                        .get(
                          const GetOptions(source: Source.server),
                        ),
                builder: (context, AsyncSnapshot snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data.docs.length <= 0) {
                      return showIfNoData(
                          imagePath: 'images/animation_heart.json',
                          text: 'У вас нет Лайков',
                          animationController: animationController);
                    } else {
                      return AnimationLimiter(
                        child: ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          scrollDirection: Axis.vertical,
                          itemCount: snapshot.data.docs.length + 1,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            if (index < snapshot.data.docs.length) {
                              int indexAnimation = index + 1;
                              return AnimationConfiguration.staggeredList(
                                position: index,
                                delay: const Duration(milliseconds: 250),
                                child: SlideAnimation(
                                  duration: const Duration(milliseconds: 1500),
                                  verticalOffset: 220,
                                  curve: Curves.ease,
                                  child: FadeInAnimation(
                                    curve: Curves.easeOut,
                                    duration:
                                        const Duration(milliseconds: 3200),
                                    child: FutureBuilder(
                                      future: FirebaseFirestore.instance
                                              .collection('User')
                                              .doc(snapshot.data.docs[index].id)
                                              .get(const GetOptions(
                                                  source: Source.cache))
                                              .toString()
                                              .isEmpty
                                          ? FirebaseFirestore.instance
                                              .collection('User')
                                              .doc(snapshot.data.docs[index].id)
                                              .get(const GetOptions(
                                                  source: Source.cache))
                                          : FirebaseFirestore.instance
                                              .collection('User')
                                              .doc(snapshot.data.docs[index].id)
                                              .get(
                                                const GetOptions(
                                                    source: Source.server),
                                              ),
                                      builder: (context,
                                          AsyncSnapshot<DocumentSnapshot>
                                              snapshot) {
                                        if (snapshot.hasData) {
                                          UserModel userFriend = UserModel(
                                              name: '',
                                              uid: '',
                                              state: '',
                                              description: '',
                                              myCity: '',
                                              ageInt: 0,
                                              ageTime: Timestamp.now(),
                                              token: '',
                                              notification: true,
                                              userPol: '',
                                              searchPol: '',
                                              searchRangeStart: 0,
                                              userImageUrl: [],
                                              userImagePath: [],
                                              imageBackground: '',
                                              userInterests: [],
                                              searchRangeEnd: 0);

                                          try {
                                            if (List<String>.from(snapshot
                                                        .data!['listImageUri'])
                                                    .isNotEmpty ||
                                                snapshot.data![
                                                        'imageBackground'] !=
                                                    '') {
                                              userFriend = UserModel(
                                                  name: snapshot.data!['name'],
                                                  uid: snapshot.data!['uid'],
                                                  ageTime:
                                                      snapshot.data!['ageTime'],
                                                  userPol:
                                                      snapshot.data!['myPol'],
                                                  searchPol: snapshot
                                                      .data!['searchPol'],
                                                  searchRangeStart: snapshot
                                                      .data!['rangeStart'],
                                                  userInterests: List<String>.from(snapshot
                                                      .data!['listInterests']),
                                                  userImagePath: List<String>.from(snapshot
                                                      .data!['listImagePath']),
                                                  userImageUrl: List<String>.from(snapshot
                                                      .data!['listImageUri']),
                                                  searchRangeEnd: snapshot
                                                      .data!['rangeEnd'],
                                                  myCity:
                                                      snapshot.data!['myCity'],
                                                  imageBackground: snapshot
                                                      .data!['imageBackground'],
                                                  ageInt:
                                                      DateTime.now().difference(getDataTime(snapshot.data!['ageTime'])).inDays ~/
                                                          365,
                                                  state: snapshot.data!['state'],
                                                  token: snapshot.data!['token'],
                                                  notification: snapshot.data!['notification'],
                                                  description: snapshot.data!['description']);
                                            }
                                          } catch (e) {}

                                          if (userFriend
                                                  .userImageUrl.isNotEmpty ||
                                              userFriend.imageBackground !=
                                                  '' ||
                                              userFriend.uid != '') {
                                            return itemUserLike(
                                                userFriend,
                                                userModelCurrent,
                                                indexAnimation);
                                          }

                                          return const SizedBox();
                                        }

                                        return const SizedBox();
                                      },
                                    ),
                                  ),
                                ),
                              );
                            } else {
                              if (snapshot.data.docs.length >= limit) {
                                if (isLoadingNewUser) {
                                  return Padding(
                                    padding: EdgeInsets.symmetric(
                                        vertical: height / 16),
                                    child: const Center(
                                      child: SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 0.8,
                                        ),
                                      ),
                                    ),
                                  );
                                }
                              }
                            }
                            return const SizedBox();
                          },
                        ),
                      );
                    }
                  }
                  return const SizedBox();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
