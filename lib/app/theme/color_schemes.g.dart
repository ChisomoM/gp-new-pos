import 'package:flutter/material.dart';

const lightColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: Color(0xFF383D92), // gp-cobalt
  onPrimary: Color(0xFFFFFFFF),
  primaryContainer: Color(0xFFECECF8), // info tile / icon chip fill
  onPrimaryContainer: Color(0xFF383D92),
  secondary: Color(0xFF00AFEB), // gp-sky
  onSecondary: Color(0xFFFFFFFF),
  secondaryContainer: Color(0xFFECECF8),
  onSecondaryContainer: Color(0xFF383D92),
  onTertiary: Color(0xFFFFFFFF),
  tertiaryContainer: Color(0xFFFAD7FC),
  onTertiaryContainer: Color(0xFF29132E),
  error: Color(0xFFE11D2E),
  errorContainer: Color(0xFFFDE8E8),
  onError: Color(0xFFFFFFFF),
  onErrorContainer: Color(0xFF991B1B),
  surface: Color(0xFFFFFFFF), // card/sheet surface
  onSurface: Color(0xFF141A34), // neutral text — primary
  onSurfaceVariant: Color(0xFF70788F), // neutral text — tertiary
  outline: Color(0xFFDDE0EB), // border — medium
  onInverseSurface: Color(0xFFF2F0F4),
  inverseSurface: Color(0xFF2F3033),
  inversePrimary: Color(0xFFACC7FF),
  shadow: Color(0xFF080C30),
  surfaceTint: Color(0xFFFFFFFF),
  outlineVariant: Color(0xFFEEF0F5), // border — light
  scrim: Color(0xFF000000),
  surfaceContainer: Color(0xFFF3F4F6), // divider
  // secondaryFixed: Color(0xFFFFFFFF),
);

const darkColorScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: Color(0xFF313180),
  onPrimary: Color(0xFFFFFFFF),
  primaryContainer: Color(0xFFFFFFFF),
  onPrimaryContainer: Color(0xFFD7E2FF),
  secondary: Color(0xFF54B065),
  onSecondary: Color(0xFFFFFFFF),
  secondaryContainer: Color(0xFF3F4759),
  onSecondaryContainer: Color(0xFFDAE2F9),
  tertiary: Color(0xFFDDBCE0),
  onTertiary: Color(0xFF3F2844),
  tertiaryContainer: Color(0xFF573E5B),
  onTertiaryContainer: Color(0xFFFAD7FC),
  error: Color(0xFFFFB4AB),
  errorContainer: Color(0xFF93000A),
  onError: Color(0xFF690005),
  onErrorContainer: Color(0xFFFFDAD6),
  surface: Color(0xFF1A1B1F),
  onSurface: Color(0xFFE3E2E6),
  surfaceContainerHighest: Color(0xFF44474E),
  onSurfaceVariant: Color(0xFFC4C6D0),
  outline: Color(0xFF8E9099),
  onInverseSurface: Color(0xFF1A1B1F),
  inverseSurface: Color(0xFFE3E2E6),
  inversePrimary: Color(0xFF4F008D),
  shadow: Color(0xFF000000),
  // surfaceTint: Color(0xFFACC7FF),
  outlineVariant: Color(0xFF44474E),
  scrim: Color(0xFF000000),
);
