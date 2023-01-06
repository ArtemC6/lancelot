import 'package:flutter/material.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';

const color_blue_90 = Color(0xff192028);
const color_black_88 = Color(0xff212428);
const color_red = Color(0xFFFC0465);

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
  'Рыбалка',
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

final items = interestsList
    .map((interests) => MultiSelectItem<String>(interests, interests))
    .toList();


const List<IconData> listOfIcons = [
  Icons.home_rounded,
  Icons.favorite_rounded,
  Icons.message,
  Icons.person_rounded,
];
