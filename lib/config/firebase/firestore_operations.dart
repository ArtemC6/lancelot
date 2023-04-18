import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

import '../../model/interests_model.dart';
import '../../model/user_model.dart';
import '../../screens/manager_screen.dart';
import '../../screens/settings/edit_profile_screen.dart';
import '../../widget/dialog_widget.dart';
import '../const.dart';

Future _cropImage(
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

  if (croppedFile != null) croppedFileCurrent = croppedFile;

  return croppedFileCurrent;
}

Future uploadFirstImage(BuildContext context, UserModel modelUser) async {
  final storage = GetIt.I<FirebaseStorage>();
  final pickedImage = await ImagePicker()
      .pickImage(source: ImageSource.gallery, imageQuality: 38, maxWidth: 1920);
  if (pickedImage != null) {
    await _cropImage(context, pickedImage, 38).then((croppedFile) async {
      if (croppedFile != null) {
        final fileName = path.basename(croppedFile.path);
        final imageFile = File(croppedFile.path);
        final task = storage.ref(fileName).putFile(imageFile);

        if (task == null) return;
        showAlertDialogLoading(context);

        final snapshot = await task.whenComplete(() {});
        final urlDownload = await snapshot.ref.getDownloadURL();

        modelUser.listImagePath.add(fileName);
        modelUser.listImageUri.add(urlDownload);

        final docUser =
            GetIt.I<FirebaseFirestore>().collection('User').doc(modelUser.uid);

        final json = {
          'listImageUri': modelUser.listImageUri,
          'listImagePath': modelUser.listImagePath
        };

        await docUser.update(json);
        Navigator.pop(context);
      }
    });
  }
}

Future uploadImageAdd(BuildContext context, UserModel userModelCurrent) async {
  final pickedImage = await ImagePicker()
      .pickImage(source: ImageSource.gallery, imageQuality: 28, maxWidth: 1920);
  if (pickedImage != null) {
    await _cropImage(context, pickedImage, 28).then((croppedFile) async {
      if (croppedFile != null) {
        final fileName = path.basename(croppedFile.path);
        final imageFile = File(croppedFile.path);
        try {
          final task =
              GetIt.I<FirebaseStorage>().ref(fileName).putFile(imageFile);

          if (task == null) return;
          showAlertDialogLoading(context);

          final snapshot = await task.whenComplete(() {});
          final urlDownload = await snapshot.ref.getDownloadURL();

          userModelCurrent.listImageUri.add(urlDownload);
          userModelCurrent.listImagePath.add(fileName);

          final docUser = GetIt.I<FirebaseFirestore>()
              .collection('User')
              .doc(userModelCurrent.uid);

          final json = {
            'listImageUri': userModelCurrent.listImageUri,
            'listImagePath': userModelCurrent.listImagePath
          };

          docUser.update(json);

          Navigator.pushReplacement(
            context,
            FadeRouteAnimation(
              ManagerScreen(
                currentIndex: 3,
                userModelCurrent: UserModel.fromDocument(dataCash),
              ),
            ),
          );
        } on FirebaseException {
          Navigator.pop(context);
        }
      }
    });
  }
}

Future updateFirstImage(
    BuildContext context, UserModel userModelCurrent, bool isScreen) async {
  List<String> listImageUri = [], listImagePath = [];
  final storage = GetIt.I<FirebaseStorage>(), picker = ImagePicker();
  final pickedImage = await picker.pickImage(
      source: ImageSource.gallery, imageQuality: 38, maxWidth: 1920);
  if (pickedImage != null) {
    await _cropImage(context, pickedImage, 38).then((croppedFile) async {
      if (croppedFile != null) {
        final fileName = path.basename(croppedFile.path);
        final imageFile = File(croppedFile.path);

        try {
          final task = storage.ref(fileName).putFile(imageFile);
          if (task == null) return;

          showAlertDialogLoading(context);

          final snapshot = await task.whenComplete(() {});
          final urlDownload = await snapshot.ref.getDownloadURL();

          CachedNetworkImage.evictFromCache(userModelCurrent.listImageUri[0]);

          storage.ref(userModelCurrent.listImagePath[0]).delete();

          userModelCurrent.listImageUri.removeAt(0);
          userModelCurrent.listImagePath.removeAt(0);

          listImagePath.add(fileName);
          listImageUri.add(urlDownload);

          listImagePath.addAll(userModelCurrent.listImagePath);
          listImageUri.addAll(userModelCurrent.listImageUri);

          final docUser = GetIt.I<FirebaseFirestore>()
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
                  isFirst: true,
                  userModel: UserModel.fromDocument(dataCash),
                )));
          } else {
            Navigator.pushReplacement(
                context,
                FadeRouteAnimation(ManagerScreen(
                    currentIndex: 3,
                    userModelCurrent: UserModel.fromDocument(dataCash))));
          }
        } on FirebaseException {
          Navigator.pop(context);
        }
      }
    });
    }
}

