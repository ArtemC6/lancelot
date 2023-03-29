import 'package:Lancelot/screens/settings/settiongs_profile_screen.dart';
import 'package:flutter/material.dart';

import '../../config/const.dart';
import '../../config/firebase/firestore_operations.dart';
import '../../model/interests_model.dart';
import '../../model/user_model.dart';
import '../../widget/animation_widget.dart';
import '../../widget/button_widget.dart';
import '../../widget/component_widget.dart';

class EditImageProfileScreen extends StatefulWidget {
  final UserModel userModel;
  final List<InterestsModel> listInterests;

  const EditImageProfileScreen(
      {Key? key, required this.userModel, required this.listInterests})
      : super(key: key);

  @override
  State<EditImageProfileScreen> createState() =>
      _EditImageProfileScreen(userModel, listInterests);
}

class _EditImageProfileScreen extends State<EditImageProfileScreen> {
  bool isLoading = false;
  List<String> listImageUri = [];
  final UserModel userModel;
  final List<InterestsModel> listInterests;
  int indexImage = 100;

  _EditImageProfileScreen(this.userModel, this.listInterests);

  @override
  void initState() {
    readFirebaseImageProfile().then((result) {
      listImageUri = result;

      if (userModel.imageBackground.isNotEmpty) {
        indexImage = listImageUri
            .indexWhere((element) => element == userModel.imageBackground);
      }

      setState(() => isLoading = true);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    if (isLoading) {
      return Scaffold(
        backgroundColor: color_black_88,
        body: SafeArea(
          child: Theme(
            data: ThemeData.light(),
            child: NestedScrollView(
              physics: const BouncingScrollPhysics(),
              headerSliverBuilder:
                  (BuildContext context, bool innerBoxIsScrolled) {
                return <Widget>[
                  SliverAppBar(
                    expandedHeight: height / 28,
                    automaticallyImplyLeading: false,
                    forceElevated: innerBoxIsScrolled,
                    titleSpacing: 0,
                    backgroundColor:
                        innerBoxIsScrolled ? color_black_88 : color_black_88,
                    title: const SizedBox(),
                    flexibleSpace: FlexibleSpaceBar(
                        background: Container(
                      color: color_black_88,
                      child: Padding(
                        padding: EdgeInsets.all(height / 200),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (userModel.imageBackground.isNotEmpty)
                              IconButton(
                                onPressed: () => Navigator.pushReplacement(
                                  context,
                                  FadeRouteAnimation(
                                    ProfileSettingScreen(
                                      userModel: userModel,
                                      listInterests: listInterests,
                                    ),
                                  ),
                                ),
                                icon: Icon(Icons.arrow_back_ios_new_rounded,
                                    size: height / 40),
                                color: Colors.white,
                              )
                            else
                              const SizedBox(),
                            animatedText(height / 50, 'Фон профиля',
                                Colors.white, 700, 1),
                            Padding(
                              padding: EdgeInsets.only(
                                right: height / 80,
                              ),
                              child: customIconButton(
                                height: height / 35,
                                width: height / 35,
                                path: 'images/ic_image.png',
                                padding: 2,
                                onTap: () {},
                              ),
                            )
                          ],
                        ),
                      ),
                    )),
                  ),
                ];
              },
              body: SizedBox(
                height: height,
                child: listImageProfile(
                  indexImage: indexImage,
                  listImageUri: listImageUri,
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
