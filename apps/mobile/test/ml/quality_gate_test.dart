import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:shilpsetu/ml/models/quality_assessment.dart';
import 'package:shilpsetu/ml/quality_gate.dart';

void main() {
  group('Pre-shutter Quality Gate (ADR-0003)', () {
    late QualityGate qualityGate;

    setUp(() {
      qualityGate = const QualityGate();
    });

    test('accepts clear, well-lit craft photo', () {
      // Create sharp image with high edge variance and good exposure
      final image = img.Image(width: 160, height: 160);
      img.fill(image, color: img.ColorRgb8(180, 180, 180));
      // Checkerboard / high frequency pattern
      for (var y = 20; y < 140; y += 10) {
        for (var x = 20; x < 140; x += 10) {
          img.fillRect(
            image,
            x1: x,
            y1: y,
            x2: x + 5,
            y2: y + 5,
            color: img.ColorRgb8(30, 30, 30),
          );
        }
      }

      final assessment = qualityGate.evaluateImage(image);
      expect(assessment.isAcceptable, isTrue);
      expect(assessment.issue, equals(QualityIssue.none));
      expect(assessment.blurScore, greaterThan(qualityGate.blurThreshold));
    });

    test('refuses underexposed / dark frame and provides spoken guidance key', () {
      // Very dark image
      final darkImage = img.Image(width: 160, height: 160);
      img.fill(darkImage, color: img.ColorRgb8(15, 15, 15));

      final assessment = qualityGate.evaluateImage(darkImage);
      expect(assessment.isAcceptable, isFalse);
      expect(assessment.issue, equals(QualityIssue.tooDark));
      expect(assessment.arbKey, equals('qualityDark'));
      expect(assessment.guidanceMessage, contains('Too dark'));
    });

    test('refuses flat blurry image with low Laplacian variance', () {
      // Solid uniform color (0 variance = maximum blur)
      final flatImage = img.Image(width: 160, height: 160);
      img.fill(flatImage, color: img.ColorRgb8(140, 140, 140));

      final assessment = qualityGate.evaluateImage(flatImage);
      expect(assessment.isAcceptable, isFalse);
      expect(assessment.issue, equals(QualityIssue.blur));
      expect(assessment.arbKey, equals('qualityBlur'));
      expect(assessment.guidanceMessage, contains('blurry'));
    });

    test('evaluates raw decoded bytes gracefully', () {
      final image = img.Image(width: 100, height: 100);
      img.fill(image, color: img.ColorRgb8(150, 150, 150));
      final bytes = Uint8List.fromList(img.encodeJpg(image));

      final assessment = qualityGate.evaluateImageBytes(bytes);
      expect(assessment, isNotNull);
    });
  });
}