Future createSympathy(String idPartner, UserModel userModelCurrent) async {
  final init = GetIt.I<FirebaseFirestore>()
      .collection('User')
      .doc(idPartner)
      .collection('sympathy');
  init
      .where('uid', isEqualTo: userModelCurrent.uid)
      .get()
      .then((querySnapshot) {
    for (var document in querySnapshot.docs) {
      if (document['uid'] == userModelCurrent.uid) return;
    }
    final docUser = init.doc();
    docUser.set({
      'id_doc': docUser.id,
      'uid': userModelCurrent.uid,
      'time': DateTime.now(),
    });
  });
}

Future deleteSympathy(String idDoc, idUser) async {
 await GetIt.I<FirebaseFirestore>()
      .collection("User")
      .doc(idUser)
      .collection('sympathy')
      .doc(idDoc)
      .delete()
      .then((value) {});
}

Future deleteSympathyPartner(String idPartner, String idUser) async {
  final init = GetIt.I<FirebaseFirestore>()
      .collection('User')
      .doc(idPartner)
      .collection('sympathy');

  await init.where('uid', isEqualTo: idUser).get().then((query) async {
    for (var result in query.docs) {
      await init.doc(result.data()['id_doc']).delete();
    }
  });
}

Future<void> imageRemove(
    int index, BuildContext context, UserModel userModelCurrent) async {
  try {
    GetIt.I<FirebaseStorage>()
        .ref(userModelCurrent.listImagePath[index])
        .delete();
    CachedNetworkImage.evictFromCache(userModelCurrent.listImageUri[index]);
    userModelCurrent.listImageUri.removeAt(index);
    userModelCurrent.listImagePath.removeAt(index);

    GetIt.I<FirebaseFirestore>()
        .collection('User')
        .doc(userModelCurrent.uid)
        .update({
      'listImageUri': userModelCurrent.listImageUri,
      'listImagePath': userModelCurrent.listImagePath
    });
    Navigator.pushReplacement(
      context,
      FadeRouteAnimation(
        ManagerScreen(
          currentIndex: 3,
          userModelCurrent: UserModel.fromDocument(dataCash),
        ),
      ),
    );
  } on FirebaseException {
    Navigator.pop(context);
  }
}

Future setStateFirebase(String state, [String? uid]) async {
  await GetIt.I<FirebaseFirestore>()
      .collection('User')
      .doc(uid ?? GetIt.I<FirebaseAuth>().currentUser?.uid)
      .update({
    'state': state,
    if (state == 'offline') 'lastDateOnline': DateTime.now(),
  });
}

Future deleteUserTokenFirebase(String uid) async {
  await GetIt.I<FirebaseFirestore>().collection('User').doc(uid).update({
    'token': '',
  });
}

Future setTokenUserFirebase() async {
  await FirebaseMessaging.instance.getToken().then((token) async {
    await GetIt.I<FirebaseFirestore>()
        .collection('User')
        .doc(GetIt.I<FirebaseAuth>().currentUser?.uid)
        .update({
      'token': token,
    });
  });
}

Future deleteChatFirebase(
  String friendId,
  String uidUser,
  String friendUri,
) async {
  if (friendUri.isNotEmpty) CachedNetworkImage.evictFromCache(friendUri);
  final init = GetIt.I<FirebaseFirestore>();
  final initUser = init.collection('User');

  final usersMy = initUser
      .doc(uidUser)
      .collection('messages')
      .doc(friendId)
      .collection('chats');

  final batchMy = init.batch();

   usersMy.get().then((querySnapshot) {
    for (var document in querySnapshot.docs) {
      batchMy.delete(document.reference);
    }
    return batchMy.commit();
  });

  final usersFriend = initUser
      .doc(friendId)
      .collection('messages')
      .doc(uidUser)
      .collection('chats');

  final batchFriend = init.batch();

   usersFriend.get().then((querySnapshot) {
    for (var document in querySnapshot.docs) {
      batchFriend.delete(document.reference);
    }
    return batchFriend.commit();
  });

   initUser.doc(friendId).collection('messages').doc(uidUser).delete();
  await initUser.doc(uidUser).collection('messages').doc(friendId).delete();
}

