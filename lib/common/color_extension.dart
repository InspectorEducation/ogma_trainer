import 'package:flutter/material.dart';

class TColor {
  static Color get primaryColor1 => const Color(0xff55c1ff);
  static Color get primaryColor2 => const Color(0xff5887ff);

  static Color get secondaryColor1 => const Color(0xff9776e8);
  static Color get secondaryColor2 => const Color(0xff715aff);

  static List<Color> get primaryG =>[ primaryColor1, primaryColor2 ];
  static List<Color> get secondaryG => [ secondaryColor1, secondaryColor2 ];

  static Color get black => const Color(0xff1d1617);
  static Color get gray => const Color(0xff786f72);
  static Color get white => Colors.white;
  static Color get lightGray => const Color(0xfff7f8f8);
}