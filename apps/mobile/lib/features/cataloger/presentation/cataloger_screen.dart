import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shilpsetu/core/theme/accessible_widgets.dart';
import 'package:shilpsetu/core/theme/tokens.dart';

/// Voice Cataloger Screen (Flutter Dev B).
///
/// Features:
/// - Record voice note in native language
/// - Send to /v1/catalog/from-voice
/// - Conversational missing attribute questions
/// - Mandatory audio readback before publishing
class CatalogerScreen extends ConsumerStatefulWidget {
  const CatalogerScreen({super.key});

  @override
  ConsumerState<CatalogerScreen> createState() => _CatalogerScreenState();
}

class _CatalogerScreenState extends ConsumerState<CatalogerScreen> {
  bool _isRecording = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('इसके बारे में बताइए • Speak'),
        backgroundColor: Palette.surfaceContainer,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Sizes.gutter),
          child: Column(
            children: [
              const ZeroLiteracyPromptCard(
                promptText: 'इसके बारे में बताइए (रंग, सामग्री, बनाने का समय)',
                icon: Icons.mic_rounded,
              ),
              const Spacer(),
              Center(
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _isRecording = !_isRecording;
                    });
                  },
                  borderRadius: BorderRadius.circular(60),
                  child: Container(
                    width: Sizes.primaryActionTarget + 20,
                    height: Sizes.primaryActionTarget + 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isRecording ? Palette.revise : Palette.primary,
                      boxShadow: [
                        BoxShadow(
                          color:
                              (_isRecording ? Palette.revise : Palette.primary)
                                  .withValues(alpha: 0.4),
                          blurRadius: 20,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: Icon(
                      _isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                      size: 56,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: Sizes.gapLarge),
              Text(
                _isRecording
                    ? 'Listening... Bolte rahiye'
                    : 'Tap to start recording',
                style: const TextStyle(
                  fontSize: Sizes.promptText,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              SpokenActionButton(
                onPressed: () {
                  context.push('/pricing');
                },
                icon: Icons.arrow_forward_rounded,
                label: 'मूल्य तय करें • Check Price',
                isLarge: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
