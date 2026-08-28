import 'dart:io';
import 'dart:typed_data';
import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shilpsetu/core/database/app_database.dart';
import 'package:shilpsetu/features/capture/domain/models/captured_craft.dart';
import 'package:shilpsetu/features/capture/domain/repository/capture_repository.dart';
import 'package:shilpsetu/ml/ml_isolate.dart';
import 'package:shilpsetu/ml/models/quality_assessment.dart';
import 'package:shilpsetu/ml/quality_gate.dart';
import 'package:shilpsetu/ml/segmenter.dart';

class CaptureRepositoryImpl implements CaptureRepository {
  CaptureRepositoryImpl({
    AppDatabase? database,
    MlIsolateRunner? isolateRunner,
    QualityGate? qualityGate,
    MlSegmenter? segmenter,
  })  : _database = database,
        _isolateRunner = isolateRunner ?? MlIsolateRunner(qualityGate: qualityGate, segmenter: segmenter),
        _qualityGate = qualityGate ?? const QualityGate(),
        _segmenter = segmenter ?? DeviceMlSegmenter();

  final AppDatabase? _database;
  final MlIsolateRunner _isolateRunner;
  final QualityGate _qualityGate;
  final MlSegmenter _segmenter;

  @override
  Future<QualityAssessment> evaluateFrame(Uint8List frameBytes) async {
    try {
      return await _isolateRunner.evaluateFrameQuality(frameBytes);
    } catch (_) {
      // Fallback to in-isolate / direct evaluation
      return _qualityGate.evaluateImageBytes(frameBytes);
    }
  }

  @override
  Future<CapturedCraft> processAndSaveCapture({
    required Uint8List rawBytes,
    required QualityAssessment quality,
  }) async {
    // 1. Run ML segmentation & image enhancement
    SegmentationResult result;
    try {
      result = await _isolateRunner.processSegmentation(rawBytes);
    } catch (_) {
      result = await _segmenter.processImage(rawBytes);
    }

    // 2. Persist output image to local storage
    final craftId = 'craft_${DateTime.now().millisecondsSinceEpoch}';
    final outputDir = await _getStorageDirectory();
    final filePath = p.join(outputDir.path, '$craftId.jpg');
    final file = File(filePath);
    await file.writeAsBytes(result.processedBytes, flush: true);

    final capturedCraft = CapturedCraft(
      id: craftId,
      localProcessedPath: filePath,
      qualityAssessment: quality,
      processingDurationMs: result.durationMs,
      thumbnailBytes: result.processedBytes,
      createdAt: DateTime.now(),
    );

    // 3. Store draft record in Drift database
    await saveLocalDraft(capturedCraft);

    return capturedCraft;
  }

  @override
  Future<void> saveLocalDraft(CapturedCraft craft) async {
    final db = _database;
    if (db == null) return;

    await db.insertProduct(
      LocalProductsCompanion(
        id: Value(craft.id),
        localImagePath: Value(craft.localProcessedPath),
        status: const Value('draft'),
        createdAt: Value(craft.createdAt),
        updatedAt: Value(craft.createdAt),
      ),
    );
  }

  Future<Directory> _getStorageDirectory() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final craftsDir = Directory(p.join(appDir.path, 'crafts'));
      if (!await craftsDir.exists()) {
        await craftsDir.create(parents: true);
      }
      return craftsDir;
    } catch (_) {
      // Fallback for tests / memory filesystem
      final tempDir = Directory.systemTemp;
      return tempDir;
    }
  }
}
