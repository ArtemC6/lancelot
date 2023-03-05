import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class textFieldAuth extends StatelessWidget {
  const textFieldAuth({
    super.key,
    required this.hint,
    required this.controller,
    required this.icon,
    required this.isPassword,
    required this.length,
    required this.onSubmitted,
  });

  final String hint;
  final TextEditingController controller;
  final IconData icon;
  final bool isPassword;
  final int length;
  final dynamic onSubmitted;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaY: 15,
          sigmaX: 15,
        ),
        child: Container(
          height: width / 7.7,
          width: width / 1.2,
          alignment: Alignment.center,
          padding: EdgeInsets.only(right: width / 30),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white10, width: 0.5),
            color: Colors.white.withOpacity(.05),
            borderRadius: BorderRadius.circular(15),
          ),
          child: TextField(
            onSubmitted: onSubmitted,
            obscureText: isPassword,
            inputFormatters: [
              LengthLimitingTextInputFormatter(length),
            ],
            textAlignVertical: TextAlignVertical.center,
            controller: controller,
            style: TextStyle(
                color: Colors.white.withOpacity(.8), fontSize: height / 58),
            cursorColor: Colors.white,
            decoration: InputDecoration(
              prefixIcon: Icon(
                icon,
                color: Colors.white.withOpacity(.7),
              ),
              border: InputBorder.none,
              hintMaxLines: 1,
              hintText: hint,
              hintStyle: TextStyle(
                  fontSize: height / 58, color: Colors.white.withOpacity(.5)),
            ),
          ),
        ),
      ),
    );
  }
}

class textFieldProfileSettings extends StatelessWidget {
  const textFieldProfileSettings({
    super.key,
    required this.nameController,
    required this.isLook,
    required this.hint,
    required this.length,
    required this.onTap,
    required this.imaxLength,
  });

  final TextEditingController nameController;
  final bool isLook;
  final String hint;
  final int length, imaxLength;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Padding(
      padding: EdgeInsets.only(
          top: height / 62,
          bottom: imaxLength > 2 ? height / 360 : height / 62),
      child: Theme(
        data: ThemeData.dark(),
        child: TextField(
          maxLength: length,
          inputFormatters: [
            LengthLimitingTextInputFormatter(length),
          ],
          enableInteractiveSelection: isLook,
          readOnly: isLook,
          maxLines: imaxLength,
          minLines: 1,
          onTap: onTap,
          controller: nameController,
          style: GoogleFonts.lato(
              textStyle: TextStyle(
                  color: Colors.white,
                  fontSize: height / 58,
                  letterSpacing: .5)),
          decoration: InputDecoration(
            helperStyle: GoogleFonts.lato(
                textStyle: TextStyle(
                    color: Colors.white70,
                    fontSize: height / 78,
                    letterSpacing: .6)),
            counterText: imaxLength > 2 ? null : '',
            suffixIcon: const Icon(
              Icons.arrow_forward_ios_outlined,
              color: Colors.white,
              size: 18,
            ),
            labelText: hint,
            floatingLabelStyle: GoogleFonts.lato(
                textStyle: TextStyle(
                    color: Colors.white,
                    fontSize: height / 50,
                    letterSpacing: .6)),
            labelStyle: GoogleFonts.lato(
              textStyle: TextStyle(
                  color: Colors.white,
                  fontSize: height / 56,
                  letterSpacing: .6),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.blueAccent),
            ),
          ),
        ),
      ),
    );
  }
}
