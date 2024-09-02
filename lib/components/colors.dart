import 'package:flutter/material.dart';

String hexDarkBlue = "#293241";
String hexMediumBlue = "#3D5A80";
String hexLightBlue = "#98C1D9";
String hexOrange = "#EE6C4D";

Color hexToColor(String hexString, {String alpha = 'FF'}) {
  return Color(int.parse(hexString.replaceFirst('#', '0x$alpha')));
}

const Color darkBlue = Color(0xFF293241);
const Color mediumBlue = Color(0xFF3D5A80);
const Color lightBlue = Color(0xFF98C1D9);
const Color orange = Color(0xFFEE6C4D);
const Color white = Color(0xFFFFFFFF);
const Color gridGrey = Color(0x4C293241);

Color alphaDarkBlue = darkBlue.withAlpha(150);

class AppColorScheme extends ColorScheme {
  static const Color appDarkBlue = darkBlue;
  static const Color appMediumBlue = mediumBlue;
  static const Color appLightBlue = lightBlue;
  static const Color appOrange = orange;
  static const Color appWhite = white;
  static Color alphaDarkBlue = const Color(0xFF293241).withAlpha(150);

  const AppColorScheme({
    super.primary = darkBlue,
    super.secondary = lightBlue,
    super.surface = white,
    super.background = white,
    super.error = orange,
    super.onPrimary = white,
    super.onSecondary = darkBlue,
    super.onSurface = darkBlue,
    super.onBackground = darkBlue,
    super.onError = white,
    super.brightness = Brightness.light,
  });
}
