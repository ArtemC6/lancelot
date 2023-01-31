import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lancelot/config/utils.dart';
import 'package:path/path.dart' as path;

import '../model/user_model.dart';
import '../screens/manager_screen.dart';
import '../screens/settings/edit_profile_screen.dart';
import '../screens/settings/warning_screen.dart';
import '../widget/dialog_widget.dart';
import 'const.dart';

Future<CroppedFile?> _cropImage(
    BuildContext context, XFile pickedImage, int compressQuality) async {
  CroppedFile? _croppedFile;

  final croppedFile = await ImageCropper().cropImage(
    sourcePath: pickedImage.path,
    compressFormat: ImageCompressFormat.jpg,
    compressQuality: compressQuality,
    uiSettings: [
      AndroidUiSettings(
        toolbarTitle: 'Обрезать',
        toolbarColor: Colors.black,
        toolbarWidgetColor: Colors.white,
        initAspectRatio: CropAspectRatioPreset.original,
        lockAspectRatio: false,
        activeControlsWidgetColor: Colors.blueAccent,
      ),
      IOSUiSettings(
        title: 'Обрезать',
      ),
      WebUiSettings(
        context: context,
        presentStyle: CropperPresentStyle.dialog,
        boundary: const CroppieBoundary(
          width: 520,
          height: 520,
        ),
        viewPort:
            const CroppieViewPort(width: 480, height: 480, type: 'circle'),
        enableExif: true,
        enableZoom: true,
        showZoomer: true,
      ),
    ],
  );

  if (croppedFile != null) {
    _croppedFile = croppedFile;
  }
  return _croppedFile;
}

Future<String> uploadFirstImage(BuildContext context, List<String> userImageUrl,
    List<String> userImagePath) async {
  String uri = '';
  FirebaseStorage storage = FirebaseStorage.instance;
  try {
    final pickedImage = await ImagePicker().pickImage(
        source: ImageSource.gallery, imageQuality: 38, maxWidth: 1920);
    if (pickedImage != null) {
      await _cropImage(context, pickedImage, 38).then((croppedFile) async {
        if (croppedFile != null) {
          final String fileName = path.basename(croppedFile.path);
          File imageFile = File(croppedFile.path);

          var task = storage.ref(fileName).putFile(imageFile);

          if (task == null) return '';
          showAlertDialogLoading(context);

          final snapshot = await task.whenComplete(() {});
          final urlDownload = await snapshot.ref.getDownloadURL();

          userImagePath.add(fileName);
          userImageUrl.add(urlDownload);

          final docUser = FirebaseFirestore.instance
              .collection('User')
              .doc(FirebaseAuth.instance.currentUser?.uid);

          final json = {
            'listImageUri': userImageUrl,
            'listImagePath': userImagePath
          };

          await docUser.update(json).then((value) {
            uri = urlDownload;
          });
        }
      });
    }
  } catch (err) {}

  return uri;
}

Future<void> uploadImageAdd(
    BuildContext context, UserModel userModelCurrent) async {
  FirebaseStorage storage = FirebaseStorage.instance;
  final picker = ImagePicker();

  try {
    final pickedImage = await picker.pickImage(
        source: ImageSource.gallery, imageQuality: 28, maxWidth: 1920);
    if (pickedImage != null) {
      await _cropImage(context, pickedImage, 28).then((croppedFile) async {
        if (croppedFile != null) {
          final String fileName = path.basename(croppedFile.path);
          File imageFile = File(croppedFile.path);
          try {
            var task = storage.ref(fileName).putFile(imageFile);

            if (task == null) return;
            showAlertDialogLoading(context);

            final snapshot = await task.whenComplete(() {});
            final urlDownload = await snapshot.ref.getDownloadURL();

            userModelCurrent.userImageUrl.add(urlDownload);
            userModelCurrent.userImagePath.add(fileName);

            final docUser = FirebaseFirestore.instance
                .collection('User')
                .doc(FirebaseAuth.instance.currentUser?.uid);

            final json = {
              'listImageUri': userModelCurrent.userImageUrl,
              'listImagePath': userModelCurrent.userImagePath
            };

            docUser.update(json).then((value) {
              Navigator.pushReplacement(
                  context,
                  FadeRouteAnimation(ManagerScreen(
                      currentIndex: 3,
                      userModelCurrent: UserModel(
                          name: '',
                          uid: '',
                          state: '',
                          myCity: '',
                          ageInt: 0,
                          ageTime: Timestamp.now(),
                          userPol: '',
                          searchPol: '',
                          searchRangeStart: 0,
                          userImageUrl: [],
                          userImagePath: [],
                          imageBackground: '',
                          userInterests: [],
                          searchRangeEnd: 0,
                          token: '',
                          notification: true,
                          description: ''))));
            });
          } on FirebaseException {
            Navigator.pop(context);
          }
        }
      });
    }
  } catch (err) {}
}

