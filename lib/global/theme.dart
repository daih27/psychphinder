import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppColors {
  static const Color primaryGreen = Color(0xFF4CAF50);
  static const Color accent = Color(0xFF81C784);
  static const Color secondary = Color(0xFF2E7D32);
  static const Color tertiary = Color(0xFFA5D6A7);
  static const Color surface = Color(0xFFF1F8E9);
  static const Color error = Color(0xFFE57373);
  static const Color warning = Color(0xFFFFB74D);
  static const Color success = Color(0xFF66BB6A);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryGreen, accent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF66BB6A), Color(0xFF4CAF50)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

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
    }
  }
}

class ThemeProvider with ChangeNotifier {
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primaryGreen,
      brightness: Brightness.light,
      primary: AppColors.primaryGreen,
      secondary: AppColors.secondary,
      tertiary: AppColors.tertiary,
      surface: AppColors.surface,
      error: AppColors.error,
    ),
    fontFamily: 'Lato',
    dividerColor: Colors.transparent,
    cardTheme: CardThemeData(
      elevation: 8,
      shadowColor: AppColors.primaryGreen.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 4,
        shadowColor: AppColors.primaryGreen.withValues(alpha: 0.4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primaryGreen,
      brightness: Brightness.dark,
      primary: AppColors.accent,
      secondary: AppColors.secondary,
      tertiary: AppColors.tertiary,
    ),
    fontFamily: 'Lato',
    dividerColor: Colors.transparent,
    cardTheme: CardThemeData(
      elevation: 8,
      shadowColor: AppColors.primaryGreen.withValues(alpha: 0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        elevation: 4,
        shadowColor: AppColors.accent.withValues(alpha: 0.4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
    ),
  );

  static final ThemeData blackTheme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: Colors.black,
    fontFamily: 'Lato',
    dividerColor: Colors.transparent,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primaryGreen,
      brightness: Brightness.dark,
      primary: AppColors.accent,
      secondary: AppColors.secondary,
      surface: const Color(0xFF121212),
      onSurface: Colors.white,
    ),
    cardTheme: CardThemeData(
      elevation: 8,
      shadowColor: AppColors.primaryGreen.withValues(alpha: 0.2),
      color: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        elevation: 4,
        shadowColor: AppColors.accent.withValues(alpha: 0.4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.black,
      elevation: 0,
      centerTitle: true,
      surfaceTintColor: Colors.transparent,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.black,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Colors.black,
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

  ThemeData _getThemeData(ThemeType themeType) {
    switch (themeType) {
      case ThemeType.light:
        return lightTheme;
      case ThemeType.dark:
        return darkTheme;
      case ThemeType.black:
        return blackTheme;
    }
  }

  Future<void> _saveTheme(ThemeType themeType) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt(_themeKey, themeType.index);
  }
}
