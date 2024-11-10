import 'package:flutter/material.dart';
import 'package:katze/presentation/theme/app_colors.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = true;

  ThemeProvider({bool isDarkMode = true}) : _isDarkMode = isDarkMode;

  bool get isDarkMode => _isDarkMode;
  ThemeData get themeData => _isDarkMode ? AppColors.darkTheme : AppColors.lightTheme;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  void setDarkMode(bool value) {
    if (_isDarkMode != value) {
      _isDarkMode = value;
      notifyListeners();
    }
  }
}
