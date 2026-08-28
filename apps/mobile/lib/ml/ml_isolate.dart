import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shilpsetu/ml/image_processor.dart';
import 'package:shilpsetu/ml/models/quality_assessment.dart';
import 'package:shilpsetu/ml/quality_gate.dart';
import 'package:shilpsetu/ml/segmenter.dart';

/// Request payload sent to the segmentation worker isolate.
class _IsolateSegmentationRequest {
  const _IsolateSegmentationRequest({
    required this.imageBytes,
  });

  final Uint8List imageBytes;
}

/// Runner that delegates heavy ML inference and image manipulation to background isolates.
///
/// Ensures 60fps / 120fps UI render stability on budget ₹7,000 Android devices.
class MlIsolateRunner {
  const MlIsolateRunner();

  /// Evaluates pre-shutter quality in background isolate.
  Future<QualityAssessment> evaluateFrameQuality(Uint8List frameBytes) async {
    return compute(_evaluateQualityWorker, frameBytes);
  }

  /// Runs full segmentation & auto-crop pipeline in background isolate.
  Future<SegmentationResult> processSegmentation(Uint8List imageBytes) async {
    return compute(
      _segmentationWorker,
      _IsolateSegmentationRequest(imageBytes: imageBytes),
    );
  }

  static QualityAssessment _evaluateQualityWorker(Uint8List bytes) {
    const gate = QualityGate();
    return gate.evaluateImageBytes(bytes);
  }

  static Future<SegmentationResult> _segmentationWorker(
    _IsolateSegmentationRequest request,
  ) async {
    final segmenter = DeviceMlSegmenter(imageProcessor: const ImageProcessor());
    return segmenter.processImage(request.imageBytes);
  }
}
