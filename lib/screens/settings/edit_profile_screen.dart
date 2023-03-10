import 'package:bottom_sheet/bottom_sheet.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delayed_display/delayed_display.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:multi_select_flutter/bottom_sheet/multi_select_bottom_sheet_field.dart';
import 'package:multi_select_flutter/chip_display/multi_select_chip_display.dart';
import 'package:multi_select_flutter/util/multi_select_list_type.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

import '../../config/const.dart';
import '../../config/firebase/firestore_operations.dart';
import '../../config/firebase_auth.dart';
import '../../config/utils.dart';
import '../../model/user_model.dart';
import '../../widget/animation_widget.dart';
import '../../widget/button_widget.dart';
import '../../widget/dialog_widget.dart';
import '../../widget/textField_widget.dart';
import '../manager_screen.dart';
import 'edit_image_profile_screen.dart';

class EditProfileScreen extends StatefulWidget {
  final bool isFirst;
  final UserModel userModel;

  const EditProfileScreen(
      {super.key, required this.isFirst, required this.userModel});

  @override
  State<EditProfileScreen> createState() =>
      _EditProfileScreenState(isFirst, userModel);
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final bool isFirst;
  UserModel modelUser;

  _EditProfileScreenState(this.isFirst, this.modelUser);

  bool isLoading = false, isError = false, isPhoto = true;
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
  var _dateTimeBirthday = DateTime.now();
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
      isError = false;
      isPhoto = true;

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
        'token': await getTokenUser(),
      };

      FirebaseFirestore.instance
          .collection('User')
          .doc(modelUser.uid)
          .update(json)
          .then((value) {
        if (modelUser.imageBackground != '') {
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
        } else {
          Navigator.pushReplacement(
              context,
              FadeRouteAnimation(
                  EditImageProfileScreen(bacImage: modelUser.imageBackground)));
        }
      });
    } else {
      isError = true;
      if (modelUser.userImageUrl.isNotEmpty) {
        isPhoto = true;
      } else {
        isPhoto = false;
      }
    }
    setState(() {});
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

    if (modelUser.userImageUrl.isNotEmpty) isPhoto = true;

    _selectedInterests = modelUser.userInterests;
    interestsCount = modelUser.userInterests.length;
    _dateTimeBirthday = getDataTime(modelUser.ageTime);
  }

  Future readFirebase() async {
    if (modelUser.uid == '') {
      await readUserFirebase().then((user) {
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
      });
    }

    settingsValue();
    setState(() => isLoading = true);
  }


  @override
  void initState() {
    readFirebase();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    SizedBox imageProfileSettings(double height, BuildContext context) {
      return SizedBox(
        height: width / 2.8,
        width: width / 2.8,
        child: Card(
          shadowColor: Colors.white30,
          color: color_black_88,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100),
              side: const BorderSide(
                width: 0.8,
                color: Colors.white30,
              )),
          elevation: 8,
          child: GestureDetector(
            onTap: () {
              if (modelUser.userImageUrl.isEmpty) {
                uploadFirstImage(context, modelUser).then((uri) {
                  if (uri != '') {
                    modelUser.userImageUrl.add(uri);
                    setState(() => isPhoto = true);
                  }
                });
              } else {
                updateFirstImage(context, modelUser, true);
              }
            },
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                if (modelUser.userImageUrl.isNotEmpty)
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                    ),
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
                      progressIndicatorBuilder: (context, url, progress) =>
                          Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: Shimmer(
                            child: SizedBox(
                              height: width / 2.8,
                              width: width / 2.8,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 0.8,
                                value: progress.progress,
                              ),
                            ),
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
                    width: height / 34,
                    height: height / 34,
                    onTap: () async {
                      uploadFirstImage(context, modelUser).then((uri) {
                        if (uri != '') {
                          modelUser.userImageUrl.add(uri);
                          setState(() => isPhoto = true);
                        }
                      });
                    },
                    padding: 6,
                  ),
                if (modelUser.userImageUrl.isNotEmpty)
                  customIconButton(
                    path: 'images/ic_edit.png',
                    width: height / 32,
                    height: height / 32,
                    onTap: () async {
                      updateFirstImage(context, modelUser, true);
                    },
                    padding: 5,
                  ),
              ],
            ),
          ),
        ),
      );
    }

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
                padding: EdgeInsets.symmetric(horizontal: height / 66),
                child: AnimationLimiter(
                  child: AnimationConfiguration.staggeredList(
                    position: 1,
                    child: SlideAnimation(
                      duration: const Duration(milliseconds: 1800),
                      verticalOffset: height * .40,
                      child: FadeInAnimation(
                        curve: Curves.easeOut,
                        duration: const Duration(milliseconds: 3800),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                if (!isFirst)
                                  IconButton(
                                    color: Colors.white,
                                    onPressed: () => Navigator.pop(context),
                                    icon: Icon(Icons.arrow_back_ios_new_rounded,
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
                            imageProfileSettings(
                              height,
                              context,
                            ),
                            DelayedDisplay(
                              delay: const Duration(milliseconds: 700),
                              child: Container(
                                padding: EdgeInsets.only(
                                    bottom: height / 62,
                                    top: height / 52,
                                    right: height / 64),
                                alignment: Alignment.centerRight,
                                child: buttonUniversal(
                                  text: isFirst ? 'Завершить' : 'Сохранить',
                                  time: 900,
                                  sizeText: width / 32,
                                  height: width / 10,
                                  width: width / 3.1,
                                  darkColors: true,
                                  colorButton: listColorMulticoloured,
                                  onTap: () {
                                    _uploadData();
                                  },
                                ),
                              ),
                            ),
                            if (isError)
                              Padding(
                                padding: EdgeInsets.all(height / 66),
                                child: animatedText(
                                    height / 68,
                                    'Данные введены некорректно',
                                    Colors.red,
                                    500,
                                    1),
                              ),
                            if (!isPhoto)
                              Padding(
                                padding: EdgeInsets.all(height / 66),
                                child: animatedText(
                                    height / 68,
                                    'Добавьте главное фото',
                                    Colors.red,
                                    550,
                                    1),
                              ),
                            textFieldProfileSettings(
                                nameController: _nameController,
                                isLook: false,
                                hint: 'Имя',
                                length: 10,
                                imaxLength: 1,
                                onTap: () {}),
                            textFieldProfileSettings(
                                nameController: _ageController,
                                isLook: true,
                                hint: 'Возраст',
                                length: 3,
                                imaxLength: 1,
                                onTap: () => showDatePicker()),
                            textFieldProfileSettings(
                                nameController: _myPolController,
                                isLook: true,
                                hint: 'Ваш пол',
                                length: 10,
                                imaxLength: 1,
                                onTap: () async {
                                  showBottomSheetShow(
                                      context,
                                      'Укажите свой пол',
                                      'Мужской',
                                      'Женский',
                                      _myPolController,
                                      height);
                                }),
                            textFieldProfileSettings(
                                nameController: _searchPolController,
                                isLook: true,
                                hint: 'С кем вы хотите познакомиться',
                                length: 10,
                                imaxLength: 1,
                                onTap: () {
                                  showBottomSheetShow(
                                      context,
                                      'Укажите с кем вы хотите познакомиться',
                                      'С парнем',
                                      'С девушкой',
                                      _searchPolController,
                                      height);
                                }),
                            textFieldProfileSettings(
                                nameController: _localController,
                                isLook: true,
                                hint: 'Вы проживаете',
                                length: 10,
                                imaxLength: 1,
                                onTap: () {
                                  showBottomSheetShow(
                                      context,
                                      'Укажите где вы проживаете',
                                      'Бишкек',
                                      'Каракол',
                                      _localController,
                                      height);
                                }),
                            textFieldProfileSettings(
                                nameController: _ageRangController,
                                isLook: true,
                                hint: 'Диапазон поиска',
                                length: 14,
                                imaxLength: 1,
                                onTap: () {
                                  showFlexibleBottomSheet(
                                      duration:
                                          const Duration(milliseconds: 700),
                                      decoration: const BoxDecoration(
                                          color: color_black_88,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(16))),
                                      bottomSheetColor: Colors.transparent,
                                      initHeight: 0.28,
                                      context: context,
                                      builder: (
                                        BuildContext context,
                                        ScrollController scrollController,
                                        double bottomSheetOffset,
                                      ) {
                                        return StatefulBuilder(
                                            builder: (context, setState) {
                                          return SizedBox(
                                            height: 300,
                                            width: width,
                                            child: Column(
                                              children: [
                                                Padding(
                                                    padding: EdgeInsets.only(
                                                        top: 20,
                                                        bottom: height / 18),
                                                    child: animatedText(
                                                        height / 57,
                                                        'От ${_valuesAge.start} до ${_valuesAge.end} лет',
                                                        Colors.white,
                                                        450,
                                                        1)),
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
                                nameController: _descriptionController,
                                isLook: false,
                                hint: 'Расскажите о себе (необязательно)',
                                length: 100,
                                imaxLength: 3,
                                onTap: () {}),
                            textFieldProfileSettings(
                                nameController: _notificationController,
                                isLook: true,
                                hint: 'Уведомления',
                                length: 10,
                                imaxLength: 1,
                                onTap: () {
                                  showBottomSheetShow(
                                      context,
                                      'Укажите хотите получать уведомления',
                                      'Включить',
                                      'Выключить',
                                      _notificationController,
                                      height);
                                }),
                            textFieldProfileSettings(
                                nameController: _supportController,
                                isLook: true,
                                hint: 'Техподдержка',
                                length: 30,
                                imaxLength: 1,
                                onTap: () async {
                                  launchUrlEmail('lancelotsuport@gmail.com');
                                }),
                            Theme(
                              data: ThemeData.light(),
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
                                  padding:
                                      const EdgeInsets.only(top: 8, bottom: 8),
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
                                      setState(
                                          () => interestsCount = value.length);
                                    },
                                    onConfirm: (values) {
                                      setState(
                                          () => _selectedInterests = values);
                                    },
                                    chipDisplay: MultiSelectChipDisplay(
                                      onTap: (value) {
                                        setState(() =>
                                            _selectedInterests.remove(value));
                                      },
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
}
