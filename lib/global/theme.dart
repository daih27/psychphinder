import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ThemeType {
  light,
  dark,
  black,
}

extension ThemeTypeExtension on ThemeType {
  String get name {
    switch (this) {
      case ThemeType.light:
        return 'Light';
      case ThemeType.dark:
        return 'Dark';
      case ThemeType.black:
        return 'Black';
      default:
        return '';
    }
  }
}

class ThemeProvider with ChangeNotifier {
  static final ThemeData lightTheme = ThemeData(
    colorScheme: ColorScheme.fromSwatch(
      brightness: Brightness.light,
      primarySwatch: Colors.green,
      accentColor: Colors.green,
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    colorScheme: ColorScheme.fromSwatch(
      brightness: Brightness.dark,
      accentColor: Colors.green,
    ),
  );

  static final ThemeData blackTheme = ThemeData(
    scaffoldBackgroundColor: Colors.black,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.black,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.black,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Colors.black,
    ),
    colorScheme: ColorScheme.fromSwatch(
      brightness: Brightness.dark,
      accentColor: Colors.green,
    ),
    listTileTheme: const ListTileThemeData(
      tileColor: Colors.black,
    ),
  );
  ThemeData _currentTheme = darkTheme;

  ThemeType _currentThemeType = ThemeType.dark;

  ThemeType get currentThemeType => _currentThemeType;

  void setTheme(ThemeType themeType) {
    _currentThemeType = themeType;
    _currentTheme = _getThemeData(themeType);
    _saveTheme(themeType);
    notifyListeners();
  }

  final String _themeKey = 'theme';

  ThemeProvider() {
    _loadTheme();
  }

  ThemeData get currentTheme => _currentTheme;

  Future<void> _loadTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int themeIndex = prefs.getInt(_themeKey) ?? ThemeType.dark.index;
    _currentThemeType = ThemeType.values[themeIndex];
    _currentTheme = _getThemeData(_currentThemeType);
    notifyListeners();
  }
  // void toggleTheme() {
  //   ThemeType newThemeType =
  //       _currentTheme == lightTheme ? ThemeType.dark : ThemeType.light;
  //   _currentTheme = _getThemeData(newThemeType);
  //   _saveTheme(newThemeType);
  //   notifyListeners();
  // }

  ThemeData _getThemeData(ThemeType themeType) {
    switch (themeType) {
      case ThemeType.light:
        return lightTheme;
      case ThemeType.dark:
        return darkTheme;
      case ThemeType.black:
        return blackTheme;
      default:
        return darkTheme;
    }
  }

  Future<void> _saveTheme(ThemeType themeType) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt(_themeKey, themeType.index);
  }
}
