import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../config/const.dart';
import '../../widget/dialog_widget.dart';

class WarningScreen extends StatefulWidget {
  const WarningScreen({Key? key}) : super(key: key);

  @override
  State<WarningScreen> createState() => _WarningScreenState();
}

class _WarningScreenState extends State<WarningScreen> {
  @override
  void initState() {
    Future.delayed(Duration.zero, () => showAlertDialogWarning(context));
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: color_black_88,
    );
  }
}
