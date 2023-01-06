import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import '../main.dart';
import '../screens/auth/signin_screen.dart';
import '../widget/dialog_widget.dart';
import 'const.dart';
import 'firestore_operations.dart';

class FirebaseAuthMethods {
  final FirebaseAuth _auth;
  FirebaseAuthMethods(this._auth);

  User get user => _auth.currentUser!;
  Stream<User?> get authState => FirebaseAuth.instance.authStateChanges();

  Future<void> signUpWithEmail({
    required String email,
    required String password,
    required String name,
    required BuildContext context,
  }) async {
    try {
      showAlertDialogLoading(context);
      _auth
          .createUserWithEmailAndPassword(email: email, password: password)
          .then((value) async {
        Navigator.pop(context);
        showAlertDialogSuccess(context);
        Future.delayed(const Duration(milliseconds: 1850), () {
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const Manager()));
        });

        final docUser = FirebaseFirestore.instance
            .collection('User')
            .doc(FirebaseAuth.instance.currentUser?.uid);

        String? token;
        await FirebaseMessaging.instance.getToken().then((value) {
          token = value;
        });

        final json = {
          'uid': FirebaseAuth.instance.currentUser?.uid,
          'name': name.trim(),
          'email': email.trim(),
          'password': password.trim(),
          'myPol': '',
          'imageBackground': '',
          'myCity': '',
          'searchPol': '',
          'state': '',
          'token': token,
          'rangeStart': 0,
          'rangeEnd': 0,
          'ageTime': DateTime.now(),
          'ageInt': 0,
          'listInterests': [],
          'listImagePath': [],
          'listImageUri': [],
          'notification': true,
        };

        docUser.set(json);
      }).onError((error, stackTrace) {
        Navigator.pop(context);
      });
    } on FirebaseAuthException {}
  }

  Future<void> loginWithEmail({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      showAlertDialogLoading(context);
      _auth
          .signInWithEmailAndPassword(
              email: email.trim(), password: password.trim())
          .then((value) {
        Navigator.pop(context);
        showAlertDialogSuccess(context);
        Future.delayed(const Duration(milliseconds: 1850), () {
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const Manager()));
        });
        setStateFirebase('online');
        setTokenUserFirebase();
      }).onError((error, stackTrace) {
        Navigator.pop(context);
      });
    } on FirebaseAuthException {}
  }

  Future<void> signOut(BuildContext context, String uid) async {
    try {
      _auth.signOut().then((value) {
        Navigator.pushReplacement(
            context, FadeRouteAnimation(const SignInScreen()));
        setStateFirebase('offline', uid).then((value) async {
          deleteUserTokenFirebase(uid);
        });
      });
    } on FirebaseAuthException {}
  }
}
