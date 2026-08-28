import 'dart:typed_data';
import 'package:shilpsetu/ml/models/quality_assessment.dart';

/// Represents a captured and processed craft product image before cataloging.
class CapturedCraft {
  const CapturedCraft({
    required this.id,
    required this.localProcessedPath,
    required this.qualityAssessment,
    required this.processingDurationMs,
    required this.createdAt,
    this.rawImagePath,
    this.thumbnailBytes,
  });

  final String id;
  final String localProcessedPath;
  final String? rawImagePath;
  final QualityAssessment qualityAssessment;
  final int processingDurationMs;
  final Uint8List? thumbnailBytes;
  final DateTime createdAt;

  @override
  String toString() =>
      'CapturedCraft(id: $id, processedPath: $localProcessedPath, duration: ${processingDurationMs}ms)';
}
