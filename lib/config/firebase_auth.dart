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
  static final auth = GetIt.I<FirebaseAuth>();
  static final init = GetIt.I<FirebaseFirestore>();

  static Future<void> signUpWithEmail({
    required String email,
    required String password,
    required String name,
    required BuildContext context,
  }) async {
    try {
      showAlertDialogLoading(context);
      auth
          .createUserWithEmailAndPassword(
              email: email.trim(), password: password.trim())
          .then((value) async {
        Navigator.pop(context);
        showAlertDialogSuccess(context);
        init.collection('User').doc(auth.currentUser?.uid).set({
          'uid': auth.currentUser?.uid,
          'name': name.trim(),
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
        getFuture(1720).then((i) => Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const Manager())));
      }).onError((error, stackTrace) async {
        await auth
            .createUserWithEmailAndPassword(
                email: email.trim(), password: password.trim())
            .then((value) async {
          Navigator.pop(context);
          showAlertDialogSuccess(context);

          init.collection('User').doc(auth.currentUser?.uid).set({
            'uid': auth.currentUser?.uid,
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

          getFuture(1720).then((i) => Navigator.of(context).pushReplacement(
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
      auth
          .signInWithEmailAndPassword(
          email: email.trim(), password: password.trim())
          .then((value) async {
        Navigator.pop(context);
        showAlertDialogSuccess(context);

        setStateFirebase('online');
        setTokenUserFirebase();

        getFuture(1720).then((i) => Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const Manager())));
      }).onError((error, stackTrace) {
        auth
            .signInWithEmailAndPassword(
            email: email.trim(), password: password.trim())
            .then((value) async {
          Navigator.pop(context);
          showAlertDialogSuccess(context);
          setStateFirebase('online');
          setTokenUserFirebase();
          getFuture(1720).then((i) => Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const Manager())));
        }).onError((error, stackTrace) {
          Navigator.pop(context);
        });
      });
    } on FirebaseAuthException {}
  }

  static Future<void> signOut(BuildContext context, String uid) async {
    try {
      auth.signOut().then((i) {
        Navigator.pushReplacement(
            context, FadeRouteAnimation(const SignInScreen()));
        setStateFirebase('offline', uid);
        deleteUserTokenFirebase(uid);
      });
    } on FirebaseAuthException {}
  }
}
