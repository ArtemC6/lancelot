import 'package:flutter/material.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';

import '../model/rive_model.dart';

const color_blue_90 = Color(0xff192028);
const color_black_88 = Color(0xff212428);
const color_red = Color(0xFFFC0465);

const Map<String, dynamic> dataCash = {};

class FadeRouteAnimation extends PageRouteBuilder {
  final Widget page;

  FadeRouteAnimation(this.page)
      : super(
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              page,
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) =>
              FadeTransition(
            opacity: animation,
            child: page,
          ),
        );
}

final List<String> interestsList = [
  "Фильмы",
  "Музыка",
  "Книги",
  "Спорт",
  "Путешествие",
  "Киберспорт",
  "Кулинария",
  "Мотоциклы",
  "Искусство",
  "Автомобили",
  "Волонтёрство",
  "Велоспорт",
  "TikTok",
  "Instagram",
  'Танцы',
  'Рукоделие',
  'Астрология',
  'Поэзия',
];

const List months = [
  'янв.',
  'февр.',
  'марта',
  'апр.',
  'мая',
  'июня',
  'июля',
  'авг.',
  'сент.',
  'окт.',
  'нояб.',
  'декаб.',
];

const List<Color> listColorsAnimation = [
  Colors.black12,
  Colors.white10,
  Colors.white54,
  Colors.white70,
];

const List<Color> listColorMulticoloured = [
  Colors.blueAccent,
  Colors.purpleAccent,
  Colors.orangeAccent
];

const List<IconData> listOfIcons = [
  Icons.home_rounded,
  Icons.favorite_rounded,
  Icons.message,
  Icons.person_rounded,
];

const List<String> listAnimationChatBac = [
  'images/animation_chat_bac_1.json',
  'images/animation_chat_bac_2.json',
  'images/animation_chat_bac_3.json',
  'images/animation_chat_bac_5.json',
  'images/animation_chat_bac_4.json',
  'images/animation_chat_bac_6.json',
];

List<RiveAsset> bottomNav = [
  RiveAsset("images/rive/animation_rive_icons",
      art: "HOME", stateMachineName: "HOME_interactivity", title: "Chat"),
  RiveAsset("images/rive/animation_rive_icons",
      art: "BELL",
      stateMachineName: "BELL_Interactivity",
      title: "Notifications"),
  RiveAsset("images/rive/animation_rive_icons",
      art: "CHAT", stateMachineName: "CHAT_Interactivity", title: "Chat"),
  RiveAsset("images/rive/animation_rive_icons",
      art: "USER", stateMachineName: "USER_Interactivity", title: "Profile"),
];

final items = interestsList
    .map((interests) => MultiSelectItem<String>(interests, interests))
    .toList();

