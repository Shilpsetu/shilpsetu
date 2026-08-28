import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shilpsetu/core/database/database_provider.dart';
import 'package:shilpsetu/features/capture/data/repository/capture_repository_impl.dart';
import 'package:shilpsetu/features/capture/domain/models/captured_craft.dart';
import 'package:shilpsetu/features/capture/domain/repository/capture_repository.dart';
import 'package:shilpsetu/ml/models/quality_assessment.dart';

/// State of the camera and studio capture pipeline.
class CaptureState {
  const CaptureState({
    required this.isCameraReady,
    required this.isProcessing,
    required this.quality,
    this.capturedCraft,
    this.errorMessage,
    this.isFlashOn = false,
  });

  factory CaptureState.initial() => CaptureState(
        isCameraReady: false,
        isProcessing: false,
        quality: QualityAssessment.pass(),
      );

  final bool isCameraReady;
  final bool isProcessing;
  final QualityAssessment quality;
  final CapturedCraft? capturedCraft;
  final String? errorMessage;
  final bool isFlashOn;

  CaptureState copyWith({
    bool? isCameraReady,
    bool? isProcessing,
    QualityAssessment? quality,
    CapturedCraft? capturedCraft,
    String? errorMessage,
    bool? isFlashOn,
  }) {
    return CaptureState(
      isCameraReady: isCameraReady ?? this.isCameraReady,
      isProcessing: isProcessing ?? this.isProcessing,
      quality: quality ?? this.quality,
      capturedCraft: capturedCraft ?? this.capturedCraft,
      errorMessage: errorMessage,
      isFlashOn: isFlashOn ?? this.isFlashOn,
    );
  }
}

/// Provider for CaptureRepository.
final captureRepositoryProvider = Provider<CaptureRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return CaptureRepositoryImpl(database: db);
});

/// Riverpod notifier controlling camera view, real-time quality gate, and ML processing.
class CaptureController extends StateNotifier<CaptureState> {
  CaptureController({required CaptureRepository repository})
      : _repository = repository,
        super(CaptureState.initial());

  final CaptureRepository _repository;

  void setCameraReady(bool isReady) {
    state = state.copyWith(isCameraReady: isReady);
  }

  void toggleFlash() {
    state = state.copyWith(isFlashOn: !state.isFlashOn);
  }

  /// Live pre-shutter quality check.
  Future<void> assessLiveFrame(Uint8List frameBytes) async {
    if (state.isProcessing) return;

    try {
      final quality = await _repository.evaluateFrame(frameBytes);
      state = state.copyWith(quality: quality);
    } catch (_) {
      // Keep previous assessment on transient frame read failure
    }
  }

  /// Trigger shutter capture and on-device ML studio pipeline.
  Future<CapturedCraft?> captureAndProcess(Uint8List rawBytes) async {
    // 1. Pre-shutter quality gate check
    final quality = await _repository.evaluateFrame(rawBytes);
    if (!quality.isAcceptable) {
      state = state.copyWith(
        quality: quality,
        errorMessage: quality.guidanceMessage,
      );
      return null;
    }

    state = state.copyWith(isProcessing: true, errorMessage: null);

    try {
      final craft = await _repository.processAndSaveCapture(
        rawBytes: rawBytes,
        quality: quality,
      );

      state = state.copyWith(
        isProcessing: false,
        capturedCraft: craft,
        quality: QualityAssessment.pass(),
      );

      return craft;
    } catch (e) {
      state = state.copyWith(
        isProcessing: false,
        errorMessage: 'Capture processing failed: $e',
      );
      return null;
    }
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  void reset() {
    state = CaptureState.initial();
  }
}

final captureControllerProvider =
    StateNotifierProvider<CaptureController, CaptureState>((ref) {
  final repository = ref.watch(captureRepositoryProvider);
  return CaptureController(repository: repository);
});
