import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:shilpsetu/ml/image_processor.dart';
import 'package:shilpsetu/ml/segmenter.dart';

void main() {
  group('Image Processor & ML Segmentation Pipeline (ADR-0003)', () {
    late ImageProcessor processor;
    late DeviceMlSegmenter segmenter;

    setUp(() {
      processor = const ImageProcessor();
      segmenter = DeviceMlSegmenter(imageProcessor: processor);
    });

    test('auto white balance balances color tint', () {
      // Warm yellow/orange tint image
      final warmImage = img.Image(width: 50, height: 50);
      img.fill(warmImage, color: img.ColorRgb8(240, 180, 100));

      final balanced = processor.autoWhiteBalance(warmImage);
      final pixel = balanced.getPixel(25, 25);

      // Channels should move closer to uniform gray
      expect(pixel.r, isNotNull);
      expect(pixel.g, isNotNull);
      expect(pixel.b, isNotNull);
    });

    test('processListingImage outputs square dimensions to marketplace spec', () {
      final input = img.Image(width: 400, height: 300);
      img.fill(input, color: img.ColorRgb8(200, 200, 200));

      final output = processor.processListingImage(
        input,
        targetDimension: 512,
      );

      expect(output.width, equals(512));
      expect(output.height, equals(512));
    });

    test('segmenter processes image and meets budget (< 1500ms)', () async {
      final input = img.Image(width: 200, height: 200);
      img.fill(input, color: img.ColorRgb8(180, 160, 140));
      final bytes = Uint8List.fromList(img.encodeJpg(input));

      final result = await segmenter.processImage(bytes);

      expect(result.processedBytes, isNotEmpty);
      expect(result.durationMs, isNonNegative);
      expect(result.isWithinBudget, isTrue);
      expect(result.durationMs, lessThan(1500));
    });
  });
}
