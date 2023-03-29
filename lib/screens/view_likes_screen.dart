import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get_it/get_it.dart';

import '../config/const.dart';
import '../config/firebase/firestore_operations.dart';
import '../config/utils.dart';
import '../model/user_model.dart';
import '../widget/animation_widget.dart';
import '../widget/card_widget.dart';
import '../widget/component_widget.dart';

class ViewLikesScreen extends StatefulWidget {
  final UserModel userModelCurrent, userModelLike;

  const ViewLikesScreen(
      {Key? key, required this.userModelCurrent, required this.userModelLike})
      : super(key: key);

  @override
  State<ViewLikesScreen> createState() =>
      _ViewLikesScreenState(userModelCurrent, userModelLike);
}

class _ViewLikesScreenState extends State<ViewLikesScreen>
    with TickerProviderStateMixin {
  final UserModel userModelCurrent, userModelLike;

  _ViewLikesScreenState(this.userModelCurrent, this.userModelLike);

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

        getFuture(600).then(
          (i) => scrollController.animateTo(
            scrollController.position.maxScrollExtent -
                MediaQuery.of(context).size.height / 7,
            duration: const Duration(milliseconds: 1500),
            curve: Curves.fastOutSlowIn,
          ),
        );
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
                future: GetIt.I<FirebaseFirestore>()
                    .collection('User')
                    .doc(userModelLike.uid)
                    .collection('likes')
                    .limit(limit)
                    .get(),
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
                                      future: readUserFirebase(
                                          snapshot.data.docs[index].id),
                                      builder: (context, user) {
                                        if (user.hasData) {
                                          final friend = user.data!;
                                          if (friend
                                              .imageBackground.isNotEmpty) {
                                            return itemUserLike(
                                                userModelLike: friend,
                                                userModelCurrent:
                                                    userModelCurrent,
                                                indexAnimation: indexAnimation);
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
