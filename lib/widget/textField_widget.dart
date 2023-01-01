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
    BuildContext context) {
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
          obscureText: isPassword,
          inputFormatters: [
            LengthLimitingTextInputFormatter(length),
          ],
          textAlignVertical: TextAlignVertical.center,
          controller: controller,
          style: TextStyle(
              color: Colors.white.withOpacity(.8), fontSize: size.width / 30),
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
                fontSize: size.width / 32, color: Colors.white.withOpacity(.5)),
          ),
        ),
      ),
    ),
  );
}

Widget textFieldProfileSettings(TextEditingController nameController,
    bool isLook, String hint, BuildContext context, int length, double height,  VoidCallback onTap) {
  return MediaQuery(
    data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
    child: SizedBox(
      height: height * .11,
      child: Theme(
        data: ThemeData.dark(),
        child: Column(
          children: [
            TextField(
              inputFormatters: [
                LengthLimitingTextInputFormatter(length),
              ],
              enableInteractiveSelection: isLook,
              readOnly: isLook,
              onTap: onTap,
              controller: nameController,
              style: GoogleFonts.lato(
                  textStyle:  TextStyle(
                      color: Colors.white, fontSize: height / 60, letterSpacing: .5)),
              decoration: InputDecoration(
                suffixIcon: const Icon(
                  Icons.arrow_forward_ios_outlined,
                  color: Colors.white,
                  size: 18,
                ),
                labelText: hint,
                floatingLabelStyle:  TextStyle(
                  color: Colors.white,
                  fontSize: height / 60,
                  fontWeight: FontWeight.bold,
                ),
                labelStyle: TextStyle(
                  fontSize: height / 60,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.blueAccent),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