Future uploadImagePhotoProfile(String uri, context) async {
  await GetIt.I<FirebaseFirestore>()
      .collection('User')
      .doc(GetIt.I<FirebaseAuth>().currentUser?.uid)
      .update({
    'imageBackground': uri,
  }).then(
    (_) {
      Navigator.pushReplacement(
        context,
        FadeRouteAnimation(
          ManagerScreen(
            currentIndex: 3,
            userModelCurrent: UserModel.fromDocument(dataCash),
          ),
        ),
      );
    },
  );
}

Future<UserModel> readUserFirebase([String? idUser]) async {
  Map<String, dynamic> data = {};
  UserModel userModel = UserModel.fromDocument(data);
  DocumentSnapshot<Map<String, dynamic>> query;
  final uid = GetIt.I<FirebaseAuth>().currentUser?.uid;
  final init =
      GetIt.I<FirebaseFirestore>().collection('User').doc(idUser ?? uid);
  try {
    query = await init.get(const GetOptions(source: Source.cache));
  } on FirebaseException {
    query = await init.get(const GetOptions(source: Source.server));
  }

  if (!query.metadata.isFromCache) {
    query = await init.get(const GetOptions(source: Source.server));
  }

  final dataCash = query.data() as Map<String, dynamic>;

  try {
    if (dataCash['imageBackground'] == null ||
        dataCash['listInterests'] == null ||
        dataCash['listImageUri'] == null) {
      query = await init
          .get(const GetOptions(source: Source.server));
    }
  } on FirebaseException {
    query = await init
        .get(const GetOptions(source: Source.server));
  }

  userModel = UserModel.fromDocument(query.data() as Map<String, dynamic>);

  return userModel;
}

Future<List<String>> readDislikeFirebase(String idUser) async {
  List<String> listDislike = [];
  QuerySnapshot<Map<String, dynamic>> query;
  final init = GetIt.I<FirebaseFirestore>()
      .collection('User')
      .doc(idUser)
      .collection('dislike');
  try {
    query = await init.get(const GetOptions(source: Source.cache));
  } on FirebaseException {
    query = await init.get(const GetOptions(source: Source.server));
  }

  if (query.size == 0 && query.docs.isEmpty) {
    query = await init.get(const GetOptions(source: Source.server));
  }

  for (var result in query.docs) {
    listDislike.add(result.id);
  }

  return listDislike;
}

Future deleteDislike(String idUser) async {
  final init = GetIt.I<FirebaseFirestore>();
  final collection = init.collection('User').doc(idUser).collection('dislike');
  final batch = init.batch();

  await collection.get().then((querySnapshot) {
    for (var document in querySnapshot.docs) {
      batch.delete(document.reference);
    }
    return batch.commit();
  });
}

Future deleteLike(String idUser) async {
  final init = GetIt.I<FirebaseFirestore>();
  final batch = init.batch();

  await init
      .collection('User')
      .doc(idUser)
      .collection('likes')
      .get()
      .then((querySnapshot) {
    for (var document in querySnapshot.docs) {
      batch.delete(document.reference);
    }

    return batch.commit();
  });
}

Future deleteAccountData(UserModel userModel) async {
  final init = GetIt.I<FirebaseFirestore>();
  final instanceUser = init.collection('User').doc(userModel.uid);

  deleteDislike(userModel.uid);
  deleteLike(userModel.uid);

  final batchSympathy = init.batch();
  instanceUser.collection('sympathy').get().then((querySnapshot) async {
    for (var document in querySnapshot.docs) {
      await deleteSympathyPartner(document['uid'], userModel.uid);
      batchSympathy.delete(document.reference);
    }

    return await batchSympathy.commit();
  });

  await instanceUser.collection('messages').get().then((value) async {
    for (var document in value.docs) {
      await deleteChatFirebase(document.id, userModel.uid, '');
    }
  });

  instanceUser.delete();
}

Future deleteMessageFirebase(String myId, String friendId, String idDoc,
    bool isLastMessage, AsyncSnapshot snapshotMy, int index) async {
  final init = GetIt.I<FirebaseFirestore>().collection('User');
  await init
      .doc(myId)
      .collection('messages')
      .doc(friendId)
      .collection('chats')
      .doc(idDoc)
      .delete();

  await init
      .doc(friendId)
      .collection('messages')
      .doc(myId)
      .collection('chats')
      .doc(idDoc)
      .delete();

  if (isLastMessage) {
    await init.doc(myId).collection('messages').doc(friendId).update({
      "last_msg": snapshotMy.data.docs[index]['message'],
      'date': snapshotMy.data.docs[index]['date'],
      'last_date_open_chat': DateTime.now(),
    });

    await init.doc(friendId).collection('messages').doc(myId).update({
      "last_msg": snapshotMy.data.docs[index]['message'],
      'date': snapshotMy.data.docs[index]['date'],
      'last_date_open_chat': DateTime.now(),
    });
  }
}

