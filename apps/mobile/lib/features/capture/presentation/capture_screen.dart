import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:go_router/go_router.dart';
import 'package:image/image.dart' as img;
import 'package:shilpsetu/core/localization/language_provider.dart';
import 'package:shilpsetu/core/theme/accessible_widgets.dart';
import 'package:shilpsetu/core/theme/tokens.dart';
import 'package:shilpsetu/features/capture/presentation/controllers/capture_controller.dart';
import 'package:shilpsetu/features/home/presentation/widgets/app_info_menu.dart';
import 'package:shilpsetu/ml/models/quality_assessment.dart';

/// Primary capture screen.
///
/// Features:
/// - Displays and speaks exclusively in the user's selected language
/// - Real-time viewfinder with studio guidelines
/// - Pre-shutter quality gate HUD banner (blur, backlight, underexposure)
/// - 96dp primary capture shutter button (Sizes.primaryActionTarget)
/// - 64dp secondary control buttons (Sizes.minTouchTarget)
class CaptureScreen extends ConsumerStatefulWidget {
  const CaptureScreen({super.key});

  @override
  ConsumerState<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends ConsumerState<CaptureScreen>
    with SingleTickerProviderStateMixin {
  late final FlutterTts _tts;
  late final AnimationController _pulseController;
  QualityIssue? _lastSpokenIssue;

  @override
  void initState() {
    super.initState();
    _initTts();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  bool _isPlayingPrompt = false;

  Future<void> _initTts() async {
    _tts = FlutterTts();
    try {
      final lang = ref.read(languageProvider).selectedLanguage;
      await _tts.setLanguage(lang.ttsLocale);
      await _tts.setSpeechRate(0.45);
      await _tts.setPitch(1);
      _tts
        ..setCompletionHandler(() {
          if (mounted) {
            setState(() {
              _isPlayingPrompt = false;
            });
          }
        })
        ..setCancelHandler(() {
          if (mounted) {
            setState(() {
              _isPlayingPrompt = false;
            });
          }
        })
        ..setErrorHandler((_) {
          if (mounted) {
            setState(() {
              _isPlayingPrompt = false;
            });
          }
        });
    } catch (_) {}
  }

  Future<void> _speakPrompt(String text) async {
    if (_isPlayingPrompt) {
      try {
        await _tts.stop();
      } catch (_) {}
      if (mounted) {
        setState(() {
          _isPlayingPrompt = false;
        });
      }
      return;
    }

    setState(() {
      _isPlayingPrompt = true;
    });

    final lang = ref.read(languageProvider).selectedLanguage;
    try {
      await _tts.stop();
      await _tts.setLanguage(lang.ttsLocale);
      await _tts.speak(text);
    } catch (_) {}
  }

  String _getQualityMessage(QualityIssue issue, bool isEnglish) {
    switch (issue) {
      case QualityIssue.blur:
        return isEnglish
            ? 'Photo is blurry. Please hold steady.'
            : 'फ़ोटो धुंधली है। कृपया हाथ स्थिर रखें।';
      case QualityIssue.tooDark:
        return isEnglish
            ? 'Too dark. Please move towards light.'
            : 'बहुत अंधेरा है। कृपया रोशनी में जाएं।';
      case QualityIssue.backlight:
        return isEnglish
            ? 'Backlight detected. Face towards light.'
            : 'रोशनी वस्तु के पीछे है। रोशनी की ओर मुख करें।';
      case QualityIssue.none:
        return isEnglish ? 'Ready to capture' : 'फ़ोटो लेने के लिए तैयार';
    }
  }

  void _handleQualityAlert(QualityAssessment quality) {
    final isEnglish =
        ref.read(languageProvider).selectedLanguage == AppLanguage.english;

    if (!quality.isAcceptable && quality.issue != QualityIssue.none) {
      if (_lastSpokenIssue != quality.issue) {
        _lastSpokenIssue = quality.issue;
        final msg = _getQualityMessage(quality.issue, isEnglish);
        unawaited(_speakPrompt(msg));
      }
    } else {
      _lastSpokenIssue = null;
    }
  }

  /// Simulates / triggers camera capture
  Future<void> _onShutterPressed() async {
    final controller = ref.read(captureControllerProvider.notifier);
    final isEnglish =
        ref.read(languageProvider).selectedLanguage == AppLanguage.english;

    // Create demo craft sample image
    final demoImage = img.Image(width: 480, height: 480);
    img.fill(demoImage, color: img.ColorRgb8(245, 240, 230));
    img.fillCircle(
      demoImage,
      x: 240,
      y: 240,
      radius: 140,
      color: img.ColorRgb8(181, 77, 43),
    );
    img.drawCircle(
      demoImage,
      x: 240,
      y: 240,
      radius: 100,
      color: img.ColorRgb8(30, 47, 93),
    );
    final rawBytes = Uint8List.fromList(img.encodeJpg(demoImage, quality: 90));

    final craft = await controller.captureAndProcess(rawBytes);

    if (!mounted) return;

    if (craft != null) {
      final successMsg = isEnglish
          ? 'Photo ready in ${craft.processingDurationMs}ms!'
          : 'फोटो तैयार! ${craft.processingDurationMs} मिलीसेकंड में तैयार';

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
              const Icon(
                Icons.check_circle_rounded,
                color: Colors.white,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  successMsg,
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
    final lang = ref.watch(languageProvider).selectedLanguage;
    final isEnglish = lang == AppLanguage.english;
    final quality = captureState.quality;

    ref.listen<CaptureState>(captureControllerProvider, (prev, next) {
      if (prev?.quality.issue != next.quality.issue) {
        _handleQualityAlert(next.quality);
      }
    });

    final hasWarning = !quality.isAcceptable;
    final qualityMsg = _getQualityMessage(quality.issue, isEnglish);

    return Scaffold(
      backgroundColor: Palette.surface,
      appBar: AppBar(
        title: ShilpsetuBrandLogo(isHindi: !isEnglish),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton.filledTonal(
            icon: const Icon(Icons.volume_up_rounded, size: 24),
            style: IconButton.styleFrom(
              backgroundColor: Palette.goldAccentLight,
              foregroundColor: Palette.goldAccent,
            ),
            onPressed: () {
              unawaited(
                _speakPrompt(
                  isEnglish
                      ? 'Show what you made. Center the craft in the frame.'
                      : 'आपने जो बनाया है वह दिखाइए। वस्तु को फ्रेम के बीच में रखें।',
                ),
              );
            },
          ),
          const SizedBox(width: 6),
          const AppInfoIconButton(),
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
                promptText: isEnglish
                    ? 'Show what you made'
                    : 'आपने जो बनाया है वह दिखाइए',
                icon: Icons.camera_alt_rounded,
                onReplayAudio: () {
                  unawaited(
                    _speakPrompt(
                      isEnglish
                          ? 'Show what you made'
                          : 'आपने जो बनाया है वह दिखाइए',
                    ),
                  );
                },
              ),
            ),

            // Viewfinder Area
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
                                  final scale =
                                      1.0 + (_pulseController.value * 0.05);
                                  return Transform.scale(
                                    scale: scale,
                                    child: Icon(
                                      Icons.crop_free_rounded,
                                      size: 88,
                                      color: hasWarning
                                          ? Palette.warning
                                              .withValues(alpha: 0.85)
                                          : Colors.white
                                              .withValues(alpha: 0.8),
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
                                child: Text(
                                  isEnglish
                                      ? 'Center craft in frame'
                                      : 'वस्तु को फ्रेम के बीच में रखें',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
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
                                  qualityMsg,
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
                                  unawaited(_speakPrompt(qualityMsg));
                                },
                              ),
                            ],
                          ),
                        ),
                      ),

                    // Active ML processing overlay
                    if (captureState.isProcessing)
                      ColoredBox(
                        color: Colors.black87,
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const CircularProgressIndicator(
                                color: Palette.goldAccent,
                                strokeWidth: 4.5,
                              ),
                              const SizedBox(height: Sizes.gapMedium),
                              Text(
                                isEnglish
                                    ? 'Enhancing photo...'
                                    : 'फोटो तैयार हो रही है...',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
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

            // Shutter Controls
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Sizes.gutter,
                vertical: Sizes.gapMedium,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap:
                          captureState.isProcessing ? null : _onShutterPressed,
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

                  // Shutter Button
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap:
                          captureState.isProcessing ? null : _onShutterPressed,
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
                              color: (hasWarning
                                      ? Palette.warning
                                      : Palette.primary)
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

                  // Flash toggle button
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
