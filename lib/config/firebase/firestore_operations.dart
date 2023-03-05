import 'dart:convert';
import 'dart:io';

import 'package:Lancelot/config/utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

import '../../model/user_model.dart';
import '../../screens/manager_screen.dart';
import '../../screens/settings/edit_profile_screen.dart';
import '../../widget/dialog_widget.dart';
import '../const.dart';

Future<CroppedFile?> _cropImage(
    BuildContext context, XFile pickedImage, int compressQuality) async {
  CroppedFile? croppedFileCurrent;

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
    croppedFileCurrent = croppedFile;
  }
  return croppedFileCurrent;
}

Future<String> uploadFirstImage(
    BuildContext context, UserModel modelUser) async {
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

          modelUser.userImagePath.add(fileName);
          modelUser.userImageUrl.add(urlDownload);

          final docUser = FirebaseFirestore.instance
              .collection('User')
              .doc(FirebaseAuth.instance.currentUser?.uid);

          final json = {
            'listImageUri': modelUser.userImageUrl,
            'listImagePath': modelUser.userImagePath
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
  try {
    final pickedImage = await ImagePicker().pickImage(
        source: ImageSource.gallery, imageQuality: 28, maxWidth: 1920);
    if (pickedImage != null) {
      await _cropImage(context, pickedImage, 28).then((croppedFile) async {
        if (croppedFile != null) {
          final String fileName = path.basename(croppedFile.path);
          File imageFile = File(croppedFile.path);
          try {
            var task =
                FirebaseStorage.instance.ref(fileName).putFile(imageFile);

            if (task == null) return;
            showAlertDialogLoading(context);

            final snapshot = await task.whenComplete(() {});
            final urlDownload = await snapshot.ref.getDownloadURL();

            userModelCurrent.userImageUrl.add(urlDownload);
            userModelCurrent.userImagePath.add(fileName);

            final docUser = FirebaseFirestore.instance
                .collection('User')
                .doc(userModelCurrent.uid);

            final json = {
              'listImageUri': userModelCurrent.userImageUrl,
              'listImagePath': userModelCurrent.userImagePath
            };

            docUser.update(json);

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

            storage.ref(userModelCurrent.userImagePath[0]).delete();

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

            docUser.update(json);
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
      for (var document in querySnapshot.docs) {
        if (document['uid'] == userModelCurrent.uid) {
          return;
        }
      }
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
    FirebaseFirestore.instance
        .collection("User")
        .doc(idUser)
        .collection('sympathy')
        .doc(idDoc)
        .delete()
        .then((value) {});
  } on FirebaseException {}
}

Future<void> deleteSympathyPartner(String idPartner, String idUser) async {
  await FirebaseFirestore.instance
      .collection('User')
      .doc(idPartner)
      .collection('sympathy')
      .where('uid', isEqualTo: idUser)
      .get()
      .then((querySnapshot) async {
    for (var result in querySnapshot.docs) {
      Map<String, dynamic> data = result.data();
      await FirebaseFirestore.instance
          .collection("User")
          .doc(idPartner)
          .collection('sympathy')
          .doc(data['id_doc'])
          .delete()
          .then((value) {});
    }
  });
}

Future<void> imageRemove(
    int index, BuildContext context, UserModel userModelCurrent) async {
  try {
    FirebaseStorage.instance
        .ref(userModelCurrent.userImagePath[index])
        .delete();
    CachedNetworkImage.evictFromCache(userModelCurrent.userImageUrl[index]);
    userModelCurrent.userImageUrl.removeAt(index);
    userModelCurrent.userImagePath.removeAt(index);

    FirebaseFirestore.instance
        .collection('User')
        .doc(userModelCurrent.uid)
        .update({
      'listImageUri': userModelCurrent.userImageUrl,
      'listImagePath': userModelCurrent.userImagePath
    });
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
      ),
    );
  } on FirebaseException {
    Navigator.pop(context);
  }
}

Future<void> setStateFirebase(String state, [String? uid]) async {
  try {
    await FirebaseFirestore.instance
        .collection('User')
        .doc(uid ?? FirebaseAuth.instance.currentUser?.uid)
        .update({
      'state': state,
      if (state == 'offline') 'lastDateOnline': DateTime.now(),
    });
  } on FirebaseException {}
}

Future<void> deleteUserTokenFirebase(String uid) async {
  try {
    await FirebaseFirestore.instance.collection('User').doc(uid).update({
      'token': '',
    });
  } on FirebaseException {}
}

Future<void> setTokenUserFirebase() async {
  try {
    await FirebaseMessaging.instance.getToken().then((token) async {
      await FirebaseFirestore.instance
          .collection('User')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .update({
        'token': token,
      });
    });
  } on FirebaseException {}
}

Future deleteChatFirebase(String friendId, bool isBack, BuildContext context,
    String friendUri) async {
  CachedNetworkImage.evictFromCache(friendUri);

  FirebaseFirestore.instance
      .collection('User')
      .doc(FirebaseAuth.instance.currentUser?.uid)
      .collection('messages')
      .doc(friendId)
      .delete();

  FirebaseFirestore.instance
      .collection('User')
      .doc(friendId)
      .collection('messages')
      .doc(FirebaseAuth.instance.currentUser?.uid)
      .delete();

  var usersMy = FirebaseFirestore.instance
      .collection('User')
      .doc(FirebaseAuth.instance.currentUser?.uid)
      .collection('messages')
      .doc(friendId)
      .collection('chats');

  WriteBatch batchMy = FirebaseFirestore.instance.batch();

  usersMy.get().then((querySnapshot) {
    for (var document in querySnapshot.docs) {
      batchMy.delete(document.reference);
    }
    return batchMy.commit();
  });

  var usersFriend = FirebaseFirestore.instance
      .collection('User')
      .doc(friendId)
      .collection('messages')
      .doc(FirebaseAuth.instance.currentUser?.uid)
      .collection('chats');

  WriteBatch batchFriend = FirebaseFirestore.instance.batch();

  usersFriend.get().then((querySnapshot) {
    for (var document in querySnapshot.docs) {
      batchFriend.delete(document.reference);
    }
    return batchFriend.commit();
  });
}

Future<void> uploadImagePhotoProfile(String uri, BuildContext context) async {
  try {
    FirebaseFirestore.instance
        .collection('User')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .update({
      'imageBackground': uri,
    }).then((value) {
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

Future deleteDislike(String idUser) async {
  try {
    CollectionReference collection = FirebaseFirestore.instance
        .collection('User')
        .doc(idUser)
        .collection('dislike');

    WriteBatch batch = FirebaseFirestore.instance.batch();

    return collection.get().then((querySnapshot) {
      for (var document in querySnapshot.docs) {
        batch.delete(document.reference);
      }

      return batch.commit();
    });
  } on FirebaseException {}
}

Future deleteMessageFirebase(String myId, String friendId, String idDoc,
    bool isLastMessage, AsyncSnapshot snapshotMy, int index) async {
  try {
    FirebaseFirestore.instance
        .collection('User')
        .doc(myId)
        .collection('messages')
        .doc(friendId)
        .collection('chats')
        .doc(idDoc)
        .delete();

    FirebaseFirestore.instance
        .collection('User')
        .doc(friendId)
        .collection('messages')
        .doc(myId)
        .collection('chats')
        .doc(idDoc)
        .delete();

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
    }
  } on FirebaseException {
    FirebaseAuth.instance.signOut();
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

Future<String> getTokenUser() async {
  String token = '';
  try {
    token = await FirebaseMessaging.instance.getToken() ?? '';
  } on FirebaseException {}
  return token;
}

Future<void> sendMessage(
    {required bool isFirstMessage,
    required TextEditingController controllerMessage,
    required bool notification,
    required String token,
    required UserModel currentUser,
    required String friendId}) async {
  if (controllerMessage.text.trim().isNotEmpty) {
    final String messageText = controllerMessage.text.trim();
    controllerMessage.clear();
    final String idDocMessage;
    final dateCurrent = DateTime.now();

    if (notification && token != '') {
      sendFcmMessage(
          'Lancelot',
          '${currentUser.name}: отправил вам новое сообщение',
          token,
          'chat',
          currentUser.uid);
    }

    final docMessage = FirebaseFirestore.instance
        .collection('User')
        .doc(currentUser.uid)
        .collection('messages')
        .doc(friendId)
        .collection('chats')
        .doc();

    idDocMessage = docMessage.id;

    await docMessage
        .set(({
      "senderId": currentUser.uid,
      "idDoc": idDocMessage,
      "receiverId": friendId,
      "message": messageText,
      "date": dateCurrent,
    }))
        .then((value) async {
      final docUser = FirebaseFirestore.instance
          .collection('User')
          .doc(currentUser.uid)
          .collection('messages')
          .doc(friendId);

      if (isFirstMessage) {
        await docUser.update({
          'last_msg': messageText,
          'date': dateCurrent,
          'writeLastData': '',
        });
      } else {
        await docUser.set({
          'last_msg': messageText,
          'date': dateCurrent,
          'writeLastData': '',
          'last_date_open_chat': '',
        });
      }
    });

    FirebaseFirestore.instance
        .collection('User')
        .doc(friendId)
        .collection('messages')
        .doc(currentUser.uid)
        .collection("chats")
        .doc(idDocMessage)
        .set({
      "idDoc": idDocMessage,
      "senderId": currentUser.uid,
      "receiverId": friendId,
      "message": messageText,
      "date": dateCurrent,
    }).then((value) async {
      final docUser = FirebaseFirestore.instance
          .collection('User')
          .doc(friendId)
          .collection('messages')
          .doc(currentUser.uid);

      if (isFirstMessage) {
        await docUser.update({
          'last_msg': messageText,
          'date': dateCurrent,
          'writeLastData': '',
          'last_date_open_chat': '',
        });
      } else {
        await docUser.set({
          'last_msg': messageText,
          'date': dateCurrent,
          'writeLastData': '',
          'last_date_open_chat': '',
          'last_date_close_chat': '',
        });

        createLastCloseChat(currentUser.uid, friendId, '');
      }
    });
  }
}
