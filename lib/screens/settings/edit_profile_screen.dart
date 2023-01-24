import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delayed_display/delayed_display.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:multi_select_flutter/bottom_sheet/multi_select_bottom_sheet_field.dart';
import 'package:multi_select_flutter/chip_display/multi_select_chip_display.dart';
import 'package:multi_select_flutter/util/multi_select_list_type.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config/const.dart';
import '../../config/firebase_auth.dart';
import '../../config/firestore_operations.dart';
import '../../config/utils.dart';
import '../../model/user_model.dart';
import '../../widget/animation_widget.dart';
import '../../widget/button_widget.dart';
import '../../widget/dialog_widget.dart';
import '../../widget/textField_widget.dart';
import '../manager_screen.dart';
import 'edit_image_profile_screen.dart';

class EditProfileScreen extends StatefulWidget {
  bool isFirst;
  UserModel userModel;

  EditProfileScreen(
      {super.key, required this.isFirst, required this.userModel});

  @override
  State<EditProfileScreen> createState() =>
      _EditProfileScreenState(isFirst, userModel);
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final bool isFirst;
  UserModel modelUser;

  _EditProfileScreenState(this.isFirst, this.modelUser);

  bool isLoading = false, isError = false, isPhoto = false;
  final TextEditingController _ageController = TextEditingController(),
      _myPolController = TextEditingController(),
      _nameController = TextEditingController(),
      _searchPolController = TextEditingController(),
      _ageRangController = TextEditingController(),
      _localController = TextEditingController(),
      _supportController = TextEditingController(),
      _notificationController = TextEditingController(),
      _descriptionController = TextEditingController();

  var _selectedInterests = [];
  DateTime _dateTimeBirthday = DateTime.now();
  late SfRangeValues _valuesAge;
  int interestsCount = 0;

  void showDatePicker() {
    DatePicker.showDatePicker(context,
        theme: const DatePickerTheme(
            backgroundColor: color_black_88,
            cancelStyle: TextStyle(color: Colors.white),
            itemStyle: TextStyle(color: Colors.white)),
        showTitleActions: true,
        minTime: DateTime(1993),
        maxTime: DateTime(2007), onChanged: (date) {
      setState(() {
        _dateTimeBirthday = date;
        _ageController.text =
            (DateTime.now().difference(_dateTimeBirthday).inDays ~/ 365)
                .toString();
      });
    },
        onConfirm: (date) {},
        currentTime: getDataTime(modelUser.ageTime),
        locale: LocaleType.ru);
  }

  Future<void> _uploadData() async {
    bool interests =
        _selectedInterests.isNotEmpty && _selectedInterests.length <= 6;
    bool myPol = _myPolController.text.length == 7;
    bool name = _nameController.text.length >= 3;
    bool searchPol = _searchPolController.text.length >= 7;
    bool localUser = _localController.text.length >= 6;
    bool userPhoto = modelUser.userImageUrl.isNotEmpty;
    bool userAge = DateTime.now().year - _dateTimeBirthday.year >= 16;
    bool ageRange = _valuesAge.start >= 16 && _valuesAge.end < 50;

    if (interests &&
        myPol &&
        name &&
        searchPol &&
        localUser &&
        userPhoto &&
        userAge &&
        ageRange) {
      showAlertDialogLoading(context);
      String? token;
      await FirebaseMessaging.instance.getToken().then((value) {
        token = value;
      });

      final docUser = FirebaseFirestore.instance
          .collection('User')
          .doc(FirebaseAuth.instance.currentUser?.uid);

      final json = {
        'listInterests': _selectedInterests,
        'myPol': _myPolController.text,
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'searchPol':
            _searchPolController.text == 'С парнем' ? 'Мужской' : 'Женский',
        'ageTime': _dateTimeBirthday,
        'rangeStart': _valuesAge.start,
        'rangeEnd': _valuesAge.end,
        'myCity': _localController.text,
        'notification':
            _notificationController.text == 'Включить' ? true : false,
        'token': token,
      };

      docUser.update(json).then((value) {
        if (modelUser.imageBackground != '') {
          Navigator.pushReplacement(
              context,
              FadeRouteAnimation(
                ManagerScreen(currentIndex: 3),
              ));
        } else {
          Navigator.pushReplacement(
              context,
              FadeRouteAnimation(
                  EditImageProfileScreen(bacImage: modelUser.imageBackground)));
        }
      });
    } else {
      setState(() {
        isError = false;
        isError = true;
        if (modelUser.userImageUrl.isNotEmpty) {
          isPhoto = true;
        } else {
          isPhoto = false;
        }
      });
    }
  }

