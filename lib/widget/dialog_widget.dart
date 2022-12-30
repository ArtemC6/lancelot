import 'dart:io';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:lottie/lottie.dart';
import 'package:ndialog/ndialog.dart';

import '../config/const.dart';
import '../config/firestore_operations.dart';

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
    BuildContext context,
    String friendId,
    String myId,
    String friendName,
    String deleteMessageIdMy,
    String deleteMessageIdPartner,
    AsyncSnapshot snapshotMy,
    int index,
    bool isLastMessage) {
  bool isDeletePartner = false;

  Widget cancelButton = TextButton(
    child: const Text("Отмена"),
    onPressed: () {
      Navigator.pop(context);
    },
  );

  Widget continueButton = TextButton(
    child: const Text("Удалить"),
    onPressed: () {
      Navigator.pop(context);
      deleteMessageFirebase(myId, friendId, deleteMessageIdMy, isDeletePartner,
          deleteMessageIdPartner, isLastMessage, snapshotMy, index);
    },
  );

  showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
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
                        value: isDeletePartner,
                        onChanged: (newValue) {
                          setState(() {
                            isDeletePartner = !isDeletePartner;
                          });
                        },
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
                ],
              ),
            );
          },
        );
      });
}

showAlertDialogWarning(BuildContext context) async {
  String title = '';
  String message = '';

  await FirebaseFirestore.instance
      .collection('StartApp')
      .doc('IsStart')
      .get()
      .then((DocumentSnapshot documentSnapshot) {
    if (documentSnapshot.exists) {
      title = documentSnapshot['text_title'];
      message = documentSnapshot['text_message'];
    }
  });

  Widget cancelButton = TextButton(
    child: const Text("Выйти"),
    onPressed: () {
      exit(0);
    },
  );

  showDialog(
    barrierDismissible: false,
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                backgroundColor: color_black_88,
                actions: <Widget>[
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: RichText(
                          text: TextSpan(
                            text: title,
                            style: GoogleFonts.lato(
                              textStyle: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  letterSpacing: .4),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: RichText(
                          text: TextSpan(
                            text: message,
                            style: GoogleFonts.lato(
                              textStyle: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  letterSpacing: .4),
                            ),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(child: cancelButton),
                        ],
                      )
                    ],
                  ),
                ],
              ),
            );
          },
        );
      });
}

showAlertDialogDeleteChat(BuildContext context, String friendId,
    String friendName, bool isBack, String friendUri) {
  bool isDeletePartner = false;
  Widget cancelButton = TextButton(
    child: const Text("Отмена"),
    onPressed: () {
      Navigator.pop(context);
    },
  );

  Widget continueButton = TextButton(
    child: const Text("Удалить"),
    onPressed: () {
      deleteChatFirebase(isDeletePartner, friendId, isBack, context, friendUri);
    },
  );

  showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                backgroundColor: color_black_88,
                actions: <Widget>[
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: RichText(
                          text: TextSpan(
                            text: 'Удалить чат',
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
                        value: isDeletePartner,
                        onChanged: (newValue) {
                          setState(() {
                            isDeletePartner = !isDeletePartner;
                          });
                        },
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
                ],
              ),
            );
          },
        );
      });
}

showAlertDialogLoading(BuildContext context) {
  CustomProgressDialog.future(
    loadingWidget: Center(
      child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
          child: Lottie.asset(
            'images/animation_loader.json',
            width: MediaQuery.of(context).size.width * 0.22,
            height: MediaQuery.of(context).size.height * 0.22,
            alignment: Alignment.center,
            errorBuilder: (context, error, stackTrace) {
              return LoadingAnimationWidget.dotsTriangle(
                size: 48,
                color: Colors.blueAccent,
              );
            },
          )),
    ),
    dismissable: false,
    context,
    future: Future.delayed(const Duration(seconds: 4)),
  );
}