Future<String> updateFirstImage(
    BuildContext context, UserModel userModelCurrent, bool isScreen) async {
  List<String> listImageUri = [], listImagePath = [];
  String uri = '';
  FirebaseStorage storage = FirebaseStorage.instance;
  final picker = ImagePicker();
  try {
    final pickedImage = await picker.pickImage(
        source: ImageSource.gallery, imageQuality: 38, maxWidth: 1920);
    if (pickedImage != null) {
      await _cropImage(context, pickedImage, 38).then((croppedFile) async {
        if (croppedFile != null) {
          final String fileName = path.basename(croppedFile.path);
          File imageFile = File(croppedFile.path);

          try {
            var task = storage.ref(fileName).putFile(imageFile);
            if (task == null) return;

            showAlertDialogLoading(context);

            final snapshot = await task.whenComplete(() {});
            final urlDownload = await snapshot.ref.getDownloadURL();

            CachedNetworkImage.evictFromCache(userModelCurrent.userImageUrl[0]);

            await storage.ref(userModelCurrent.userImagePath[0]).delete();

            userModelCurrent.userImageUrl.removeAt(0);
            userModelCurrent.userImagePath.removeAt(0);

            listImagePath.add(fileName);
            listImageUri.add(urlDownload);

            listImagePath.addAll(userModelCurrent.userImagePath);
            listImageUri.addAll(userModelCurrent.userImageUrl);

            final docUser = FirebaseFirestore.instance
                .collection('User')
                .doc(userModelCurrent.uid);

            final json = {
              'listImageUri': listImageUri,
              'listImagePath': listImagePath
            };

            docUser.update(json).then((value) {
              Navigator.pop(context);
              if (isScreen) {
                Navigator.pushReplacement(
                    context,
                    FadeRouteAnimation(EditProfileScreen(
                      isFirst: false,
                      userModel: UserModel(
                          name: '',
                          uid: '',
                          myCity: '',
                          ageTime: Timestamp.now(),
                          userPol: '',
                          searchPol: '',
                          searchRangeStart: 0,
                          userImageUrl: [],
                          userImagePath: [],
                          imageBackground: '',
                          userInterests: [],
                          searchRangeEnd: 0,
                          ageInt: 0,
                          state: '',
                          token: '',
                          notification: true,
                          description: ''),
                    )));
              } else {
                Navigator.pushReplacement(
                    context,
                    FadeRouteAnimation(ManagerScreen(
                      currentIndex: 3,
                      userModelCurrent: UserModel(
                          name: '',
                          uid: '',
                          state: '',
                          myCity: '',
                          ageInt: 0,
                          ageTime: Timestamp.now(),
                          userPol: '',
                          searchPol: '',
                          searchRangeStart: 0,
                          userImageUrl: [],
                          userImagePath: [],
                          imageBackground: '',
                          userInterests: [],
                          searchRangeEnd: 0,
                          token: '',
                          notification: true,
                          description: ''),
                    )));
              }
            });
          } on FirebaseException {
            Navigator.pop(context);
          }
        }
      });
    }
  } catch (err) {}
  return uri;
}

