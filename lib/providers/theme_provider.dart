import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../theme/theme.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _boxName = 'theme_box';
  static const String _themeKey = 'theme_mode';

  late Box<dynamic> _box;
  ThemeMode _themeMode = ThemeMode.light;

  ThemeProvider() {
    _initHive();
  }

  Future<void> _initHive() async {
    _box = await Hive.openBox<dynamic>(_boxName);
    _loadTheme();
  }

  void _loadTheme() {
    final storedTheme = _box.get(_themeKey);
    if (storedTheme != null) {
      _themeMode = ThemeMode.values[storedTheme];
    } else {
      _themeMode = ThemeConfig().themeMode;
    }
    notifyListeners();
  }

  ThemeMode get themeMode => _themeMode;
  ThemeData get lightTheme => ThemeConfig().lightTheme;
  ThemeData get darkTheme => ThemeConfig().darkTheme;

  void toggleTheme() {
    if (_themeMode == ThemeMode.light) {
      setThemeMode(ThemeMode.dark);
    } else {
      setThemeMode(ThemeMode.light);
    }
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    _box.put(_themeKey, mode.index);
    notifyListeners();
  }
}