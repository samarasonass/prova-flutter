import 'package:flutter/material.dart';


final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);


const Color corApp = Colors.pink;

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: corApp),
    inputDecorationTheme:
        const InputDecorationTheme(border: OutlineInputBorder()),
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme:
        ColorScheme.fromSeed(seedColor: corApp, brightness: Brightness.dark),
    inputDecorationTheme:
        const InputDecorationTheme(border: OutlineInputBorder()),
  );

  static Color corPrioridade(String p) {
    switch (p) {
      case 'Alta':
        return Colors.red;
      case 'Baixa':
        return Colors.green;
      default:
        return Colors.orange;
    }
  }

  static IconData iconePrioridade(String p) {
    switch (p) {
      case 'Alta':
        return Icons.keyboard_double_arrow_up;
      case 'Baixa':
        return Icons.keyboard_arrow_down;
      default:
        return Icons.drag_handle;
    }
  }
}
