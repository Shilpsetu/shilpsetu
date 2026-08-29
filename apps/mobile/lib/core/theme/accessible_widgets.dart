import 'package:flutter/material.dart';
import 'package:shilpsetu/core/theme/tokens.dart';

/// The exact Shilpsetu brand logo as shown in reference:
/// - Rounded dark blue badge with connecting node icon
/// - "shilp" in dark ink text + "setu" in vibrant terracotta orange
class ShilpsetuBrandLogo extends StatelessWidget {
  const ShilpsetuBrandLogo({
    super.key,
    this.isHindi = false,
    this.fontSize = 22,
    this.iconSize = 34,
  });

  final bool isHindi;
  final double fontSize;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Brand icon: rounded dark blue container with connecting bridge nodes
        Container(
          width: iconSize,
          height: iconSize,
          decoration: BoxDecoration(
            color: Palette.logoBadgeBg,
            borderRadius: BorderRadius.circular(iconSize * 0.28),
            boxShadow: [
              BoxShadow(
                color: Palette.logoBadgeBg.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Icon(
              Icons.hub_rounded,
              color: Colors.white,
              size: iconSize * 0.58,
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Split-color text: 'shilp' in dark ink, 'setu' in vibrant terracotta orange
        RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
            children: isHindi
                ? const [
                    TextSpan(
                      text: 'शिल्प',
                      style: TextStyle(
                        color: Palette.logoInk,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    TextSpan(
                      text: 'सेतु',
                      style: TextStyle(
                        color: Palette.logoOrange,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ]
                : const [
                    TextSpan(
                      text: 'shilp',
                      style: TextStyle(
                        color: Palette.logoInk,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    TextSpan(
                      text: 'setu',
                      style: TextStyle(
                        color: Palette.logoOrange,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
          ),
        ),
      ],
    );
  }
}

/// A signature purple hero container as shown in the reference design:
/// - Slate purple gradient background with subtle translucent circles & sparkle stars
/// - Amber ochre category badge
/// - Bold white headline + white subtitle
/// - Warm amber call-to-action button
class ShilpsetuPurpleCard extends StatelessWidget {
  const ShilpsetuPurpleCard({
    required this.tag,
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.onTap,
    super.key,
    this.icon = Icons.mic_rounded,
    this.tagIcon = Icons.mic_rounded,
    this.onSpeak,
    this.isSpeaking = false,
  });

  final String tag;
  final String title;
  final String subtitle;
  final String buttonText;
  final VoidCallback onTap;
  final IconData icon;
  final IconData tagIcon;
  final VoidCallback? onSpeak;
  final bool isSpeaking;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Palette.purpleContainer, Palette.purpleContainerDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Palette.purpleContainerDark.withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Decorative background translucent shapes & sparkles (as seen in reference)
            Positioned(
              right: -30,
              top: -20,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
            ),
            const Positioned(
              right: 48,
              top: 52,
              child: Icon(
                Icons.auto_awesome,
                color: Color(0xFFF7A833),
                size: 28,
              ),
            ),
            Positioned(
              right: 20,
              bottom: 38,
              child: Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.25),
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 36,
                ),
              ),
            ),

            // Card content
            Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Golden Ochre Tag
                  Row(
                    children: [
                      Icon(
                        tagIcon,
                        color: const Color(0xFFF7A833),
                        size: 15,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        tag.toUpperCase(),
                        style: const TextStyle(
                          color: Color(0xFFF7A833),
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                          letterSpacing: 1.1,
                        ),
                      ),
                      const Spacer(),
                      if (onSpeak != null)
                        IconButton.filledTonal(
                          icon: Icon(
                            isSpeaking
                                ? Icons.volume_up_rounded
                                : Icons.volume_down_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                          style: IconButton.styleFrom(
                            backgroundColor:
                                Colors.white.withValues(alpha: 0.2),
                            minimumSize: const Size(36, 36),
                            padding: EdgeInsets.zero,
                          ),
                          onPressed: onSpeak,
                        ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Headline
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 240),
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        height: 1.15,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Subtitle
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 220),
                    child: Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.88),
                        height: 1.3,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Amber Action Button (as in reference image)
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onTap,
                      borderRadius: BorderRadius.circular(30),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Palette.amberButton,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  Palette.amberButton.withValues(alpha: 0.35),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              buttonText,
                              style: const TextStyle(
                                color: Palette.ink,
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.arrow_forward_rounded,
                              color: Palette.ink,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ),
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

/// A primary 96dp or 64dp interactive action button equipped with icon,
/// high-contrast label, tactile elevation, and optional audio prompt button.
class SpokenActionButton extends StatelessWidget {
  const SpokenActionButton({
    required this.onPressed,
    required this.icon,
    required this.label,
    super.key,
    this.backgroundColor = Palette.purpleContainer,
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
                    color: Colors.white.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: isLarge ? 34 : 26,
                    color: foregroundColor,
                  ),
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
                          fontSize: isLarge
                              ? Sizes.minBodyText + 2
                              : Sizes.minBodyText,
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
                            color: foregroundColor.withValues(alpha: 0.88),
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

/// A zero-literacy audio-first prompt banner with signature purple container styling.
class ZeroLiteracyPromptCard extends StatelessWidget {
  const ZeroLiteracyPromptCard({
    required this.promptText,
    required this.icon,
    super.key,
    this.onReplayAudio,
    this.accentColor = Palette.purpleContainer,
    this.isListening = false,
  });

  final String promptText;
  final IconData icon;
  final VoidCallback? onReplayAudio;
  final Color accentColor;
  final bool isListening;

  @override
  Widget build(BuildContext context) {
    final isPurple = accentColor == Palette.purpleContainer ||
        accentColor == Palette.primary;

    return Container(
      decoration: BoxDecoration(
        gradient: isPurple
            ? const LinearGradient(
                colors: [Palette.purpleContainer, Palette.purpleContainerDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: isPurple ? null : Colors.white,
        borderRadius: BorderRadius.circular(Sizes.cardRadius),
        border: isPurple
            ? null
            : Border.all(
                color: accentColor.withValues(alpha: 0.25),
                width: 2,
              ),
        boxShadow: [
          BoxShadow(
            color: isPurple
                ? Palette.purpleContainerDark.withValues(alpha: 0.3)
                : accentColor.withValues(alpha: 0.08),
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
                color: isPurple
                    ? Colors.white.withValues(alpha: 0.18)
                    : accentColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isPurple
                      ? Colors.white.withValues(alpha: 0.3)
                      : accentColor.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: Icon(
                icon,
                color: isPurple ? Colors.white : accentColor,
                size: 30,
              ),
            ),
            const SizedBox(width: Sizes.gapMedium),
            Expanded(
              child: Text(
                promptText,
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: isPurple ? Colors.white : Palette.ink,
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
                      color: isPurple
                          ? Palette.amberButton
                          : accentColor.withValues(alpha: 0.14),
                      shape: BoxShape.circle,
                      boxShadow: isPurple
                          ? [
                              BoxShadow(
                                color: Palette.amberButton
                                    .withValues(alpha: 0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Icon(
                      Icons.volume_up_rounded,
                      color: isPurple ? Palette.ink : accentColor,
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
