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
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'config/firestore_operations.dart';
import 'model/user_model.dart';

void main() async {
  CachedNetworkImage.logLevel = CacheManagerLogLevel.debug;
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const MyApp());

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      darkTheme: ThemeData.dark(),
      builder: (BuildContext context, Widget child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: child,
        );
      },
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
  bool isEmptyImageBackground = false,
      isEmptyDataUser = false,
      isStart = false,
      isLoading = false;
  UserModel userModelCurrent;

  @override
  void initState() {
    super.initState();

    readFirebaseIsAccountFull(context).then((userModel) {
      setState(() {
        if (userModel.uid.isNotEmpty) {
          if (userModel.userInterests.isNotEmpty &&
              userModel.myCity.isNotEmpty &&
              userModel.searchPol.isNotEmpty) {
            isEmptyDataUser = true;
            if (userModel.imageBackground != '') {
              isEmptyImageBackground = true;
              userModelCurrent = userModel;
            }
          }
        }
        isLoading = true;

        userNavigator();
      });
    });
  }

  Future userNavigator() async {
      if (FirebaseAuth.instance.currentUser?.uid != null) {
      if (FirebaseAuth.instance.currentUser.emailVerified) {
        if (isEmptyDataUser) {
          if (isEmptyImageBackground) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => ManagerScreen(
                  currentIndex: 0,
                  userModelCurrent: userModelCurrent,
                ),
              ),
            );
          } else {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => EditImageProfileScreen(
                    bacImage: '',
                  ),
                ),
              );
            }
          } else {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => EditProfileScreen(
                  isFirst: true,
                  userModel: UserModel(
                      name: '',
                      uid: '',
                      myCity: '',
                      ageTime: Timestamp.now(),
                      ageInt: 0,
                    userPol: '',
                    searchPol: '',
                    searchRangeStart: 0,
                    userImageUrl: [],
                    userImagePath: [],
                    imageBackground: '',
                    userInterests: [],
                    searchRangeEnd: 0,
                    state: '',
                    token: '',
                    notification: true,
                    description: ''),
              ),
              ),
            );
          }
        } else {
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const VerifyScreen()));
        }
      } else {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const SignInScreen()));
      }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const loadingCustom();
  }
}