Future<void> createSympathy(
    String idPartner, UserModel userModelCurrent) async {
  try {
    FirebaseFirestore.instance
        .collection('User')
        .doc(idPartner)
        .collection('sympathy')
        .where('uid', isEqualTo: userModelCurrent.uid)
        .get()
        .then((querySnapshot) {
      final docUser = FirebaseFirestore.instance
          .collection("User")
          .doc(idPartner)
          .collection('sympathy')
          .doc();
      docUser.set({
        'id_doc': docUser.id,
        'uid': userModelCurrent.uid,
        'time': DateTime.now(),
      });
    });
  } on FirebaseException {}
}

Future<void> deleteSympathy(String idDoc, idUser) async {
  try {
    final docUser = FirebaseFirestore.instance
        .collection("User")
        .doc(idUser)
        .collection('sympathy');
    docUser.doc(idDoc).delete().then((value) {});
  } on FirebaseException {}
}

Future<void> deleteSympathyPartner(String idPartner, String idUser) async {
  FirebaseFirestore.instance
      .collection('User')
      .doc(idPartner)
      .collection('sympathy')
      .where('uid', isEqualTo: idUser)
      .get()
      .then((querySnapshot) {
    for (var result in querySnapshot.docs) {
      Map<String, dynamic> data = result.data();
      final docUser = FirebaseFirestore.instance
          .collection("User")
          .doc(idPartner)
          .collection('sympathy');
      docUser.doc(data['id_doc']).delete().then((value) {});
    }
  });
}

Future<void> imageRemove(
    int index, BuildContext context, UserModel userModelCurrent) async {
  FirebaseStorage storage = FirebaseStorage.instance;
  try {
    try {
      showAlertDialogLoading(context);
      await storage.ref(userModelCurrent.userImagePath[index]).delete();

      CachedNetworkImage.evictFromCache(userModelCurrent.userImageUrl[index]);

      userModelCurrent.userImageUrl.removeAt(index);
      userModelCurrent.userImagePath.removeAt(index);

      final docUser = FirebaseFirestore.instance
          .collection('User')
          .doc(userModelCurrent.uid);

      final json = {
        'listImageUri': userModelCurrent.userImageUrl,
        'listImagePath': userModelCurrent.userImagePath
      };

      docUser.update(json).then((value) {
        Navigator.pushReplacement(
            context,
            FadeRouteAnimation(ManagerScreen(
              currentIndex: 3,
              userModelCurrent: UserModel(
                  name: '',
                  uid: '',
                  state: '',
                  myCity: '',
                  ageInt: 0,
                  ageTime: Timestamp.now(),
                  userPol: '',
                  searchPol: '',
                  searchRangeStart: 0,
                  userImageUrl: [],
                  userImagePath: [],
                  imageBackground: '',
                  userInterests: [],
                  searchRangeEnd: 0,
                  token: '',
                  notification: true,
                  description: ''),
            )));
      });
    } on FirebaseException {
      Navigator.pop(context);
    }
  } catch (err) {}
}

Future<void> setStateFirebase(String state, [String? uid]) async {
  try {
    final docUser = FirebaseFirestore.instance
        .collection('User')
        .doc(uid ?? FirebaseAuth.instance.currentUser?.uid);

    final json = {
      'state': state,
      if (state == 'offline') 'lastDateOnline': DateTime.now(),
    };
    await docUser.update(json);
  } on FirebaseException {}
}

Future<void> deleteUserTokenFirebase(String uid) async {
  try {
    final docUser = FirebaseFirestore.instance.collection('User').doc(uid);
    final json = {
      'token': '',
    };
    await docUser.update(json);
  } on FirebaseException {}
}

