import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../config/const.dart';
import '../config/firestore_operations.dart';
import '../config/utils.dart';
import '../model/user_model.dart';
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

class _ViewLikesScreenState extends State<ViewLikesScreen> {
  final UserModel userModelCurrent;

  _ViewLikesScreenState(this.userModelCurrent);

  List<UserModel> listUser = [];
  List<String> listLike = [];
  bool isLoading = false, isLoadingNewUser = true;
  final scrollController = ScrollController();
  int limit = 0;

  Future readFirebase(int setLimit, isReadLike) async {
    limit += setLimit;
    print(limit);

    listUser.clear();
    if (isReadLike) {
      await readLikeFirebase(userModelCurrent.uid).then((list) {
        setState(() {
          listLike.addAll(list);
        });
      });
    }

    FirebaseFirestore.instance
        .collection('User')
        .limit(limit)
        .get(const GetOptions(source: Source.cache))
        .then((QuerySnapshot querySnapshot) {
      for (var document in querySnapshot.docs) {
        Map<String, dynamic> data = document.data() as Map<String, dynamic>;
        bool isLike = false;
        Future.forEach(listLike, (idUser) {
          if (idUser == data['uid']) {
            isLike = true;
          }
        }).then((value) async {
          if (isLike) {
            setState(() {
              listUser.add(UserModel(
                  name: data['name'],
                  uid: data['uid'],
                  ageTime: Timestamp.now(),
                  userPol: data['myPol'],
                  searchPol: '',
                  searchRangeStart: 0,
                  userInterests: List<String>.from(data['listInterests']),
                  userImagePath: [],
                  userImageUrl: List<String>.from(data['listImageUri']),
                  searchRangeEnd: 0,
                  myCity: data['myCity'],
                  imageBackground: data['imageBackground'],
                  ageInt: ageInt(data),
                  state: data['state'],
                  token: data['token'],
                  notification: data['notification']));
              if (listLike.length == listUser.length + 1) {
                isLoadingNewUser = false;
              }
            });
          }
        });
      }
    }).then((value) {
      setState(() {
        isLoading = true;
      });
    });
  }

  @override
  void initState() {
    readFirebase(8, true);
    scrollController.addListener(() {
      if (scrollController.position.maxScrollExtent ==
          scrollController.offset) {
        readFirebase(5, false);
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    if (isLoading) {
      return Scaffold(
          backgroundColor: color_black_88,
          body: SafeArea(
            child: SingleChildScrollView(
              controller: scrollController,
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  topPanel(
                    context,
                  'Отметки \'Нравится\'',
                  Icons.favorite_outlined,
                  Colors.red,
                  true,
                  size.height,
                ),
                AnimationLimiter(
                  child: ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: listUser.length + 1,
                    itemBuilder: (context, index) {
                      if (index < listUser.length) {
                        int indexAnimation = index + 1;
                        return AnimationConfiguration.staggeredList(
                          position: index,
                          delay: const Duration(milliseconds: 200),
                          child: SlideAnimation(
                            duration: const Duration(milliseconds: 1200),
                            verticalOffset: 200,
                            curve: Curves.decelerate,
                            child: FadeInAnimation(
                              curve: Curves.easeOut,
                              duration: const Duration(milliseconds: 2500),
                              child: itemUserLike(listUser[index],
                                  userModelCurrent, indexAnimation),
                            ),
                          ),
                          );
                        } else {
                          if (isLoadingNewUser) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 40),
                            child: Center(
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
                        } else {
                          return const SizedBox();
                        }
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return const Scaffold(backgroundColor: color_black_88, body: SizedBox());
  }
}
