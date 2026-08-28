import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shilpsetu/core/theme/accessible_widgets.dart';
import 'package:shilpsetu/core/theme/tokens.dart';

/// Enquiries & Orders Screen (Flutter Dev A).
///
/// Features:
/// - Incoming buyer purchase enquiries and interest alerts
/// - Spoken audio readback in artisan's language
class EnquiriesScreen extends ConsumerWidget {
  const EnquiriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ऑर्डर और पूछताछ • Enquiries',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: Palette.surfaceContainer,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Sizes.gutter,
                vertical: Sizes.gapSmall,
              ),
              child: ZeroLiteracyPromptCard(
                promptText: 'खरीदारों के नए संदेश और ऑर्डर',
                icon: Icons.mark_chat_unread_rounded,
                accentColor: Palette.affirm,
              ),
            ),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.notifications_none_rounded,
                      size: 80,
                      color: Palette.muted.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: Sizes.gapMedium),
                    const Text(
                      'No new enquiries yet.\nIncoming buyer alerts will appear here.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: Sizes.minBodyText,
                        color: Palette.muted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
