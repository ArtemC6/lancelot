import 'dart:ui';

import 'package:bottom_sheet/bottom_sheet.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:ndialog/ndialog.dart';

import '../config/const.dart';
import '../config/firebase/firestore_operations.dart';
import '../main.dart';
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
      child: const Text("Отмена"), onPressed: () => Navigator.pop(context));

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
    required String uidUser,
    required String friendName,
    required bool isBack,
    required String friendUri,
    required double height}) {
  Widget cancelButton = TextButton(
    child: animatedText(height / 62, 'Отмена', Colors.blueAccent, 400, 1),
    onPressed: () => Navigator.pop(context),
  );

  Widget continueButton = TextButton(
    child: animatedText(height / 62, 'Удалить', Colors.blueAccent, 400, 1),
    onPressed: () {
      deleteChatFirebase(friendId, uidUser, friendUri);
      Navigator.pop(context);
      Map<String, dynamic> data = {};
      Navigator.push(
        context,
        FadeRouteAnimation(
          ManagerScreen(
            currentIndex: 2,
            userModelCurrent: UserModel.fromDocument(data),
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
        filter: ImageFilter.blur(sigmaX: 2.3, sigmaY: 2.3),
        child: AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.transparent,
          actions: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 2.8, sigmaY: 2.8),
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

showAlertDialogDeleteAccount(
    {required context, required double height, required UserModel userModel}) {
  final cancelButton = TextButton(
    child: animatedText(height / 62, 'Отмена', Colors.blueAccent, 400, 1),
    onPressed: () => Navigator.pop(context),
  );

  final continueButton = TextButton(
    child: animatedText(height / 62, 'Удалить', Colors.blueAccent, 400, 1),
    onPressed: () async {
      try {
        final uid = GetIt.I<FirebaseAuth>().currentUser?.uid;
        if (uid != null) {
          await deleteAccountData(userModel);
          GetIt.I<FirebaseFirestore>().collection("User").doc(uid).delete();
          await GetIt.I<FirebaseAuth>().currentUser!.delete();
        }
        await GetIt.I<FirebaseAuth>().signOut();
      } catch (e) {
        await GetIt.I<FirebaseAuth>().signOut();
      }
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const Manager()));
    },
  );

  showDialog(
    barrierColor: const Color(0x01000000),
    context: context,
    builder: (context) {
      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 2.5, sigmaY: 2.5),
        child: AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.transparent,
          actions: [
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 2.8, sigmaY: 2.8),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: Colors.transparent,
                      border: Border.all(width: 0.8, color: Colors.white38),
                      borderRadius: BorderRadius.circular(18)),
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                            top: height / 36,
                            bottom: 32,
                            left: height / 42,
                            right: height / 42),
                        child: animatedText(height / 48, 'Удалить аккаунт',
                            Colors.white, 350, 1),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            bottom: height / 42,
                            left: height / 42,
                            right: height / 42),
                        child: Row(
                          children: [
                            Expanded(child: cancelButton),
                            Expanded(child: continueButton),
                          ],
                        ),
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
        filter: ImageFilter.blur(sigmaX: 3.5, sigmaY: 3.5),
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
    future: Future.delayed(const Duration(seconds: 10)),
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

showBottomSheetShow(
    context, title, select_1, select_2, controller, double height) {
  return showFlexibleBottomSheet(
    bottomSheetColor: Colors.transparent,
    duration: const Duration(milliseconds: 800),
    initHeight: 0.32,
    maxHeight: 0.32,
    context: context,
    builder: (
      context,
      scrollController,
      bottomSheetOffset,
    ) {
      return ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Padding(
                  padding:
                      EdgeInsets.only(top: height / 80, bottom: height / 72),
                  child: animatedText(height / 56, title, Colors.white, 500, 2),
                ),
                ListTile(
                  title:
                      animatedText(height / 57, select_1, Colors.white, 550, 1),
                  onTap: () {
                    controller.text = select_1;
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title:
                      animatedText(height / 57, select_2, Colors.white, 550, 1),
                  onTap: () {
                    controller.text = select_2;
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
