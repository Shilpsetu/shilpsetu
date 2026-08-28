import 'dart:math' as math;
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:shilpsetu/ml/models/quality_assessment.dart';

/// Pre-shutter quality gate (ADR-0003).
///
/// Refuses a blurred, underexposed, or backlit frame *before* the shutter
/// fires and explains why aloud. Fixing a bad photo on a village phone
/// is more expensive than not taking one.
class QualityGate {
  const QualityGate({
    this.blurThreshold = 45,
    this.minBrightness = 40,
    this.maxBrightness = 230,
    this.backlightRatioThreshold = 2.4,
  });

  /// Laplacian variance threshold for blur detection. Lower means more blur.
  final double blurThreshold;

  /// Minimum acceptable mean luminance (0-255).
  final double minBrightness;

  /// Maximum acceptable mean luminance before overexposure.
  final double maxBrightness;

  /// Ratio of outer frame brightness to center frame brightness.
  /// A ratio > threshold indicates backlighting.
  final double backlightRatioThreshold;

  /// Evaluates an image from raw decoded bytes.
  QualityAssessment evaluateImageBytes(Uint8List bytes) {
    final image = img.decodeImage(bytes);
    if (image == null) {
      return QualityAssessment.fail(
        issue: QualityIssue.blur,
        blurScore: 0,
        brightnessScore: 0,
        backlightScore: 0,
        guidanceMessage: 'Unable to decode image frame.',
      );
    }
    return evaluateImage(image);
  }

  /// Evaluates an `img.Image` structure.
  QualityAssessment evaluateImage(img.Image image) {
    // Downscale to ~160x120 for real-time evaluation (< 10ms).
    final downscaled = (image.width > 240 || image.height > 240)
        ? img.copyResize(
            image,
            width: 160,
            height: (160 * image.height / image.width).round(),
          )
        : image;

    final grayscale = img.grayscale(downscaled);
    final width = grayscale.width;
    final height = grayscale.height;

    // 1. Mean brightness & backlight ratio
    var totalLuminance = 0.0;
    var centerLuminance = 0.0;
    var borderLuminance = 0.0;
    var centerCount = 0;
    var borderCount = 0;

    final centerXMin = (width * 0.25).round();
    final centerXMax = (width * 0.75).round();
    final centerYMin = (height * 0.25).round();
    final centerYMax = (height * 0.75).round();

    for (var y = 0; y < height; y++) {
      for (var x = 0; x < width; x++) {
        final pixel = grayscale.getPixel(x, y);
        final lum = pixel.r.toDouble(); // In grayscale, r == g == b
        totalLuminance += lum;

        if (x >= centerXMin &&
            x <= centerXMax &&
            y >= centerYMin &&
            y <= centerYMax) {
          centerLuminance += lum;
          centerCount++;
        } else {
          borderLuminance += lum;
          borderCount++;
        }
      }
    }

    final totalPixels = width * height;
    final meanBrightness = totalPixels > 0 ? totalLuminance / totalPixels : 0.0;
    final avgCenter = centerCount > 0 ? centerLuminance / centerCount : 0.0;
    final avgBorder = borderCount > 0 ? borderLuminance / borderCount : 0.0;

    // Backlight ratio: background is much brighter than subject in center
    final backlightRatio = avgCenter > 5 ? avgBorder / avgCenter : 1.0;

    // 2. Blur detection via Laplacian edge variance
    final blurVariance = _calculateLaplacianVariance(grayscale);

    // Check quality criteria in order of severity:
    // A. Underexposure (Too Dark)
    if (meanBrightness < minBrightness) {
      return QualityAssessment.fail(
        issue: QualityIssue.tooDark,
        blurScore: blurVariance,
        brightnessScore: meanBrightness,
        backlightScore: backlightRatio,
        guidanceMessage: 'Too dark. Please move to brighter light.',
      );
    }

    // B. Backlighting
    if (backlightRatio > backlightRatioThreshold &&
        avgBorder > 160 &&
        avgCenter < 100) {
      return QualityAssessment.fail(
        issue: QualityIssue.backlight,
        blurScore: blurVariance,
        brightnessScore: meanBrightness,
        backlightScore: backlightRatio,
        guidanceMessage: 'Light is behind the object. Move to face the light.',
      );
    }

    // C. Blur
    if (blurVariance < blurThreshold) {
      return QualityAssessment.fail(
        issue: QualityIssue.blur,
        blurScore: blurVariance,
        brightnessScore: meanBrightness,
        backlightScore: backlightRatio,
        guidanceMessage: 'The photo is blurry. Please hold steady.',
      );
    }

    return QualityAssessment.pass(
      blurScore: blurVariance,
      brightnessScore: meanBrightness,
      backlightScore: backlightRatio,
    );
  }

  /// Calculates variance of the discrete 3x3 Laplacian operator.
  /// Standard computer vision method for blur detection (Pech-Pacheco et al.).
  double _calculateLaplacianVariance(img.Image gray) {
    final w = gray.width;
    final h = gray.height;
    if (w < 3 || h < 3) return 100;

    var sum = 0.0;
    var sumSq = 0.0;
    var count = 0;

    // Kernel:
    // [ 0,  1, 0]
    // [ 1, -4, 1]
    // [ 0,  1, 0]
    for (var y = 1; y < h - 1; y++) {
      for (var x = 1; x < w - 1; x++) {
        final center = gray.getPixel(x, y).r;
        final top = gray.getPixel(x, y - 1).r;
        final bottom = gray.getPixel(x, y + 1).r;
        final left = gray.getPixel(x - 1, y).r;
        final right = gray.getPixel(x + 1, y).r;

        final laplacian = (top + bottom + left + right - (4 * center)).toDouble();
        sum += laplacian;
        sumSq += laplacian * laplacian;
        count++;
      }
    }

    if (count == 0) return 0;
    final mean = sum / count;
    final variance = (sumSq / count) - (mean * mean);
    return math.max(0, variance);
  }
}
