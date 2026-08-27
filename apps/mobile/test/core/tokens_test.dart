import 'package:flutter_test/flutter_test.dart';
import 'package:karigar/core/theme/tokens.dart';

void main() {
  group('zero-literacy constraints (Bet 01)', () {
    test('minimum touch target is at least 64dp', () {
      // Material's 48dp default is designed for a different user than ours.
      expect(Sizes.minTouchTarget, greaterThanOrEqualTo(64));
    });

    test('primary actions are larger than the minimum target', () {
      expect(Sizes.primaryActionTarget, greaterThan(Sizes.minTouchTarget));
    });

    test('body text is never below 18sp', () {
      expect(Sizes.minBodyText, greaterThanOrEqualTo(18));
    });

    test('Phase 1 ships Hindi as well as English', () {
      final codes = SupportedLocales.phase1.map((l) => l.languageCode).toSet();
      expect(codes, containsAll(<String>['hi', 'en']));
    });
  });
}
