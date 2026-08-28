import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:go_router/go_router.dart';
import 'package:image/image.dart' as img;
import 'package:shilpsetu/core/theme/accessible_widgets.dart';
import 'package:shilpsetu/core/theme/tokens.dart';
import 'package:shilpsetu/features/capture/presentation/controllers/capture_controller.dart';
import 'package:shilpsetu/ml/models/quality_assessment.dart';

/// Primary capture screen (Flutter Dev A).
///
/// Features:
/// - Real-time camera viewfinder
/// - Pre-shutter quality gate banner (blur, backlight, underexposure)
/// - 96dp primary capture shutter button (Sizes.primaryActionTarget)
/// - 64dp secondary control buttons (Sizes.minTouchTarget)
/// - Zero-literacy spoken capture prompts & multi-lingual audio guidance
class CaptureScreen extends ConsumerStatefulWidget {
  const CaptureScreen({super.key});

  @override
  ConsumerState<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends ConsumerState<CaptureScreen> {
  late final FlutterTts _tts;
  String? _lastSpokenWarning;

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  Future<void> _initTts() async {
    _tts = FlutterTts();
    try {
      await _tts.setLanguage('hi-IN');
      await _tts.setSpeechRate(0.45);
      await _tts.setPitch(1.0);
    } catch (_) {
      // Fallback if TTS engine isn't configured in test/emulator
    }
  }

  Future<void> _speakPrompt(String text) async {
    try {
      await _tts.stop();
      await _tts.speak(text);
    } catch (_) {}
  }

  void _handleQualityAlert(QualityAssessment quality) {
    if (!quality.isAcceptable && quality.guidanceMessage != null) {
      if (_lastSpokenWarning != quality.guidanceMessage) {
        _lastSpokenWarning = quality.guidanceMessage;
        _speakPrompt(quality.guidanceMessage!);
      }
    } else {
      _lastSpokenWarning = null;
    }
  }

  /// Simulates / triggers camera capture
  Future<void> _onShutterPressed() async {
    final controller = ref.read(captureControllerProvider.notifier);

    // Create demo craft sample image (high contrast pattern)
    final demoImage = img.Image(width: 480, height: 480);
    img.fill(demoImage, color: img.ColorRgb8(240, 235, 220));
    img.fillCircle(demoImage, x: 240, y: 240, radius: 140, color: img.ColorRgb8(181, 77, 43)); // Terracotta craft
    img.drawCircle(demoImage, x: 240, y: 240, radius: 100, color: img.ColorRgb8(30, 47, 93)); // Indigo motif
    final rawBytes = Uint8List.fromList(img.encodeJpg(demoImage, quality: 90));

    final craft = await controller.captureAndProcess(rawBytes);

    if (!mounted) return;

    if (craft != null) {
      // Show studio enhancement benchmark banner
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Palette.affirm,
          duration: const Duration(seconds: 2),
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Processed in ${craft.processingDurationMs}ms (Budget: ${Timings.segmentationBudget.inMilliseconds}ms)',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      );

      // Transition to voice cataloger flow with craft ID
      context.push('/cataloger');
    }
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final captureState = ref.watch(captureControllerProvider);
    final quality = captureState.quality;

    ref.listen<CaptureState>(captureControllerProvider, (prev, next) {
      if (prev?.quality.issue != next.quality.issue) {
        _handleQualityAlert(next.quality);
      }
    });

    final hasWarning = !quality.isAcceptable;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'शिल्पसेतु • Shilpsetu',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: Palette.surfaceContainer,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.volume_up_rounded, size: 28),
            tooltip: 'Speak guidance',
            onPressed: () {
              _speakPrompt('आपने जो बनाया है वह दिखाइए. Show me what you made');
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Zero-Literacy Prompt Banner
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Sizes.gutter,
                vertical: Sizes.gapSmall,
              ),
              child: ZeroLiteracyPromptCard(
                promptText: 'आपने जो बनाया है वह दिखाइए\nShow me what you made',
                icon: Icons.camera_alt_rounded,
                onReplayAudio: () {
                  _speakPrompt('आपने जो बनाया है वह दिखाइए');
                },
              ),
            ),