Future<void> setTokenUserFirebase() async {
  try {
    await FirebaseMessaging.instance.getToken().then((token) async {
      final docUser = FirebaseFirestore.instance
          .collection('User')
          .doc(FirebaseAuth.instance.currentUser?.uid);
      final json = {
        'token': token,
      };
      await docUser.update(json);
    });
  } on FirebaseException {}
}

Future deleteChatFirebase(bool isDeletePartner, String friendId, bool isBack,
    BuildContext context, String friendUri) async {
  CachedNetworkImage.evictFromCache(friendUri);
  if (isDeletePartner) {
    if (isBack) {
      Navigator.pop(context);
    }
    Navigator.push(
        context,
        FadeRouteAnimation(ManagerScreen(
          currentIndex: 2,
          userModelCurrent: UserModel(
              name: '',
              uid: '',
              state: '',
              myCity: '',
              ageInt: 0,
              ageTime: Timestamp.now(),
              userPol: '',
              searchPol: '',
              searchRangeStart: 0,
              userImageUrl: [],
              userImagePath: [],
              imageBackground: '',
              userInterests: [],
              searchRangeEnd: 0,
              token: '',
              notification: true,
              description: ''),
        )));

    FirebaseFirestore.instance
        .collection('User')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .collection('messages')
        .doc(friendId)
        .delete();

    var collection = FirebaseFirestore.instance
        .collection('User')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .collection('messages')
        .doc(friendId)
        .collection('chats');
    var snapshots = await collection.get();
    for (var doc in snapshots.docs) {
      await doc.reference.delete();
    }

    FirebaseFirestore.instance
        .collection('User')
        .doc(friendId)
        .collection('messages')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .delete();
    var collectionFriend = FirebaseFirestore.instance
        .collection('User')
        .doc(friendId)
        .collection('messages')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .collection('chats');

    var snapshotsFriend = await collectionFriend.get();

    for (var doc in snapshotsFriend.docs) {
      await doc.reference.delete();
    }
  } else {
    if (isBack) {
      Navigator.pop(context);
    }
    Navigator.push(
        context,
        FadeRouteAnimation(ManagerScreen(
          currentIndex: 2,
          userModelCurrent: UserModel(
              name: '',
              uid: '',
              state: '',
              myCity: '',
              ageInt: 0,
              ageTime: Timestamp.now(),
              userPol: '',
              searchPol: '',
              searchRangeStart: 0,
              userImageUrl: [],
              userImagePath: [],
              imageBackground: '',
              userInterests: [],
              searchRangeEnd: 0,
              token: '',
              notification: true,
              description: ''),
        )));
    FirebaseFirestore.instance
        .collection('User')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .collection('messages')
        .doc(friendId)
        .delete()
        .then((value) async {
      var collection = FirebaseFirestore.instance
          .collection('User')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .collection('messages')
          .doc(friendId)
          .collection('chats');
      var snapshots = await collection.get();
      for (var doc in snapshots.docs) {
        await doc.reference.delete();
      }
    });
  }
}

Future<void> uploadImagePhotoProfile(String uri, BuildContext context) async {
  try {
    final docUser = FirebaseFirestore.instance
        .collection('User')
        .doc(FirebaseAuth.instance.currentUser?.uid);

    final json = {
      'imageBackground': uri,
    };

    docUser.update(json).then((value) {
      Navigator.pushReplacement(
          context,
          FadeRouteAnimation(
            ManagerScreen(
              currentIndex: 3,
              userModelCurrent: UserModel(
                  name: '',
                  uid: '',
                  state: '',
                  myCity: '',
                  ageInt: 0,
                  ageTime: Timestamp.now(),
                  userPol: '',
                  searchPol: '',
                  searchRangeStart: 0,
                  userImageUrl: [],
                  userImagePath: [],
                  imageBackground: '',
                  userInterests: [],
                  searchRangeEnd: 0,
                  token: '',
                  notification: true,
                  description: ''),
            ),
          ));
    });
  } on FirebaseException {}
}

