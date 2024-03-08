import 'package:flutter/material.dart';

ThemeData themeData = ThemeData(
    scaffoldBackgroundColor: Colors.white,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
         minimumSize: const Size.fromHeight(50),
        backgroundColor: const Color.fromARGB(255, 8, 149, 128),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(4)),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
        //  minimumSize: const Size.fromHeight(40),

      foregroundColor: const Color.fromARGB(255, 8, 149, 128),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(4)),
      ),
    )),
    inputDecorationTheme: InputDecorationTheme(
      border: underlineInputBorder,
      errorBorder: underlineInputBorder,
      enabledBorder: underlineInputBorder,
      focusedBorder: underlineInputBorder,
      disabledBorder: underlineInputBorder,
    ));

UnderlineInputBorder underlineInputBorder = const UnderlineInputBorder(
    borderSide: BorderSide(
  color: Color.fromARGB(255, 54, 79, 54),
));