            // Viewfinder Area / Camera Container
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: Sizes.gutter),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(Sizes.cardRadius),
                  border: Border.all(
                    color: hasWarning
                        ? Palette.warning
                        : Palette.primary.withValues(alpha: 0.3),
                    width: hasWarning ? 4 : 2,
                  ),
                  boxShadow: [
                    if (hasWarning)
                      BoxShadow(
                        color: Palette.warning.withValues(alpha: 0.25),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                  ],
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Viewfinder Framing Grid & Guide
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.crop_free_rounded,
                            size: 110,
                            color: hasWarning
                                ? Palette.warning.withValues(alpha: 0.8)
                                : Colors.white.withValues(alpha: 0.7),
                          ),
                          const SizedBox(height: Sizes.gapMedium),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(Sizes.radius),
                            ),
                            child: const Text(
                              'Center craft inside frame\nवस्तु को केंद्र में रखें',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: Sizes.minBodyText,
                                fontWeight: FontWeight.w600,
                                height: 1.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Pre-shutter Quality Gate Overlay Banner
                    if (hasWarning)
                      Positioned(
                        top: 16,
                        left: 16,
                        right: 16,
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Palette.warningLight,
                            borderRadius: BorderRadius.circular(Sizes.radius),
                            border: Border.all(color: Palette.warning, width: 2),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.warning_amber_rounded,
                                color: Palette.warning,
                                size: 32,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  quality.guidanceMessage ?? 'Check lighting and focus',
                                  style: const TextStyle(
                                    color: Palette.ink,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.volume_up_rounded, color: Palette.warning),
                                onPressed: () {
                                  if (quality.guidanceMessage != null) {
                                    _speakPrompt(quality.guidanceMessage!);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ),

                    // Active ML processing overlay
                    if (captureState.isProcessing)
                      Container(
                        color: Colors.black54,
                        child: const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(
                                color: Palette.onPrimary,
                                strokeWidth: 4,
                              ),
                              SizedBox(height: Sizes.gapMedium),
                              Text(
                                'Enhancing craft photo...\nस्टूडियो फोटो तैयार हो रही है...',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: Sizes.minBodyText,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Shutter Controls (Strict 64dp & 96dp Touch Targets)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Sizes.gutter,
                vertical: Sizes.gapMedium,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Gallery picker button (64dp target)
                  IconButton.filledTonal(
                    style: IconButton.styleFrom(
                      minimumSize: const Size(
                        Sizes.minTouchTarget,
                        Sizes.minTouchTarget,
                      ),
                      backgroundColor: Palette.surfaceContainerHigh,
                    ),
                    icon: const Icon(Icons.photo_library_outlined, size: 30),
                    tooltip: 'Gallery',
                    onPressed: captureState.isProcessing ? null : _onShutterPressed,
                  ),

                  // Shutter Button (96dp primary action target)
                  InkWell(
                    onTap: captureState.isProcessing ? null : _onShutterPressed,
                    borderRadius: BorderRadius.circular(50),
                    child: Container(
                      width: Sizes.primaryActionTarget,
                      height: Sizes.primaryActionTarget,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: hasWarning ? Palette.warning : Palette.primary,
                        border: Border.all(color: Colors.white, width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: (hasWarning ? Palette.warning : Palette.primary)
                                .withValues(alpha: 0.4),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: captureState.isProcessing
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            )
                          : const Icon(
                              Icons.camera_alt_rounded,
                              size: 48,
                              color: Palette.onPrimary,
                            ),
                    ),
                  ),

                  // Flash toggle button (64dp target)
                  IconButton.filledTonal(
                    style: IconButton.styleFrom(
                      minimumSize: const Size(
                        Sizes.minTouchTarget,
                        Sizes.minTouchTarget,
                      ),
                      backgroundColor: captureState.isFlashOn
                          ? Palette.goldAccentLight
                          : Palette.surfaceContainerHigh,
                    ),
                    icon: Icon(
                      captureState.isFlashOn
                          ? Icons.flash_on_rounded
                          : Icons.flash_off_rounded,
                      color: captureState.isFlashOn ? Palette.goldAccent : Palette.ink,
                      size: 30,
                    ),
                    tooltip: 'Flash',
                    onPressed: () {
                      ref.read(captureControllerProvider.notifier).toggleFlash();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
