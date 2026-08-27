/// Design tokens for the zero-literacy interaction model (Bet 01).
///
/// These are not styling suggestions. They are the constraints that make the
/// app usable by an artisan who cannot read, on a low-end device, in daylight.
/// Changing a value here changes a claim we make on stage — discuss it before
/// you do.
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

  /// Primary actions (capture, record, confirm) get this.
  static const double primaryActionTarget = 96;

  /// Minimum body text. Below this we are guessing that people can read.
  static const double minBodyText = 18;

  static const double gutter = 20;
  static const double gapSmall = 12;
  static const double gapLarge = 28;
  static const double radius = 12;
}

/// Semantic colours.
///
/// Meaning is never carried by hue alone — every state also carries an icon
/// and a spoken cue, because colour-blind users and bright sunlight both
/// destroy hue. Contrast ratios below are against [Palette.surface] and must
/// stay at or above WCAG AA (4.5:1) for text.
abstract final class Palette {
  static const Color surface = Color(0xFFF6F5F2);
  static const Color ink = Color(0xFF15171C);
  static const Color muted = Color(0xFF5B6068);

  /// Natural indigo — primary actions, focus, selection.
  static const Color primary = Color(0xFF2E3A73);
  static const Color onPrimary = Color(0xFFFFFFFF);

  /// Confirm / publish. Paired with a check icon and a spoken confirmation.
  static const Color affirm = Color(0xFF1F6B47);

  /// Re-record / reject. Paired with an undo icon, never used alone.
  static const Color revise = Color(0xFF9B3A2F);

  /// Below the fair-wage floor. This colour means "we will not publish this"
  /// (Bet 03) and is used nowhere else.
  static const Color belowFloor = Color(0xFF9B3A2F);
}

/// Timing.
abstract final class Timings {
  /// Budget for on-device segmentation on the reference device (ADR-0003).
  /// Exceeding this is a release blocker, not a performance nice-to-have.
  static const Duration segmentationBudget = Duration(milliseconds: 1500);

  /// How long a spoken prompt waits before repeating itself.
  static const Duration promptRepeatAfter = Duration(seconds: 6);
}

/// Languages the app ships with. Phase 1 is Hindi + English only; the rest
/// arrive in Phase 2. Adding a locale here without adding its ARB file is a
/// build failure, which is deliberate.
abstract final class SupportedLocales {
  static const List<Locale> phase1 = [
    Locale('hi', 'IN'),
    Locale('en', 'IN'),
  ];
}
