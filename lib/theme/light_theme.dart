import 'package:flutter/material.dart';

ThemeData light({Color color = const Color(0xFFfcb817)}) => ThemeData(
      scaffoldBackgroundColor: Colors.white,
      fontFamily: 'Roboto',
      primaryColor: color,
      secondaryHeaderColor: const Color(0xFF913F83),
      shadowColor: const Color(0xffF7F7F7),
      disabledColor: const Color(0xFFBABFC4),
      brightness: Brightness.light,
      hintColor: const Color(0xFF9F9F9F),
      cardColor: Colors.white,
      textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: color)),
      colorScheme: ColorScheme.light(primary: color, secondary: color)
          .copyWith(background: const Color(0xFFF3F3F3))
          .copyWith(error: const Color(0xFFE84D4F)),
    );
