import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

Future<CroppedFile?> _cropImage(BuildContext context, XFile pickedImage) async {
  CroppedFile? _croppedFile;

  final croppedFile = await ImageCropper().cropImage(
    sourcePath: pickedImage.path,
    compressFormat: ImageCompressFormat.jpg,
    compressQuality: 40,
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

Future uploadPlacesFirebase(
  BuildContext context,
  String nameEvent,
) async {
  FirebaseStorage storage = FirebaseStorage.instance;
  int position = 0;
  try {
    final picker = ImagePicker();
    final image = await picker.pickImage(
        source: ImageSource.gallery, imageQuality: 40, maxWidth: 1920);

    if (image != null) {
      await _cropImage(context, image).then((croppedFile) async {
        if (croppedFile != null) {
          final String fileName = path.basename(croppedFile.path);
          File imageFile = File(croppedFile.path);
          List<String> listUri = [];

          var task = storage.ref(fileName).putFile(imageFile);

          if (task == null) return '';

          final snapshot = await task.whenComplete(() {});
          final urlDownload = await snapshot.ref.getDownloadURL();

          // final docUser =
          // FirebaseFirestore.instance.collection(nameEvent).doc();
          //
          // listUri.add(urlDownload);
          //
          // final json = {
          //   'id': docUser.id,
          //   'photo': listUri,
          //   'name': '',
          //   'location': '',
          //   'position': position,
          // };
          //
          // docUser.set(json).then((value) {
          //   Navigator.push(
          //       context,
          //       FadeRouteAnimation(
          //         const Manager(),
          //       ));
          // });
        }
      });
    }
  } catch (err) {}
}
