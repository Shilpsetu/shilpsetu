/// Design tokens for the zero-literacy interaction model (Bet 01).
///
/// These are not styling suggestions. They are the strict constraints that
/// make the app usable by an artisan who cannot read, on a low-end device, in daylight.
library;

import 'package:flutter/widgets.dart';

/// Sizing rules.
///
/// Ordinary Material guidance says 48dp minimum touch target. We use 64dp:
/// our users are often older, frequently outdoors, and sometimes have hands
/// roughened by loom work. 48dp is designed for a different person.
abstract final class Sizes {
  /// Absolute minimum tappable edge. Nothing interactive may be smaller.
  static const double minTouchTarget = 64;

  /// Primary actions (capture shutter, record voice, confirm publish) get this.
  static const double primaryActionTarget = 96;

  /// Minimum body text. Below this we are guessing that people can read.
  static const double minBodyText = 18;

  /// Header and prompt text size.
  static const double promptText = 22;

  /// Giant counter/price text size.
  static const double heroText = 32;

  static const double gutter = 20;
  static const double gapSmall = 12;
  static const double gapMedium = 16;
  static const double gapLarge = 28;
  static const double radius = 16;
  static const double cardRadius = 20;
}

/// Semantic colours inspired by natural Indian craft dyes and high-contrast accessibility.
///
/// Meaning is never carried by hue alone — every state also carries an icon
/// and a spoken cue, because colour-blind users and bright sunlight both
/// destroy hue. Contrast ratios below are against [Palette.surface] and must
/// stay at or above WCAG AA (4.5:1) for text.
abstract final class Palette {
  /// Natural warm canvas / handmade paper surface.
  static const Color surface = Color(0xFFF7F5EE);
  static const Color surfaceContainer = Color(0xFFEBE8DC);
  static const Color surfaceContainerHigh = Color(0xFFDFDACB);

  /// High contrast ink for text and contours.
  static const Color ink = Color(0xFF16181D);
  static const Color muted = Color(0xFF535862);

  /// Natural indigo — primary actions, focus, active navigation.
  static const Color primary = Color(0xFF1E2F5D);
  static const Color primaryLight = Color(0xFF334B8C);
  static const Color onPrimary = Color(0xFFFFFFFF);

  /// Terracotta / Ochre accent for secondary craft badges and cards.
  static const Color terracotta = Color(0xFFB54D2B);
  static const Color terracottaLight = Color(0xFFF5E4DC);

  /// Brass / Sandalwood gold accent for highlights and active audio cues.
  static const Color goldAccent = Color(0xFFC78B25);
  static const Color goldAccentLight = Color(0xFFFBF2DC);

  /// Forest leaf green — Confirm / publish / quality pass.
  static const Color affirm = Color(0xFF1B633F);
  static const Color affirmLight = Color(0xFFE2F0E7);

  /// Madder root red — Re-record / reject / below fair-wage floor.
  static const Color revise = Color(0xFF9E2A2B);
  static const Color reviseLight = Color(0xFFFBE6E7);

  /// Below the fair-wage floor. This colour means "we will not publish this"
  /// (Bet 03) and is used nowhere else.
  static const Color belowFloor = Color(0xFF9E2A2B);
  static const Color belowFloorLight = Color(0xFFFBE6E7);

  /// Camera guidance warning (blur, underexposure, backlight).
  static const Color warning = Color(0xFFD97706);
  static const Color warningLight = Color(0xFFFEF3C7);

  /// Brand signature logo and hero container colors
  static const Color logoBadgeBg = Color(0xFF2C328E);
  static const Color logoOrange = Color(0xFFE85026);
  static const Color logoInk = Color(0xFF1E212D);
  static const Color purpleContainer = Color(0xFF676BB0);
  static const Color purpleContainerDark = Color(0xFF575B9E);
  static const Color purpleContainerLight = Color(0xFFEEEFFB);
  static const Color amberButton = Color(0xFFF7A833);
  static const Color amberButtonDark = Color(0xFFE59822);
}

/// Timing and latency budgets.
abstract final class Timings {
  /// Budget for on-device segmentation on the reference device (ADR-0003).
  /// Exceeding this is a release blocker, not a performance nice-to-have.
  static const Duration segmentationBudget = Duration(milliseconds: 1500);

  /// How long a spoken prompt waits before repeating itself.
  static const Duration promptRepeatAfter = Duration(seconds: 6);

  /// Animation duration for button press and state feedback.
  static const Duration microInteraction = Duration(milliseconds: 200);
}

/// Supported locales.
abstract final class SupportedLocales {
  static const List<Locale> phase1 = [
    Locale('hi', 'IN'),
    Locale('en', 'IN'),
  ];
}
