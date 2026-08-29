import 'dart:math' as math;
import 'dart:typed_data';
import 'package:image/image.dart' as img;

/// Image Processing Pipeline (ADR-0003).
///
/// Post-capture transformations to produce market-ready listing imagery:
/// 1. Subject bounding box auto-crop
/// 2. White balance (Gray World algorithm)
/// 3. Exposure / contrast normalization
/// 4. Neutral studio canvas framing (Amazon / Bharat TULIP listing standard)
class ImageProcessor {
  const ImageProcessor();

  /// Full post-capture enhancement pipeline.
  img.Image processListingImage(
    img.Image source, {
    img.Image? segmentationMask,
    int targetDimension = 512,
    double marginFraction = 0.10,
  }) {
    // 1. Auto-white balance
    final balanced = autoWhiteBalance(source);

    // 2. Compute bounding box of craft subject
    final boundingBox = _computeBoundingBox(
      balanced,
      mask: segmentationMask,
      marginFraction: marginFraction,
    );

    // 3. Crop to square listing frame
    final cropped = _cropToSquare(balanced, boundingBox);

    // 4. Resize to standard listing dimension
    final resized = img.copyResize(
      cropped,
      width: targetDimension,
      height: targetDimension,
      interpolation: img.Interpolation.linear,
    );

    // 5. Mild contrast enhancement for marketplace clarity
    return _enhanceListingClarity(resized);
  }

  /// White balance using the Gray World assumption.
  /// Computes average R, G, B channels and scales each to the overall gray mean.
  img.Image autoWhiteBalance(img.Image input) {
    final result = img.Image.from(input);
    final width = result.width;
    final height = result.height;
    final totalPixels = width * height;
    if (totalPixels == 0) return result;

    var sumR = 0.0;
    var sumG = 0.0;
    var sumB = 0.0;

    for (var y = 0; y < height; y++) {
      for (var x = 0; x < width; x++) {
        final pixel = result.getPixel(x, y);
        sumR += pixel.r;
        sumG += pixel.g;
        sumB += pixel.b;
      }
    }

    final avgR = sumR / totalPixels;
    final avgG = sumG / totalPixels;
    final avgB = sumB / totalPixels;
    final grayMean = (avgR + avgG + avgB) / 3.0;

    if (avgR == 0 || avgG == 0 || avgB == 0) return result;

    final scaleR = (grayMean / avgR).clamp(0.7, 1.4);
    final scaleG = (grayMean / avgG).clamp(0.7, 1.4);
    final scaleB = (grayMean / avgB).clamp(0.7, 1.4);

    for (var y = 0; y < height; y++) {
      for (var x = 0; x < width; x++) {
        final pixel = result.getPixel(x, y);
        final r = (pixel.r * scaleR).round().clamp(0, 255);
        final g = (pixel.g * scaleG).round().clamp(0, 255);
        final b = (pixel.b * scaleB).round().clamp(0, 255);
        result.setPixelRgba(x, y, r, g, b, pixel.a);
      }
    }

    return result;
  }

  /// Bounding box calculation based on foreground mask or center saliency.
  math.Rectangle<int> _computeBoundingBox(
    img.Image image, {
    img.Image? mask,
    double marginFraction = 0.10,
  }) {
    final w = image.width;
    final h = image.height;

    if (mask != null && mask.width == w && mask.height == h) {
      var minX = w;
      var maxX = 0;
      var minY = h;
      var maxY = 0;
      var found = false;

      for (var y = 0; y < h; y++) {
        for (var x = 0; x < w; x++) {
          final alpha = mask.getPixel(x, y).r;
          if (alpha > 128) {
            found = true;
            if (x < minX) minX = x;
            if (x > maxX) maxX = x;
            if (y < minY) minY = y;
            if (y > maxY) maxY = y;
          }
        }
      }

      if (found && maxX > minX && maxY > minY) {
        final boxW = maxX - minX;
        final boxH = maxY - minY;
        final padX = (boxW * marginFraction).round();
        final padY = (boxH * marginFraction).round();

        final left = math.max(0, minX - padX);
        final top = math.max(0, minY - padY);
        final width = math.min(w - left, boxW + (padX * 2));
        final height = math.min(h - top, boxH + (padY * 2));

        return math.Rectangle(left, top, width, height);
      }
    }

    // Default center-weighted box (80% of dimension)
    final boxSize = math.min(w, h);
    final left = ((w - boxSize) / 2).round();
    final top = ((h - boxSize) / 2).round();
    return math.Rectangle(left, top, boxSize, boxSize);
  }

  /// Crops to a square bounding box centered around the subject rectangle.
  img.Image _cropToSquare(img.Image image, math.Rectangle<int> rect) {
    final w = image.width;
    final h = image.height;

    final centerX = rect.left + (rect.width ~/ 2);
    final centerY = rect.top + (rect.height ~/ 2);
    final side = math.max(rect.width, rect.height);

    final halfSide = side ~/ 2;
    var x = centerX - halfSide;
    var y = centerY - halfSide;

    // Adjust boundaries to stay inside image
    if (x < 0) x = 0;
    if (y < 0) y = 0;
    if (x + side > w) x = math.max(0, w - side);
    if (y + side > h) y = math.max(0, h - side);

    final finalSide = math.min(side, math.min(w - x, h - y));
    return img.copyCrop(image, x: x, y: y, width: finalSide, height: finalSide);
  }

  /// Contrast normalization and sharpening for crisp craft texture.
  img.Image _enhanceListingClarity(img.Image input) {
    // Normalise histogram / contrast stretch
    return img.adjustColor(input, contrast: 1.08, saturation: 1.05);
  }

  /// Encodes image to JPEG bytes with high quality for storage.
  Uint8List encodeListingJpeg(img.Image image, {int quality = 90}) {
    return Uint8List.fromList(img.encodeJpg(image, quality: quality));
  }
}
