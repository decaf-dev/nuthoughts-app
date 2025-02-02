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

final ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.purple,
    brightness: Brightness.dark,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.black,
    foregroundColor: Colors.black,
  ),
);
