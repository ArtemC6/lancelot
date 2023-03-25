import 'dart:async';

import 'package:Lancelot/screens/profile_screen.dart';
import 'package:Lancelot/screens/sympathy_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/const.dart';
import '../config/firebase/firestore_operations.dart';
import '../config/utils.dart';
import '../model/user_model.dart';
import '../widget/animation_widget.dart';
import '../widget/component_widget.dart';
import 'chat_screen.dart';
import 'chat_user_screen.dart';
import 'home_screen.dart';

class ManagerScreen extends StatefulWidget {
  final int currentIndex;
  final UserModel userModelCurrent;

  const ManagerScreen(
      {super.key, required this.currentIndex, required this.userModelCurrent});

  @override
  _ManagerScreen createState() =>
      _ManagerScreen(currentIndex, userModelCurrent);
}

class _ManagerScreen extends State<ManagerScreen> with WidgetsBindingObserver {
  bool isLoading = false, isWrite = true;
  int currentIndex = 0,
      idNotification = 0,
      indexSympathy = 0,
      indexChat = 0,
      indexProfile = 0;

  UserModel userModelCurrent;

  _ManagerScreen(this.currentIndex, this.userModelCurrent);

  void startTimer() {
    Timer.periodic(
      const Duration(seconds: 1),
      (Timer timer) {
        setState(() => isWrite = true);
        timer.cancel();
      },
    );
  }

  setIndexPage(String payload, String uid) {
    if (payload == 'sympathy') currentIndex = 1;
    if (payload == 'like') currentIndex = 3;

    if (payload == 'chat') {
      currentIndex = 2;
      if (!isLoading) return;
      Future.delayed(const Duration(milliseconds: 300), () {
        Navigator.push(
          context,
          FadeRouteAnimation(
            ChatUserScreen(
              friendId: uid,
              friendName: '',
              friendImage: '',
              userModelCurrent: userModelCurrent,
              token: '',
              notification: true,
            ),
          ),
        );
      });
    }

    setState(() {});
  }

  Future<void> getNotificationFcm() async {
    clearAllNotification();
    await FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message == null) return;
      setIndexPage(message.data['type'], message.data['uid']);
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null) {
        if (message.data['type'] == 'sympathy') indexSympathy++;
        if (message.data['type'] == 'chat') indexChat++;
        if (message.data['type'] == 'like') indexProfile++;

        setState(() {});
        await setValueSharedPref('indexSympathy', indexSympathy);
        await setValueSharedPref('indexChat', indexChat);
        await setValueSharedPref('indexProfile', indexProfile);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null) {
        setIndexPage(message.data['type'], message.data['uid']);
      }
    });
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    initSharedPref();
    getNotificationFcm();
    readUser();
    super.initState();
  }

  Future readUser() async {
    if (userModelCurrent.uid.isEmpty) {
      await readUserFirebase().then((user) => userModelCurrent = user);
    }

    setStateFirebase('online');
    setState(() => isLoading = true);
  }

  Future<void> initSharedPref() async {
    final prefs = await SharedPreferences.getInstance();
    indexSympathy = prefs.getInt('indexSympathy') ?? 0;
    indexChat = prefs.getInt('indexChat') ?? 0;
    indexProfile = prefs.getInt('indexProfile') ?? 0;
    setState(() {});
  }

  @override
  void dispose() {
    WidgetsBinding.instance.addObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.paused:
        if (!isWrite) return;
        startTimer();
        isWrite = false;
        setStateFirebase('offline');
        break;
      case AppLifecycleState.resumed:
        if (!isWrite) return;
        startTimer();
        isWrite = false;
        setStateFirebase('online');
        break;
      case AppLifecycleState.inactive:
        if (!isWrite) return;
        startTimer();
        isWrite = false;
        setStateFirebase('offline');
        break;
      case AppLifecycleState.detached:
        if (!isWrite) return;
        startTimer();
        isWrite = false;
        setStateFirebase('offline');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    SizedBox bottomNavigationBar() {
      return SizedBox(
        height: width * .150,
        child: ListView.builder(
          itemCount: 4,
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: width * .024),
          itemBuilder: (context, index) => InkWell(
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            onTap: () => Future.delayed(const Duration(milliseconds: 40),
                () => setState(() => currentIndex = index)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(height: width * .014),
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Icon(listOfIcons[index],
                        size: width * .076, color: Colors.white),
                    if (index == 1 && currentIndex != 1)
                      if (indexSympathy > 0)
                        showAnimationBottomNotification(
                            indexNotification: indexSympathy),
                    if (index == 2 && currentIndex != 2)
                      if (indexChat > 0)
                        showAnimationBottomNotification(
                            indexNotification: indexChat),
                    if (index == 3 && currentIndex != 3)
                      if (indexProfile > 0)
                        showAnimationBottomNotification(
                            indexNotification: indexProfile),
                  ],
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 1500),
                  curve: Curves.fastLinearToSlowEaseIn,
                  margin: EdgeInsets.only(
                    top: index == currentIndex ? 0 : width * .029,
                    right: width * .0422,
                    left: width * .0422,
                  ),
                  width: width * .153,
                  height: index == currentIndex ? width * .014 : 0,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    Widget childEmployee() {
      var child;
      switch (currentIndex) {
        case 0:
          child = HomeScreen(
            userModelCurrent: userModelCurrent,
          );
          break;
        case 1:
          child = SympathyScreen(
            userModelCurrent: userModelCurrent,
          );
          setValueSharedPref('indexSympathy', indexSympathy);
          setState(() => indexSympathy = 0);
          break;
        case 2:
          child = ChatScreen(
            userModelCurrent: userModelCurrent,
          );
          setValueSharedPref('indexChat', indexChat);
          setState(() => indexChat = 0);
          break;
        case 3:
          child = ProfileScreen(
            userModelPartner: userModelCurrent,
            isBack: false,
            idUser: '',
            userModelCurrent: userModelCurrent,
          );
          setValueSharedPref('indexProfile', indexProfile);
          setState(() => indexProfile = 0);
          break;
      }
      return child;
    }

    if (isLoading) {
      return Scaffold(
          backgroundColor: color_black_88,
          bottomNavigationBar: bottomNavigationBar(),
          body: SafeArea(
            top: false,
              child: SizedBox.expand(child: childEmployee())));
    }

    return const loadingCustom();
  }

}
