import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shilpsetu/core/theme/accessible_widgets.dart';
import 'package:shilpsetu/core/theme/tokens.dart';

/// Pricing Screen (Flutter Dev B).
///
/// Features:
/// - 3 price tiers: Floor (minimum fair wage), Suggested, Stretch
/// - Spoken rationale and warning if below floor
class PricingScreen extends ConsumerWidget {
  const PricingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('मूल्य तय करें • Fair Pricing'),
        backgroundColor: Palette.surfaceContainer,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Sizes.gutter),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const ZeroLiteracyPromptCard(
                promptText: 'आपके उत्पाद का उचित मूल्य',
                icon: Icons.currency_rupee_rounded,
                accentColor: Palette.goldAccent,
              ),
              const SizedBox(height: Sizes.gapMedium),
              // Price Tiers Card
              const Card(
                color: Palette.surfaceContainer,
                child: Padding(
                  padding: EdgeInsets.all(Sizes.gutter),
                  child: Column(
                    children: [
                      _PriceTierRow(
                        title: 'Floor (उचित न्यूनतम)',
                        price: '₹ 1,850',
                        color: Palette.terracotta,
                        icon: Icons.shield_rounded,
                        description:
                            'Never sell below this — covers fair wage + material',
                      ),
                      Divider(height: 32),
                      _PriceTierRow(
                        title: 'Suggested (बाज़ार मूल्य)',
                        price: '₹ 2,400',
                        color: Palette.primary,
                        icon: Icons.star_rounded,
                        isRecommended: true,
                        description:
                            'Recommended for standard buyer marketplaces',
                      ),
                      Divider(height: 32),
                      _PriceTierRow(
                        title: 'Stretch (प्रीमियम मूल्य)',
                        price: '₹ 3,200',
                        color: Palette.affirm,
                        icon: Icons.trending_up_rounded,
                        description: 'For boutique buyers and custom orders',
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              SpokenActionButton(
                onPressed: () {
                  context.go('/catalog');
                },
                icon: Icons.check_circle_outline_rounded,
                label: 'प्रकाशित करें • Publish Listing',
                backgroundColor: Palette.affirm,
                isLarge: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PriceTierRow extends StatelessWidget {
  const _PriceTierRow({
    required this.title,
    required this.price,
    required this.color,
    required this.icon,
    required this.description,
    this.isRecommended = false,
  });

  final String title;
  final String price;
  final Color color;
  final IconData icon;
  final String description;
  final bool isRecommended;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 13,
                  color: Palette.muted,
                ),
              ),
            ],
          ),
        ),
        Text(
          price,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Palette.ink,
          ),
        ),
      ],
    );
  }
}
