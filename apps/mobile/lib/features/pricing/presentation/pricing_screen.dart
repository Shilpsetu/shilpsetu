import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:go_router/go_router.dart';
import 'package:shilpsetu/core/theme/accessible_widgets.dart';
import 'package:shilpsetu/core/theme/tokens.dart';

/// Pricing Screen (Flutter Dev B).
///
/// Features:
/// - 3 price tiers: Floor (minimum fair wage), Suggested, Stretch
/// - Audio explanation of labor and material breakdown
/// - Visual protection against selling below fair wage
class PricingScreen extends ConsumerStatefulWidget {
  const PricingScreen({super.key});

  @override
  ConsumerState<PricingScreen> createState() => _PricingScreenState();
}

class _PricingScreenState extends ConsumerState<PricingScreen> {
  late final FlutterTts _tts;
  int _selectedTierIndex = 1; // 0: Floor, 1: Suggested, 2: Stretch

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
      await _tts.setPitch(1);
    } catch (_) {}
  }

  Future<void> _speakPricingRationale() async {
    const speech =
        'आपके शिल्प के लिए अनुशंसित मूल्य चौबीस सौ रुपये है। इसमें छह सौ रुपये सामग्री और बारह सौ पचास रुपये आपके आठ घंटे के उचित श्रम का हिस्सा है। इस उत्पाद को अठारह सौ पचास रुपये से कम में कभी न बेचें।';
    try {
      await _tts.stop();
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
    return Scaffold(
      backgroundColor: Palette.surface,
      appBar: AppBar(
        title: const Text(
          'मूल्य तय करें • Fair Pricing',
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
              onPressed: _speakPricingRationale,
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
              // Zero-Literacy Prompt Banner
              ZeroLiteracyPromptCard(
                promptText:
                    'आपके शिल्प का उचित मूल्य\nFair wage & marketplace pricing',
                icon: Icons.currency_rupee_rounded,
                onReplayAudio: _speakPricingRationale,
              ),

              const SizedBox(height: Sizes.gapMedium),

              // Audio Rationale Listen Card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Palette.goldAccentLight,
                  borderRadius: BorderRadius.circular(Sizes.radius),
                  border: Border.all(
                    color: Palette.goldAccent.withValues(alpha: 0.35),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.insights_rounded,
                      color: Palette.goldAccent,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'उचित मजदूरी + कच्चा माल जोड़कर तैयार किया गया मूल्य',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Palette.ink,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.volume_up_rounded,
                        color: Palette.goldAccent,
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
                title: 'Floor (न्यूनतम उचित मूल्य)',
                price: '₹ 1,850',
                color: Palette.terracotta,
                icon: Icons.shield_rounded,
                badge: 'कम से कम (Fair Minimum)',
                subtitle: 'कच्चा माल (₹600) + 8 घंटे का श्रम (₹1,250)',
                description: 'इससे कम पर कभी न बेचें — यह आपकी न्यूनतम लागत है।',
              ),

              const SizedBox(height: Sizes.gapMedium),

              // 2. Suggested Tier (Market Standard)
              _buildPriceTierCard(
                index: 1,
                title: 'Suggested (अनुशंसित बाज़ार मूल्य)',
                price: '₹ 2,400',
                color: Palette.primary,
                icon: Icons.star_rounded,
                badge: '⭐ सबसे सही (Recommended)',
                subtitle: 'ऑनलाइन खरीदारों और बाज़ार के लिए सबसे उपयुक्त',
                description: 'अधिकांश कारीगर इस मूल्य पर तेजी से बिक्री करते हैं।',
                isHighlighted: true,
              ),

              const SizedBox(height: Sizes.gapMedium),

              // 3. Stretch Tier (Premium / Boutique)
              _buildPriceTierCard(
                index: 2,
                title: 'Stretch (प्रीमियम बुटीक मूल्य)',
                price: '₹ 3,200',
                color: Palette.affirm,
                icon: Icons.workspace_premium_rounded,
                badge: 'प्रीमियम (Boutique)',
                subtitle: 'विदेशी और बुटीक खरीदारों के लिए विशेष मूल्य',
                description: 'विशिष्ट कलात्मक डिज़ाइन और विशेष उपहार के लिए।',
              ),

              const SizedBox(height: Sizes.gapLarge),

              // Large 96dp Action Button
              SpokenActionButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: Palette.affirm,
                      content: Text(
                        'उत्पाद सफलतापूर्वक प्रकाशित हो गया! Listing is live!',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  );
                  context.go('/catalog');
                },
                icon: Icons.check_circle_rounded,
                label: 'दुकान पर जोड़ें • Publish Listing',
                subtitle: 'Start receiving buyer orders on marketplace',
                backgroundColor: Palette.affirm,
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
    bool isHighlighted = false,
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
            color: Colors.white,
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
