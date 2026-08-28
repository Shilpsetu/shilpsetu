import 'package:flutter/material.dart';
import 'package:shilpsetu/core/theme/tokens.dart';

/// A primary 96dp or 64dp interactive action button equipped with icon,
/// high-contrast label, and haptic/audio feedback.
class SpokenActionButton extends StatelessWidget {
  const SpokenActionButton({
    required this.onPressed,
    required this.icon,
    required this.label,
    super.key,
    this.backgroundColor = Palette.primary,
    this.foregroundColor = Palette.onPrimary,
    this.isLarge = false,
    this.onSpeakPrompt,
  });

  final VoidCallback? onPressed;
  final IconData icon;
  final String label;
  final Color backgroundColor;
  final Color foregroundColor;
  final bool isLarge;
  final VoidCallback? onSpeakPrompt;

  @override
  Widget build(BuildContext context) {
    final targetSize =
        isLarge ? Sizes.primaryActionTarget : Sizes.minTouchTarget;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(Sizes.radius),
        child: Ink(
          height: targetSize,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(Sizes.radius),
            boxShadow: [
              BoxShadow(
                color: backgroundColor.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: Sizes.gutter),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: isLarge ? 36 : 28, color: foregroundColor),
                const SizedBox(width: Sizes.gapSmall),
                Text(
                  label,
                  style: TextStyle(
                    fontSize:
                        isLarge ? Sizes.minBodyText + 2 : Sizes.minBodyText,
                    fontWeight: FontWeight.w700,
                    color: foregroundColor,
                  ),
                ),
                if (onSpeakPrompt != null) ...[
                  const SizedBox(width: Sizes.gapSmall),
                  IconButton(
                    icon:
                        Icon(Icons.volume_up, color: foregroundColor, size: 24),
                    onPressed: onSpeakPrompt,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A zero-literacy audio-first prompt banner.
///
/// Combines a prominent visual icon, spoken audio trigger button, and
/// large legible text.
class ZeroLiteracyPromptCard extends StatelessWidget {
  const ZeroLiteracyPromptCard({
    required this.promptText,
    required this.icon,
    super.key,
    this.onReplayAudio,
    this.accentColor = Palette.primary,
  });

  final String promptText;
  final IconData icon;
  final VoidCallback? onReplayAudio;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Sizes.gutter),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: accentColor, size: 30),
            ),
            const SizedBox(width: Sizes.gapMedium),
            Expanded(
              child: Text(
                promptText,
                style: const TextStyle(
                  fontSize: Sizes.promptText,
                  fontWeight: FontWeight.w700,
                  color: Palette.ink,
                  height: 1.2,
                ),
              ),
            ),
            if (onReplayAudio != null) ...[
              const SizedBox(width: Sizes.gapSmall),
              IconButton.filledTonal(
                iconSize: 28,
                style: IconButton.styleFrom(
                  minimumSize:
                      const Size(Sizes.minTouchTarget, Sizes.minTouchTarget),
                  backgroundColor: accentColor.withValues(alpha: 0.2),
                ),
                icon: Icon(Icons.volume_up_rounded, color: accentColor),
                onPressed: onReplayAudio,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Triple-Channel Status Badge: Color + Icon + Spoken label.
class TripleChannelStatusBadge extends StatelessWidget {
  const TripleChannelStatusBadge({
    required this.label,
    required this.icon,
    required this.color,
    super.key,
    this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Sizes.radius),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(Sizes.radius),
          border: Border.all(color: color, width: 2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: Sizes.minBodyText,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