Future<bool> putLike(
    UserModel userModelCurrent, UserModel userModel, bool isLikeOnTap) async {
  bool isLike = false;
  QuerySnapshot<Map<String, dynamic>> query;
  final init = GetIt.I<FirebaseFirestore>()
      .collection('User')
      .doc(userModel.uid)
      .collection('likes');
  try {
    query = await init.get(const GetOptions(source: Source.cache));
  } on FirebaseException {
    query = await init.get(const GetOptions(source: Source.server));
  }

  if (query.size == 0 && query.docs.isEmpty) {
    query = await init.get(const GetOptions(source: Source.server));
  }

  for (var result in query.docs) {
    if (userModelCurrent.uid == result.id) isLike = true;
  }

  if (isLikeOnTap) {
    if (!isLike) {
      await init.doc(userModelCurrent.uid).set({});

      if (userModelCurrent.uid != userModel.uid &&
          userModel.notification &&
          userModel.token.isNotEmpty) {
        sendFcmMessage(
            'Lancelot',
            '${userModelCurrent.name}: нравится ваш профиль',
            userModel.token,
            'like');
      }
    } else {
      await init.doc(userModelCurrent.uid).delete();
    }
  }

  return Future.value(!isLike);
}

Future<Map> readInterestsFirebase() async {
  Map mapInterests = {};
  QuerySnapshot<Map<String, dynamic>> query;
  final init = GetIt.I<FirebaseFirestore>().collection('ImageInterests');
  try {
    query = await init.get(const GetOptions(source: Source.cache));
  } on FirebaseException {
    query = await init.get(const GetOptions(source: Source.server));
  }

  if (query.size == 0) {
    query = await init.get(const GetOptions(source: Source.server));
  }

  for (var document in query.docs) {
    mapInterests = document.data()['Interests'];
  }

  return mapInterests;
}

Future<UserModel> readFirebaseIsAccountFull(BuildContext context) async {
  Map<String, dynamic> data = {};
  UserModel userModelCurrent = UserModel.fromDocument(data);
  final auth = GetIt.I<FirebaseAuth>();
  final uid = auth.currentUser?.uid;
  final init = GetIt.I<FirebaseFirestore>().collection('User');

  try {
    if (uid != null) {
      DocumentSnapshot<Map<String, dynamic>> queryUser;
      try {
        queryUser =
            await init.doc(uid).get(const GetOptions(source: Source.cache));
      } on FirebaseException {
        queryUser =
            await init.doc(uid).get(const GetOptions(source: Source.server));
      }

      final dataCash = queryUser.data() as Map<String, dynamic>;

      try {
        if (dataCash['imageBackground'] == null ||
            dataCash['listInterests'] == null) {
          queryUser = await init
              .doc(uid)
              .get(const GetOptions(source: Source.server));
        }
      } on FirebaseException {
        queryUser = await init
            .doc(uid)
            .get(const GetOptions(source: Source.server));
      }

      final data = queryUser.data() as Map<String, dynamic>;
      if (data['uid'] == '' || data['uid'] == null) auth.signOut();

      if (data['listInterests'] != '' &&
          List<String>.from(data['listImageUri']).isNotEmpty) {
        userModelCurrent = UserModel.fromDocument(data);
      }
    }
  } on FirebaseException {
    auth.signOut();
  }

  return userModelCurrent;
}

Future putUserWrites(
  String currentId,
  String friendId,
) async {
  await GetIt.I<FirebaseFirestore>()
      .collection("User")
      .doc(friendId)
      .collection('messages')
      .doc(currentId)
      .update({'writeLastData': DateTime.now()});
}

Future createDisLike(UserModel userModelCurrent, UserModel userModel) async {
  await GetIt.I<FirebaseFirestore>()
      .collection("User")
      .doc(userModelCurrent.uid)
      .collection('dislike')
      .doc(userModel.uid)
      .set({});
}

Future createLastOpenChat(String uid, String friendId) async {
  await GetIt.I<FirebaseFirestore>()
      .collection('User')
      .doc(friendId)
      .collection('messages')
      .doc(uid)
      .update({
    'last_date_open_chat': DateTime.now(),
  });
}

