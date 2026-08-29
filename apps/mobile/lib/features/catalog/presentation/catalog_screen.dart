import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:go_router/go_router.dart';
import 'package:shilpsetu/core/localization/language_provider.dart';
import 'package:shilpsetu/core/theme/accessible_widgets.dart';
import 'package:shilpsetu/core/theme/tokens.dart';
import 'package:shilpsetu/features/home/presentation/widgets/app_info_menu.dart';

class _CraftProduct {
  const _CraftProduct({
    required this.id,
    required this.titleHindi,
    required this.titleEnglish,
    required this.craftCategoryHindi,
    required this.craftCategoryEnglish,
    required this.price,
    required this.statusLabelHindi,
    required this.statusLabelEnglish,
    required this.statusColor,
    required this.statusIcon,
    required this.hoursToMake,
    required this.spokenDescriptionHindi,
    required this.spokenDescriptionEnglish,
    this.badgeHindi,
    this.badgeEnglish,
  });

  final String id;
  final String titleHindi;
  final String titleEnglish;
  final String craftCategoryHindi;
  final String craftCategoryEnglish;
  final String price;
  final String statusLabelHindi;
  final String statusLabelEnglish;
  final Color statusColor;
  final IconData statusIcon;
  final int hoursToMake;
  final String spokenDescriptionHindi;
  final String spokenDescriptionEnglish;
  final String? badgeHindi;
  final String? badgeEnglish;
}

