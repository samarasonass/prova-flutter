import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const _chaveTema = 'tema_escuro';

  Future<void> salvarTema(ThemeMode modo) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_chaveTema, modo == ThemeMode.dark);
  }

  Future<ThemeMode> carregarTema() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getBool(_chaveTema) ?? false) ? ThemeMode.dark : ThemeMode.light;
  }
}
