import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geepay_pos/app/theme/theme.dart';
import 'package:geepay_pos/utils/utils.dart';

export 'package:flutter_bloc/flutter_bloc.dart';

export 'color_schemes.g.dart';
export 'theme_cubit.dart';

/// {@template app_theme}
/// The Default App [ThemeData].
/// {@endtemplate}
class AppTheme {
  /// {@macro app_theme}
  const AppTheme();

  /// Default `ThemeData` for App UI.
  ThemeData get themeData {
    return ThemeData(
      useMaterial3: true,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      scaffoldBackgroundColor: const Color(0xFFF9FAFB), // surface-page
      textTheme: _textTheme,
      colorScheme: _colorScheme,
      elevatedButtonTheme: _elevatedButtonTheme,
      filledButtonTheme: _filledButtonTheme,
      outlinedButtonTheme: _outlinedButtonTheme,
      bottomSheetTheme: _bottomSheetTheme,
    );
  }

  /// Body/UI text uses Inter; headings/display use DM Sans (design spec §1).
  TextTheme get _textTheme {
    final base = GoogleFonts.interTextTheme(
      ThemeData(brightness: Brightness.light).textTheme,
    );
    const headingFont = GoogleFonts.dmSans;
    return base.copyWith(
      displayLarge: headingFont(textStyle: base.displayLarge),
      displayMedium: headingFont(textStyle: base.displayMedium),
      displaySmall: headingFont(textStyle: base.displaySmall),
      headlineLarge: headingFont(textStyle: base.headlineLarge),
      headlineMedium: headingFont(textStyle: base.headlineMedium),
      headlineSmall: headingFont(
        textStyle: base.headlineSmall,
        fontWeight: FontWeight.w700,
      ),
      titleLarge: headingFont(
        textStyle: base.titleLarge,
        fontWeight: FontWeight.w700,
      ),
      titleMedium: headingFont(textStyle: base.titleMedium),
    );
  }

  ColorScheme get _colorScheme => lightColorScheme;

  FilledButtonThemeData get _filledButtonTheme {
    return FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kAppCornerRadius),
        ),
      ),
    );
  }

  OutlinedButtonThemeData get _outlinedButtonTheme {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kAppCornerRadius),
        ),
      ),
    );
  }

  ElevatedButtonThemeData get _elevatedButtonTheme {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size.fromHeight(48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kAppCornerRadius),
        ),
      ),
    );
  }

  BottomSheetThemeData get _bottomSheetTheme {
    return BottomSheetThemeData(surfaceTintColor: lightColorScheme.surface);
  }
}

/// {@template app_dark_theme}
/// Dark Mode App [ThemeData].
/// {@endtemplate}
class AppDarkTheme extends AppTheme {
  /// {@macro app_dark_theme}
  const AppDarkTheme();

  @override
  ColorScheme get _colorScheme => darkColorScheme;

  @override
  TextTheme get _textTheme {
    return GoogleFonts.manropeTextTheme(
      ThemeData(brightness: Brightness.dark).textTheme,
    );
  }

  @override
  BottomSheetThemeData get _bottomSheetTheme {
    return BottomSheetThemeData(surfaceTintColor: darkColorScheme.surface);
  }
}

InputDecoration kTextFieldDecoration = InputDecoration(
  isDense: false,
  hintText: 'Required',
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: BorderSide(
      color: Theme.of(navKey.currentContext!).dividerColor,
    ),
  ),
  filled: true,
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: BorderSide(
      color: Theme.of(navKey.currentContext!).dividerColor,
    ),
  ),
  fillColor: Theme.of(navKey.currentContext!).colorScheme.onPrimary,
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(
      color: Theme.of(navKey.currentContext!).dividerColor,
    ),
  ),
  hintStyle: TextStyle(
    fontSize: 14, // Change font size
    fontWeight: FontWeight.w400, // Adjust weight
    fontStyle: FontStyle.italic, // Change style to italic
    color: Theme.of(
      navKey.currentContext!,
    ).colorScheme.secondary.withValues(alpha: 0.5),
  ),
  contentPadding: const EdgeInsets.only(top: 16, left: 8),
  prefixIconConstraints: const BoxConstraints(minHeight: 50),
);

final buttonShape = RoundedRectangleBorder(
  borderRadius: BorderRadius.circular(14),
);
const buttonSize = Size.fromHeight(50);
