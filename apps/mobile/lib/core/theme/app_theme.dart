import 'package:flutter/material.dart';
import 'package:shilpsetu/core/theme/tokens.dart';

/// Centralized application theme for Shilpsetu.
///
/// Designed for maximum legibility in outdoor sunlight, high-contrast,
/// zero-literacy visual recognition, and 64dp minimum touch targets.
abstract final class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: Palette.surface,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: Palette.primary,
        onPrimary: Palette.onPrimary,
        secondary: Palette.terracotta,
        onSecondary: Colors.white,
        error: Palette.revise,
        onError: Colors.white,
        surface: Palette.surface,
        onSurface: Palette.ink,
        surfaceContainer: Palette.surfaceContainer,
        surfaceContainerHigh: Palette.surfaceContainerHigh,
        outline: Palette.muted,
      ),

      // Touch target sizing enforced globally
      materialTapTargetSize: MaterialTapTargetSize.padded,

      // High-legibility typography
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: Sizes.heroText,
          fontWeight: FontWeight.w700,
          color: Palette.ink,
          letterSpacing: -0.5,
        ),
        headlineMedium: TextStyle(
          fontSize: Sizes.promptText,
          fontWeight: FontWeight.w700,
          color: Palette.ink,
        ),
        titleLarge: TextStyle(
          fontSize: Sizes.minBodyText + 2,
          fontWeight: FontWeight.w600,
          color: Palette.ink,
        ),
        bodyLarge: TextStyle(
          fontSize: Sizes.minBodyText,
          fontWeight: FontWeight.w500,
          color: Palette.ink,
          height: 1.4,
        ),
        bodyMedium: TextStyle(
          fontSize: Sizes.minBodyText - 2,
          fontWeight: FontWeight.w400,
          color: Palette.muted,
          height: 1.4,
        ),
        labelLarge: TextStyle(
          fontSize: Sizes.minBodyText,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),

      // 64dp minimum Elevated Buttons for primary actions
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Palette.primary,
          foregroundColor: Palette.onPrimary,
          minimumSize: const Size(Sizes.minTouchTarget, Sizes.minTouchTarget),
          elevation: 2,
          padding: const EdgeInsets.symmetric(
            horizontal: Sizes.gapLarge,
            vertical: Sizes.gapMedium,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Sizes.radius),
          ),
          textStyle: const TextStyle(
            fontSize: Sizes.minBodyText,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      // FilledButton Theme
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: Palette.primary,
          foregroundColor: Palette.onPrimary,
          minimumSize: const Size(Sizes.minTouchTarget, Sizes.minTouchTarget),
          padding: const EdgeInsets.symmetric(
            horizontal: Sizes.gapLarge,
            vertical: Sizes.gapMedium,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Sizes.radius),
          ),
          textStyle: const TextStyle(
            fontSize: Sizes.minBodyText,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      // OutlinedButton Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: Palette.primary,
          minimumSize: const Size(Sizes.minTouchTarget, Sizes.minTouchTarget),
          side: const BorderSide(color: Palette.primary, width: 2),
          padding: const EdgeInsets.symmetric(
            horizontal: Sizes.gapLarge,
            vertical: Sizes.gapMedium,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Sizes.radius),
          ),
          textStyle: const TextStyle(
            fontSize: Sizes.minBodyText,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      // Card Theme with tactile elevation
      cardTheme: CardThemeData(
        color: Palette.surfaceContainer,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Sizes.cardRadius),
          side:
              const BorderSide(color: Palette.surfaceContainerHigh, width: 1.5),
        ),
        margin: const EdgeInsets.symmetric(
          horizontal: Sizes.gutter,
          vertical: Sizes.gapSmall,
        ),
      ),

      // Navigation Bar Theme
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Palette.surfaceContainer,
        indicatorColor: Palette.primary.withValues(alpha: 0.15),
        height: 80,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Palette.primary,
            );
          }
          return const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Palette.muted,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(size: 32, color: Palette.primary);
          }
          return const IconThemeData(size: 28, color: Palette.muted);
        }),
      ),

      // Icon Theme
      iconTheme: const IconThemeData(
        size: 32,
        color: Palette.ink,
      ),
    );
  }
}
