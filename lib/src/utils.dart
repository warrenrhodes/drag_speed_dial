import 'package:flutter/material.dart';


/// Describe the preferences keys.
class PreferencesKeys{
  static const String isButtonCollapsed = 'isButtonCollapsed';
}

const darkLinearGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color.fromRGBO(60, 28, 20, 1),
      Color.fromRGBO(61, 29, 18, 1),
      Color.fromRGBO(52, 23, 15, 1),
      Color.fromRGBO(46, 21, 14, 1),
      Color.fromRGBO(40, 18, 13, 1),
      Color.fromRGBO(30, 16, 11, 1),
      Color.fromRGBO(29, 14, 10, 1),
      Color.fromRGBO(16, 9, 6, 1),
    ]);

const lightLinearGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color.fromRGBO(245, 245, 245, 1),
      Color.fromRGBO(245, 245, 245, 1),
      Color.fromRGBO(245, 245, 245, 1),
      Color.fromRGBO(245, 245, 245, 1),
    ]);