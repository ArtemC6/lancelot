// @dart=2.9
import 'package:Lancelot/screens/auth/signin_screen.dart';
import 'package:Lancelot/screens/auth/verify_screen.dart';
import 'package:Lancelot/screens/manager_screen.dart';
import 'package:Lancelot/screens/settings/edit_image_profile_screen.dart';
import 'package:Lancelot/screens/settings/edit_profile_screen.dart';
import 'package:Lancelot/widget/animation_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/route_manager.dart';
import 'package:get_it/get_it.dart';

import 'config/const.dart';
import 'config/firebase/firestore_operations.dart';
import 'model/user_model.dart';

Future main() async {
  final getIt = GetIt.I;
  CachedNetworkImage.logLevel = CacheManagerLogLevel.debug;
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
    statusBarColor: Colors.transparent,
    statusBarBrightness: Brightness.dark,
    statusBarIconBrightness: Brightness.light,
  ));

  await Firebase.initializeApp();
  getIt.registerSingleton(FirebaseFirestore.instance);
  getIt.registerSingleton(FirebaseAuth.instance);
  getIt.registerSingleton(FirebaseStorage.instance);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      darkTheme: ThemeData.dark(),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
        child: child,
      ),
      home: const Manager(),
    );
  }
}

class Manager extends StatefulWidget {
  const Manager({Key key}) : super(key: key);

  @override
  State<Manager> createState() => _Manager();
}

class _Manager extends State<Manager> with TickerProviderStateMixin {
  UserModel userModelCurrent;
  final auth = GetIt.I<FirebaseAuth>();

  @override
  void initState() {
    readFirebaseIsAccountFull(context).then((user) {
      bool isEmptyImageBackground = false, isEmptyDataUser = false;
      if (user.uid.isNotEmpty) {
        if (user.listInterests.isNotEmpty &&
            user.myCity.isNotEmpty &&
            user.searchPol.isNotEmpty) {
          isEmptyDataUser = true;
          if (user.imageBackground.isNotEmpty) {
            isEmptyImageBackground = true;
            userModelCurrent = user;
          }
        }
      }
      userNavigator(isEmptyDataUser, isEmptyImageBackground);
    });
    super.initState();
  }

  userNavigator(
    bool isEmptyDataUser,
    bool isEmptyImageBackground,
  ) {
    if (auth.currentUser?.uid != null) {
      if (auth.currentUser.emailVerified) {
        if (isEmptyDataUser) {
          if (isEmptyImageBackground) {
            Navigator.pushReplacement(
              context,
              FadeRouteAnimation(
                ManagerScreen(
                  currentIndex: 0,
                  userModelCurrent: userModelCurrent,
                ),
              ),
            );
          } else {
            Navigator.pushReplacement(
              context,
              FadeRouteAnimation(
                EditImageProfileScreen(
                  userModel: UserModel.fromDocument(dataCash),
                  listInterests: const [],
                ),
              ),
            );
          }
        } else {
          Navigator.pushReplacement(
            context,
            FadeRouteAnimation(
              EditProfileScreen(
                isFirst: true,
                userModel: UserModel.fromDocument(dataCash),
              ),
            ),
          );
        }
      } else {
        Navigator.pushReplacement(
            context, FadeRouteAnimation(const VerifyScreen()));
      }
    } else {
      Navigator.pushReplacement(
          context, FadeRouteAnimation(const SignInScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return const loadingCustom();
  }
}
