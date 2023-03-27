import 'package:rive/rive.dart';

class RiveAsset {
  final String art, stateMachineName, title, src;
  late SMIBool? input;

  RiveAsset(this.src,
      {required this.art,
      required this.stateMachineName,
      required this.title,
      this.input});

  set setInput(SMIBool status) => input = status;
}