Future<UserModel> readUserFirebase([String? idUser]) async {
  UserModel userModel = UserModel(
      name: '',
      uid: '',
      state: '',
      myCity: '',
      ageInt: 0,
      ageTime: Timestamp.now(),
      userPol: '',
      searchPol: '',
      searchRangeStart: 0,
      userImageUrl: [],
      userImagePath: [],
      imageBackground: '',
      userInterests: [],
      searchRangeEnd: 0,
      token: '',
      notification: true,
      description: '');
  try {
    DocumentSnapshot<Map<String, dynamic>> query;
    try {
      query = await FirebaseFirestore.instance
          .collection('User')
          .doc(idUser ?? FirebaseAuth.instance.currentUser?.uid)
          .get(const GetOptions(source: Source.cache));

      if (query == null) {
        query = await FirebaseFirestore.instance
            .collection('User')
            .doc(idUser ?? FirebaseAuth.instance.currentUser?.uid)
            .get(const GetOptions(source: Source.server));
      }
    } on FirebaseException {
      query = await FirebaseFirestore.instance
          .collection('User')
          .doc(idUser ?? FirebaseAuth.instance.currentUser?.uid)
          .get(const GetOptions(source: Source.server));
    }

    if (!query.metadata.isFromCache) {
      query = await FirebaseFirestore.instance
          .collection('User')
          .doc(idUser ?? FirebaseAuth.instance.currentUser?.uid)
          .get(const GetOptions(source: Source.server));
    }

    Map<String, dynamic> dataCash = query.data() as Map<String, dynamic>;

    try {
      if (dataCash['myPol'] == null ||
          dataCash['myCity'] == null ||
          dataCash['searchPol'] == null ||
          dataCash['rangeStart'] == null ||
          dataCash['rangeEnd'] == null ||
          dataCash['ageTime'] == null ||
          dataCash['description'] == null ||
          dataCash['notification'] == null ||
          dataCash['imageBackground'] == null ||
          dataCash['state'] == null ||
          dataCash['token'] == null ||
          dataCash['listInterests'] == null) {
        query = await FirebaseFirestore.instance
            .collection('User')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .get(const GetOptions(source: Source.server));
      }
    } on FirebaseException {
      query = await FirebaseFirestore.instance
          .collection('User')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get(const GetOptions(source: Source.server));
    }

    Map<String, dynamic> data = query.data() as Map<String, dynamic>;

    userModel = UserModel(
        name: data['name'],
        uid: data['uid'],
        ageTime: data['ageTime'],
        userPol: data['myPol'],
        searchPol: data['searchPol'],
        searchRangeStart: data['rangeStart'],
        userInterests: List<String>.from(data['listInterests']),
        userImagePath: List<String>.from(data['listImagePath']),
        userImageUrl: List<String>.from(data['listImageUri']),
        searchRangeEnd: data['rangeEnd'],
        myCity: data['myCity'],
        imageBackground: data['imageBackground'],
        ageInt: ageInt(data),
        state: data['state'],
        token: data['token'],
        notification: data['notification'],
        description: data['description']);
  } on FirebaseException {}
  return userModel;
}

Future<List<String>> readDislikeFirebase(String idUser) async {
  List<String> listDislike = [];
  QuerySnapshot<Map<String, dynamic>> query;
  try {
    query = await FirebaseFirestore.instance
        .collection('User')
        .doc(idUser)
        .collection('dislike')
        .get(const GetOptions(source: Source.cache));
    if (query == null) {
      query = await FirebaseFirestore.instance
          .collection('User')
          .doc(idUser)
          .collection('dislike')
          .get(const GetOptions(source: Source.server));
    }
  } on FirebaseException {
    query = await FirebaseFirestore.instance
        .collection('User')
        .doc(idUser)
        .collection('dislike')
        .get(const GetOptions(source: Source.server));
  }

  if (query.size == 0 && query.docs.isEmpty) {
    query = await FirebaseFirestore.instance
        .collection('User')
        .doc(idUser)
        .collection('dislike')
        .get(const GetOptions(source: Source.server));
  }

  for (var result in query.docs) {
    listDislike.add(result.id);
  }

  return listDislike;
}

