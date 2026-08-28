import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:go_router/go_router.dart';
import 'package:shilpsetu/core/theme/accessible_widgets.dart';
import 'package:shilpsetu/core/theme/tokens.dart';

class _CraftProduct {
  const _CraftProduct({
    required this.id,
    required this.titleHindi,
    required this.titleEnglish,
    required this.craftCategory,
    required this.price,
    required this.statusLabel,
    required this.statusColor,
    required this.statusIcon,
    required this.hoursToMake,
    required this.spokenDescription,
    this.badge,
  });

  final String id;
  final String titleHindi;
  final String titleEnglish;
  final String craftCategory;
  final String price;
  final String statusLabel;
  final Color statusColor;
  final IconData statusIcon;
  final int hoursToMake;
  final String spokenDescription;
  final String? badge;
}

/// Product Catalog Screen.
///
/// Strictly visual & zero-literacy:
/// - Products identified by their own photos (no typing or text search required)
/// - Tap product card to hear price and description spoken aloud
class CatalogScreen extends ConsumerStatefulWidget {
  const CatalogScreen({super.key});

  @override
  ConsumerState<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends ConsumerState<CatalogScreen> {
  late final FlutterTts _tts;
  String? _activePlayingId;

  final List<_CraftProduct> _sampleProducts = const [
    _CraftProduct(
      id: 'prod_1',
      titleHindi: 'हाथ से बना टेराकोटा दीया सेट',
      titleEnglish: 'Handmade Terracotta Diya Set',
      craftCategory: 'मिट्टी शिल्प • Clay',
      price: '₹ 1,850',
      statusLabel: 'Live',
      statusColor: Palette.affirm,
      statusIcon: Icons.check_circle_rounded,
      hoursToMake: 8,
      spokenDescription:
          'यह हाथ से बना टेराकोटा दीया सेट है। बाज़ार मूल्य अठारह सौ पचास रुपये है। यह बिक्री के लिए लाइव है।',
      badge: 'GI Tagged',
    ),
    _CraftProduct(
      id: 'prod_2',
      titleHindi: 'पोचमपल्ली इकत सिल्क स्कार्फ',
      titleEnglish: 'Pochampally Ikat Silk Scarf',
      craftCategory: 'हथकरघा • Handloom',
      price: '₹ 2,400',
      statusLabel: 'Live',
      statusColor: Palette.affirm,
      statusIcon: Icons.check_circle_rounded,
      hoursToMake: 24,
      spokenDescription:
          'पोचमपल्ली इकत सिल्क स्कार्फ। शुद्ध रेशम और प्राकृतिक रंगों से निर्मित। मूल्य चौबीस सौ रुपये है।',
      badge: '100% Silk',
    ),
    _CraftProduct(
      id: 'prod_3',
      titleHindi: 'ढोकरा पीतल आदिवासी मूर्ति',
      titleEnglish: 'Dhokra Brass Tribal Figurine',
      craftCategory: 'धातु शिल्प • Metal',
      price: '₹ 3,200',
      statusLabel: 'Draft',
      statusColor: Palette.warning,
      statusIcon: Icons.edit_note_rounded,
      hoursToMake: 36,
      spokenDescription:
          'ढोकरा पीतल की आदिवासी मूर्ति। मोम कास्टिंग विधि से निर्मित। मूल्य बत्तीस सौ रुपये है।',
    ),
    _CraftProduct(
      id: 'prod_4',
      titleHindi: 'नीली मिट्टी का फूलदान',
      titleEnglish: 'Jaipur Blue Pottery Vase',
      craftCategory: 'ब्लू पॉटरी • Ceramic',
      price: '₹ 1,950',
      statusLabel: 'Live',
      statusColor: Palette.affirm,
      statusIcon: Icons.check_circle_rounded,
      hoursToMake: 14,
      spokenDescription:
          'जयपुर नीली मिट्टी का पारंपरिक फूलदान। मूल्य उन्नीस सौ पचास रुपये है।',
      badge: 'Bestseller',
    ),
  ];

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

  Future<void> _speakProduct(_CraftProduct product) async {
    setState(() {
      _activePlayingId = product.id;
    });

    try {
      await _tts.stop();
      await _tts.speak(product.spokenDescription);
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
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Palette.terracotta.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.grid_view_rounded,
                color: Palette.terracotta,
                size: 22,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'मेरे उत्पाद • My Products',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 20,
                color: Palette.ink,
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
              tooltip: 'Speak summary',
              onPressed: () {
                unawaited(
                  _tts.speak(
                    'आपके पास ${_sampleProducts.length} उत्पाद सूचीबद्ध हैं। किसी भी उत्पाद की जानकारी सुनने के लिए उस पर टैप करें।',
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
                promptText:
                    'आपके द्वारा बनाए गए उत्पाद\nTap any craft to hear details',
                icon: Icons.inventory_2_rounded,
                accentColor: Palette.terracotta,
                onReplayAudio: () {
                  unawaited(
                    _tts.speak(
                      'यहाँ आपके बनाए सभी उत्पाद दिखाई दे रहे हैं',
                    ),
                  );
                },
              ),
            ),

            // Product Cards Grid
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(Sizes.gutter),
                itemCount: _sampleProducts.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: Sizes.gapMedium),
                itemBuilder: (context, index) {
                  final product = _sampleProducts[index];
                  final isPlaying = _activePlayingId == product.id;

                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(Sizes.cardRadius),
                      border: Border.all(
                        color: isPlaying
                            ? Palette.goldAccent
                            : Palette.surfaceContainerHigh,
                        width: isPlaying ? 2.5 : 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isPlaying
                              ? Palette.goldAccent.withValues(alpha: 0.18)
                              : Palette.ink.withValues(alpha: 0.05),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top bar: craft category + status badge
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      Palette.primary.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  product.craftCategory,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Palette.primary,
                                  ),
                                ),
                              ),
                              if (product.badge != null) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Palette.goldAccentLight,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    product.badge!,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      color: Palette.goldAccent,
                                    ),
                                  ),
                                ),
                              ],
                              const Spacer(),
                              TripleChannelStatusBadge(
                                label: product.statusLabel,
                                icon: product.statusIcon,
                                color: product.statusColor,
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // Titles & Rupee Price
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Visual craft thumbnail avatar
                              Container(
                                width: 72,
                                height: 72,
                                decoration: BoxDecoration(
                                  color:
                                      Palette.terracotta.withValues(alpha: 0.1),
                                  borderRadius:
                                      BorderRadius.circular(Sizes.radius),
                                  border: Border.all(
                                    color: Palette.terracotta
                                        .withValues(alpha: 0.25),
                                  ),
                                ),
                                child: const Icon(
                                  Icons.palette_outlined,
                                  color: Palette.terracotta,
                                  size: 36,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.titleHindi,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                        color: Palette.ink,
                                      ),
                                    ),
                                    Text(
                                      product.titleEnglish,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Palette.muted,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      product.price,
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w900,
                                        color: Palette.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // 64dp Touch Target Audio Readout Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(
                                  Sizes.minTouchTarget,
                                  Sizes.minTouchTarget,
                                ),
                                backgroundColor: isPlaying
                                    ? Palette.goldAccent
                                    : Palette.primary,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(Sizes.radius),
                                ),
                              ),
                              icon: Icon(
                                isPlaying
                                    ? Icons.volume_up_rounded
                                    : Icons.play_circle_fill_rounded,
                                size: 28,
                              ),
                              label: Text(
                                isPlaying
                                    ? 'विवरण चल रहा है... (Playing)'
                                    : 'जानकारी सुनें (Listen Details)',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              onPressed: () => _speakProduct(product),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Palette.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.add_a_photo_rounded, size: 28),
        label: const Text(
          'नया उत्पाद (Add Craft)',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
        onPressed: () {
          context.go('/capture');
        },
      ),
    );
  }
}
