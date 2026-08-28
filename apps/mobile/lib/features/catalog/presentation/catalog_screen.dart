import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shilpsetu/core/theme/accessible_widgets.dart';
import 'package:shilpsetu/core/theme/tokens.dart';

/// Product Catalog Screen (Flutter Dev B).
///
/// Strictly visual & zero-literacy:
/// - Products identified by their own photo (no typing or text search box)
/// - Tap product card to hear price and description spoken aloud
class CatalogScreen extends ConsumerWidget {
  const CatalogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'मेरे उत्पाद • My Products',
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
                promptText: 'आपके द्वारा बनाए गए सभी उत्पाद',
                icon: Icons.inventory_2_rounded,
                accentColor: Palette.terracotta,
              ),
            ),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.photo_library_outlined,
                      size: 80,
                      color: Palette.muted.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: Sizes.gapMedium),
                    const Text(
                      'No products saved yet.\nTake a photo to get started!',
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