Future<List<String>> readLikeFirebase(String idUser) async {
  List<String> listDislike = [];
  try {
    await FirebaseFirestore.instance
        .collection('User')
        .doc(idUser)
        .collection('likes')
        .get()
        .then((querySnapshot) {
      for (var result in querySnapshot.docs) {
        listDislike.add(result.id);
      }
    });
  } on FirebaseException {}
  return listDislike;
}

Future deleteDislike(String idUser) async {
  try {
    var collection = FirebaseFirestore.instance
        .collection('User')
        .doc(idUser)
        .collection('dislike');
    var snapshots = await collection.get();
    for (var doc in snapshots.docs) {
      doc.reference.delete();
    }
  } on FirebaseException {}
}

Future deleteMessageFirebase(
    String myId,
    String friendId,
    String deleteMessageIdMy,
    bool isDeletePartner,
    String deleteMessageIdPartner,
    bool isLastMessage,
    AsyncSnapshot snapshotMy,
    int index) async {
  try {
    if (isLastMessage) {
      FirebaseFirestore.instance
          .collection('User')
          .doc(myId)
          .collection('messages')
          .doc(friendId)
          .update({
        "last_msg": snapshotMy.data.docs[index]['message'],
        'date': snapshotMy.data.docs[index]['date'],
        'last_date_open_chat': DateTime.now(),
      });

      if (isDeletePartner) {
        FirebaseFirestore.instance
            .collection('User')
            .doc(friendId)
            .collection('messages')
            .doc(myId)
            .update({
          "last_msg": snapshotMy.data.docs[index]['message'],
          'date': snapshotMy.data.docs[index]['date'],
          'last_date_open_chat': DateTime.now(),
        });
      }
    }

    FirebaseFirestore.instance
        .collection('User')
        .doc(myId)
        .collection('messages')
        .doc(friendId)
        .collection('chats')
        .doc(deleteMessageIdMy)
        .delete();

    if (isDeletePartner) {
      FirebaseFirestore.instance
          .collection('User')
          .doc(friendId)
          .collection('messages')
          .doc(myId)
          .collection('chats')
          .doc(deleteMessageIdPartner)
          .delete();
    }
  } on FirebaseException {}
}

Future<bool> putLike(
    UserModel userModelCurrent, UserModel userModel, bool isLikeOnTap) async {
  bool isLike = false;
  try {
    QuerySnapshot<Map<String, dynamic>> query;
    try {
      query = await FirebaseFirestore.instance
          .collection('User')
          .doc(userModel.uid)
          .collection('likes')
          .get(const GetOptions(source: Source.cache));

      if (query == null) {
        query = await FirebaseFirestore.instance
            .collection('User')
            .doc(userModel.uid)
            .collection('likes')
            .get(const GetOptions(source: Source.server));
      }
    } on FirebaseException {
      query = await FirebaseFirestore.instance
          .collection('User')
          .doc(userModel.uid)
          .collection('likes')
          .get(const GetOptions(source: Source.server));
    }

    if (query.size == 0 && query.docs.isEmpty) {
      query = await FirebaseFirestore.instance
          .collection('User')
          .doc(userModel.uid)
          .collection('likes')
          .get(const GetOptions(source: Source.server));
    }

    for (var result in query.docs) {
      if (userModelCurrent.uid == result.id) {
        isLike = true;
      }
    }

    if (isLikeOnTap) {
      if (!isLike) {
        FirebaseFirestore.instance
            .collection("User")
            .doc(userModel.uid)
            .collection('likes')
            .doc(userModelCurrent.uid)
            .set({});

        if (userModelCurrent.uid != userModel.uid &&
            userModel.notification &&
            userModel.token != '') {
          sendFcmMessage(
              'Lancelot',
              '${userModelCurrent.name}: нравится вашь профиль',
              userModel.token,
              'like');
        }
      } else {
        FirebaseFirestore.instance
            .collection("User")
            .doc(userModel.uid)
            .collection('likes')
            .doc(userModelCurrent.uid)
            .delete();
      }
    }
  } on FirebaseException {}

  return Future.value(!isLike);
}

