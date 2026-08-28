import 'dart:async';
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
/// Crafted specifically for zero-literacy rural artisans:
/// - Real-time viewfinder with studio guidelines
/// - Pre-shutter quality gate HUD banner (blur, backlight, underexposure)
/// - 96dp primary capture shutter button (Sizes.primaryActionTarget)
/// - 64dp secondary control buttons (Sizes.minTouchTarget)
/// - Zero-literacy spoken capture prompts & multi-lingual audio guidance
class CaptureScreen extends ConsumerStatefulWidget {
  const CaptureScreen({super.key});

  @override
  ConsumerState<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends ConsumerState<CaptureScreen>
    with SingleTickerProviderStateMixin {
  late final FlutterTts _tts;
  late final AnimationController _pulseController;
  String? _lastSpokenWarning;

  @override
  void initState() {
    super.initState();
    _initTts();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  Future<void> _initTts() async {
    _tts = FlutterTts();
    try {
      await _tts.setLanguage('hi-IN');
      await _tts.setSpeechRate(0.45);
      await _tts.setPitch(1);
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
        unawaited(_speakPrompt(quality.guidanceMessage!));
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
    img.fill(demoImage, color: img.ColorRgb8(245, 240, 230));
    img.fillCircle(
      demoImage,
      x: 240,
      y: 240,
      radius: 140,
      color: img.ColorRgb8(181, 77, 43),
    ); // Terracotta craft
    img.drawCircle(
      demoImage,
      x: 240,
      y: 240,
      radius: 100,
      color: img.ColorRgb8(30, 47, 93),
    ); // Indigo motif
    final rawBytes = Uint8List.fromList(img.encodeJpg(demoImage, quality: 90));

    final craft = await controller.captureAndProcess(rawBytes);

    if (!mounted) return;

    if (craft != null) {
      // Show studio enhancement benchmark banner
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Palette.affirm,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Sizes.radius),
          ),
          duration: const Duration(seconds: 3),
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'फोटो तैयार! ${craft.processingDurationMs}ms में स्टूडियो फिनिशिंग',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      );

      // Transition to voice cataloger flow with craft ID
      if (mounted) {
        unawaited(context.push('/cataloger'));
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    unawaited(_tts.stop());
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
      backgroundColor: Palette.surface,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Palette.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                color: Palette.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'शिल्पसेतु • Shilpsetu',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 20,
                color: Palette.ink,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            child: IconButton.filledTonal(
              icon: const Icon(Icons.volume_up_rounded, size: 26),
              style: IconButton.styleFrom(
                backgroundColor: Palette.goldAccentLight,
                foregroundColor: Palette.goldAccent,
              ),
              tooltip: 'Speak guidance',
              onPressed: () {
                unawaited(
                  _speakPrompt(
                    'आपने जो बनाया है वह दिखाइए. Show me what you made',
                  ),
                );
              },
            ),
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
                  unawaited(_speakPrompt('आपने जो बनाया है वह दिखाइए'));
                },
              ),
            ),

