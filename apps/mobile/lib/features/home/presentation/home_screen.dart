import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:go_router/go_router.dart';
import 'package:shilpsetu/core/localization/language_provider.dart';
import 'package:shilpsetu/core/theme/accessible_widgets.dart';
import 'package:shilpsetu/core/theme/tokens.dart';
import 'package:shilpsetu/features/auth/presentation/controllers/auth_controller.dart';
import 'package:shilpsetu/features/home/presentation/widgets/app_info_menu.dart';

/// The Primary Home Screen for Shilpsetu.
///
/// Designed per the exact signature visual style:
/// - Brand logo (blue connected node icon + 'shilp' ink + 'setu' terracotta)
/// - "Namaste, {Name}" greeting
/// - Signature purple hero containers with amber buttons and sparkles
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late final FlutterTts _tts;
  String? _currentlySpeakingCardId;

  @override
  void initState() {
    super.initState();
    _initTts();
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
              _currentlySpeakingCardId = null;
            });
          }
        })
        ..setCancelHandler(() {
          if (mounted) {
            setState(() {
              _currentlySpeakingCardId = null;
            });
          }
        })
        ..setErrorHandler((_) {
          if (mounted) {
            setState(() {
              _currentlySpeakingCardId = null;
            });
          }
        });
    } catch (_) {}
  }

  Future<void> _speakText({required String cardId, required String text}) async {
    if (_currentlySpeakingCardId == cardId) {
      try {
        await _tts.stop();
      } catch (_) {}
      if (mounted) {
        setState(() {
          _currentlySpeakingCardId = null;
        });
      }
      return;
    }

    setState(() {
      _currentlySpeakingCardId = cardId;
    });

    final lang = ref.read(languageProvider).selectedLanguage;
    try {
      await _tts.stop();
      await _tts.setLanguage(lang.ttsLocale);
      await _tts.speak(text);
    } catch (_) {}
  }

  @override
  void dispose() {
    unawaited(_tts.stop());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(languageProvider).selectedLanguage;
    final isEnglish = lang == AppLanguage.english;
    final authState = ref.watch(authControllerProvider);
    final artisanName = authState.currentUser?.name ??
        (isEnglish ? 'Radha' : 'कारीगर जी');

    return Scaffold(
      backgroundColor: Palette.surface,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: ShilpsetuBrandLogo(isHindi: !isEnglish),
        actions: [
          // Language Switcher Badge
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: Palette.surfaceContainer,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: () => context.go('/language'),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Palette.logoBadgeBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    isEnglish ? 'EN' : 'हिं',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 11,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  isEnglish ? 'हिंदी' : 'EN',
                  style: const TextStyle(
                    color: Palette.ink,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          IconButton.filledTonal(
            icon: const Icon(Icons.volume_up_rounded, size: 22),
            style: IconButton.styleFrom(
              backgroundColor: Palette.goldAccentLight,
              foregroundColor: Palette.goldAccent,
            ),
            tooltip: isEnglish ? 'Listen overview' : 'जानकारी सुनें',
            onPressed: () {
              unawaited(
                _speakText(
                  cardId: 'header',
                  text: isEnglish
                      ? 'Namaste, $artisanName. What will you make today? Use your voice, check fair pricing, or recognize crafts.'
                      : 'नमस्ते, $artisanName। आज आप क्या बनाएंगे? बोलकर उत्पाद जोड़ें, उचित मूल्य जानें या शिल्प पहचानें।',
                ),
              );
            },
          ),
          const SizedBox(width: 4),
          const AppInfoIconButton(),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: Sizes.gutter,
            vertical: Sizes.gapMedium,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting Section (as seen in reference design)
              Text(
                isEnglish
                    ? 'Namaste, $artisanName'
                    : 'नमस्ते, $artisanName',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Palette.ink,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                isEnglish
                    ? 'What will you make today?'
                    : 'आज आप क्या बनाएंगे?',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Palette.muted,
                ),
              ),

              const SizedBox(height: Sizes.gapLarge),

              // 1. Signature Purple Hero Card (Voice-First Cataloging)
              ShilpsetuPurpleCard(
                tag: isEnglish
                    ? 'VOICE-FIRST CATALOGING'
                    : 'आवाज़ से उत्पाद सूचीकरण',
                title: isEnglish ? 'Add your\ncraft' : 'अपना शिल्प\nजोड़ें',
                subtitle: isEnglish
                    ? "Speak your story. We'll shape the rest."
                    : 'अपनी कहानी बोलें, बाकी हम तैयार करेंगे।',
                buttonText: isEnglish
                    ? 'Begin with your voice'
                    : 'बोलकर शुरू करें',
                onTap: () => context.push('/cataloger'),
                isSpeaking: _currentlySpeakingCardId == 'voice_card',
                onSpeak: () => _speakText(
                  cardId: 'voice_card',
                  text: isEnglish
                      ? "Add your craft. Speak your story, we'll shape the rest."
                      : 'अपना शिल्प जोड़ें। अपनी कहानी बोलें, बाकी विवरण हम तैयार करेंगे।',
                ),
              ),

              const SizedBox(height: Sizes.gapLarge),

              // Section Header
              Row(
                children: [
                  Text(
                    isEnglish ? 'SMART ARTISAN TOOLS' : 'स्मार्ट कारीगर टूल्स',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Palette.terracotta,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.auto_awesome,
                    color: Palette.terracotta.withValues(alpha: 0.8),
                    size: 18,
                  ),
                ],
              ),

              const SizedBox(height: Sizes.gapSmall),

              // 2. Purple Container: Transparent Fair-Wage Pricing
              ShilpsetuPurpleCard(
                tag: isEnglish
                    ? '🛡️ GOVT MINIMUM WAGE BASE'
                    : '🛡️ सरकारी न्यूनतम मजदूरी आधार',
                title: isEnglish
                    ? 'Fair Price\nCalculator'
                    : 'उचित मूल्य\nकैलकुलेटर',
                subtitle: isEnglish
                    ? 'Know your true artisan worth. Never sell below fair wage.'
                    : 'अपने श्रम का सही मूल्य जानें। कम में कभी न बेचें।',
                buttonText:
                    isEnglish ? 'Check Fair Price' : 'उचित मूल्य जानें',
                icon: Icons.balance_rounded,
                tagIcon: Icons.currency_rupee_rounded,
                onTap: () => context.push('/pricing'),
                isSpeaking: _currentlySpeakingCardId == 'price_card',
                onSpeak: () => _speakText(
                  cardId: 'price_card',
                  text: isEnglish
                      ? 'Fair Price Calculator. Know your true worth, based on government minimum wage.'
                      : 'उचित मूल्य कैलकुलेटर। अपने श्रम का सही मूल्य जानें।',
                ),
              ),

              const SizedBox(height: Sizes.gapMedium),

              // 3. Purple Container: On-Device Craft Recognition
              ShilpsetuPurpleCard(
                tag: isEnglish
                    ? '📶 100% OFFLINE RECOGNITION'
                    : '📶 बिना इंटरनेट के काम करता है',
                title: isEnglish
                    ? 'Recognize\nYour Craft'
                    : 'शिल्प\nपहचानें',
                subtitle: isEnglish
                    ? 'Take a photo, we identify craft techniques offline.'
                    : 'फोटो खींचें, हम तकनीक और शिल्प बिना इंटरनेट के पहचानेंगे।',
                buttonText: isEnglish ? 'Recognize Craft' : 'शिल्प पहचानें',
                icon: Icons.document_scanner_rounded,
                tagIcon: Icons.camera_alt_rounded,
                onTap: () => context.go('/capture'),
                isSpeaking: _currentlySpeakingCardId == 'recog_card',
                onSpeak: () => _speakText(
                  cardId: 'recog_card',
                  text: isEnglish
                      ? 'Recognize Your Craft. Take a photo, works 100% offline without internet.'
                      : 'शिल्प पहचानें। फोटो खींचें, यह बिना इंटरनेट के काम करता है।',
                ),
              ),

              const SizedBox(height: Sizes.gapMedium),

              // 4. Purple Container: Photo Studio
              ShilpsetuPurpleCard(
                tag: isEnglish
                    ? '⚡ 320MS STUDIO FINISH'
                    : '⚡ 320MS स्टूडियो फिनिश',
                title: isEnglish
                    ? 'Studio Photo\nEnhancer'
                    : 'फ़ोटो स्टूडियो\nफिनिशर',
                subtitle: isEnglish
                    ? 'Turn simple home photos into clean marketplace listings.'
                    : 'घर की साधारण फोटो को बनाएं बाज़ार जैसी साफ फ़ोटो।',
                buttonText: isEnglish ? 'Open Studio' : 'स्टूडियो खोलें',
                icon: Icons.photo_filter_rounded,
                tagIcon: Icons.auto_fix_high_rounded,
                onTap: () => context.go('/capture'),
                isSpeaking: _currentlySpeakingCardId == 'studio_card',
                onSpeak: () => _speakText(
                  cardId: 'studio_card',
                  text: isEnglish
                      ? 'Studio Photo Enhancer. Turn home photos into clean marketplace listings in 320ms.'
                      : 'फ़ोटो स्टूडियो। साधारण फोटो को बनाएं बाज़ार जैसी साफ फ़ोटो।',
                ),
              ),

              const SizedBox(height: Sizes.gapLarge),
            ],
          ),
        ),
      ),
    );
  }
}
