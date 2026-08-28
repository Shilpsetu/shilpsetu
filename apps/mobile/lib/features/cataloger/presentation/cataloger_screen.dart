import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:go_router/go_router.dart';
import 'package:shilpsetu/core/theme/accessible_widgets.dart';
import 'package:shilpsetu/core/theme/tokens.dart';

/// Voice Cataloger Screen (Flutter Dev B).
///
/// Features:
/// - Record voice note in native dialect/language
/// - Real-time extracted craft attributes
/// - Mandatory audio readback for zero-literacy verification
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

  final List<String> _extractedAttributes = [
    '🎨 शुद्ध मिट्टी (Terracotta Clay)',
    '⏱️ 8 घंटे का श्रम (8 Hours Labor)',
    '🌿 प्राकृतिक रंग (Natural Dyes)',
    '🪔 10 दीयों का सेट (Set of 10)',
  ];

  @override
  void initState() {
    super.initState();
    _initTts();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  Future<void> _initTts() async {
    _tts = FlutterTts();
    try {
      await _tts.setLanguage('hi-IN');
      await _tts.setSpeechRate(0.45);
      await _tts.setPitch(1);
    } catch (_) {}
  }

  Future<void> _speakPrompt(String text) async {
    try {
      await _tts.stop();
      await _tts.speak(text);
    } catch (_) {}
  }

  Future<void> _playReadback() async {
    setState(() {
      _isPlayingReadback = true;
    });

    const readbackText =
        'हमने आपकी आवाज़ से यह जानकारी बनाई है: हाथ से बना टेराकोटा दीया सेट। प्राकृतिक रंगों से तैयार, बनाने में आठ घंटे लगे। क्या यह विवरण सही है?';
    try {
      await _tts.stop();
      await _tts.speak(readbackText);
    } finally {
      if (mounted) {
        setState(() {
          _isPlayingReadback = false;
        });
      }
    }
  }

  void _toggleRecording() {
    setState(() {
      _isRecording = !_isRecording;
      if (!_isRecording) {
        _hasRecorded = true;
      }
    });

    if (_isRecording) {
      unawaited(_speakPrompt('बोलिए, हम सुन रहे हैं...'));
    } else {
      unawaited(_playReadback());
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
    return Scaffold(
      backgroundColor: Palette.surface,
      appBar: AppBar(
        title: const Text(
          'उत्पाद का विवरण बोलें • Voice',
          style: TextStyle(fontWeight: FontWeight.w800, color: Palette.ink),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Palette.ink),
          onPressed: () => context.pop(),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            child: IconButton.filledTonal(
              icon: const Icon(Icons.volume_up_rounded, size: 26),
              style: IconButton.styleFrom(
                backgroundColor: Palette.goldAccentLight,
                foregroundColor: Palette.goldAccent,
              ),
              onPressed: () {
                unawaited(
                  _speakPrompt(
                    'अपने उत्पाद के बारे में बताइए जैसे रंग, सामग्री और इसे बनाने में कितना समय लगा।',
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(Sizes.gutter),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Zero Literacy Instruction Banner
              ZeroLiteracyPromptCard(
                promptText:
                    _isRecording
                        ? 'हम सुन रहे हैं... बोलते रहिए\nListening to your voice...'
                        : _hasRecorded
                            ? 'विवरण की पुष्टि करें\nConfirm generated details'
                            : 'इसके बारे में बताइए (रंग, सामग्री, समय)\nTell about your craft',
                icon: _isRecording ? Icons.graphic_eq_rounded : Icons.mic_rounded,
                accentColor: _isRecording ? Palette.revise : Palette.primary,
                onReplayAudio: () {
                  unawaited(
                    _speakPrompt(
                      'माइक बटन दबाएं और अपने शिल्प के बारे में बोलकर बताएं।',
                    ),
                  );
                },
              ),

              const SizedBox(height: Sizes.gapLarge),

              // Giant Interactive Mic Button with Aura Rings
              Center(
                child: Column(
                  children: [
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        final scale = _isRecording
                            ? 1.0 + (_pulseController.value * 0.12)
                            : 1.0;
                        return Transform.scale(
                          scale: scale,
                          child: InkWell(
                            onTap: _toggleRecording,
                            borderRadius: BorderRadius.circular(70),
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: _isRecording
                                      ? [Palette.revise, const Color(0xFFC53030)]
                                      : [Palette.primary, Palette.primaryLight],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: (_isRecording
                                            ? Palette.revise
                                            : Palette.primary)
                                        .withValues(alpha: 0.45),
                                    blurRadius: 24,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Icon(
                                _isRecording
                                    ? Icons.stop_rounded
                                    : Icons.mic_rounded,
                                size: 60,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: Sizes.gapMedium),

                    // Recording status / soundwave indicator
                    if (_isRecording) ...[
                      const SoundWaveBars(
                        color: Palette.revise,
                        barCount: 7,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'सुन रहे हैं... (Recording...)',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Palette.revise,
                        ),
                      ),
                    ] else ...[
                      Text(
                        _hasRecorded
                            ? 'दोबारा बोलने के लिए माइक दबाएं'
                            : 'बोलने के लिए माइक दबाएं (Tap to Speak)',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Palette.muted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: Sizes.gapLarge),

              // Extracted Attributes Card
              if (_hasRecorded) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(Sizes.cardRadius),
                    border: Border.all(
                      color: Palette.affirm.withValues(alpha: 0.3),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Palette.ink.withValues(alpha: 0.05),
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
                            color: Palette.affirm,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'पहचाने गए विवरण (Recognized Craft):',
                            style: TextStyle(
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
                              color: Palette.affirm,
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
                        children: _extractedAttributes.map((attr) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Palette.affirmLight,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Palette.affirm.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Text(
                              attr,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Palette.affirm,
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

              // Next Action Button (64dp / 96dp target)
              SpokenActionButton(
                onPressed: () {
                  context.push('/pricing');
                },
                icon: Icons.currency_rupee_rounded,
                label: 'उचित मूल्य तय करें • Check Price',
                subtitle: 'Fair wage & marketplace pricing breakdown',
                isLarge: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
