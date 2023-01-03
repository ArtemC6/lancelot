// @dart=2.9
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lancelot/screens/auth/signin_screen.dart';
import 'package:lancelot/screens/auth/verify_screen.dart';
import 'package:lancelot/screens/manager_screen.dart';
import 'package:lancelot/screens/settings/edit_image_profile_screen.dart';
import 'package:lancelot/screens/settings/edit_profile_screen.dart';
import 'package:lancelot/screens/settings/warning_screen.dart';
import 'package:lancelot/widget/animation_widget.dart';
import 'package:provider/provider.dart';

import 'config/firebase_auth.dart';
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
    return MultiProvider(
      providers: [
        Provider<FirebaseAuthMethods>(
          create: (_) => FirebaseAuthMethods(FirebaseAuth.instance),
        ),
        StreamProvider(
          create: (context) => context.read<FirebaseAuthMethods>().authState,
          initialData: null,
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark(),
        darkTheme: ThemeData.dark(),
        home: const Manager(),
      ),
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
  AnimationController animationController;

  @override
  void initState() {
    animationController = AnimationController(vsync: this);
    super.initState();
    readFirebaseIsAccountFull().then((result) {
      setState(() {
        isEmptyImageBackground = result.isEmptyImageBackground;
        isEmptyDataUser = result.isEmptyDataUser;
        isStart = result.isStart;
        isLoading = true;
      });
    });
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return StreamBuilder<User>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const loadingCustom();
          } else if (snapshot.hasData) {
            if (isStart) {
              if (true) {
              // if (snapshot.data.emailVerified) {
                if (isEmptyDataUser) {
                  if (isEmptyImageBackground) {
                    return ManagerScreen(
                      currentIndex: 0,
                    );
                  } else {
                    return EditImageProfileScreen(
                      bacImage: '',
                    );
                  }
                } else {
                  return EditProfileScreen(
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
                        notification: true),
                  );
                }
              } else {
                return const VerifyScreen();
              }
            } else {
              return const WarningScreen();
            }
          } else {
            return const SignInScreen();
          }
        },
      );
    }

    return const loadingCustom();
  }
}
