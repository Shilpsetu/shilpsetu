import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:go_router/go_router.dart';
import 'package:shilpsetu/core/localization/language_provider.dart';
import 'package:shilpsetu/core/theme/accessible_widgets.dart';
import 'package:shilpsetu/core/theme/tokens.dart';

/// Cataloger Screen.
///
/// Features:
/// - Displays and speaks exclusively in the user's selected language
/// - Giant tactile audio recording button (96dp)
/// - Visual audio wave bars while recording
/// - Spoken readback of extracted craft attributes
class CatalogerScreen extends ConsumerStatefulWidget {
  const CatalogerScreen({super.key});

  @override
  ConsumerState<CatalogerScreen> createState() => _CatalogerScreenState();
}

class _CatalogerScreenState extends ConsumerState<CatalogerScreen>
    with SingleTickerProviderStateMixin {
  late final FlutterTts _tts;
  late final AnimationController _pulseController;

  bool _isRecording = false;
  bool _hasRecorded = false;
  bool _isPlayingReadback = false;

  final List<String> _sampleAttributesHindi = const [
    'शुद्ध मिट्टी',
    '8 घंटे का श्रम',
    'पारंपरिक दीया',
    'प्राकृतिक रंग',
    'हाथ से तराशा गया',
  ];

  final List<String> _sampleAttributesEnglish = const [
    'Pure Terracotta Clay',
    '8 Hours Artisan Labor',
    'Traditional Diya Set',
    '100% Natural Organic Dyes',
    'Hand Sculpted Finish',
  ];

  bool _isPlayingPrompt = false;

  @override
  void initState() {
    super.initState();
    _initTts();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
  }

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
              _isPlayingReadback = false;
              _isPlayingPrompt = false;
            });
          }
        })
        ..setCancelHandler(() {
          if (mounted) {
            setState(() {
              _isPlayingReadback = false;
              _isPlayingPrompt = false;
            });
          }
        })
        ..setErrorHandler((_) {
          if (mounted) {
            setState(() {
              _isPlayingReadback = false;
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
      _isPlayingReadback = false;
    });

    final lang = ref.read(languageProvider).selectedLanguage;
    try {
      await _tts.stop();
      await _tts.setLanguage(lang.ttsLocale);
      await _tts.speak(text);
    } catch (_) {}
  }

  void _toggleRecording() {
    setState(() {
      _isRecording = !_isRecording;
      if (_isRecording) {
        _hasRecorded = false;
        _pulseController.repeat(reverse: true);
      } else {
        _hasRecorded = true;
        _pulseController
          ..stop()
          ..reset();
        _playReadback();
      }
    });
  }

  Future<void> _playReadback() async {
    if (_isPlayingReadback) {
      try {
        await _tts.stop();
      } catch (_) {}
      if (mounted) {
        setState(() {
          _isPlayingReadback = false;
        });
      }
      return;
    }

    final lang = ref.read(languageProvider).selectedLanguage;
    final isEnglish = lang == AppLanguage.english;

    setState(() {
      _isPlayingReadback = true;
      _isPlayingPrompt = false;
    });

    final readbackText = isEnglish
        ? 'We generated this description from your voice: Handmade Terracotta craft, made with pure organic clay over eight hours of skilled artisan labor.'
        : 'हमने आपकी आवाज़ से यह जानकारी बनाई है: हाथ से बना टेराकोटा शिल्प, शुद्ध प्राकृतिक मिट्टी से 8 घंटे के श्रम में निर्मित।';

    try {
      await _tts.stop();
      await _tts.setLanguage(lang.ttsLocale);
      await _tts.speak(readbackText);
    } catch (_) {}
  }

  @override
  void dispose() {
    _pulseController.dispose();
    unawaited(_tts.stop());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(languageProvider).selectedLanguage;
    final isEnglish = lang == AppLanguage.english;
    final attributes =
        isEnglish ? _sampleAttributesEnglish : _sampleAttributesHindi;

    return Scaffold(
      backgroundColor: Palette.surface,
      appBar: AppBar(
        title: ShilpsetuBrandLogo(isHindi: !isEnglish),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Palette.ink),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
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
                      ? 'Tell us about your craft, such as colors, materials, and time taken to make it.'
                      : 'अपने उत्पाद के बारे में बताइए जैसे रंग, सामग्री और इसे बनाने में कितना समय लगा।',
                ),
              );
            },
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(Sizes.gutter),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Signature Purple Prompt Banner
              ZeroLiteracyPromptCard(
                promptText: _isRecording
                    ? (isEnglish
                        ? 'Listening to your voice...'
                        : 'हम सुन रहे हैं... बोलते रहिए')
                    : _hasRecorded
                        ? (isEnglish
                            ? 'Confirm generated craft details'
                            : 'विवरण की पुष्टि करें')
                        : (isEnglish
                            ? 'Tell about colors, materials, and time'
                            : 'इसके बारे में बताइए (रंग, सामग्री, समय)'),
                icon: _isRecording
                    ? Icons.graphic_eq_rounded
                    : Icons.mic_rounded,
                accentColor: _isRecording ? Palette.revise : Palette.purpleContainer,
                onReplayAudio: () {
                  unawaited(
                    _speakPrompt(
                      isEnglish
                          ? 'Tap the microphone and speak about your craft.'
                          : 'माइक बटन दबाएं और अपने शिल्प के बारे में बोलकर बताएं।',
                    ),
                  );
                },
              ),

              const SizedBox(height: Sizes.gapLarge),

              // Giant Mic Button
              Center(
                child: Column(
                  children: [
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        final scale =
                            _isRecording ? 1.0 + (_pulseController.value * 0.12) : 1.0;
                        return Transform.scale(
                          scale: scale,
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: _toggleRecording,
                              borderRadius: BorderRadius.circular(60),
                              child: Container(
                                width: 110,
                                height: 110,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: _isRecording
                                        ? [Palette.revise, const Color(0xFFD32F2F)]
                                        : [
                                            Palette.purpleContainer,
                                            Palette.purpleContainerDark,
                                          ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: (_isRecording
                                              ? Palette.revise
                                              : Palette.purpleContainerDark)
                                          .withValues(alpha: 0.4),
                                      blurRadius: _isRecording ? 24 : 16,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  _isRecording
                                      ? Icons.stop_rounded
                                      : Icons.mic_rounded,
                                  size: 52,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: Sizes.gapMedium),

                    Text(
                      _isRecording
                          ? (isEnglish ? 'Recording...' : 'सुन रहे हैं...')
                          : (isEnglish
                              ? 'Tap to Speak'
                              : 'बोलने के लिए टैप करें'),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: _isRecording ? Palette.revise : Palette.purpleContainerDark,
                      ),
                    ),

                    if (_isRecording) ...[
                      const SizedBox(height: 12),
                      const SoundWaveBars(
                        color: Palette.revise,
                        barCount: 7,
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: Sizes.gapLarge),

              // Generated Attributes Card
              if (_hasRecorded) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(Sizes.cardRadius),
                    border: Border.all(
                      color: Palette.purpleContainer.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Palette.purpleContainer.withValues(alpha: 0.1),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.auto_awesome_rounded,
                            color: Palette.purpleContainerDark,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isEnglish
                                ? 'Recognized Craft Attributes:'
                                : 'पहचाने गए विवरण:',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Palette.ink,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: Icon(
                              _isPlayingReadback
                                  ? Icons.volume_up_rounded
                                  : Icons.play_circle_fill_rounded,
                              color: Palette.purpleContainerDark,
                              size: 28,
                            ),
                            onPressed: _playReadback,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: attributes.map((attr) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Palette.purpleContainerLight,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Palette.purpleContainer
                                    .withValues(alpha: 0.3),
                              ),
                            ),
                            child: Text(
                              attr,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Palette.purpleContainerDark,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: Sizes.gapLarge),
              ],

              // Next Action Button in Amber styling
              SpokenActionButton(
                onPressed: () {
                  context.push('/pricing');
                },
                icon: Icons.currency_rupee_rounded,
                label: isEnglish ? 'Check Fair Price' : 'उचित मूल्य तय करें',
                subtitle: isEnglish
                    ? 'Fair wage and pricing breakdown'
                    : 'उचित मजदूरी एवं बाज़ार मूल्य विवरण',
                backgroundColor: Palette.amberButton,
                foregroundColor: Palette.ink,
                isLarge: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
