import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

Widget textFieldAuth(
    String hint,
    TextEditingController controller,
    IconData icon,
    Size size,
    bool isPassword,
    int length,
    BuildContext context,
    onSubmitted) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(15),
    child: BackdropFilter(
      filter: ImageFilter.blur(
        sigmaY: 15,
        sigmaX: 15,
      ),
      child: Container(
        height: size.width / 8,
        width: size.width / 1.2,
        alignment: Alignment.center,
        padding: EdgeInsets.only(right: size.width / 30),
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
              color: Colors.white.withOpacity(.8), fontSize: size.height / 61),
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
                fontSize: size.height / 61,
                color: Colors.white.withOpacity(.5)),
          ),
        ),
      ),
    ),
  );
}

Widget textFieldProfileSettings(
    TextEditingController nameController,
    bool isLook,
    String hint,
    BuildContext context,
    int length,
    double height,
    onTap,
    [imaxLength = 1]) {
  return Padding(
    padding: EdgeInsets.only(
        top: height / 62, bottom: imaxLength > 2 ? height / 360 : height / 62),
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
                color: Colors.white, fontSize: height / 58, letterSpacing: .5)),
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
                  letterSpacing: .6)),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.blueAccent),
          ),
        ),
      ),
    ),
  );
}
