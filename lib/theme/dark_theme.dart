import 'package:flutter/material.dart';

ThemeData dark({Color color = const Color(0xf7fcb817)}) => ThemeData(
      fontFamily: 'Roboto',
      primaryColor: color,
      secondaryHeaderColor: const Color(0xFF913F83),
      disabledColor: const Color(0xffa2a7ad),
      brightness: Brightness.dark,
      hintColor: const Color(0xFFbebebe),
      cardColor: Colors.black,
      textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: color)),
      colorScheme: ColorScheme.dark(primary: color, secondary: color)
          .copyWith(background: const Color(0xFF343636))
          .copyWith(error: const Color(0xFFdd3135)),
    );
