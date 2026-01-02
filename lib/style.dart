import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pocket_guard/settings/constants/preferences-keys.dart';
import 'package:pocket_guard/settings/preferences-utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:system_theme/system_theme.dart';

import 'helpers/records-utility-functions.dart';

const String FontNameDefault = 'Montserrat';

class MaterialThemeInstance {
  static ThemeData? lightTheme;
  static ThemeData? darkTheme;
  static ThemeData? currentTheme;
  static ThemeMode? themeMode;
  static Color defaultSeedColor = Color.fromARGB(255, 129, 156, 129);

  static getDefaultColorScheme(Brightness brightness) {
    ColorScheme defaultColorScheme = ColorScheme.fromSeed(
      seedColor: defaultSeedColor,
      brightness: brightness,
    );
    return defaultColorScheme;
  }

  static Future<ColorScheme> getColorScheme(Brightness brightness) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? dynamicColorScheme = PreferencesUtils.getOrDefault<int>(
      prefs,
      PreferencesKeys.themeColor,
    );

    switch (dynamicColorScheme) {
      case 1:
        {
          log("Using system colors");
          await SystemTheme.accentColor.load();
          SystemTheme.fallbackColor = defaultSeedColor;
          final accentColor = SystemTheme.accentColor.accent;
          if (accentColor == defaultSeedColor) {
            log("Failed to retrieve system color, using default instead");
          }
          return ColorScheme.fromSeed(
            seedColor: accentColor,
            brightness: brightness,
          );
        }

      case 2:
        {
          log("Using dynamic colors");
          AssetImage assetImage = getBackgroundImage();
          ColorScheme colorScheme = await ColorScheme.fromImageProvider(
            provider: assetImage,
            brightness: brightness,
          );
          return colorScheme;
        }

      default:
        {
          return getDefaultColorScheme(brightness);
        }
    }
  }

  static getMaterialThemeData(Brightness brightness) async {
    var colorScheme = await getColorScheme(brightness);
    ThemeData baseTheme = ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      brightness: brightness,
    );

    return baseTheme.copyWith(
      textTheme: GoogleFonts.interTextTheme(baseTheme.textTheme),
      primaryTextTheme: GoogleFonts.interTextTheme(baseTheme.primaryTextTheme),
    );
  }

  static Future<ThemeMode> getThemeMode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? themeModeIndex = PreferencesUtils.getOrDefault<int>(
      prefs,
      PreferencesKeys.themeMode,
    );
    themeMode = ThemeMode.values[themeModeIndex!];
    return themeMode!;
  }

  static Future<ThemeData> getLightTheme() async {
    if (lightTheme == null) {
      lightTheme = await getMaterialThemeData(Brightness.light);
    }
    return lightTheme!;
  }

  static Future<ThemeData> getDarkTheme() async {
    if (darkTheme == null) {
      darkTheme = await getMaterialThemeData(Brightness.dark);
    }
    return darkTheme!;
  }
}
