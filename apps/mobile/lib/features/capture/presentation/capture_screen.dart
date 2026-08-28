import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shilpsetu/core/theme/accessible_widgets.dart';
import 'package:shilpsetu/core/theme/tokens.dart';

/// Primary capture screen (Flutter Dev A).
///
/// Features:
/// - Real-time camera viewfinder
/// - Pre-shutter quality gate banner (blur, backlight, underexposure)
/// - 96dp primary capture shutter button
/// - Zero-literacy spoken capture prompts
class CaptureScreen extends ConsumerStatefulWidget {
  const CaptureScreen({super.key});

  @override
  ConsumerState<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends ConsumerState<CaptureScreen> {
  final bool _isProcessing = false;
  final String? _qualityWarning = null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'शिल्पसेतु • Shilpsetu',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: Palette.surfaceContainer,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.volume_up_rounded, size: 28),
            onPressed: () {
              // Trigger TTS spoken prompt
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Zero-Literacy Prompt Banner
            const Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Sizes.gutter,
              ),
              child: ZeroLiteracyPromptCard(
                promptText: 'आपने जो बनाया है वह दिखाइए\nShow me what you made',
                icon: Icons.camera_alt_rounded,
              ),
            ),

            // Viewfinder Area / Camera Container
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: Sizes.gutter),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(Sizes.cardRadius),
                  border: Border.all(
                    color: _qualityWarning != null
                        ? Palette.warning
                        : Palette.primary.withValues(alpha: 0.3),
                    width: 3,
                  ),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Viewfinder placeholder (replaces with CameraPreview in isolate integration)
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.crop_free_rounded,
                            size: 96,
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                          const SizedBox(height: Sizes.gapMedium),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(Sizes.radius),
                            ),
                            child: const Text(
                              'Center your craft in frame',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: Sizes.minBodyText,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Pre-shutter Quality Gate Overlay (if quality fails)
                    if (_qualityWarning != null)
                      Positioned(
                        top: 16,
                        left: 16,
                        right: 16,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Palette.warningLight,
                            borderRadius: BorderRadius.circular(Sizes.radius),
                            border:
                                Border.all(color: Palette.warning, width: 2),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.warning_amber_rounded,
                                color: Palette.warning,
                                size: 28,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _qualityWarning,
                                  style: const TextStyle(
                                    color: Palette.ink,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Shutter Controls (96dp Primary Action Target)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Sizes.gutter,
                vertical: Sizes.gapMedium,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Gallery picker button (64dp target)
                  IconButton.filledTonal(
                    style: IconButton.styleFrom(
                      minimumSize: const Size(
                        Sizes.minTouchTarget,
                        Sizes.minTouchTarget,
                      ),
                      backgroundColor: Palette.surfaceContainerHigh,
                    ),
                    icon: const Icon(Icons.photo_library_outlined, size: 30),
                    onPressed: () {},
                  ),

                  // Shutter Button (96dp target)
                  InkWell(
                    onTap: _isProcessing
                        ? null
                        : () {
                            // Hand off captured image to Voice Cataloger
                            context.push('/cataloger');
                          },
                    borderRadius: BorderRadius.circular(50),
                    child: Container(
                      width: Sizes.primaryActionTarget,
                      height: Sizes.primaryActionTarget,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Palette.primary,
                        border: Border.all(color: Colors.white, width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: Palette.primary.withValues(alpha: 0.4),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: _isProcessing
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            )
                          : const Icon(
                              Icons.camera_alt_rounded,
                              size: 48,
                              color: Palette.onPrimary,
                            ),
                    ),
                  ),

                  // Flash toggle button (64dp target)
                  IconButton.filledTonal(
                    style: IconButton.styleFrom(
                      minimumSize: const Size(
                        Sizes.minTouchTarget,
                        Sizes.minTouchTarget,
                      ),
                      backgroundColor: Palette.surfaceContainerHigh,
                    ),
                    icon: const Icon(Icons.flash_auto_rounded, size: 30),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
