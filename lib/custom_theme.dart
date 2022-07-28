import 'package:flutter/material.dart';

class CustomTheme {
  static ThemeData get darkTheme {
    return ThemeData.dark().copyWith(
      primaryColor: Colors.purple[800],
      scaffoldBackgroundColor: Colors.grey[800],
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        foregroundColor: Colors.black,
        backgroundColor: Colors.amber[700],
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
            primary: Colors.amber[700],
            onPrimary: Colors.black,
            textStyle: const TextStyle(
              fontSize: 15,
            ),
            padding: const EdgeInsets.all(15)),
      ),
      appBarTheme: AppBarTheme(
        color: Colors.indigo[800],
      ),
      errorColor: const Color.fromARGB(255, 255, 115, 0),
      // inputDecorationTheme: const InputDecorationTheme(
      //     labelStyle: TextStyle(
      //       color: Colors.amber,
      //     ),
      //     border: OutlineInputBorder(),
      //     focusedBorder: OutlineInputBorder(
      //       borderSide: BorderSide(
      //         color: Colors.amber,
      //       ),
      //     ),
      //     ),
    );
  }
}
