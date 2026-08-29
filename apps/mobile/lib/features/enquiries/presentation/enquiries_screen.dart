import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shilpsetu/core/localization/language_provider.dart';
import 'package:shilpsetu/core/theme/accessible_widgets.dart';
import 'package:shilpsetu/core/theme/tokens.dart';
import 'package:shilpsetu/features/enquiries/domain/models/enquiry_item.dart';
import 'package:shilpsetu/features/enquiries/presentation/controllers/enquiries_controller.dart';
import 'package:shilpsetu/features/home/presentation/widgets/app_info_menu.dart';

/// Enquiries & Orders Screen.
///
/// Features:
/// - Exact signature design language with ShilpsetuBrandLogo and ShilpsetuPurpleCard hero banner
/// - Direct buyer purchase enquiries and interest alerts
/// - Universal Tap-to-Speak and Tap-to-Stop audio controls with SoundWaveBars
/// - Amber / Affirm button triggers for order acceptance
class EnquiriesScreen extends ConsumerStatefulWidget {
  const EnquiriesScreen({super.key});

  @override
  ConsumerState<EnquiriesScreen> createState() => _EnquiriesScreenState();
}

class _EnquiriesScreenState extends ConsumerState<EnquiriesScreen> {
  late final FlutterTts _tts;
  String? _localPlayingId;

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
              _localPlayingId = null;
            });
            ref
                .read(enquiriesControllerProvider.notifier)
                .setActivePlaying(null);
          }
        })
        ..setCancelHandler(() {
          if (mounted) {
            setState(() {
              _localPlayingId = null;
            });
            ref
                .read(enquiriesControllerProvider.notifier)
                .setActivePlaying(null);
          }
        })
        ..setErrorHandler((_) {
          if (mounted) {
            setState(() {
              _localPlayingId = null;
            });
            ref
                .read(enquiriesControllerProvider.notifier)
                .setActivePlaying(null);
          }
        });
    } catch (_) {}
  }

  Future<void> _stopAudio() async {
    try {
      await _tts.stop();
    } catch (_) {}
    if (mounted) {
      setState(() {
        _localPlayingId = null;
      });
      ref.read(enquiriesControllerProvider.notifier).setActivePlaying(null);
    }
  }

  Future<void> _speakEnquiry(EnquiryItem enquiry) async {
    if (_localPlayingId == enquiry.id) {
      await _stopAudio();
      return;
    }

    setState(() {
      _localPlayingId = enquiry.id;
    });
    ref
        .read(enquiriesControllerProvider.notifier)
        .setActivePlaying(enquiry.id);

    final lang = ref.read(languageProvider).selectedLanguage;
    final isEnglish = lang == AppLanguage.english;

    final pricePart = enquiry.offeredPrice != null &&
            enquiry.offeredPrice!.isNotEmpty
        ? (isEnglish
            ? ' Offered price: ${enquiry.offeredPrice!}.'
            : ' प्रस्तावित मूल्य: ${enquiry.offeredPrice!}।')
        : '';

    final speech = isEnglish
        ? 'Buyer ${enquiry.buyerName} says: ${enquiry.messageText}.$pricePart'
        : 'खरीदार ${enquiry.buyerName} ने कहा है: ${enquiry.messageText}।$pricePart';

    try {
      await _tts.stop();
      await _tts.setLanguage(lang.ttsLocale);
      await _tts.speak(speech);
      if (mounted) {
        unawaited(
          ref.read(enquiriesControllerProvider.notifier).markRead(enquiry.id),
        );
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _localPlayingId = null;
        });
      }
    }
  }

  Future<void> _speakAllMessages(List<EnquiryItem> enquiries) async {
    const headerId = 'header_card';
    if (_localPlayingId == headerId) {
      await _stopAudio();
      return;
    }

    setState(() {
      _localPlayingId = headerId;
    });
    ref
        .read(enquiriesControllerProvider.notifier)
        .setActivePlaying(headerId);

    final lang = ref.read(languageProvider).selectedLanguage;
    final isEnglish = lang == AppLanguage.english;

    final String text;
    if (enquiries.isEmpty) {
      text = isEnglish
          ? 'You have no new buyer messages right now.'
          : 'अभी आपके पास कोई नया संदेश नहीं है।';
    } else {
      final unreadCount = enquiries.where((e) => e.isUnread).length;
      if (unreadCount > 0) {
        final firstUnread = enquiries.firstWhere((e) => e.isUnread);
        text = isEnglish
            ? 'You have $unreadCount new buyer messages. Latest from ${firstUnread.buyerName}: ${firstUnread.messageText}.'
            : 'आपके पास $unreadCount नए संदेश हैं। ${firstUnread.buyerName} ने पूछा है: ${firstUnread.messageText}।';
      } else {
        final first = enquiries.first;
        text = isEnglish
            ? 'You have ${enquiries.length} total orders. Message from ${first.buyerName}: ${first.messageText}.'
            : 'आपके पास कुल ${enquiries.length} संदेश हैं। ${first.buyerName} का संदेश: ${first.messageText}।';
      }
    }

    try {
      await _tts.stop();
      await _tts.setLanguage(lang.ttsLocale);
      await _tts.speak(text);
    } catch (_) {
      if (mounted) {
        setState(() {
          _localPlayingId = null;
        });
      }
    }
  }

  @override
  void dispose() {
    unawaited(_tts.stop());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(enquiriesControllerProvider);
    final lang = ref.watch(languageProvider).selectedLanguage;
    final isEnglish = lang == AppLanguage.english;
    final isHeaderPlaying = _localPlayingId == 'header_card';

    return Scaffold(
      backgroundColor: Palette.surface,
      appBar: AppBar(
        title: ShilpsetuBrandLogo(isHindi: !isEnglish),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (state.unreadCount > 0)
            Container(
              margin: const EdgeInsets.only(right: 6),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Palette.amberButton,
                borderRadius: BorderRadius.circular(Sizes.radius),
                boxShadow: [
                  BoxShadow(
                    color: Palette.amberButton.withValues(alpha: 0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.notifications_active_rounded,
                    color: Palette.ink,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isEnglish
                        ? '${state.unreadCount} New'
                        : '${state.unreadCount} नए',
                    style: const TextStyle(
                      color: Palette.ink,
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
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
                tag: isEnglish ? 'BUYER CONNECT' : 'खरीदार संदेश',
                title: isEnglish
                    ? 'Direct Buyer\nOrders'
                    : 'सीधे खरीदार\nऑर्डर',
                subtitle: isEnglish
                    ? 'Listen to incoming purchase enquiries and accept buyer offers.'
                    : 'नए संदेश सुनें और सीधे खरीदारों के ऑर्डर स्वीकार करें।',
                buttonText: isHeaderPlaying
                    ? (isEnglish ? 'Stop Audio' : 'आवाज़ रोकें')
                    : (isEnglish
                        ? 'Listen All Messages'
                        : 'सभी संदेश सुनें'),
                icon: Icons.mark_chat_unread_rounded,
                tagIcon: Icons.shopping_bag_rounded,
                onTap: () => _speakAllMessages(state.enquiries),
                isSpeaking: isHeaderPlaying,
                onSpeak: () => _speakAllMessages(state.enquiries),
              ),

              const SizedBox(height: Sizes.gapLarge),

              // Section Header
              Row(
                children: [
                  Text(
                    isEnglish ? 'INCOMING INTEREST' : 'आए हुए संदेश और ऑर्डर',
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
                          ? '${state.enquiries.length} Enquiries'
                          : '${state.enquiries.length} संदेश',
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

              // Enquiries List
              if (state.isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(
                      color: Palette.purpleContainer,
                    ),
                  ),
                )
              else if (state.enquiries.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 84,
                          height: 84,
                          decoration: const BoxDecoration(
                            color: Palette.purpleContainerLight,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.notifications_none_rounded,
                            size: 44,
                            color: Palette.purpleContainerDark,
                          ),
                        ),
                        const SizedBox(height: Sizes.gapMedium),
                        Text(
                          isEnglish
                              ? 'No new messages yet\nIncoming buyer alerts will appear here'
                              : 'अभी कोई नया संदेश नहीं है\nखरीदार के संदेश यहाँ दिखेंगे',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: Sizes.minBodyText,
                            color: Palette.muted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: state.enquiries.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: Sizes.gapMedium),
                  itemBuilder: (context, index) {
                    final enquiry = state.enquiries[index];
                    final isPlaying = _localPlayingId == enquiry.id;

                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(Sizes.cardRadius),
                        border: Border.all(
                          color: isPlaying
                              ? Palette.amberButton
                              : enquiry.isUnread
                                  ? Palette.purpleContainer
                                  : Palette.surfaceContainerHigh,
                          width: isPlaying
                              ? 2.5
                              : enquiry.isUnread
                                  ? 2
                                  : 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isPlaying
                                ? Palette.amberButton.withValues(alpha: 0.25)
                                : enquiry.isUnread
                                    ? Palette.purpleContainerDark
                                        .withValues(alpha: 0.12)
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
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 24,
                                  backgroundColor: enquiry.isUnread
                                      ? Palette.purpleContainerLight
                                      : Palette.surfaceContainerHigh,
                                  child: Icon(
                                    Icons.person_rounded,
                                    color: enquiry.isUnread
                                        ? Palette.purpleContainerDark
                                        : Palette.muted,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        enquiry.buyerName,
                                        style: const TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w800,
                                          color: Palette.ink,
                                        ),
                                      ),
                                      if (enquiry.productTitle !=
                                          null)
                                        Text(
                                          isEnglish
                                              ? 'Product: ${enquiry.productTitle!}'
                                              : 'उत्पाद: ${enquiry.productTitle!}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Palette.muted,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                if (enquiry.status ==
                                    EnquiryStatus.accepted)
                                  TripleChannelStatusBadge(
                                    label: isEnglish
                                        ? 'Accepted'
                                        : 'स्वीकृत',
                                    icon: Icons.check_circle_rounded,
                                    color: Palette.affirm,
                                  )
                                else if (enquiry.isUnread)
                                  TripleChannelStatusBadge(
                                    label: isEnglish ? 'New' : 'नया',
                                    icon: Icons.fiber_new_rounded,
                                    color: Palette.purpleContainerDark,
                                  ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Palette.surface,
                                borderRadius:
                                    BorderRadius.circular(Sizes.radius),
                                border: Border.all(
                                  color: Palette.surfaceContainerHigh,
                                ),
                              ),
                              child: Text(
                                enquiry.messageText,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Palette.ink,
                                  fontWeight: FontWeight.w600,
                                  height: 1.35,
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            Row(
                              children: [
                                // Spoken Audio Listen / Stop Button
                                Expanded(
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      minimumSize: const Size(
                                        Sizes.minTouchTarget,
                                        Sizes.minTouchTarget,
                                      ),
                                      backgroundColor: isPlaying
                                          ? Palette.amberButton
                                          : Palette.purpleContainer,
                                      foregroundColor: isPlaying
                                          ? Palette.ink
                                          : Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(
                                          Sizes.radius,
                                        ),
                                      ),
                                    ),
                                    icon: isPlaying
                                        ? const SoundWaveBars(
                                            color: Palette.ink,
                                          )
                                        : const Icon(
                                            Icons.volume_up_rounded,
                                            size: 26,
                                          ),
                                    label: Text(
                                      isPlaying
                                          ? (isEnglish
                                              ? 'Stop (Playing...)'
                                              : 'रोकें (चल रहा है)')
                                          : (isEnglish
                                              ? 'Listen Message'
                                              : 'संदेश सुनें'),
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    onPressed: () =>
                                        _speakEnquiry(enquiry),
                                  ),
                                ),

                                if (enquiry.status !=
                                    EnquiryStatus.accepted) ...[
                                  const SizedBox(width: 12),
                                  // Accept Button in Warm Amber
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      minimumSize: const Size(
                                        Sizes.minTouchTarget,
                                        Sizes.minTouchTarget,
                                      ),
                                      backgroundColor:
                                          Palette.amberButton,
                                      foregroundColor: Palette.ink,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(
                                          Sizes.radius,
                                        ),
                                      ),
                                    ),
                                    icon: const Icon(
                                      Icons.check_circle_rounded,
                                      size: 24,
                                      color: Palette.ink,
                                    ),
                                    label: Text(
                                      isEnglish
                                          ? 'Accept'
                                          : 'स्वीकार करें',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    onPressed: () {
                                      ref
                                          .read(
                                            enquiriesControllerProvider
                                                .notifier,
                                          )
                                          .accept(enquiry.id);
                                      final acceptMsg = isEnglish
                                          ? 'Order accepted! Notification sent to buyer.'
                                          : 'ऑर्डर स्वीकार किया गया! खरीदार को सूचना भेजी गई।';
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          backgroundColor:
                                              Palette.affirm,
                                          content: Text(
                                            acceptMsg,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight:
                                                  FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ],
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
    );
  }
}