  void settingsValue() {
    _nameController.text = modelUser.name;
    _supportController.text =
        'Если у вас возникла проблема или есть предложения по улучшению вы можете обратиться';
    if (modelUser.notification) {
      _notificationController.text = 'Включить';
    } else {
      _notificationController.text = 'Вюключить';
    }

    if (modelUser.description == '') {
      _descriptionController.text = ' ';
    } else {
      _descriptionController.text = modelUser.description;
    }

    _ageRangController.text = modelUser.searchRangeStart == 0
        ? ' '
        : 'От ${modelUser.searchRangeStart.toInt()} до ${modelUser.searchRangeEnd.toInt()} лет';

    _ageController.text =
        modelUser.ageInt == 0 ? ' ' : modelUser.ageInt.toString();

    _valuesAge = SfRangeValues(
        modelUser.searchRangeStart == 0 ? 16 : modelUser.searchRangeStart,
        modelUser.searchRangeEnd == 0 ? 30 : modelUser.searchRangeEnd);
    _myPolController.text = modelUser.userPol == '' ? ' ' : modelUser.userPol;
    _localController.text = modelUser.myCity == '' ? ' ' : modelUser.myCity;
    if (modelUser.searchPol == '') {
      _searchPolController.text = ' ';
    } else {
      _searchPolController.text =
          modelUser.searchPol == 'Мужской' ? 'С парнем' : 'С девушкой';
    }

    if (modelUser.userImageUrl.isNotEmpty) {
      isPhoto = true;
    }
    _selectedInterests = modelUser.userInterests;
    interestsCount = modelUser.userInterests.length;
    _dateTimeBirthday = getDataTime(modelUser.ageTime);
  }

  Future readFirebase() async {
    if (modelUser.uid == '') {
      await readUserFirebase().then((user) {
        setState(() {
          modelUser = UserModel(
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
              notification: user.notification,
              description: user.description);
          isLoading = true;
        });
      });
    }
    setState(() {
      isLoading = true;
      settingsValue();
    });
  }

  Future<void> _launchUrl(String uri) async {
    // lancelotsuport@gmail.com
    String? encodeQueryParameters(Map<String, String> params) {
      return params.entries
          .map((MapEntry<String, String> e) =>
              '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
          .join('&');
    }

    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: uri,
      query: encodeQueryParameters(<String, String>{
        'subject': '',
      }),
    );

    launchUrl(emailLaunchUri);
  }

