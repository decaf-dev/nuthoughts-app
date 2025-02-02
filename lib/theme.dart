import 'package:flutter/material.dart';

const Color white2 = Color(0xfff4f6f8);
const Color darkBlue = Color(0xff35364b);
const Color lightGray = Color(0xfff0f0f0);
const Color gray2 = Color(0xffbbbdbe);

final ThemeData theme = ThemeData(
  useMaterial3: true,
  colorScheme: const ColorScheme.light(
      primary: Colors.white,
      onPrimary: darkBlue,
      secondary: white2,
      onSecondary: darkBlue,
      tertiary: Colors.blue,
      onTertiary: Colors.white,
      outline: lightGray),
);

const Color darkBlue2 = Color(0xff1c232e);
const Color darkerBlue2 = Color(0xff11191f);
const Color darkGray = Color(0xff4f5457);
const Color borderGray = Color(0xff3a4147);

final ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.dark(
      primary: darkBlue2,
      onPrimary: Colors.white,
      secondary: darkBlue2,
      onSecondary: darkGray,
      tertiary: Colors.blue,
      onTertiary: Colors.white,
      outline: borderGray),
);