Future<Map> readInterestsFirebase() async {
  Map mapInterests = {};
  QuerySnapshot<Map<String, dynamic>> query;
  try {
    query = await FirebaseFirestore.instance
        .collection('ImageInterests')
        .get(const GetOptions(source: Source.cache));

    if (query == null) {
      query = await FirebaseFirestore.instance
          .collection('ImageInterests')
          .get(const GetOptions(source: Source.server));
    }
  } on FirebaseException {
    query = await FirebaseFirestore.instance
        .collection('ImageInterests')
        .get(const GetOptions(source: Source.server));
  }

  if (query.size == 0) {
    query = await FirebaseFirestore.instance
        .collection('ImageInterests')
        .get(const GetOptions(source: Source.server));
  }

  for (var document in query.docs) {
    Map<String, dynamic> data = document.data();
    mapInterests = data['Interests'];
  }

  return mapInterests;
}

Future<UserModel> readFirebaseIsAccountFull(BuildContext context) async {
  UserModel userModelCurrent = UserModel(
      name: '',
      uid: '',
      state: '',
      myCity: '',
      ageInt: 0,
      ageTime: Timestamp.now(),
      userPol: '',
      searchPol: '',
      searchRangeStart: 0,
      userImageUrl: [],
      userImagePath: [],
      imageBackground: '',
      userInterests: [],
      searchRangeEnd: 0,
      token: '',
      notification: true,
      description: '');

  try {
    if (FirebaseAuth.instance.currentUser?.uid != null) {
      DocumentSnapshot<Map<String, dynamic>> queryUser;

      try {
        queryUser = await FirebaseFirestore.instance
            .collection('User')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .get(const GetOptions(source: Source.cache));

        if (queryUser == null) {
          queryUser = await FirebaseFirestore.instance
              .collection('User')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .get(const GetOptions(source: Source.server));
        }
      } on FirebaseException {
        queryUser = await FirebaseFirestore.instance
            .collection('User')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .get(const GetOptions(source: Source.server));
      }

      Map<String, dynamic> dataCash = queryUser.data() as Map<String, dynamic>;

      try {
        if (dataCash['myPol'] == null ||
            dataCash['myCity'] == null ||
            dataCash['searchPol'] == null ||
            dataCash['rangeStart'] == null ||
            dataCash['rangeEnd'] == null ||
            dataCash['ageTime'] == null ||
            dataCash['description'] == null ||
            dataCash['notification'] == null ||
            dataCash['imageBackground'] == null ||
            dataCash['state'] == null ||
            dataCash['token'] == null ||
            dataCash['listInterests'] == null) {
          queryUser = await FirebaseFirestore.instance
              .collection('User')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .get(const GetOptions(source: Source.server));
        }
      } on FirebaseException {
        queryUser = await FirebaseFirestore.instance
            .collection('User')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .get(const GetOptions(source: Source.server));
      }

      Map<String, dynamic> data = queryUser.data() as Map<String, dynamic>;

      if (data['myPol'] != '' &&
          data['myCity'] != '' &&
          data['searchPol'] != '' &&
          data['rangeStart'] != '' &&
          data['rangeEnd'] != '' &&
          data['ageTime'] != '' &&
          data['listInterests'] != '' &&
          List<String>.from(data['listImageUri']).isNotEmpty &&
          List<String>.from(data['listImageUri']).isNotEmpty) {
        userModelCurrent = UserModel(
            name: data['name'],
            uid: data['uid'],
            ageTime: data['ageTime'],
            userPol: data['myPol'],
            searchPol: data['searchPol'],
            searchRangeStart: data['rangeStart'],
            userInterests: List<String>.from(data['listInterests']),
            userImagePath: List<String>.from(data['listImagePath']),
            userImageUrl: List<String>.from(data['listImageUri']),
            searchRangeEnd: data['rangeEnd'],
            myCity: data['myCity'],
            imageBackground: data['imageBackground'],
            ageInt: ageInt(data),
            state: data['state'],
            token: data['token'],
            notification: data['notification'],
            description: data['description']);
      }
    } else {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const WarningScreen()));
    }
  } on FirebaseException {
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const WarningScreen()));
  }

  return userModelCurrent;
}