Future createLastCloseChat(String uid, String friendId, data) async {
  await GetIt.I<FirebaseFirestore>()
      .collection('User')
      .doc(friendId)
      .collection('messages')
      .doc(uid)
      .update({
    'last_date_close_chat': data,
  });
}

Future<List<String>> readFirebaseImageProfile() async {
  DocumentSnapshot<Map<String, dynamic>> query;
  List<String> listImages = [];
  final init =
      GetIt.I<FirebaseFirestore>().collection('ImageProfile').doc('Image');
  try {
    query = await init.get(const GetOptions(source: Source.cache));
  } on FirebaseException {
    query = await init.get(const GetOptions(source: Source.server));
  }

  if (query.data()!.isEmpty) {
    query = await init.get(const GetOptions(source: Source.server));
  }

  listImages.addAll(List<String>.from(query['listProfileImage']));

  return listImages;
}

Future<bool> sendFcmMessage(
    String title, String message, String userToken, String type,
    [String? uid, String? uri]) async {
  try {
    final url = Uri.parse('https://fcm.googleapis.com/fcm/send');

    const keyAuth =
        'key=AAAAKuk0_pM:APA91bHewKAMBWy9XgTLMZ3vKV9EgDkBAF_H1lwS-XOFDudRcGu2t3kQfYP_3zmlOHxChObB1sqX9gVnIGlewtw7it-4heFSbIclpAs1L-oLYlpGH_X3Gu6SBuswrbPlgVOZehBVhn3I';

    const title = 'Lancelot';

    final header = {
      "Content-Type": "application/json",
      "Authorization": keyAuth,
    };

    final request = {
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
  return await FirebaseMessaging.instance.getToken() ?? '';
}

sendMessage(
    {required bool isFirstMessage,
    required TextEditingController controllerMessage,
    required bool notification,
    required String token,
    required UserModel currentUser,
    required String friendId}) async {
  if (controllerMessage.text.trim().isNotEmpty) {
    final String messageText = controllerMessage.text.trim(), idDocMessage;
    controllerMessage.clear();
    final dateCurrent = DateTime.now();
    final init = GetIt.I<FirebaseFirestore>().collection('User');

    final docMessage = init
        .doc(currentUser.uid)
        .collection('messages')
        .doc(friendId)
        .collection('chats')
        .doc();

    idDocMessage = docMessage.id;

    await docMessage.set(({
      "senderId": currentUser.uid,
      "idDoc": idDocMessage,
      "receiverId": friendId,
      "message": messageText,
      "date": dateCurrent,
    }));

    final docUserCurrent = init
        .doc(currentUser.uid)
        .collection('messages')
        .doc(friendId);

    if (isFirstMessage) {
      await docUserCurrent.update({
        'last_msg': messageText,
        'date': dateCurrent,
        'writeLastData': '',
      });
    } else {
      await docUserCurrent.set({
        'last_msg': messageText,
        'date': dateCurrent,
        'writeLastData': '',
        'last_date_open_chat': '',
      });
    }

    await init
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
    });

    final docUser = init
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

      await createLastCloseChat(currentUser.uid, friendId, '');
    }

    if (notification && token.isNotEmpty) {
      await sendFcmMessage(
          'Lancelot',
          '${currentUser.name}: отправил вам новое сообщение',
          token,
          'chat',
          currentUser.uid);
    }
  }
}

Future<List<InterestsModel>> sortingList(UserModel userModelPartner) async {
  List<InterestsModel> listStory = [];
  await readInterestsFirebase().then((map) {
    for (var elementMain in userModelPartner.listInterests) {
      map.forEach((key, value) {
        if (elementMain == key) {
          if (userModelPartner.listInterests.length != listStory.length) {
            listStory.add(InterestsModel(name: key, id: '', uri: value));
          }
        }
      });
    }
  });

  return listStory;
}

Future<QuerySnapshot<Map<String, dynamic>>> readSympathyFriendFirebase(
    String uid, String friend, int limit) async {
  QuerySnapshot<Map<String, dynamic>> query;
  final init = GetIt.I<FirebaseFirestore>()
      .collection('User')
      .doc(uid)
      .collection('sympathy')
      .where('uid', isEqualTo: friend);

  try {
    query = await init.get(const GetOptions(source: Source.cache));
  } on FirebaseException {
    query = await init.get(const GetOptions(source: Source.server));
  }

  return query;
}

Future<QuerySnapshot<Map<String, dynamic>>> readSympathyFirebase(
    int limit, String uid) async {
  return await GetIt.I<FirebaseFirestore>()
      .collection('User')
      .doc(uid)
      .collection('sympathy')
      .orderBy("time", descending: true)
      .limit(limit)
      .get();
}
