import 'package:flutter/material.dart';

import '../../config/const.dart';
import '../../config/firebase/firestore_operations.dart';
import '../../widget/animation_widget.dart';
import '../../widget/button_widget.dart';
import '../../widget/component_widget.dart';

class EditImageProfileScreen extends StatefulWidget {
  final String bacImage;

  const EditImageProfileScreen({Key? key, required this.bacImage})
      : super(key: key);

  @override
  State<EditImageProfileScreen> createState() =>
      _EditImageProfileScreen(bacImage);
}

class _EditImageProfileScreen extends State<EditImageProfileScreen> {
  bool isLoading = false;
  String bacImage;
  List<String> listImageUri = [];
  int indexImage = 100;

  _EditImageProfileScreen(this.bacImage);

  @override
  void initState() {
    readFirebaseImageProfile().then((result) {
      listImageUri = result;

      if (bacImage.isNotEmpty) {
        indexImage = listImageUri.indexWhere((element) => element == bacImage);
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
                            if (bacImage.isNotEmpty)
                              IconButton(
                                onPressed: () => Navigator.pop(context),
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
