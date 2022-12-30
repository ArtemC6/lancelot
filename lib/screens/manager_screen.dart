import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lancelot/screens/profile_screen.dart';
import 'package:lancelot/screens/sympathy_screen.dart';
import 'package:lancelot/screens/that_screen.dart';
import 'package:lancelot/screens/that_user_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/const.dart';
import '../config/firestore_operations.dart';
import '../config/notification_api.dart';
import '../config/utils.dart';
import '../model/user_model.dart';
import '../widget/animation_widget.dart';
import 'home_screen.dart';

class ManagerScreen extends StatefulWidget {
  int currentIndex;

  ManagerScreen({super.key, required this.currentIndex});

  @override
  _ManagerScreen createState() => _ManagerScreen(currentIndex);
}

class _ManagerScreen extends State<ManagerScreen> with WidgetsBindingObserver {
  bool isLoading = false, isWrite = true;
  int currentIndex = 0,
      idNotification = 0,
      indexSympathy = 0,
      indexChat = 0,
      indexProfile = 0;

  late UserModel userModelCurrent;

  _ManagerScreen(this.currentIndex);

  void startTimer() {
    Timer.periodic(
      const Duration(seconds: 1),
      (Timer timer) {
        setState(() {
          isWrite = true;
        });
        timer.cancel();
      },
    );
  }

  void setIndexPage(String payload, String uid) {
    setState(() {
      if (payload == 'sympathy') {
        currentIndex = 1;
      }
      if (payload == 'chat') {
        currentIndex = 2;
        if (isLoading) {
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
        } else {
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

      }
      if (payload == 'like') {
        currentIndex = 3;
      }
    });
  }

  // void listenNotification() {
  //   NotificationApi.onNotifications.stream.listen((payload) {
  //     setIndexPage(payload.split(',')[0], payload.split(',')[1]);
  //   });
  // }

  Future<void> getNotificationFcm() async {
    await FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        setIndexPage(message.data['type'], message.data['uid']);
      }
    });

    // NotificationApi.initNotification();
    // listenNotification();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null) {
        setState(() {
          if (message.data['type'] == 'sympathy') {
            indexSympathy++;
          }
          if (message.data['type'] == 'chat') {
            indexChat++;
          }
          if (message.data['type'] == 'like') {
            indexProfile++;
          }
        });

        await setValueSharedPref('indexSympathy', indexSympathy);
        await setValueSharedPref('indexChat', indexChat);
        await setValueSharedPref('indexProfile', indexProfile);

        // NotificationApi.showNotification(
        //   id: idNotification++,
        //   title: notification.title.toString(),
        //   body: notification.body.toString(),
        //   payload: '${message.data['type']},${message.data['uid']}',
        //   uri: message.data['uri'],
        // );
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
    initSharedPref();
    WidgetsBinding.instance.addObserver(this);
    getNotificationFcm();
    readUserFirebase().then((user) {
      setState(() {
        userModelCurrent = UserModel(
            name: user.name,
            uid: user.uid,
            ageTime: user.ageTime,
            userPol: user.userPol,
            searchPol: user.searchPol,
            searchRangeStart: user.searchRangeStart,
            userInterests: user.userInterests,
            userImagePath: user.userImagePath,
            userImageUrl: user.userImageUrl,
            searchRangeEnd: user.searchRangeEnd,
            myCity: user.myCity,
            imageBackground: user.imageBackground,
            ageInt: user.ageInt,
            state: user.state,
            token: user.token,
            notification: user.notification);
      });
      isLoading = true;
      setStateFirebase('online');
    });

    super.initState();
  }

  Future<void> initSharedPref() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      indexSympathy = prefs.getInt('indexSympathy') ?? 0;
      indexChat = prefs.getInt('indexChat') ?? 0;
      indexProfile = prefs.getInt('indexProfile') ?? 0;
    });
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
        if (isWrite) {
          startTimer();
          isWrite = false;
          print('of');
          setStateFirebase('offline');
        }
        break;
      case AppLifecycleState.resumed:
        if (isWrite) {
          startTimer();
          isWrite = false;
          print('on');
          setStateFirebase('online');
        }
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.detached:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    SizedBox bottomNavigationBar(Size size) {
      return SizedBox(
        height: size.width * .150,
        child: ListView.builder(
          itemCount: 4,
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: size.width * .024),
          itemBuilder: (context, index) => InkWell(
            onTap: () {
              Future.delayed(const Duration(milliseconds: 20), () {
                setState(() {
                  currentIndex = index;
                });
              });
            },
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(height: size.width * .014),
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Icon(listOfIcons[index],
                        size: size.width * .076, color: Colors.white),
                    if (index == 1 && currentIndex != 1)
                      if (indexSympathy > 0)
                        showAnimationBottomNotification(indexSympathy),
                    if (index == 2 && currentIndex != 2)
                      if (indexChat > 0)
                        showAnimationBottomNotification(indexChat),
                    if (index == 3 && currentIndex != 3)
                      if (indexProfile > 0)
                        showAnimationBottomNotification(indexProfile),
                  ],
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 1500),
                  curve: Curves.fastLinearToSlowEaseIn,
                  margin: EdgeInsets.only(
                    top: index == currentIndex ? 0 : size.width * .029,
                    right: size.width * .0422,
                    left: size.width * .0422,
                  ),
                  width: size.width * .153,
                  height: index == currentIndex ? size.width * .014 : 0,
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
          setState(() => indexSympathy = 0);
          setValueSharedPref('indexSympathy', indexSympathy);
          break;
        case 2:
          child = ChatScreen(
            userModelCurrent: userModelCurrent,
          );
          setState(() => indexChat = 0);
          setValueSharedPref('indexChat', indexChat);
          break;
        case 3:
          child = ProfileScreen(
            userModelPartner: userModelCurrent,
            isBack: false,
            idUser: '',
            userModelCurrent: userModelCurrent,
          );
          setState(() => indexProfile = 0);
          setValueSharedPref('indexProfile', indexProfile);
          break;
      }
      return child;
    }

    if (isLoading) {
      return Scaffold(
          backgroundColor: color_black_88,
          bottomNavigationBar: bottomNavigationBar(size),
          body: SizedBox.expand(child: childEmployee()));
    }

    return const loadingCustom();
  }

  SlideFadeTransition showAnimationBottomNotification(int indexNotification) {
    return SlideFadeTransition(
      animationDuration: const Duration(milliseconds: 750),
      child: Container(
        alignment: Alignment.center,
        width: 15,
        height: 15,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            color: Colors.deepPurpleAccent),
        child:
            animatedText(9.0, indexNotification.toString(), Colors.white, 0, 1),
      ),
    );
  }
}
