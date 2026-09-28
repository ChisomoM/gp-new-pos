import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geepay_pos/app/theme/color_schemes.g.dart';
import 'package:geepay_pos/app/theme/design_system.dart';

export 'package:flutter_bloc/flutter_bloc.dart';

export 'color_schemes.g.dart';
export 'design_system.dart';

/// {@template app_theme}
/// The app's [ThemeData]. Light only; dark mode is out of scope.
///
/// Stock Material widgets are themed from the design tokens so anything
/// not yet built from the shared components still matches.
/// {@endtemplate}
class AppTheme {
  /// {@macro app_theme}
  const AppTheme();

  ThemeData get themeData {
    final textTheme = AppTextStyles.textTheme;
    return ThemeData(
      useMaterial3: true,
      visualDensity: VisualDensity.standard,
      colorScheme: lightColorScheme,
      scaffoldBackgroundColor: AppColors.surfacePage,
      textTheme: textTheme,
      splashFactory: InkRipple.splashFactory,
      splashColor: AppColors.pressedOverlay,
      highlightColor: Colors.transparent,
      hoverColor: AppColors.hoverOverlay,
      focusColor: AppColors.focusRing,
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 1,
      ),
      iconTheme: const IconThemeData(
        size: AppIconSize.md,
        color: AppColors.textSecondary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surfaceWhite,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: AppSize.appBar,
        titleTextStyle: AppTextStyles.title3,
        iconTheme: const IconThemeData(
          size: AppIconSize.md,
          color: AppColors.textSecondary,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(style: _buttonStyle()),
      elevatedButtonTheme: ElevatedButtonThemeData(style: _buttonStyle()),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: _buttonStyle().copyWith(
          foregroundColor: const WidgetStatePropertyAll(
            AppColors.textSecondary,
          ),
          side: const WidgetStatePropertyAll(
            BorderSide(color: AppColors.borderMedium),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.gpCobalt,
          textStyle: AppTextStyles.label,
          minimumSize: const Size(AppSize.touchTarget, AppSize.buttonSm),
          padding: const EdgeInsets.symmetric(horizontal: AppSpace.x3),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.brMd),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceWhite,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpace.x4,
          vertical: AppSpace.x3 + 2, // 52px field with 24px line height
        ),
        hintStyle: AppTextStyles.bodyLg.copyWith(color: AppColors.textMuted),
        helperStyle: AppTextStyles.caption.copyWith(
          color: AppColors.textTertiary,
        ),
        errorStyle: AppTextStyles.caption.copyWith(
          color: AppColors.dangerText,
        ),
        prefixIconColor: AppColors.textMuted,
        suffixIconColor: AppColors.textMuted,
        border: _inputBorder(AppColors.borderMedium),
        enabledBorder: _inputBorder(AppColors.borderMedium),
        focusedBorder: _inputBorder(AppColors.gpCobalt),
        errorBorder: _inputBorder(AppColors.dangerIcon),
        focusedErrorBorder: _inputBorder(AppColors.dangerIcon),
        disabledBorder: _inputBorder(AppColors.borderLight),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surfaceWhite,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.brXl),
        titleTextStyle: AppTextStyles.title3,
        contentTextStyle: AppTextStyles.body.copyWith(
          color: AppColors.textTertiary,
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surfaceWhite,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: AppColors.surfaceWhite,
        showDragHandle: false,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.xl),
          ),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: EdgeInsets.all(AppSpace.x4),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: const BoxDecoration(
          color: AppColors.inverseSurface,
          borderRadius: AppRadius.brXs,
        ),
        textStyle: AppTextStyles.caption.copyWith(color: AppColors.onBrandHigh),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpace.x2,
          vertical: AppSpace.x1,
        ),
        waitDuration: AppMotion.base,
        exitDuration: AppMotion.fast,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.gpCobalt,
        linearTrackColor: AppColors.infoFill,
        circularTrackColor: Colors.transparent,
        refreshBackgroundColor: AppColors.surfaceWhite,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.linux: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.windows: FadeForwardsPageTransitionsBuilder(),
        },
      ),
    );
  }

  static ButtonStyle _buttonStyle() {
    return FilledButton.styleFrom(
      minimumSize: const Size.fromHeight(AppSize.buttonLg),
      textStyle: AppTextStyles.button,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.brMd),
    );
  }

  static OutlineInputBorder _inputBorder(Color color) => OutlineInputBorder(
    borderRadius: AppRadius.brMd,
    borderSide: BorderSide(color: color, width: 1.5),
  );
}