Future putUserWrites(
  String currentId,
  String friendId,
) async {
  try {
    FirebaseFirestore.instance
        .collection("User")
        .doc(friendId)
        .collection('messages')
        .doc(currentId)
        .update({'writeLastData': DateTime.now()});
  } on FirebaseException {}
}

Future createDisLike(UserModel userModelCurrent, UserModel userModel) async {
  try {
    FirebaseFirestore.instance
        .collection("User")
        .doc(userModelCurrent.uid)
        .collection('dislike')
        .doc(userModel.uid)
        .set({});
  } on FirebaseException {}
}

Future createLastOpenChat(String uid, String friendId) async {
  try {
    FirebaseFirestore.instance
        .collection('User')
        .doc(friendId)
        .collection('messages')
        .doc(uid)
        .update({
      'last_date_open_chat': DateTime.now(),
    });
  } on FirebaseException {}
}

Future createLastCloseChat(String uid, String friendId, data) async {
  try {
    FirebaseFirestore.instance
        .collection('User')
        .doc(friendId)
        .collection('messages')
        .doc(uid)
        .update({
      'last_date_close_chat': data,
    });
  } on FirebaseException {}
}

Future<List<String>> readFirebaseImageProfile() async {
  DocumentSnapshot<Map<String, dynamic>> query;
  List<String> listImages = [];
  try {
    query = await FirebaseFirestore.instance
        .collection('ImageProfile')
        .doc('Image')
        .get(const GetOptions(source: Source.cache));
    if (query == null) {
      query = await FirebaseFirestore.instance
          .collection('ImageProfile')
          .doc('Image')
          .get(const GetOptions(source: Source.server));
    }
  } on FirebaseException {
    query = await FirebaseFirestore.instance
        .collection('ImageProfile')
        .doc('Image')
        .get(const GetOptions(source: Source.server));
  }

  if (query.data()?.length == 0) {
    query = await FirebaseFirestore.instance
        .collection('ImageProfile')
        .doc('Image')
        .get(const GetOptions(source: Source.server));
  }

  listImages.addAll(List<String>.from(query['listProfileImage']));

  return listImages;
}

Future<bool> sendFcmMessage(
    String title, String message, String userToken, String type,
    [String? uid, String? uri]) async {
  try {
    var url = Uri.parse('https://fcm.googleapis.com/fcm/send');

    String keyAuth =
        'key=AAAAKuk0_pM:APA91bHewKAMBWy9XgTLMZ3vKV9EgDkBAF_H1lwS-XOFDudRcGu2t3kQfYP_3zmlOHxChObB1sqX9gVnIGlewtw7it-4heFSbIclpAs1L-oLYlpGH_X3Gu6SBuswrbPlgVOZehBVhn3I';

    String title = 'Lancelot';

    var header = {
      "Content-Type": "application/json",
      "Authorization": keyAuth,
    };

    var request = {
      "notification": {
        "title": title,
        "body": message,
        "sound": "default",
        "content_available": true,
        "click_action": "FLUTTER_NOTIFICATION_CLICK",
        "android_channel_id": "high_importance_channel",
        if (uri != null) "image": uri,
      },
      "priority": "high",
      'data': {
        'type': type,
        'uid': uid ?? '',
        'uri': uri ?? '',
      },
      "to": userToken,
    };

    await http.post(url, headers: header, body: json.encode(request));

    return true;
  } catch (e) {
    return false;
  }
}
