import "package:flutter/material.dart";

class MaterialTheme {
  final TextTheme textTheme;

  const MaterialTheme(this.textTheme);

  static TextTheme createShantellSansTextTheme() {
    const fontFamily = 'ShantellSans';
    return TextTheme(
      displayLarge: TextStyle(fontFamily: fontFamily),
      displayMedium: TextStyle(fontFamily: fontFamily),
      displaySmall: TextStyle(fontFamily: fontFamily),
      headlineLarge: TextStyle(fontFamily: fontFamily),
      headlineMedium: TextStyle(fontFamily: fontFamily),
      headlineSmall: TextStyle(fontFamily: fontFamily),
      titleLarge: TextStyle(fontFamily: fontFamily),
      titleMedium: TextStyle(fontFamily: fontFamily),
      titleSmall: TextStyle(fontFamily: fontFamily),
      bodyLarge: TextStyle(fontFamily: fontFamily),
      bodyMedium: TextStyle(fontFamily: fontFamily),
      bodySmall: TextStyle(fontFamily: fontFamily),
      labelLarge: TextStyle(fontFamily: fontFamily),
      labelMedium: TextStyle(fontFamily: fontFamily),
      labelSmall: TextStyle(fontFamily: fontFamily),
    );
  }

  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff5d7e22),
      surfaceTint: Color(0xff5d7e22),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xffd6f5a8),
      onPrimaryContainer: Color(0xff2d4507),
      secondary: Color(0xff6f7b58),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xffe5f0d1),
      onSecondaryContainer: Color(0xff40492f),
      tertiary: Color(0xff3d7873),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xffbdf2ed),
      onTertiaryContainer: Color(0xff1c4c48),
      error: Color(0xffda2c2c),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffffdad6),
      onErrorContainer: Color(0xff93000a),
      surface: Color(0xfffafcf0),
      onSurface: Color(0xff1a1c16),
      onSurfaceVariant: Color(0xff44483d),
      outline: Color(0xff75796c),
      outlineVariant: Color(0xffc5c8ba),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff2f312a),
      inversePrimary: Color(0xffb9de8a),
      primaryFixed: Color(0xffd6f5a8),
      onPrimaryFixed: Color(0xff102000),
      primaryFixedDim: Color(0xffb9de8a),
      onPrimaryFixedVariant: Color(0xff354e16),
      secondaryFixed: Color(0xffe5f0d1),
      onSecondaryFixed: Color(0xff151e0b),
      secondaryFixedDim: Color(0xffc9d6b7),
      onSecondaryFixedVariant: Color(0xff404a33),
      tertiaryFixed: Color(0xffbdf2ed),
      onTertiaryFixed: Color(0xff00201e),
      tertiaryFixedDim: Color(0xffa5dcd7),
      onTertiaryFixedVariant: Color(0xff1f4e4b),
      surfaceDim: Color(0xffdadbd0),
      surfaceBright: Color(0xfffafcf0),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff5f8ea),
      surfaceContainer: Color(0xffeff2e4),
      surfaceContainerHigh: Color(0xffeaecdf),
      surfaceContainerHighest: Color(0xffe4e6d9),
    );
  }

  ThemeData light() {
    return theme(lightScheme());
  }

  static ColorScheme lightMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff253d05),
      surfaceTint: Color(0xff4c662b),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff5a7539),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff303924),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff667157),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff083d3a),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff477572),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff740006),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffcf2c27),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfff9faef),
      onSurface: Color(0xff0f120c),
      onSurfaceVariant: Color(0xff34382d),
      outline: Color(0xff505449),
      outlineVariant: Color(0xff6b6f62),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff2f312a),
      inversePrimary: Color(0xffb1d18a),
      primaryFixed: Color(0xff5a7539),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff425c23),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff667157),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff4e5840),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff477572),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff2e5c59),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffc6c7bd),
      surfaceBright: Color(0xfff9faef),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff3f4e9),
      surfaceContainer: Color(0xffe8e9de),
      surfaceContainerHigh: Color(0xffdcded3),
      surfaceContainerHighest: Color(0xffd1d3c8),
    );
  }

  ThemeData lightMediumContrast() {
    return theme(lightMediumContrastScheme());
  }

  static ColorScheme lightHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff1c3200),
      surfaceTint: Color(0xff4c662b),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff375018),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff262f1a),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff434c35),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff003230),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff21504e),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff600004),
      onError: Color(0xffffffff),
      errorContainer: Color(0xff98000a),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfff9faef),
      onSurface: Color(0xff000000),
      onSurfaceVariant: Color(0xff000000),
      outline: Color(0xff2a2d24),
      outlineVariant: Color(0xff474b40),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff2f312a),
      inversePrimary: Color(0xffb1d18a),
      primaryFixed: Color(0xff375018),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff213903),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff434c35),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff2c3620),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff21504e),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff033937),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffb8baaf),
      surfaceBright: Color(0xfff9faef),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff1f2e6),
      surfaceContainer: Color(0xffe2e3d8),
      surfaceContainerHigh: Color(0xffd4d5ca),
      surfaceContainerHighest: Color(0xffc6c7bd),
    );
  }

  ThemeData lightHighContrast() {
    return theme(lightHighContrastScheme());
  }

  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffbde08a),
      surfaceTint: Color(0xffbde08a),
      onPrimary: Color(0xff1f3701),
      primaryContainer: Color(0xff3d5c1a),
      onPrimaryContainer: Color(0xffd8f7a3),
      secondary: Color(0xffc9d6b7),
      onSecondary: Color(0xff2a331e),
      secondaryContainer: Color(0xff484e3b),
      onSecondaryContainer: Color(0xffe5f0d1),
      tertiary: Color(0xffaadcd7),
      onTertiary: Color(0xff003735),
      tertiaryContainer: Color(0xff265854),
      onTertiaryContainer: Color(0xffc6f8f3),
      error: Color(0xffff9c91),
      onError: Color(0xff690005),
      errorContainer: Color(0xffba160e),
      onErrorContainer: Color(0xffffdad6),
      surface: Color(0xff12140e),
      onSurface: Color(0xffe6e8dd),
      onSurfaceVariant: Color(0xffc9cdbf),
      outline: Color(0xff939689),
      outlineVariant: Color(0xff44483d),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe6e8dd),
      inversePrimary: Color(0xff4c662b),
      primaryFixed: Color(0xffd8f7a3),
      onPrimaryFixed: Color(0xff102000),
      primaryFixedDim: Color(0xffbde08a),
      onPrimaryFixedVariant: Color(0xff354e16),
      secondaryFixed: Color(0xffe5f0d1),
      onSecondaryFixed: Color(0xff151e0b),
      secondaryFixedDim: Color(0xffc9d6b7),
      onSecondaryFixedVariant: Color(0xff404a33),
      tertiaryFixed: Color(0xffc6f8f3),
      onTertiaryFixed: Color(0xff00201e),
      tertiaryFixedDim: Color(0xffaadcd7),
      onTertiaryFixedVariant: Color(0xff1f4e4b),
      surfaceDim: Color(0xff12140e),
      surfaceBright: Color(0xff3a3c34),
      surfaceContainerLowest: Color(0xff0c0f09),
      surfaceContainerLow: Color(0xff1a1c16),
      surfaceContainer: Color(0xff1e201a),
      surfaceContainerHigh: Color(0xff282b24),
      surfaceContainerHighest: Color(0xff33362e),
    );
  }

  ThemeData dark() {
    return theme(darkScheme());
  }

  static ColorScheme darkMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffc7e79e),
      surfaceTint: Color(0xffb1d18a),
      onPrimary: Color(0xff172b00),
      primaryContainer: Color(0xff7d9a59),
      onPrimaryContainer: Color(0xff000000),
      secondary: Color(0xffd5e1c2),
      onSecondary: Color(0xff1f2814),
      secondaryContainer: Color(0xff8a9579),
      onSecondaryContainer: Color(0xff000000),
      tertiary: Color(0xffb5e6e1),
      onTertiary: Color(0xff002b29),
      tertiaryContainer: Color(0xff6b9995),
      onTertiaryContainer: Color(0xff000000),
      error: Color(0xffffd2cc),
      onError: Color(0xff540003),
      errorContainer: Color(0xffff5449),
      onErrorContainer: Color(0xff000000),
      surface: Color(0xff12140e),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffdbdecf),
      outline: Color(0xffb0b3a6),
      outlineVariant: Color(0xff8e9285),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe2e3d8),
      inversePrimary: Color(0xff364f17),
      primaryFixed: Color(0xffcdeda3),
      onPrimaryFixed: Color(0xff081400),
      primaryFixedDim: Color(0xffb1d18a),
      onPrimaryFixedVariant: Color(0xff253d05),
      secondaryFixed: Color(0xffdce7c8),
      onSecondaryFixed: Color(0xff0b1403),
      secondaryFixedDim: Color(0xffbfcbad),
      onSecondaryFixedVariant: Color(0xff303924),
      tertiaryFixed: Color(0xffbcece7),
      onTertiaryFixed: Color(0xff001413),
      tertiaryFixedDim: Color(0xffa0d0cb),
      onTertiaryFixedVariant: Color(0xff083d3a),
      surfaceDim: Color(0xff12140e),
      surfaceBright: Color(0xff43453d),
      surfaceContainerLowest: Color(0xff060804),
      surfaceContainerLow: Color(0xff1c1e18),
      surfaceContainer: Color(0xff262922),
      surfaceContainerHigh: Color(0xff31342c),
      surfaceContainerHighest: Color(0xff3c3f37),
    );
  }

  ThemeData darkMediumContrast() {
    return theme(darkMediumContrastScheme());
  }

  static ColorScheme darkHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffdafbb0),
      surfaceTint: Color(0xffb1d18a),
      onPrimary: Color(0xff000000),
      primaryContainer: Color(0xffadcd86),
      onPrimaryContainer: Color(0xff050e00),
      secondary: Color(0xffe9f4d5),
      onSecondary: Color(0xff000000),
      secondaryContainer: Color(0xffbcc7a9),
      onSecondaryContainer: Color(0xff060d01),
      tertiary: Color(0xffc9f9f5),
      onTertiary: Color(0xff000000),
      tertiaryContainer: Color(0xff9cccc7),
      onTertiaryContainer: Color(0xff000e0d),
      error: Color(0xffffece9),
      onError: Color(0xff000000),
      errorContainer: Color(0xffffaea4),
      onErrorContainer: Color(0xff220001),
      surface: Color(0xff12140e),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffffffff),
      outline: Color(0xffeef2e2),
      outlineVariant: Color(0xffc1c4b6),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe2e3d8),
      inversePrimary: Color(0xff364f17),
      primaryFixed: Color(0xffcdeda3),
      onPrimaryFixed: Color(0xff000000),
      primaryFixedDim: Color(0xffb1d18a),
      onPrimaryFixedVariant: Color(0xff081400),
      secondaryFixed: Color(0xffdce7c8),
      onSecondaryFixed: Color(0xff000000),
      secondaryFixedDim: Color(0xffbfcbad),
      onSecondaryFixedVariant: Color(0xff0b1403),
      tertiaryFixed: Color(0xffbcece7),
      onTertiaryFixed: Color(0xff000000),
      tertiaryFixedDim: Color(0xffa0d0cb),
      onTertiaryFixedVariant: Color(0xff001413),
      surfaceDim: Color(0xff12140e),
      surfaceBright: Color(0xff4f5149),
      surfaceContainerLowest: Color(0xff000000),
      surfaceContainerLow: Color(0xff1e201a),
      surfaceContainer: Color(0xff2f312a),
      surfaceContainerHigh: Color(0xff3a3c35),
      surfaceContainerHighest: Color(0xff454840),
    );
  }

  ThemeData darkHighContrast() {
    return theme(darkHighContrastScheme());
  }

  ThemeData theme(ColorScheme colorScheme) => ThemeData(
        useMaterial3: true,
        brightness: colorScheme.brightness,
        colorScheme: colorScheme,
        textTheme: textTheme.apply(
          bodyColor: colorScheme.onSurface,
          displayColor: colorScheme.onSurface,
        ),
        fontFamily: 'ShantellSans',
        scaffoldBackgroundColor: colorScheme.surface,
        canvasColor: colorScheme.surface,
      );

  List<ExtendedColor> get extendedColors => [];
}

class ExtendedColor {
  final Color seed, value;
  final ColorFamily light;
  final ColorFamily lightHighContrast;
  final ColorFamily lightMediumContrast;
  final ColorFamily dark;
  final ColorFamily darkHighContrast;
  final ColorFamily darkMediumContrast;

  const ExtendedColor({
    required this.seed,
    required this.value,
    required this.light,
    required this.lightHighContrast,
    required this.lightMediumContrast,
    required this.dark,
    required this.darkHighContrast,
    required this.darkMediumContrast,
  });
}

class ColorFamily {
  const ColorFamily({
    required this.color,
    required this.onColor,
    required this.colorContainer,
    required this.onColorContainer,
  });

  final Color color;
  final Color onColor;
  final Color colorContainer;
  final Color onColorContainer;
}
