import 'package:Lancelot/config/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../main.dart';
import '../screens/auth/signin_screen.dart';
import '../widget/dialog_widget.dart';
import 'const.dart';
import 'firebase/firestore_operations.dart';

class FirebaseAuthMethods {
  static Future<void> signUpWithEmail({
    required String email,
    required String password,
    required String name,
    required BuildContext context,
  }) async {
    try {
      showAlertDialogLoading(context);
      GetIt.I<FirebaseAuth>()
          .createUserWithEmailAndPassword(
              email: email.trim(), password: password.trim())
          .then((value) async {
        Navigator.pop(context);
        showAlertDialogSuccess(context);
        GetIt.I<FirebaseFirestore>()
            .collection('User')
            .doc(GetIt.I<FirebaseAuth>().currentUser?.uid)
            .set({
          'uid': GetIt.I<FirebaseAuth>().currentUser?.uid,
          'name': name.trim(),
          'email': email.trim(),
          'password': password.trim(),
          'myPol': '',
          'imageBackground': '',
          'myCity': '',
          'searchPol': '',
          'description': '',
          'state': '',
          'token': await getTokenUser(),
          'rangeStart': 0,
          'rangeEnd': 0,
          'ageTime': DateTime.now(),
          'listInterests': [],
          'listImagePath': [],
          'listImageUri': [],
          'notification': true,
        });

        getFuture(1740).then((i) => Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const Manager())));
      }).onError((error, stackTrace) async {
        await GetIt.I<FirebaseAuth>()
            .createUserWithEmailAndPassword(
                email: email.trim(), password: password.trim())
            .then((value) async {
          Navigator.pop(context);
          showAlertDialogSuccess(context);

          GetIt.I<FirebaseFirestore>()
              .collection('User')
              .doc(GetIt.I<FirebaseAuth>().currentUser?.uid)
              .set({
            'uid': GetIt.I<FirebaseAuth>().currentUser?.uid,
            'name': name.trim(),
            'email': email.trim(),
            'password': password.trim(),
            'myPol': '',
            'imageBackground': '',
            'myCity': '',
            'searchPol': '',
            'description': '',
            'state': '',
            'token': await getTokenUser(),
            'rangeStart': 0,
            'rangeEnd': 0,
            'ageTime': DateTime.now(),
            'listInterests': [],
            'listImagePath': [],
            'listImageUri': [],
            'notification': true,
          });

          getFuture(1740).then((i) => Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const Manager())));
        }).onError((error, stackTrace) {
          Navigator.pop(context);
        });
      });
    } on FirebaseAuthException {}
  }

  static Future<void> loginWithEmail({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      showAlertDialogLoading(context);
      GetIt.I<FirebaseAuth>()
          .signInWithEmailAndPassword(
              email: email.trim(), password: password.trim())
          .then((value) async {
        Navigator.pop(context);
        showAlertDialogSuccess(context);

        setStateFirebase('online');
        setTokenUserFirebase();

        getFuture(1740).then((i) => Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const Manager())));
      }).onError((error, stackTrace) {
        GetIt.I<FirebaseAuth>()
            .signInWithEmailAndPassword(
                email: email.trim(), password: password.trim())
            .then((value) async {
          Navigator.pop(context);
          showAlertDialogSuccess(context);

          setStateFirebase('online');
          setTokenUserFirebase();
          getFuture(1740).then((i) => Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const Manager())));
        }).onError((error, stackTrace) {
          Navigator.pop(context);
        });
      });
    } on FirebaseAuthException {}
  }

  static Future<void> signOut(BuildContext context, String uid) async {
    try {
      GetIt.I<FirebaseAuth>().signOut().then((value) {
        Navigator.pushReplacement(
            context, FadeRouteAnimation(const SignInScreen()));
        setStateFirebase('offline', uid);
        deleteUserTokenFirebase(uid);
      });
    } on FirebaseAuthException {}
  }
}
