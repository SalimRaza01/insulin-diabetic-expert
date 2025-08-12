import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
        //background color
        onPrimary: Color.fromARGB(255, 242, 242, 247),
        //foreground color
        primary: Color.fromARGB(255, 255, 255, 255),
        //appBar Color
        secondary: Color.fromARGB(255, 5, 53, 93),
        //Title Color
        primaryContainer: Color.fromARGB(255, 100, 100, 100),
        tertiary: Color.fromARGB(255, 5, 53, 93),
        tertiaryContainer: Colors.white,
        onSecondary: Color.fromARGB(255, 5, 53, 93),
        onSurface: Color.fromARGB(255, 242, 242, 247),
        onPrimaryContainer: Colors.white,
        onInverseSurface: Color.fromARGB(255, 59, 58, 58),
        //SubtitleClor
        secondaryContainer: Color.fromARGB(255, 100, 100, 100), 
        surface: Color.fromARGB(255, 255, 255, 255),
        outline: Color.fromARGB(255, 242, 242, 247)
        
        ));

ThemeData darkMode = ThemeData(
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
        //background color
        onPrimary: Color.fromARGB(255, 13, 13, 13),
        //foreground color
        primary: Color.fromARGB(255, 44, 44, 44),
        //appBar Color
        secondary: Color.fromARGB(255, 44, 44, 44),
        tertiaryContainer: Color.fromARGB(255, 69, 67, 67),
        //Title Color
        primaryContainer: Color.fromARGB(255, 255, 255, 255),
        //SubtitleClor
        secondaryContainer: Color.fromARGB(255, 234, 234, 234),
        onPrimaryContainer: const Color.fromARGB(255, 228, 227, 227),
        onSecondary: Colors.black,
        onSurface: Color.fromARGB(255, 69, 67, 67),
         onInverseSurface: Color.fromARGB(255, 255, 255, 255),
        surface: Color.fromARGB(255, 214, 214, 214),
        outline: Color.fromARGB(255, 13, 13, 13),
        //screenText
        tertiary: Colors.white));
        
