import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

import '../config/const.dart';
import '../config/firebase/firestore_operations.dart';
import '../model/user_model.dart';
import 'animation_widget.dart';
import 'button_widget.dart';
import 'dialog_widget.dart';

class photoProfile extends StatelessWidget {
  String uri;
  photoProfile({Key? key, required this.uri}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return ZoomTapAnimation(
      onTap: () {
        showDialogZoom(uri: uri, context: context);
      },
      child: SizedBox(
        height: height * 0.15,
        width: height * 0.15,
        child: Card(
          shadowColor: Colors.white38,
          color: color_black_88,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: const BorderSide(
                width: 0.8,
                color: Colors.white30,
              )),
          elevation: 4,
          child: CachedNetworkImage(
            errorWidget: (context, url, error) => const Icon(Icons.error),
            progressIndicatorBuilder: (context, url, progress) =>
                loadingPhotoAnimation(
              height: height,
            ),
            imageUrl: uri,
            imageBuilder: (context, imageProvider) => Container(
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: const BorderRadius.all(Radius.circular(14)),
                image: DecorationImage(
                  image: imageProvider,
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class photoProfileGallery extends StatelessWidget {
  List<String> listPhoto = [];

  photoProfileGallery(this.listPhoto, {super.key});

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;

    return Column(
      children: [
        Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.all(20),
          child: animatedText(
              height / 62, 'Фото', Colors.white.withOpacity(0.8), 950, 1),
        ),
        SizedBox(
          height: height / 2,
          child: AnimationLimiter(
            child: GridView.count(
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 6),
              crossAxisCount: 3,
              children: List.generate(
                listPhoto.length,
                (int index) {
                  return AnimationConfiguration.staggeredGrid(
                    position: index,
                    duration: const Duration(milliseconds: 2200),
                    columnCount: 3,
                    child: ScaleAnimation(
                      duration: const Duration(milliseconds: 2200),
                      curve: Curves.fastLinearToSlowEaseIn,
                      child: FadeInAnimation(
                        child: ZoomTapAnimation(
                          onTap: () {
                            showDialogZoom(
                              uri: listPhoto[index],
                              context: context,
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(5),
                            child: Card(
                              shadowColor: Colors.white30,
                              color: color_black_88,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: const BorderSide(
                                    width: 0.6,
                                    color: Colors.white30,
                                  )),
                              elevation: 6,
                              child: CachedNetworkImage(
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.error),
                                imageBuilder: (context, imageProvider) =>
                                    Container(
                                  decoration: BoxDecoration(
                                    color: color_black_88,
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(12)),
                                    image: DecorationImage(
                                      image: imageProvider,
                                      fit: BoxFit.cover,
                                      alignment: Alignment.topCenter,
                                    ),
                                  ),
                                ),
                                progressIndicatorBuilder:
                                    (context, url, progress) =>
                                        loadingPhotoAnimation(height: height),

                                // loadingPhotoAnimation(height),
                                imageUrl: listPhoto[index],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class photoProfileSettingsGallery extends StatefulWidget {
  UserModel userModel;

  photoProfileSettingsGallery(this.userModel, {super.key});

  @override
  State<photoProfileSettingsGallery> createState() =>
      _photoProfileSettingsGalleryState(userModel);
}

class _photoProfileSettingsGalleryState
    extends State<photoProfileSettingsGallery> {
  List<String> listImageUri = [], listImagePath = [];
  UserModel userModel;

  FirebaseStorage storage = FirebaseStorage.instance;
  bool isVisibl = false;

  _photoProfileSettingsGalleryState(this.userModel);

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Column(
      children: [
        Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.all(20),
          child: animatedText(
              height / 62, 'Фото', Colors.white.withOpacity(0.8), 950, 1),
        ),
        SizedBox(
          height: height / 2,
          child: AnimationLimiter(
            child: GridView.count(
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 6),
              crossAxisCount: 3,
              children: List.generate(
                9,
                    (int index) {
                  return AnimationConfiguration.staggeredGrid(
                    position: index,
                    duration: const Duration(milliseconds: 2200),
                    columnCount: 3,
                    child: ScaleAnimation(
                      duration: const Duration(milliseconds: 2200),
                      curve: Curves.fastLinearToSlowEaseIn,
                      child: FadeInAnimation(
                        child: ZoomTapAnimation(
                          onTap: () {
                            if (widget.userModel.userImageUrl.length > index) {
                              showDialogZoom(
                                uri: widget.userModel.userImageUrl[index],
                                context: context,
                              );
                            }
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
                              child: Stack(
                                alignment: Alignment.bottomRight,
                                children: [
                                  if (widget.userModel.userImageUrl.length >
                                      index)
                                    CachedNetworkImage(
                                      errorWidget: (context, url, error) =>
                                          const Icon(Icons.error),
                                      imageBuilder: (context, imageProvider) =>
                                          Container(
                                        decoration: BoxDecoration(
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(12)),
                                          image: DecorationImage(
                                            image: imageProvider,
                                            fit: BoxFit.cover,
                                            alignment: Alignment.topCenter,
                                          ),
                                        ),
                                      ),
                                      progressIndicatorBuilder:
                                          (context, url, progress) =>
                                              loadingPhotoAnimation(
                                        height: height,
                                      ),
                                      imageUrl:
                                          widget.userModel.userImageUrl[index],
                                    ),
                                  if (0 == index)
                                    InkWell(
                                      splashColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                      onTap: () {
                                        updateFirstImage(
                                            context, widget.userModel, false);
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(4),
                                        child: Image.asset(
                                          'images/ic_edit.png',
                                          height: height / 35,
                                          width: height / 35,
                                        ),
                                      ),
                                    ),
                                  if (widget.userModel.userImageUrl.length >
                                          index &&
                                      index != 0)
                                    customIconButton(
                                        padding: 2,
                                        width: height / 30,
                                        height: height / 30,
                                        path: 'images/ic_remove.png',
                                        onTap: () {
                                          imageRemove(
                                              index, context, userModel);
                                        }),
                                  if (widget.userModel.userImageUrl.length <=
                                          index &&
                                      widget.userModel.userImageUrl.isNotEmpty)
                                    customIconButton(
                                        padding: 6,
                                        width: height / 36,
                                        height: height / 36,
                                        path: 'images/ic_add.png',
                                        onTap: () {
                                          uploadImageAdd(
                                              context, widget.userModel);
                                        }),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
