import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:shilpsetu/features/capture/domain/models/captured_craft.dart';
import 'package:shilpsetu/features/capture/domain/repository/capture_repository.dart';
import 'package:shilpsetu/features/capture/presentation/controllers/capture_controller.dart';
import 'package:shilpsetu/ml/models/quality_assessment.dart';

class MockCaptureRepository implements CaptureRepository {
  bool shouldPassQuality = true;

  @override
  Future<QualityAssessment> evaluateFrame(Uint8List frameBytes) async {
    if (shouldPassQuality) {
      return QualityAssessment.pass(blurScore: 120, brightnessScore: 120);
    }
    return QualityAssessment.fail(
      issue: QualityIssue.blur,
      blurScore: 10,
      brightnessScore: 120,
      backlightScore: 1,
      guidanceMessage: 'The photo is blurry. Please hold steady.',
    );
  }

  @override
  Future<CapturedCraft> processAndSaveCapture({
    required Uint8List rawBytes,
    required QualityAssessment quality,
  }) async {
    return CapturedCraft(
      id: 'test_craft_1',
      localProcessedPath: '/temp/test_craft_1.jpg',
      qualityAssessment: quality,
      processingDurationMs: 320,
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<void> saveLocalDraft(CapturedCraft craft) async {}
}

void main() {
  group('CaptureController', () {
    late MockCaptureRepository repository;
    late CaptureController controller;

    setUp(() {
      repository = MockCaptureRepository();
      controller = CaptureController(repository: repository);
    });

    test('initial state has camera not ready and no error', () {
      expect(controller.state.isCameraReady, isFalse);
      expect(controller.state.isProcessing, isFalse);
      expect(controller.state.errorMessage, isNull);
    });

    test('toggleFlash flips flash state', () {
      expect(controller.state.isFlashOn, isFalse);
      controller.toggleFlash();
      expect(controller.state.isFlashOn, isTrue);
      controller.toggleFlash();
      expect(controller.state.isFlashOn, isFalse);
    });

    test('captureAndProcess rejects blurry frame before processing', () async {
      repository.shouldPassQuality = false;

      final testImage = img.Image(width: 50, height: 50);
      final bytes = Uint8List.fromList(img.encodeJpg(testImage));

      final result = await controller.captureAndProcess(bytes);

      expect(result, isNull);
      expect(controller.state.quality.isAcceptable, isFalse);
      expect(controller.state.errorMessage, contains('blurry'));
      expect(controller.state.isProcessing, isFalse);
    });

    test('captureAndProcess succeeds when quality passes', () async {
      repository.shouldPassQuality = true;

      final testImage = img.Image(width: 50, height: 50);
      final bytes = Uint8List.fromList(img.encodeJpg(testImage));

      final result = await controller.captureAndProcess(bytes);

      expect(result, isNotNull);
      expect(result!.id, equals('test_craft_1'));
      expect(controller.state.isProcessing, isFalse);
      expect(controller.state.capturedCraft, isNotNull);
    });
  });
}
