import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shilpsetu/core/theme/accessible_widgets.dart';
import 'package:shilpsetu/core/theme/tokens.dart';
import 'package:shilpsetu/features/enquiries/domain/models/enquiry_item.dart';
import 'package:shilpsetu/features/enquiries/presentation/controllers/enquiries_controller.dart';

/// Enquiries & Orders Screen (Flutter Dev A).
///
/// Features:
/// - Incoming buyer purchase enquiries and interest alerts
/// - Spoken audio readback in artisan's language (Hindi / English TTS)
/// - Triple-channel status badges (Color + Icon + Audio)
/// - 64dp minimum interactive touch targets
class EnquiriesScreen extends ConsumerStatefulWidget {
  const EnquiriesScreen({super.key});

  @override
  ConsumerState<EnquiriesScreen> createState() => _EnquiriesScreenState();
}

class _EnquiriesScreenState extends ConsumerState<EnquiriesScreen> {
  late final FlutterTts _tts;

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

  Future<void> _speakEnquiry(EnquiryItem enquiry) async {
    final controller = ref.read(enquiriesControllerProvider.notifier)
      ..setActivePlaying(enquiry.id);

    final speech =
        'खरीदार ${enquiry.buyerName} ने पूछा है: ${enquiry.messageText}. कीमत: ${enquiry.offeredPrice ?? ""}.';
    try {
      await _tts.stop();
      await _tts.speak(speech);
      await controller.markRead(enquiry.id);
    } catch (_) {}
  }

  @override
  void dispose() {
    unawaited(_tts.stop());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(enquiriesControllerProvider);

    return Scaffold(
      backgroundColor: Palette.surface,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Palette.affirm.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.mark_chat_unread_rounded,
                color: Palette.affirm,
                size: 22,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'ऑर्डर और संदेश • Orders',
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
          if (state.unreadCount > 0)
            Container(
              margin: const EdgeInsets.only(right: 14),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Palette.affirm,
                borderRadius: BorderRadius.circular(Sizes.radius),
                boxShadow: [
                  BoxShadow(
                    color: Palette.affirm.withValues(alpha: 0.3),
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
                    color: Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${state.unreadCount} New',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                ],
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
                    'खरीदारों के नए संदेश और ऑर्डर\nIncoming buyer messages & orders',
                icon: Icons.mark_chat_unread_rounded,
                accentColor: Palette.affirm,
                onReplayAudio: () {
                  unawaited(
                    _tts.speak('यहाँ खरीदारों के नए संदेश और ऑर्डर दिखाई देंगे'),
                  );
                },
              ),
            ),

            // Enquiries List
            Expanded(
              child: state.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : state.enquiries.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.notifications_none_rounded,
                                size: 80,
                                color: Palette.muted.withValues(alpha: 0.4),
                              ),
                              const SizedBox(height: Sizes.gapMedium),
                              const Text(
                                'अभी कोई नया संदेश नहीं है\nIncoming buyer alerts will appear here',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: Sizes.minBodyText,
                                  color: Palette.muted,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(Sizes.gutter),
                          itemCount: state.enquiries.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: Sizes.gapMedium),
                          itemBuilder: (context, index) {
                            final enquiry = state.enquiries[index];
                            final isPlaying =
                                state.activePlayingId == enquiry.id;

                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.circular(Sizes.cardRadius),
                                border: Border.all(
                                  color: isPlaying
                                      ? Palette.goldAccent
                                      : enquiry.isUnread
                                          ? Palette.primary
                                          : Palette.surfaceContainerHigh,
                                  width: isPlaying
                                      ? 2.5
                                      : enquiry.isUnread
                                          ? 2
                                          : 1.2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: enquiry.isUnread
                                        ? Palette.primary.withValues(alpha: 0.1)
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
                                    // Header: Buyer Avatar, Name, Location
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 24,
                                          backgroundColor: enquiry.isUnread
                                              ? Palette.primaryLight
                                                  .withValues(alpha: 0.15)
                                              : Palette.surfaceContainerHigh,
                                          child: Icon(
                                            Icons.person_rounded,
                                            color: enquiry.isUnread
                                                ? Palette.primary
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
                                                  'उत्पाद: ${enquiry.productTitle!}',
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
                                          const TripleChannelStatusBadge(
                                            label: 'Accepted',
                                            icon: Icons.check_circle_rounded,
                                            color: Palette.affirm,
                                          )
                                        else if (enquiry.isUnread)
                                          const TripleChannelStatusBadge(
                                            label: 'New',
                                            icon: Icons.fiber_new_rounded,
                                            color: Palette.primary,
                                          ),
                                      ],
                                    ),

                                    const SizedBox(height: 12),

                                    // Message text box
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

                                    // Action bar: Spoken audio listen (64dp target) + Accept Order
                                    Row(
                                      children: [
                                        // 64dp Spoken Audio Listen Button
                                        Expanded(
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
                                                    BorderRadius.circular(
                                                  Sizes.radius,
                                                ),
                                              ),
                                            ),
                                            icon: isPlaying
                                                ? const SoundWaveBars(
                                                    color: Colors.white,
                                                    barCount: 4,
                                                  )
                                                : const Icon(
                                                    Icons.volume_up_rounded,
                                                    size: 26,
                                                  ),
                                            label: Text(
                                              isPlaying
                                                  ? 'चल रहा है...'
                                                  : 'संदेश सुनें (Listen)',
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
                                          // 64dp Accept Button
                                          ElevatedButton.icon(
                                            style: ElevatedButton.styleFrom(
                                              minimumSize: const Size(
                                                Sizes.minTouchTarget,
                                                Sizes.minTouchTarget,
                                              ),
                                              backgroundColor: Palette.affirm,
                                              foregroundColor: Colors.white,
                                              elevation: 0,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                  Sizes.radius,
                                                ),
                                              ),
                                            ),
                                            icon: const Icon(
                                              Icons.check_rounded,
                                              size: 26,
                                            ),
                                            label: const Text(
                                              'स्वीकार करें\n(Accept)',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                            onPressed: () {
                                              ref
                                                  .read(
                                                    enquiriesControllerProvider
                                                        .notifier,
                                                  )
                                                  .accept(enquiry.id);
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  backgroundColor:
                                                      Palette.affirm,
                                                  content: Text(
                                                    'Order accepted! सूचना खरीदार को भेज दी गई है',
                                                    style: TextStyle(
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
            ),
          ],
        ),
      ),
    );
  }
}
