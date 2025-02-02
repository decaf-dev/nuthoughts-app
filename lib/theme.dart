import 'package:flutter/material.dart';

class LightColors {
  static Color white100 = Color(0xfff4f6f8);
  static Color white200 = Color(0xfff0f0f0);
  static Color gray400 = Color(0xffbbbdbe);
  static Color blue900 = Color(0xff35364b);
}

final ThemeData theme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.light(
      primary: Colors.white,
      onPrimary: LightColors.blue900,
      secondary: LightColors.white100,
      onSecondary: LightColors.blue900,
      tertiary: Colors.blue,
      onTertiary: Colors.white,
      outline: LightColors.white200),
);

class DarkColors {
  static Color blue600 = Color(0xff4f5457);
  static Color blue700 = Color(0xff3a4147);
  static Color blue800 = Color(0xff1c232e);
  static Color blue900 = Color(0xff11191f);
}

final ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.dark(
      primary: DarkColors.blue800,
      onPrimary: Colors.white,
      secondary: DarkColors.blue800,
      onSecondary: DarkColors.blue600,
      tertiary: Colors.blue,
      onTertiary: Colors.white,
      outline: DarkColors.blue700),
);