/// Product Catalog Screen.
///
/// Features:
/// - Exact signature design language with ShilpsetuBrandLogo and ShilpsetuPurpleCard hero banner
/// - High-contrast accessible product listings
/// - Individual audio readback with soundwave animation
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
      craftCategoryHindi: 'मिट्टी शिल्प',
      craftCategoryEnglish: 'Terracotta Clay',
      price: '₹ 1,850',
      statusLabelHindi: 'लाइव',
      statusLabelEnglish: 'Live',
      statusColor: Palette.affirm,
      statusIcon: Icons.check_circle_rounded,
      hoursToMake: 8,
      spokenDescriptionHindi:
          'यह हाथ से बना टेराकोटा दीया सेट है। बाज़ार मूल्य अठारह सौ पचास रुपये है। यह बिक्री के लिए लाइव है।',
      spokenDescriptionEnglish:
          'This is a handmade Terracotta Diya Set. Marketplace price is eighteen hundred fifty rupees. It is live for sale.',
      badgeHindi: 'जीआई प्रमाणित',
      badgeEnglish: 'GI Tagged',
    ),
    _CraftProduct(
      id: 'prod_2',
      titleHindi: 'पोचमपल्ली इकत सिल्क स्कार्फ',
      titleEnglish: 'Pochampally Ikat Silk Scarf',
      craftCategoryHindi: 'हथकरघा सिल्क',
      craftCategoryEnglish: 'Handloom Silk',
      price: '₹ 2,400',
      statusLabelHindi: 'लाइव',
      statusLabelEnglish: 'Live',
      statusColor: Palette.affirm,
      statusIcon: Icons.check_circle_rounded,
      hoursToMake: 24,
      spokenDescriptionHindi:
          'पोचमपल्ली इकत सिल्क स्कार्फ। शुद्ध रेशम और प्राकृतिक रंगों से निर्मित। मूल्य चौबीस सौ रुपये है।',
      spokenDescriptionEnglish:
          'Pochampally Ikat Silk Scarf. Made with pure silk and natural dyes. Price is twenty-four hundred rupees.',
      badgeHindi: '100% रेशम',
      badgeEnglish: '100% Silk',
    ),
    _CraftProduct(
      id: 'prod_3',
      titleHindi: 'ढोकरा पीतल आदिवासी मूर्ति',
      titleEnglish: 'Dhokra Brass Tribal Figurine',
      craftCategoryHindi: 'धातु शिल्प',
      craftCategoryEnglish: 'Brass Metal',
      price: '₹ 3,200',
      statusLabelHindi: 'प्रारूप',
      statusLabelEnglish: 'Draft',
      statusColor: Palette.warning,
      statusIcon: Icons.edit_note_rounded,
      hoursToMake: 36,
      spokenDescriptionHindi:
          'ढोकरा पीतल की आदिवासी मूर्ति। मोम कास्टिंग विधि से निर्मित। मूल्य बत्तीस सौ रुपये है।',
      spokenDescriptionEnglish:
          'Dhokra Brass Tribal Figurine. Crafted via lost-wax casting. Price is thirty-two hundred rupees.',
    ),
    _CraftProduct(
      id: 'prod_4',
      titleHindi: 'जयपुर नीली मिट्टी का फूलदान',
      titleEnglish: 'Jaipur Blue Pottery Vase',
      craftCategoryHindi: 'ब्लू पॉटरी',
      craftCategoryEnglish: 'Blue Pottery Ceramic',
      price: '₹ 1,950',
      statusLabelHindi: 'लाइव',
      statusLabelEnglish: 'Live',
      statusColor: Palette.affirm,
      statusIcon: Icons.check_circle_rounded,
      hoursToMake: 14,
      spokenDescriptionHindi:
          'जयपुर नीली मिट्टी का पारंपरिक फूलदान। मूल्य उन्नीस सौ पचास रुपये है।',
      spokenDescriptionEnglish:
          'Jaipur Blue Pottery Vase. Price is nineteen hundred fifty rupees.',
      badgeHindi: 'सर्वाधिक लोकप्रिय',
      badgeEnglish: 'Bestseller',
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
      final lang = ref.read(languageProvider).selectedLanguage;
      await _tts.setLanguage(lang.ttsLocale);
      await _tts.setSpeechRate(0.45);
      await _tts.setPitch(1);
      _tts
        ..setCompletionHandler(() {
          if (mounted) {
            setState(() {
              _activePlayingId = null;
            });
          }
        })
        ..setCancelHandler(() {
          if (mounted) {
            setState(() {
              _activePlayingId = null;
            });
          }
        })
        ..setErrorHandler((_) {
          if (mounted) {
            setState(() {
              _activePlayingId = null;
            });
          }
        });
    } catch (_) {}
  }

  Future<void> _speakText(String id, String text) async {
    if (_activePlayingId == id) {
      try {
        await _tts.stop();
      } catch (_) {}
      if (mounted) {
        setState(() {
          _activePlayingId = null;
        });
      }
      return;
    }

    setState(() {
      _activePlayingId = id;
    });

    final lang = ref.read(languageProvider).selectedLanguage;
    try {
      await _tts.stop();
      await _tts.setLanguage(lang.ttsLocale);
      await _tts.speak(text);
    } catch (_) {}
  }

  Future<void> _speakProduct(_CraftProduct product) async {
    if (_activePlayingId == product.id) {
      try {
        await _tts.stop();
      } catch (_) {}
      if (mounted) {
        setState(() {
          _activePlayingId = null;
        });
      }
      return;
    }

    setState(() {
      _activePlayingId = product.id;
    });

    final lang = ref.read(languageProvider).selectedLanguage;
    final isEnglish = lang == AppLanguage.english;
    final text = isEnglish
        ? product.spokenDescriptionEnglish
        : product.spokenDescriptionHindi;

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

    return Scaffold(
      backgroundColor: Palette.surface,
      appBar: AppBar(
        title: ShilpsetuBrandLogo(isHindi: !isEnglish),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton.filledTonal(
            icon: Icon(
              _activePlayingId == 'appbar_overview'
                  ? Icons.stop_rounded
                  : Icons.volume_up_rounded,
              size: 24,
            ),
            style: IconButton.styleFrom(
              backgroundColor: Palette.goldAccentLight,
              foregroundColor: Palette.goldAccent,
            ),
            tooltip: isEnglish ? 'Listen overview' : 'जानकारी सुनें',
            onPressed: () {
              unawaited(
                _speakText(
                  'appbar_overview',
                  isEnglish
                      ? 'You have ${_sampleProducts.length} craft products listed. Tap any product to hear full details.'
                      : 'आपके पास ${_sampleProducts.length} उत्पाद सूचीबद्ध हैं। किसी भी उत्पाद की जानकारी सुनने के लिए उस पर टैप करें।',
                ),
              );
            },
          ),
          const SizedBox(width: 6),
          const AppInfoIconButton(),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(Sizes.gutter),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Signature Purple Hero Banner
              ShilpsetuPurpleCard(
                tag: isEnglish ? 'MY CRAFT SHOWROOM' : 'मेरा शिल्प शोरूम',
                title: isEnglish
                    ? 'Listed\nCreations'
                    : 'सूचीबद्ध\nउत्पाद',
                subtitle: isEnglish
                    ? 'Listen to audio stories and manage your marketplace craft items.'
                    : 'ऑडियो विवरण सुनें और अपने उत्पादों की स्थिति देखें।',
                buttonText:
                    isEnglish ? 'Add New Craft' : 'नया शिल्प जोड़ें',
                icon: Icons.inventory_2_rounded,
                tagIcon: Icons.storefront_rounded,
                onTap: () => context.push('/capture'),
                isSpeaking: _activePlayingId == 'header_card',
                onSpeak: () {
                  unawaited(
                    _speakText(
                      'header_card',
                      isEnglish
                          ? 'My craft showroom. You have ${_sampleProducts.length} listed creations.'
                          : 'मेरा शिल्प शोरूम। आपके ${_sampleProducts.length} उत्पाद सूचीबद्ध हैं।',
                    ),
                  );
                },
              ),

              const SizedBox(height: Sizes.gapLarge),

              // Section Header
              Row(
                children: [
                  Text(
                    isEnglish ? 'YOUR WORK, YOUR STORY' : 'आपके उत्पाद और शिल्प',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Palette.terracotta,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Palette.purpleContainerLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isEnglish
                          ? '${_sampleProducts.length} Items'
                          : '${_sampleProducts.length} उत्पाद',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Palette.purpleContainerDark,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: Sizes.gapMedium),

              // Product Cards List
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _sampleProducts.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: Sizes.gapMedium),
                itemBuilder: (context, index) {
                  final product = _sampleProducts[index];
                  final isPlaying = _activePlayingId == product.id;
                  final title =
                      isEnglish ? product.titleEnglish : product.titleHindi;
                  final category = isEnglish
                      ? product.craftCategoryEnglish
                      : product.craftCategoryHindi;
                  final status = isEnglish
                      ? product.statusLabelEnglish
                      : product.statusLabelHindi;
                  final badge = isEnglish
                      ? product.badgeEnglish
                      : product.badgeHindi;

                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(Sizes.cardRadius),
                      border: Border.all(
                        color: isPlaying
                            ? Palette.amberButton
                            : Palette.purpleContainer.withValues(alpha: 0.25),
                        width: isPlaying ? 2.5 : 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isPlaying
                              ? Palette.amberButton.withValues(alpha: 0.25)
                              : Palette.purpleContainerDark
                                  .withValues(alpha: 0.08),
                          blurRadius: 16,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: Palette.purpleContainerLight,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  category,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: Palette.purpleContainerDark,
                                  ),
                                ),
                              ),
                              if (badge != null) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFBF2DC),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    badge,
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
                                label: status,
                                icon: product.statusIcon,
                                color: product.statusColor,
                              ),
                            ],
                          ),

                          const SizedBox(height: 14),

                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 76,
                                height: 76,
                                decoration: BoxDecoration(
                                  color: Palette.purpleContainerLight,
                                  borderRadius:
                                      BorderRadius.circular(Sizes.radius),
                                  border: Border.all(
                                    color: Palette.purpleContainer
                                        .withValues(alpha: 0.25),
                                    width: 1.5,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.palette_rounded,
                                  color: Palette.purpleContainerDark,
                                  size: 38,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      title,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                        color: Palette.ink,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      product.price,
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w900,
                                        color: Palette.purpleContainerDark,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Audio Playback Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(
                                  Sizes.minTouchTarget,
                                  Sizes.minTouchTarget,
                                ),
                                backgroundColor: isPlaying
                                    ? Palette.amberButton
                                    : Palette.purpleContainer,
                                foregroundColor:
                                    isPlaying ? Palette.ink : Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(Sizes.radius),
                                ),
                              ),
                              icon: isPlaying
                                  ? const SoundWaveBars(
                                      color: Palette.ink,
                                    )
                                  : const Icon(
                                      Icons.play_circle_fill_rounded,
                                      size: 28,
                                    ),
                              label: Text(
                                isPlaying
                                    ? (isEnglish
                                        ? 'Playing details...'
                                        : 'विवरण चल रहा है...')
                                    : (isEnglish
                                        ? 'Listen Details'
                                        : 'जानकारी सुनें'),
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
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Palette.amberButton,
        foregroundColor: Palette.ink,
        elevation: 4,
        icon: const Icon(Icons.add_a_photo_rounded, size: 26),
        label: Text(
          isEnglish ? 'Add Craft' : 'नया उत्पाद',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
        onPressed: () {
          context.push('/capture');
        },
      ),
    );
  }
}