            // Viewfinder Area / Camera Container
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: Sizes.gutter),
                decoration: BoxDecoration(
                  color: const Color(0xFF12141A),
                  borderRadius: BorderRadius.circular(Sizes.cardRadius + 4),
                  border: Border.all(
                    color: hasWarning
                        ? Palette.warning
                        : Palette.primary.withValues(alpha: 0.4),
                    width: hasWarning ? 3.5 : 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: hasWarning
                          ? Palette.warning.withValues(alpha: 0.3)
                          : Palette.ink.withValues(alpha: 0.15),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Viewfinder Framing Grid & Saliency Target Guide
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(Sizes.gapSmall),
                        child: FittedBox(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AnimatedBuilder(
                                animation: _pulseController,
                                builder: (context, child) {
                                  final scale = 1.0 + (_pulseController.value * 0.05);
                                  return Transform.scale(
                                    scale: scale,
                                    child: Icon(
                                      Icons.crop_free_rounded,
                                      size: 88,
                                      color: hasWarning
                                          ? Palette.warning.withValues(alpha: 0.85)
                                          : Colors.white.withValues(alpha: 0.8),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: Sizes.gapSmall),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.65),
                                  borderRadius:
                                      BorderRadius.circular(Sizes.radius),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.15),
                                  ),
                                ),
                                child: const Text(
                                  'वस्तु को फ्रेम के बीच में रखें\nCenter craft in frame',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    height: 1.25,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Pre-shutter Quality Gate Overlay Banner
                    if (hasWarning)
                      Positioned(
                        top: 14,
                        left: 14,
                        right: 14,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Palette.warningLight,
                            borderRadius: BorderRadius.circular(Sizes.radius),
                            border:
                                Border.all(color: Palette.warning, width: 2),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 10,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: Palette.warning,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.warning_amber_rounded,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  quality.guidanceMessage ??
                                      'कृपया रोशनी और फोकस जांचें',
                                  style: const TextStyle(
                                    color: Palette.ink,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              IconButton.filledTonal(
                                icon: const Icon(
                                  Icons.volume_up_rounded,
                                  color: Palette.warning,
                                  size: 22,
                                ),
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.white,
                                ),
                                onPressed: () {
                                  if (quality.guidanceMessage != null) {
                                    unawaited(
                                      _speakPrompt(
                                        quality.guidanceMessage!,
                                      ),
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ),

                    // Active ML processing overlay
                    if (captureState.isProcessing)
                      const ColoredBox(
                        color: Colors.black87,
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(
                                color: Palette.goldAccent,
                                strokeWidth: 4.5,
                              ),
                              SizedBox(height: Sizes.gapMedium),
                              Text(
                                'स्टूडियो फोटो तैयार हो रही है...\nEnhancing craft photo...',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  height: 1.3,
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
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: captureState.isProcessing ? null : _onShutterPressed,
                      borderRadius: BorderRadius.circular(32),
                      child: Ink(
                        width: Sizes.minTouchTarget,
                        height: Sizes.minTouchTarget,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Palette.muted.withValues(alpha: 0.2),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Palette.ink.withValues(alpha: 0.06),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.photo_library_outlined,
                          size: 28,
                          color: Palette.ink,
                        ),
                      ),
                    ),
                  ),

                  // Shutter Button (96dp primary action target with radiant aura)
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: captureState.isProcessing ? null : _onShutterPressed,
                      borderRadius: BorderRadius.circular(50),
                      child: Container(
                        width: Sizes.primaryActionTarget,
                        height: Sizes.primaryActionTarget,
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: hasWarning
                                ? [Palette.warning, const Color(0xFFB45309)]
                                : [Palette.primary, Palette.primaryLight],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: (hasWarning ? Palette.warning : Palette.primary)
                                  .withValues(alpha: 0.4),
                              blurRadius: 18,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3.5),
                          ),
                          child: captureState.isProcessing
                              ? const Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 3,
                                  ),
                                )
                              : const Icon(
                                  Icons.camera_alt_rounded,
                                  size: 44,
                                  color: Palette.onPrimary,
                                ),
                        ),
                      ),
                    ),
                  ),

                  // Flash toggle button (64dp target)
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        ref
                            .read(captureControllerProvider.notifier)
                            .toggleFlash();
                      },
                      borderRadius: BorderRadius.circular(32),
                      child: Ink(
                        width: Sizes.minTouchTarget,
                        height: Sizes.minTouchTarget,
                        decoration: BoxDecoration(
                          color: captureState.isFlashOn
                              ? Palette.goldAccentLight
                              : Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: captureState.isFlashOn
                                ? Palette.goldAccent
                                : Palette.muted.withValues(alpha: 0.2),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Palette.ink.withValues(alpha: 0.06),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Icon(
                          captureState.isFlashOn
                              ? Icons.flash_on_rounded
                              : Icons.flash_off_rounded,
                          color: captureState.isFlashOn
                              ? Palette.goldAccent
                              : Palette.ink,
                          size: 28,
                        ),
                      ),
                    ),
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
