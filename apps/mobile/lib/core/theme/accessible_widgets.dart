import 'package:flutter/material.dart';
import 'package:shilpsetu/core/theme/tokens.dart';

/// A primary 96dp or 64dp interactive action button equipped with icon,
/// high-contrast label, tactile elevation, and optional audio prompt button.
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
    this.subtitle,
  });

  final VoidCallback? onPressed;
  final IconData icon;
  final String label;
  final String? subtitle;
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
          height: subtitle != null ? targetSize + 12 : targetSize,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(Sizes.radius),
            boxShadow: [
              BoxShadow(
                color: backgroundColor.withValues(alpha: 0.35),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: Sizes.gutter),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: isLarge ? 34 : 26, color: foregroundColor),
                ),
                const SizedBox(width: Sizes.gapSmall + 2),
                Flexible(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          fontSize:
                              isLarge ? Sizes.minBodyText + 2 : Sizes.minBodyText,
                          fontWeight: FontWeight.w800,
                          color: foregroundColor,
                          letterSpacing: 0.2,
                        ),
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle!,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: foregroundColor.withValues(alpha: 0.85),
                          ),
                        ),
                    ],
                  ),
                ),
                if (onSpeakPrompt != null) ...[
                  const SizedBox(width: Sizes.gapSmall),
                  IconButton(
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                    ),
                    icon: Icon(
                      Icons.volume_up_rounded,
                      color: foregroundColor,
                      size: 24,
                    ),
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

/// A zero-literacy audio-first prompt banner with craft styling and audio wave indicator.
class ZeroLiteracyPromptCard extends StatelessWidget {
  const ZeroLiteracyPromptCard({
    required this.promptText,
    required this.icon,
    super.key,
    this.onReplayAudio,
    this.accentColor = Palette.primary,
    this.isListening = false,
  });

  final String promptText;
  final IconData icon;
  final VoidCallback? onReplayAudio;
  final Color accentColor;
  final bool isListening;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Sizes.cardRadius),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.25),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Icon container with breathing glow
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
                border: Border.all(
                  color: accentColor.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: Icon(icon, color: accentColor, size: 30),
            ),
            const SizedBox(width: Sizes.gapMedium),
            Expanded(
              child: Text(
                promptText,
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: Palette.ink,
                  height: 1.25,
                ),
              ),
            ),
            if (onReplayAudio != null) ...[
              const SizedBox(width: Sizes.gapSmall),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onReplayAudio,
                  borderRadius: BorderRadius.circular(30),
                  child: Ink(
                    width: Sizes.minTouchTarget,
                    height: Sizes.minTouchTarget,
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.14),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: accentColor.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Icon(
                      Icons.volume_up_rounded,
                      color: accentColor,
                      size: 30,
                    ),
                  ),
                ),
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Sizes.radius),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(Sizes.radius),
            border: Border.all(color: color, width: 2),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.1),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Animated pulsating sound wave bar indicators.
class SoundWaveBars extends StatefulWidget {
  const SoundWaveBars({
    super.key,
    this.color = Palette.goldAccent,
    this.barCount = 5,
    this.isPlaying = true,
  });

  final Color color;
  final int barCount;
  final bool isPlaying;

  @override
  State<SoundWaveBars> createState() => _SoundWaveBarsState();
}

class _SoundWaveBarsState extends State<SoundWaveBars>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isPlaying) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(
          widget.barCount,
          (index) => Container(
            margin: const EdgeInsets.symmetric(horizontal: 2),
            width: 4,
            height: 8,
            decoration: BoxDecoration(
              color: widget.color.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      );
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(widget.barCount, (index) {
            final phase = (index * 0.25) % 1.0;
            final heightFactor =
                ((_controller.value + phase) % 1.0 * 24.0).clamp(6.0, 26.0);
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2.5),
              width: 4.5,
              height: heightFactor,
              decoration: BoxDecoration(
                color: widget.color,
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        );
      },
    );
  }
}
