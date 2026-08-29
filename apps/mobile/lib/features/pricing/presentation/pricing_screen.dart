import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:go_router/go_router.dart';
import 'package:shilpsetu/core/localization/language_provider.dart';
import 'package:shilpsetu/core/theme/accessible_widgets.dart';
import 'package:shilpsetu/core/theme/tokens.dart';

/// Pricing Screen.
///
/// Features:
/// - Displays and speaks exclusively in the user's selected language
/// - 3 price tiers: Floor (minimum fair wage), Suggested, Stretch
/// - Audio explanation of labor and material breakdown
class PricingScreen extends ConsumerStatefulWidget {
  const PricingScreen({super.key});

  @override
  ConsumerState<PricingScreen> createState() => _PricingScreenState();
}

class _PricingScreenState extends ConsumerState<PricingScreen> {
  late final FlutterTts _tts;
  int _selectedTierIndex = 1; // 0: Floor, 1: Suggested, 2: Stretch
  bool _isSpeaking = false;

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
              _isSpeaking = false;
            });
          }
        })
        ..setCancelHandler(() {
          if (mounted) {
            setState(() {
              _isSpeaking = false;
            });
          }
        })
        ..setErrorHandler((_) {
          if (mounted) {
            setState(() {
              _isSpeaking = false;
            });
          }
        });
    } catch (_) {}
  }

  Future<void> _speakPricingRationale() async {
    if (_isSpeaking) {
      try {
        await _tts.stop();
      } catch (_) {}
      if (mounted) {
        setState(() {
          _isSpeaking = false;
        });
      }
      return;
    }

    setState(() {
      _isSpeaking = true;
    });

    final lang = ref.read(languageProvider).selectedLanguage;
    final isEnglish = lang == AppLanguage.english;

    final speech = isEnglish
        ? 'The recommended price for your craft is twenty-four hundred rupees. This includes six hundred rupees for raw material and twelve hundred fifty rupees for eight hours of fair artisan labor. Never sell below eighteen hundred fifty rupees.'
        : 'आपके शिल्प के लिए अनुशंसित मूल्य चौबीस सौ रुपये है। इसमें छह सौ रुपये सामग्री और बारह सौ पचास रुपये आपके आठ घंटे के उचित श्रम का हिस्सा है। इस उत्पाद को अठारह सौ पचास रुपये से कम में कभी न बेचें।';

    try {
      await _tts.stop();
      await _tts.setLanguage(lang.ttsLocale);
      await _tts.speak(speech);
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
            onPressed: _speakPricingRationale,
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
                promptText: isEnglish
                    ? 'Fair wage and pricing calculation'
                    : 'आपके शिल्प का उचित मूल्य',
                icon: Icons.currency_rupee_rounded,
                onReplayAudio: _speakPricingRationale,
              ),

              const SizedBox(height: Sizes.gapMedium),

              // Audio Rationale Card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Palette.purpleContainerLight,
                  borderRadius: BorderRadius.circular(Sizes.radius),
                  border: Border.all(
                    color: Palette.purpleContainer.withValues(alpha: 0.35),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.insights_rounded,
                      color: Palette.purpleContainerDark,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        isEnglish
                            ? 'Calculated using fair wages and raw material costs'
                            : 'उचित मजदूरी + कच्चा माल जोड़कर तैयार किया गया मूल्य',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Palette.ink,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.volume_up_rounded,
                        color: Palette.purpleContainerDark,
                        size: 26,
                      ),
                      onPressed: _speakPricingRationale,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: Sizes.gapMedium),

              // 1. Floor Tier (Fair Wage Minimum)
              _buildPriceTierCard(
                index: 0,
                title: isEnglish ? 'Minimum Fair Wage' : 'न्यूनतम उचित मूल्य',
                price: '₹ 1,850',
                color: Palette.terracotta,
                icon: Icons.shield_rounded,
                badge: isEnglish ? 'Fair Minimum' : 'कम से कम',
                subtitle: isEnglish
                    ? 'Material (₹600) + 8h Labor (₹1,250)'
                    : 'कच्चा माल (₹600) + 8 घंटे का श्रम (₹1,250)',
                description: isEnglish
                    ? 'Never sell below this — covers fair wage and cost.'
                    : 'इससे कम पर कभी न बेचें — यह आपकी न्यूनतम लागत है।',
              ),

              const SizedBox(height: Sizes.gapMedium),

              // 2. Suggested Tier (Market Standard)
              _buildPriceTierCard(
                index: 1,
                title: isEnglish
                    ? 'Suggested Market Price'
                    : 'अनुशंसित बाज़ार मूल्य',
                price: '₹ 2,400',
                color: Palette.purpleContainerDark,
                icon: Icons.star_rounded,
                badge: isEnglish ? '⭐ Recommended' : '⭐ सबसे सही',
                subtitle: isEnglish
                    ? 'Best for standard online marketplace buyers'
                    : 'ऑनलाइन खरीदारों और बाज़ार के लिए सबसे उपयुक्त',
                description: isEnglish
                    ? 'Recommended for quick and fair sales on marketplaces.'
                    : 'अधिकांश कारीगर इस मूल्य पर तेजी से बिक्री करते हैं।',
              ),

              const SizedBox(height: Sizes.gapMedium),

              // 3. Stretch Tier (Premium / Boutique)
              _buildPriceTierCard(
                index: 2,
                title: isEnglish
                    ? 'Premium Boutique Price'
                    : 'प्रीमियम बुटीक मूल्य',
                price: '₹ 3,200',
                color: Palette.affirm,
                icon: Icons.workspace_premium_rounded,
                badge: isEnglish ? 'Boutique' : 'प्रीमियम',
                subtitle: isEnglish
                    ? 'For custom orders and boutique buyers'
                    : 'विदेशी और बुटीक खरीदारों के लिए विशेष मूल्य',
                description: isEnglish
                    ? 'For intricate artistic craftsmanship and gifting.'
                    : 'विशिष्ट कलात्मक डिज़ाइन और विशेष उपहार के लिए।',
              ),

              const SizedBox(height: Sizes.gapLarge),

              // Large Action Button with Amber styling
              SpokenActionButton(
                onPressed: () {
                  final msg = isEnglish
                      ? 'Listing published successfully!'
                      : 'उत्पाद सफलतापूर्वक प्रकाशित हुआ!';
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Palette.affirm,
                      content: Text(
                        msg,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  );
                  context.go('/catalog');
                },
                icon: Icons.check_circle_rounded,
                label: isEnglish ? 'Publish Listing' : 'दुकान पर जोड़ें',
                subtitle: isEnglish
                    ? 'Start receiving buyer orders on marketplace'
                    : 'ऑनलाइन खरीदारों से ऑर्डर प्राप्त करना शुरू करें',
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

  Widget _buildPriceTierCard({
    required int index,
    required String title,
    required String price,
    required Color color,
    required IconData icon,
    required String badge,
    required String subtitle,
    required String description,
  }) {
    final isSelected = _selectedTierIndex == index;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedTierIndex = index;
          });
        },
        borderRadius: BorderRadius.circular(Sizes.cardRadius),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected
                ? color.withValues(alpha: 0.06)
                : Colors.white,
            borderRadius: BorderRadius.circular(Sizes.cardRadius),
            border: Border.all(
              color: isSelected ? color : Palette.surfaceContainerHigh,
              width: isSelected ? 3 : 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? color.withValues(alpha: 0.18)
                    : Palette.ink.withValues(alpha: 0.05),
                blurRadius: isSelected ? 16 : 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: color, size: 26),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: color,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            badge,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: color,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    price,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: isSelected ? color : Palette.ink,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Palette.ink,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Palette.muted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