  @override
  void initState() {
    readFirebase();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    if (isLoading) {
      return WillPopScope(
        onWillPop: () async {
          return !isFirst;
        },
        child: Scaffold(
          backgroundColor: color_black_88,
          body: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Container(
                padding: const EdgeInsets.only(left: 16, right: 16),
                child: AnimationLimiter(
                  child: AnimationConfiguration.staggeredList(
                    position: 1,
                    delay: const Duration(milliseconds: 100),
                    child: SlideAnimation(
                      duration: const Duration(milliseconds: 2000),
                      verticalOffset: height * .40,
                      curve: Curves.ease,
                      child: FadeInAnimation(
                        curve: Curves.easeOut,
                        duration: const Duration(milliseconds: 4000),
                        child: Column(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 10, bottom: 0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  if (!isFirst)
                                    IconButton(
                                      color: Colors.white,
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      icon: Icon(
                                          Icons.arrow_back_ios_new_rounded,
                                          size: height / 38),
                                    ),
                                  customIconButton(
                                    path: 'images/ic_log_out.png',
                                    width: height / 26,
                                    height: height / 26,
                                    onTap: () async {
                                      FirebaseAuthMethods.signOut(
                                          context, modelUser.uid);
                                    },
                                    padding: 0,
                                  ),
                                ],
                              ),
                            ),
                            imageProfileSettings(
                              height,
                              context,
                            ),
                            SlideFadeTransition(
                              animationDuration:
                                  const Duration(milliseconds: 800),
                              child: Container(
                                padding: EdgeInsets.only(
                                    bottom: height / 62,
                                    top: height / 62,
                                    right: 8),
                                alignment: Alignment.centerRight,
                                child: buttonUniversalAnimationColors(
                                    isFirst ? 'Завершить' : 'Сохронить',
                                    [
                                      Colors.blueAccent,
                                      Colors.purpleAccent,
                                      Colors.orangeAccent
                                    ],
                                    height / 22, () {
                                  _uploadData();
                                }, 900),
                              ),
                            ),
                            if (isError)
                              Padding(
                                padding: EdgeInsets.all(height / 66),
                                child: animatedText(
                                    height / 72,
                                    'Данные введены некорректно',
                                    Colors.red,
                                    500,
                                    1),
                              ),
                            if (!isPhoto)
                              Padding(
                                padding: EdgeInsets.all(height / 66),
                                child: animatedText(
                                    height / 72,
                                    'Добавьте главное фото',
                                    Colors.red,
                                    550,
                                    1),
                              ),
                            textFieldProfileSettings(_nameController, false,
                                'Имя', context, 10, height, () {}),
                            textFieldProfileSettings(
                                _ageController,
                                true,
                                'Возраст',
                                context,
                                3,
                                height,
                                () => showDatePicker()),
                            textFieldProfileSettings(_myPolController, true,
                                'Ваш пол', context, 10, height, () {
                              showBottomSheet(context, 'Укажите свой пол',
                                  'Мужской', 'Женский', _myPolController);
                            }),
                            textFieldProfileSettings(
                                _searchPolController,
                                true,
                                'С кем вы хотите познакомиться',
                                context,
                                10,
                                height, () {
                              showBottomSheet(
                                  context,
                                  'Укажите с кем вы хотите познакомиться',
                                  'С парнем',
                                  'С девушкой',
                                  _searchPolController);
                            }),
                            textFieldProfileSettings(_localController, true,
                                'Вы проживаете', context, 10, height, () {
                              showBottomSheet(
                                  context,
                                  'Укажите где вы проживаете',
                                  'Бишкек',
                                  'Каракол',
                                  _localController);
                            }),
                            textFieldProfileSettings(_ageRangController, true,
                                'Диапазон поиска', context, 14, height, () {
                              showCupertinoModalBottomSheet(
                                  topRadius: const Radius.circular(30),
                                  duration: const Duration(milliseconds: 700),
                                  backgroundColor: color_black_88,
                                  context: context,
                                  builder: (context) {
                                    return StatefulBuilder(
                                        builder: (context, setState) {
                                      return SizedBox(
                                        height: 200,
                                        width: width,
                                        child: Column(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 20, bottom: 60),
                                              child: DelayedDisplay(
                                                delay: const Duration(
                                                    milliseconds: 450),
                                                child: RichText(
                                                  text: TextSpan(
                                                    text:
                                                        'От ${_valuesAge.start} до ${_valuesAge.end} лет',
                                                    style: GoogleFonts.lato(
                                                      textStyle:
                                                          const TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 13,
                                                              letterSpacing:
                                                                  .9),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SfRangeSlider(
                                              activeColor: Colors.blue,
                                              min: 16,
                                              max: 30,
                                              values: _valuesAge,
                                              stepSize: 1,
                                              enableTooltip: true,
                                              onChanged:
                                                  (SfRangeValues values) {
                                                setState(() {
                                                  _valuesAge = values;
                                                  _ageRangController.text =
                                                      'От ${_valuesAge.start} до ${_valuesAge.end} лет';
                                                });
                                              },
                                            ),
                                          ],
                                        ),
                                      );
                                    });
                                  });
                            }),
                            textFieldProfileSettings(
                                _descriptionController,
                                false,
                                'Расскажите о себе (необязательно)',
                                context,
                                100,
                                height,
                                () {},
                                3),
                            textFieldProfileSettings(_notificationController,
                                true, 'Уведомления', context, 10, height, () {
                              showBottomSheet(
                                  context,
                                  'Укажите хотите получать уведомления',
                                  'Включить',
                                  'Выключить',
                                  _notificationController);
                            }),
                            textFieldProfileSettings(_supportController, true,
                                'Техподдержка', context, 30, height, () async {
                              String gmail = 'lancelotsuport@gmail.com';
                              _launchUrl(gmail);
                            }, 2),
                            Theme(
                              data: ThemeData.light(),
                              child: MediaQuery(
                                data: MediaQuery.of(context)
                                    .copyWith(textScaleFactor: 1.0),
                                child: Card(
                                  color: color_black_88,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18),
                                      side: const BorderSide(
                                        width: 0.8,
                                        color: Colors.white38,
                                      )),
                                  elevation: 10,
                                  child: Container(
                                    padding: const EdgeInsets.only(
                                        top: 8, bottom: 8),
                                    child: MultiSelectBottomSheetField(
                                      initialValue: modelUser.userInterests,
                                      searchHintStyle:
                                          const TextStyle(color: Colors.white),
                                      buttonText: Text(
                                        'Выбрать $interestsCount максимум (6)',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: height / 62),
                                      ),
                                      buttonIcon: Icon(
                                        Icons.arrow_forward_ios_outlined,
                                        color: Colors.white,
                                        size: height / 54,
                                      ),
                                      backgroundColor: color_black_88,
                                      checkColor: Colors.white,
                                      confirmText: Text(
                                        'Выбрать',
                                        style: GoogleFonts.lato(
                                            textStyle: TextStyle(
                                                color: Colors.blueAccent,
                                                fontSize: height / 60,
                                                letterSpacing: .6)),
                                      ),
                                      cancelText: Text(
                                        'Закрыть',
                                        style: GoogleFonts.lato(
                                            textStyle: TextStyle(
                                                color: Colors.blueAccent,
                                                fontSize: height / 60,
                                                letterSpacing: .6)),
                                      ),
                                      searchIcon: const Icon(
                                        Icons.search,
                                        color: Colors.white,
                                      ),
                                      closeSearchIcon: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                      ),
                                      searchHint: 'Поиск',
                                      searchTextStyle:
                                          const TextStyle(color: Colors.white),
                                      initialChildSize: 0.4,
                                      listType: MultiSelectListType.CHIP,
                                      searchable: true,
                                      itemsTextStyle: GoogleFonts.lato(
                                          textStyle: TextStyle(
                                              color: Colors.black,
                                              fontSize: height / 60,
                                              letterSpacing: .6)),
                                      selectedItemsTextStyle: GoogleFonts.lato(
                                          textStyle: TextStyle(
                                              color: Colors.black,
                                              fontSize: height / 60,
                                              letterSpacing: .6)),
                                      title: animatedText(
                                          height / 60,
                                          "Ваши интересы ${interestsCount.toString()} максимум (6)",
                                          Colors.white,
                                          500,
                                          1),
                                      items: items,
                                      onSelectionChanged: (value) {
                                        setState(() {
                                          interestsCount = value.length;
                                        });
                                      },
                                      onConfirm: (values) {
                                        setState(() {
                                          _selectedInterests = values;
                                        });
                                      },
                                      chipDisplay: MultiSelectChipDisplay(
                                        onTap: (value) {
                                          setState(() {
                                            _selectedInterests.remove(value);
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: height * .05,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return WillPopScope(
        onWillPop: () async {
          return !isFirst;
        },
        child: const loadingCustom());
  }

  SizedBox imageProfileSettings(double height, BuildContext context) {
    return SizedBox(
      height: height / 6.5,
      width: height / 6.5,
      child: Card(
        shadowColor: Colors.white30,
        color: color_black_88,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
            side: const BorderSide(
              width: 0.8,
              color: Colors.white30,
            )),
        elevation: 6,
        child: Stack(
          alignment: Alignment.bottomRight,
          children: [
            if (modelUser.userImageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: CachedNetworkImage(
                  imageBuilder: (context, imageProvider) => Container(
                    decoration: BoxDecoration(
                      borderRadius:
                          const BorderRadius.all(Radius.circular(100)),
                      image: DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.cover,
                          alignment: Alignment.topCenter),
                    ),
                  ),
                  progressIndicatorBuilder: (context, url, progress) => Center(
                    child: SizedBox(
                      height: height / 6.5,
                      width: height / 6.5,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 0.8,
                        value: progress.progress,
                      ),
                    ),
                  ),
                  imageUrl: modelUser.userImageUrl[0],
                  fit: BoxFit.cover,
                ),
              ),
            if (modelUser.userImageUrl.isEmpty)
              customIconButton(
                path: 'images/ic_add.png',
                width: height / 36,
                height: height / 36,
                onTap: () async {
                  uploadFirstImage(context, modelUser.userImageUrl,
                          modelUser.userImagePath)
                      .then((uri) {
                    setState(() {
                      if (uri != '') {
                        isPhoto = true;
                        modelUser.userImageUrl.add(uri);
                      }
                    });
                  });
                },
                padding: 6,
              ),
            if (modelUser.userImageUrl.isNotEmpty)
              customIconButton(
                path: 'images/ic_edit.png',
                width: height / 36,
                height: height / 36,
                onTap: () async {
                  updateFirstImage(context, modelUser, true);
                },
                padding: 3,
              ),
          ],
        ),
      ),
    );
  }

  Future<dynamic> showBottomSheet(
      context, title, select_1, select_2, TextEditingController controller) {
    return showCupertinoModalBottomSheet(
        topRadius: const Radius.circular(30),
        duration: const Duration(milliseconds: 800),
        backgroundColor: color_black_88,
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return Container(
              height: 260,
              padding: const EdgeInsets.all(28),
              width: MediaQuery.of(context).size.width,
              child: Column(
                children: [
                  Card(
                    shadowColor: Colors.white30,
                    color: color_black_88,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: const BorderSide(
                          width: 0.8,
                          color: Colors.white38,
                        )),
                    elevation: 16,
                    child: Theme(
                      data: ThemeData.light(),
                      child: ExpansionTile(
                        initiallyExpanded: true,
                        title: animatedText(12, title, Colors.white, 0, 2),
                        children: [
                          ListTile(
                            title: animatedText(
                                12, select_1, Colors.white, 600, 1),
                            onTap: () {
                              setState(() {
                                controller.text = select_1;
                                Navigator.pop(context);
                              });
                            },
                          ),
                          ListTile(
                            title: animatedText(
                                12, select_2, Colors.white, 600, 1),
                            onTap: () {
                              setState(() {
                                controller.text = select_2;
                                Navigator.pop(context);
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          });
        });
  }
}
