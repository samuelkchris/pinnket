import 'package:flutter/material.dart';
import 'package:yaru/yaru.dart';

class ThemeConfig {
  ThemeConfig._privateConstructor();

  static final ThemeConfig _instance = ThemeConfig._privateConstructor();

  factory ThemeConfig() {
    return _instance;
  }

  final ThemeData lightTheme = yaruLight.copyWith(
    colorScheme: const ColorScheme.light(
      primary: Color(0xff4c9c44),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff9ee29f),
      onPrimaryContainer: Color(0xff002201),
      primaryFixed: Color(0xffe8f5e9),
      primaryFixedDim: Color(0xffc8e6c9),
      onPrimaryFixed: Color(0xff1b5e20),
      onPrimaryFixedVariant: Color(0xff2e7d32),
      secondary: Color(0xfff6921e),
      onSecondary: Color(0xff000000),
      secondaryContainer: Color(0xffffd699),
      onSecondaryContainer: Color(0xff2b1700),
      secondaryFixed: Color(0xfffff3e0),
      secondaryFixedDim: Color(0xffffe0b2),
      onSecondaryFixed: Color(0xff6a1b9a),
      onSecondaryFixedVariant: Color(0xff8e24aa),
      tertiary: Color(0xff2c7e2e),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xffb8e6b9),
      onTertiaryContainer: Color(0xff002201),
      tertiaryFixed: Color(0xffe0f2f1),
      tertiaryFixedDim: Color(0xffb2dfdb),
      onTertiaryFixed: Color(0xff004d40),
      onTertiaryFixedVariant: Color(0xff00695c),
      error: Color(0xffb00020),
      onError: Color(0xffffffff),
      errorContainer: Color(0xfffcd8df),
      onErrorContainer: Color(0xff65001e),
      surface: Color(0xfff5f5f5),
      onSurface: Color(0xff333333),
      surfaceDim: Color(0xffe0e0e0),
      surfaceBright: Color(0xfffafafa),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff5f5f5),
      surfaceContainer: Color(0xfff0f0f0),
      surfaceContainerHigh: Color(0xffebebeb),
      surfaceContainerHighest: Color(0xffe6e6e6),
      onSurfaceVariant: Color(0xff49454f),
      outline: Color(0xff79747e),
      outlineVariant: Color(0xffcac4d0),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff121212),
      onInverseSurface: Color(0xffffffff),
      inversePrimary: Color(0xffa5d6a7),
      surfaceTint: Color(0xff4c9c44),
    ),
    scaffoldBackgroundColor: const Color(0xfffafafa),
    dialogBackgroundColor: const Color(0xffffffff),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xffb8e6b9),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[400]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xff4c9c44), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xffb00020), width: 2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xffb00020), width: 2),
      ),
      filled: true,
      fillColor: const Color(0xffffffff),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: Color(0xff4c9c44),
    ),
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return Colors.grey;
        }
        return const Color(0xff4c9c44);
      }),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    canvasColor: const Color(0xfff5f5f5),
    cardColor: const Color(0xffffffff),
    dividerColor: const Color(0xffe0e0e0),
    focusColor: const Color(0xff4c9c44),
    highlightColor: const Color(0xff4c9c44),
    hintColor: const Color(0xff808080),
    hoverColor: const Color(0xffe0e0e0),
    indicatorColor: const Color(0xff4c9c44),
    primaryColor: const Color(0xff4c9c44),
    primaryColorDark: const Color(0xff002201),
    primaryColorLight: const Color(0xff9ee29f),
    secondaryHeaderColor: const Color(0xffffd699),
    shadowColor: const Color(0xff000000),
    splashColor: const Color(0xff4c9c44),
    unselectedWidgetColor: const Color(0xff808080),
  );

  final ThemeData darkTheme = yaruDark.copyWith(
    colorScheme: const ColorScheme.dark(
      primary: Color(0xff7ac073),
      onPrimary: Color(0xff000000),
      primaryContainer: Color(0xff3a7a33),
      onPrimaryContainer: Color(0xffc2f0bb),
      primaryFixed: Color(0xff1b5e20),
      primaryFixedDim: Color(0xff2e7d32),
      onPrimaryFixed: Color(0xffe8f5e9),
      onPrimaryFixedVariant: Color(0xffc8e6c9),
      secondary: Color(0xfffaa64b),
      onSecondary: Color(0xff000000),
      secondaryContainer: Color(0xffb36812),
      onSecondaryContainer: Color(0xffffddb0),
      secondaryFixed: Color(0xff6a1b9a),
      secondaryFixedDim: Color(0xff8e24aa),
      onSecondaryFixed: Color(0xfffff3e0),
      onSecondaryFixedVariant: Color(0xffffe0b2),
      tertiary: Color(0xff5db361),
      onTertiary: Color(0xff000000),
      tertiaryContainer: Color(0xff225a25),
      onTertiaryContainer: Color(0xffb8e6b9),
      tertiaryFixed: Color(0xff004d40),
      tertiaryFixedDim: Color(0xff00695c),
      onTertiaryFixed: Color(0xffe0f2f1),
      onTertiaryFixedVariant: Color(0xffb2dfdb),
      error: Color(0xffcf6679),
      onError: Color(0xff000000),
      errorContainer: Color(0xff93000a),
      onErrorContainer: Color(0xfffcd8df),
      surface: Color(0xff121212),
      onSurface: Color(0xffe0e0e0),
      surfaceDim: Color(0xff2c2c2c),
      surfaceBright: Color(0xff3a3a3a),
      surfaceContainerLowest: Color(0xff0d0d0d),
      surfaceContainerLow: Color(0xff1e1e1e),
      surfaceContainer: Color(0xff252525),
      surfaceContainerHigh: Color(0xff2e2e2e),
      surfaceContainerHighest: Color(0xff373737),
      onSurfaceVariant: Color(0xffcac4d0),
      outline: Color(0xff938f99),
      outlineVariant: Color(0xff49454f),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffffffff),
      onInverseSurface: Color(0xff121212),
      inversePrimary: Color(0xff4c9c44),
      surfaceTint: Color(0xff7ac073),
    ),
    scaffoldBackgroundColor: const Color(0xff121212),
    dialogBackgroundColor: const Color(0xff1e1e1e),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xff225a25),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[700]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xff7ac073), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xffcf6679), width: 2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xffcf6679), width: 2),
      ),
      filled: true,
      fillColor: const Color(0xff1e1e1e),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return Colors.grey;
        }
        return const Color(0xff7ac073);
      }),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: Color(0xff7ac073),
    ),
    canvasColor: const Color(0xff121212),
    cardColor: const Color(0xff1e1e1e),
    dividerColor: const Color(0xffe0e0e0),
    focusColor: const Color(0xff7ac073),
    highlightColor: const Color(0xff7ac073),
    hintColor: const Color(0xff808080),
    hoverColor: const Color(0xff1e1e1e),
    indicatorColor: const Color(0xff7ac073),
    primaryColor: const Color(0xff7ac073),
    primaryColorDark: const Color(0xff3a7a33),
    primaryColorLight: const Color(0xffc2f0bb),
    secondaryHeaderColor: const Color(0xffb36812),
    shadowColor: const Color(0xff000000),
    splashColor: const Color(0xff7ac073),
    unselectedWidgetColor: const Color(0xff808080),
    iconTheme: const IconThemeData(
      color: Color(0xffe0e0e0),
    ),
  );

  final ThemeMode themeMode = ThemeMode.light;
}
