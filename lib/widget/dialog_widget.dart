import 'dart:ui';

import 'package:bottom_sheet/bottom_sheet.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:ndialog/ndialog.dart';

import '../config/const.dart';
import '../config/firebase/firestore_operations.dart';
import '../model/user_model.dart';
import '../screens/manager_screen.dart';
import 'animation_widget.dart';

void showDialogZoom({required String uri, required BuildContext context}) {
  ZoomDialog(
    zoomScale: 5,
    child: SizedBox(
      height: MediaQuery.of(context).size.height * 0.40,
      width: MediaQuery.of(context).size.width * 0.94,
      child: CachedNetworkImage(
        errorWidget: (context, url, error) => const Icon(Icons.error),
        imageBuilder: (context, imageProvider) => Container(
          decoration: BoxDecoration(
            color: color_black_88,
            border: Border.all(color: Colors.white30, width: 0.6),
            borderRadius: const BorderRadius.all(Radius.circular(20)),
            image: DecorationImage(
                image: imageProvider,
                fit: BoxFit.cover,
                alignment: Alignment.topCenter),
          ),
        ),
        progressIndicatorBuilder: (context, url, progress) => Center(
          child: SizedBox(
            height: 26,
            width: 26,
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 0.8,
              value: progress.progress,
            ),
          ),
        ),
        imageUrl: uri,
      ),
    ),
  ).show(context);
}

showAlertDialogDeleteMessage(
    {required BuildContext context,
    required String friendId,
    required String myId,
    required String friendName,
    required String idDoc,
    required AsyncSnapshot snapshotMy,
    required int index,
    required bool isLastMessage}) {
  Widget cancelButton = TextButton(
    child: const Text("Отмена"),
    onPressed: () {
      Navigator.pop(context);
    },
  );

  Widget continueButton = TextButton(
    child: const Text("Удалить"),
    onPressed: () async {
      deleteMessageFirebase(
          myId, friendId, idDoc, isLastMessage, snapshotMy, index);

      Navigator.pop(context);
    },
  );

  showDialog(
    context: context,
    builder: (context) {
      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: color_black_88,
          actions: <Widget>[
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: RichText(
                    text: TextSpan(
                      text: 'Удалить сообщение',
                      style: GoogleFonts.lato(
                        textStyle: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            letterSpacing: .4),
                      ),
                    ),
                  ),
                ),
                CheckboxListTile(
                  activeColor: Colors.blue,
                  title: RichText(
                    text: TextSpan(
                      text: "Также удалить для $friendName",
                      style: GoogleFonts.lato(
                        textStyle: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            letterSpacing: .6),
                      ),
                    ),
                  ),
                  value: true,
                  onChanged: (newValue) {},
                  controlAffinity:
                      ListTileControlAffinity.leading, //  <-- leading Checkbox
                ),
                Row(
                  children: [
                    Expanded(child: cancelButton),
                    Expanded(child: continueButton),
                  ],
                )
              ],
            ),
          ],
        ),
      );
    },
  );
}

showAlertDialogDeleteChat(
    {required BuildContext context,
    required String friendId,
    required String friendName,
    required bool isBack,
    required String friendUri,
    required double height}) {
  Widget cancelButton = TextButton(
    child: animatedText(height / 62, 'Отмена', Colors.blueAccent, 400, 1),
    onPressed: () {
      Navigator.pop(context);
    },
  );

  Widget continueButton = TextButton(
    child: animatedText(height / 62, 'Удалить', Colors.blueAccent, 400, 1),
    onPressed: () {
      deleteChatFirebase(friendId, isBack, context, friendUri);
      Navigator.pop(context);
      Navigator.push(
        context,
        FadeRouteAnimation(
          ManagerScreen(
            currentIndex: 2,
            userModelCurrent: UserModel(
                name: '',
                uid: '',
                state: '',
                myCity: '',
                ageInt: 0,
                ageTime: Timestamp.now(),
                userPol: '',
                searchPol: '',
                searchRangeStart: 0,
                userImageUrl: [],
                userImagePath: [],
                imageBackground: '',
                userInterests: [],
                searchRangeEnd: 0,
                token: '',
                notification: true,
                description: ''),
          ),
        ),
      );
    },
  );

  showDialog(
    barrierColor: const Color(0x01000000),
    context: context,
    builder: (context) {
      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 2.2, sigmaY: 2.2),
        child: AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.transparent,
          actions: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.01),
                      border: Border.all(width: 0.8, color: Colors.white38),
                      borderRadius: BorderRadius.circular(18)),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: animatedText(
                            height / 48, 'Удалить чат', Colors.white, 320, 1),
                      ),
                      CheckboxListTile(
                        activeColor: Colors.blueAccent,
                        title: animatedText(
                            height / 62,
                            'Также удалить для $friendName',
                            Colors.white,
                            360,
                            1),
                        value: true,
                        onChanged: (newValue) {},
                        controlAffinity: ListTileControlAffinity
                            .leading, //  <-- leading Checkbox
                      ),
                      Row(
                        children: [
                          Expanded(child: cancelButton),
                          Expanded(child: continueButton),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

showAlertDialogLoading(BuildContext context) {
  CustomProgressDialog.future(
    loadingWidget: Center(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
        child: Lottie.asset(
          'images/animation_loader.json',
          width: MediaQuery.of(context).size.width * 0.58,
          height: MediaQuery.of(context).size.height * 0.58,
          alignment: Alignment.center,
        ),
      ),
    ),
    dismissable: false,
    context,
    future: Future.delayed(const Duration(seconds: 4)),
  );
}

showAlertDialogSuccess(BuildContext context) {
  CustomProgressDialog.future(
    loadingWidget: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
      child: Lottie.asset(
        'images/animation_success.json',
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        alignment: Alignment.center,
      ),
    ),
    dismissable: false,
    context,
    future: Future.delayed(const Duration(milliseconds: 1900)),
  );
}

Future<dynamic> showBottomSheetShow(context, title, select_1, select_2,
    TextEditingController controller, double height) {
  return showFlexibleBottomSheet(
    duration: const Duration(milliseconds: 800),
    decoration: const BoxDecoration(
        color: color_black_88,
        borderRadius: BorderRadius.all(Radius.circular(16))),
    bottomSheetColor: color_black_88,
    initHeight: 0.345,
    context: context,
    builder: (
      BuildContext context,
      ScrollController scrollController,
      double bottomSheetOffset,
    ) {
      return StatefulBuilder(builder: (context, setState) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Card(
            shadowColor: Colors.white30,
            color: color_black_88,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: const BorderSide(
                  width: 0.8,
                  color: Colors.white38,
                )),
            elevation: 16,
            child: Theme(
              data: ThemeData.light(),
              child: ExpansionTile(
                key: GlobalKey(),
                initiallyExpanded: true,
                maintainState: true,
                title: animatedText(height / 56, title, Colors.white, 0, 2),
                children: [
                  ListTile(
                    title: animatedText(
                        height / 57, select_1, Colors.white, 550, 1),
                    onTap: () {
                      setState(() => controller.text = select_1);
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    title: animatedText(
                        height / 57, select_2, Colors.white, 550, 1),
                    onTap: () {
                      setState(() => controller.text = select_2);
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      });
    },
  );
}
