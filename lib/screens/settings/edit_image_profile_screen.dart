import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../config/const.dart';
import '../../config/firestore_operations.dart';
import '../../widget/animation_widget.dart';
import '../../widget/button_widget.dart';
import '../../widget/card_widget.dart';

class EditImageProfileScreen extends StatefulWidget {
 final String bacImage;

  EditImageProfileScreen({Key? key, required this.bacImage}) : super(key: key);

  @override
  State<EditImageProfileScreen> createState() =>
      _EditImageProfileScreen(bacImage);
}

class _EditImageProfileScreen extends State<EditImageProfileScreen> {
  bool isLoading = false;
  final String bacImage;
  List<String> listImageUri = [];
  int indexImage = 100;

  _EditImageProfileScreen(this.bacImage);

  @override
  void initState() {
    readFirebaseImageProfile().then((result) {
      setState(() {
        listImageUri = result;
      });
    }).then((value) {
      setState(() {
        if (bacImage != '') {
          indexImage =
              listImageUri.indexWhere((element) => element == bacImage);
        }
        isLoading = true;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    AnimationLimiter listImageProfile(BuildContext context) {
      return AnimationLimiter(
          child: AnimationConfiguration.staggeredList(
        position: 1,
        delay: const Duration(milliseconds: 250),
        child: SlideAnimation(
          duration: const Duration(milliseconds: 2200),
          horizontalOffset: 250,
          curve: Curves.ease,
          child: FadeInAnimation(
              curve: Curves.easeOut,
                duration: const Duration(milliseconds: 3000),
                child: GridView.custom(
                    shrinkWrap: true,
                    gridDelegate: SliverQuiltedGridDelegate(
                        mainAxisSpacing: 4,
                        crossAxisSpacing: 0,
                        repeatPattern: QuiltedGridRepeatPattern.inverted,
                        pattern: [
                          const QuiltedGridTile(2, 2),
                          const QuiltedGridTile(1, 1),
                          const QuiltedGridTile(1, 1),
                          const QuiltedGridTile(1, 2),
                          const QuiltedGridTile(1, 2),
                        ],
                        crossAxisCount: 4),
                    physics: const NeverScrollableScrollPhysics(),
                    childrenDelegate: SliverChildBuilderDelegate(
                        childCount: listImageUri.length, (context, index) {
                      return Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          InkWell(
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: () {
                              uploadImagePhotoProfile(
                                  listImageUri[index], context);
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: Card(
                                shadowColor: Colors.white30,
                                color: color_black_88,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: const BorderSide(
                                      width: 0.8,
                                      color: Colors.white38,
                                    )),
                                elevation: 6,
                                child: CachedNetworkImage(
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.error),
                                  imageBuilder: (context, imageProvider) =>
                                      Container(
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(14)),
                                      image: DecorationImage(
                                        image: imageProvider,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  progressIndicatorBuilder:
                                      (context, url, progress) => Center(
                                        child: cardLoading(size, 14),
                                  ),
                                  imageUrl: listImageUri[index],
                                ),
                              ),
                            ),
                          ),
                          if (indexImage == index && indexImage != 100)
                            customIconButton(
                                height: size.height / 34,
                                width: size.height / 34,
                                padding: 4,
                                path: 'images/ic_save.png',
                                onTap: () {
                                  uploadImagePhotoProfile(
                                      listImageUri[index], context);
                                }),
                          if (indexImage != index)
                            InkWell(
                              splashColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onTap: () {
                                uploadImagePhotoProfile(
                                    listImageUri[index], context);
                              },
                              child: Container(
                                height: size.height / 38,
                                width: size.height / 38,
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        width: 0.5, color: Colors.white38),
                                    borderRadius: BorderRadius.circular(50),
                                    color: Colors.white12),
                                // padding: const EdgeInsets.all(10),
                              ),
                            ),
                        ],
                      );
                    })),
              )),
        ),
      );
    }

    Padding topPanelProfile(BuildContext context) {
      return Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (bacImage != '')
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                color: Colors.white,
              ),
            if (bacImage == '') const SizedBox(),
            animatedText(size.height /48, 'Фон профиля', Colors.white, 700, 1),

            Padding(
              padding: const EdgeInsets.only(
                right: 14,
                bottom: 4,
              ),
              child: customIconButton(
                height: size.height / 34,
                width: size.height / 34,
                path: 'images/ic_image.png',
                padding: 2,
                onTap: () {},
              ),
            )
            // Container(
          ],
        ),
      );
    }

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
                    expandedHeight: 60,
                    automaticallyImplyLeading: false,
                    floating: false,
                    forceElevated: innerBoxIsScrolled,
                    pinned: false,
                    titleSpacing: 0,
                    backgroundColor:
                        innerBoxIsScrolled ? color_black_88 : color_black_88,
                    title: const SizedBox(),
                    flexibleSpace: FlexibleSpaceBar(
                        background: Container(
                      color: color_black_88,
                      child: topPanelProfile(context),
                    )),
                  ),
                ];
              },
              body: SizedBox(
                  height: size.height, child: listImageProfile(context)),
            ),
          ),
        ),
      );
    }
    return const loadingCustom();
  }
}
