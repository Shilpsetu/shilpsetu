import 'dart:typed_data';
import 'package:shilpsetu/features/capture/domain/models/captured_craft.dart';
import 'package:shilpsetu/ml/models/quality_assessment.dart';

/// Repository contract for craft photo capture and studio pipeline.
abstract class CaptureRepository {
  /// Evaluates pre-shutter frame quality in real-time.
  Future<QualityAssessment> evaluateFrame(Uint8List frameBytes);

  /// Captures, segments, white-balances, and saves a marketplace-ready listing image.
  Future<CapturedCraft> processAndSaveCapture({
    required Uint8List rawBytes,
    required QualityAssessment quality,
  });

  /// Saves a draft entry in Drift local database.
  Future<void> saveLocalDraft(CapturedCraft craft);
}
