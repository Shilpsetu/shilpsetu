import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:go_router/go_router.dart';
import 'package:shilpsetu/core/theme/accessible_widgets.dart';
import 'package:shilpsetu/core/theme/tokens.dart';
import 'package:shilpsetu/features/auth/presentation/controllers/auth_controller.dart';

/// Authentication & Registration Screen.
///
/// Features:
/// - Validation criteria: Name (>= 2 characters) & Indian Phone Number (10 digits)
/// - Zero-literacy audio guidance via Hindi/English TTS
/// - Large 64dp/96dp touch targets
/// - Direct transition to Home upon successful entry
class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  late final FlutterTts _tts;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isRegisterMode = true;
  String _selectedCraft = 'मिट्टी शिल्प (Terracotta)';

  final List<String> _craftOptions = const [
    'मिट्टी शिल्प (Terracotta)',
    'हथकरघा बुनाई (Handloom)',
    'ढोकरा धातु (Dhokra Metal)',
    'काष्ठ शिल्प (Woodcraft)',
    'पारंपरिक चित्रकला (Painting)',
  ];

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

  Future<void> _speakPrompt(String text) async {
    try {
      await _tts.stop();
      await _tts.speak(text);
    } catch (_) {}
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    unawaited(_tts.stop());
    super.dispose();
  }

  Future<void> _submit() async {
    final controller = ref.read(authControllerProvider.notifier);
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();

    bool success;
    if (_isRegisterMode) {
      success = await controller.register(
        name: name,
        phoneNumber: phone,
        craftType: _selectedCraft,
      );
    } else {
      success = await controller.login(
        phoneNumber: phone,
        existingName: name.isNotEmpty ? name : null,
      );
    }

    if (!mounted) return;

    if (success) {
      final userName = _isRegisterMode && name.isNotEmpty ? name : 'कारीगर जी';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Palette.affirm,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Sizes.radius),
          ),
          content: Row(
            children: [
              const Icon(
                Icons.check_circle_rounded,
                color: Colors.white,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'नमस्ते $userName! शिल्पसेतु में आपका स्वागत है।',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      );

      // Navigate to Home page (/capture)
      context.go('/capture');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      backgroundColor: Palette.surface,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Palette.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.account_balance_rounded,
                color: Palette.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'शिल्पसेतु • Shilpsetu',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 20,
                color: Palette.ink,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            child: IconButton.filledTonal(
              icon: const Icon(Icons.volume_up_rounded, size: 26),
              style: IconButton.styleFrom(
                backgroundColor: Palette.goldAccentLight,
                foregroundColor: Palette.goldAccent,
              ),
              onPressed: () {
                unawaited(
                  _speakPrompt(
                    _isRegisterMode
                        ? 'शिल्पसेतु में शामिल होने के लिए कृपया अपना नाम और दस अंकों का मोबाइल नंबर दर्ज करें।'
                        : 'लॉग इन करने के लिए अपना दस अंकों का मोबाइल नंबर दर्ज करें।',
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(Sizes.gutter),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Zero-Literacy Prompt Banner
                ZeroLiteracyPromptCard(
                  promptText: _isRegisterMode
                      ? 'अपना नाम और मोबाइल नंबर दर्ज करें\nEnter your name & phone number'
                      : 'अपना मोबाइल नंबर दर्ज करें\nEnter your mobile number',
                  icon: _isRegisterMode
                      ? Icons.person_add_alt_1_rounded
                      : Icons.login_rounded,
                  onReplayAudio: () {
                    unawaited(
                      _speakPrompt(
                        _isRegisterMode
                            ? 'कृपया अपना नाम और मोबाइल नंबर दर्ज करें'
                            : 'कृपया अपना मोबाइल नंबर दर्ज करें',
                      ),
                    );
                  },
                ),

                const SizedBox(height: Sizes.gapMedium),

                // Mode Selector Toggle (Login / Register)
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Palette.surfaceContainer,
                    borderRadius: BorderRadius.circular(Sizes.radius),
                    border: Border.all(
                      color: Palette.surfaceContainerHigh,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _isRegisterMode = true;
                            });
                          },
                          borderRadius: BorderRadius.circular(Sizes.radius - 4),
                          child: Container(
                            height: 52,
                            decoration: BoxDecoration(
                              color: _isRegisterMode
                                  ? Palette.primary
                                  : Colors.transparent,
                              borderRadius:
                                  BorderRadius.circular(Sizes.radius - 4),
                            ),
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.how_to_reg_rounded,
                                  color: _isRegisterMode
                                      ? Colors.white
                                      : Palette.ink,
                                  size: 22,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'नया पंजीकरण (Register)',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: _isRegisterMode
                                        ? Colors.white
                                        : Palette.ink,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _isRegisterMode = false;
                            });
                          },
                          borderRadius: BorderRadius.circular(Sizes.radius - 4),
                          child: Container(
                            height: 52,
                            decoration: BoxDecoration(
                              color: !_isRegisterMode
                                  ? Palette.primary
                                  : Colors.transparent,
                              borderRadius:
                                  BorderRadius.circular(Sizes.radius - 4),
                            ),
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.login_rounded,
                                  color: !_isRegisterMode
                                      ? Colors.white
                                      : Palette.ink,
                                  size: 22,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'लॉग इन (Login)',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: !_isRegisterMode
                                        ? Colors.white
                                        : Palette.ink,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: Sizes.gapLarge),

                // 1. Name Input Field (Register mode only)
                if (_isRegisterMode) ...[
                  const Text(
                    'कारीगर का पूरा नाम (Full Name) *',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Palette.ink,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _nameController,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Palette.ink,
                    ),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: const Icon(
                        Icons.person_rounded,
                        color: Palette.primary,
                        size: 28,
                      ),
                      hintText: 'उदा. राम किशोर (e.g. Ram Kishore)',
                      hintStyle: const TextStyle(
                        fontSize: 16,
                        color: Palette.muted,
                        fontWeight: FontWeight.w500,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 18,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(Sizes.radius),
                        borderSide: const BorderSide(
                          color: Palette.surfaceContainerHigh,
                          width: 1.5,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(Sizes.radius),
                        borderSide: const BorderSide(
                          color: Palette.surfaceContainerHigh,
                          width: 1.5,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(Sizes.radius),
                        borderSide: const BorderSide(
                          color: Palette.primary,
                          width: 2.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: Sizes.gapMedium),
                ],

                // 2. Phone Number Input Field (Both modes)
                const Text(
                  'मोबाइल नंबर (Mobile Number) *',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Palette.ink,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                    color: Palette.ink,
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      margin: const EdgeInsets.only(right: 10),
                      decoration: const BoxDecoration(
                        border: Border(
                          right: BorderSide(
                            color: Palette.surfaceContainerHigh,
                            width: 1.5,
                          ),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '🇮🇳 +91',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: Palette.ink,
                            ),
                          ),
                        ],
                      ),
                    ),
                    hintText: '9876543210',
                    hintStyle: const TextStyle(
                      fontSize: 18,
                      color: Palette.muted,
                      letterSpacing: 1,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 18,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(Sizes.radius),
                      borderSide: const BorderSide(
                        color: Palette.surfaceContainerHigh,
                        width: 1.5,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(Sizes.radius),
                      borderSide: const BorderSide(
                        color: Palette.surfaceContainerHigh,
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(Sizes.radius),
                      borderSide: const BorderSide(
                        color: Palette.primary,
                        width: 2.5,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: Sizes.gapMedium),

                // 3. Craft Specialty Selection (Register mode only)
                if (_isRegisterMode) ...[
                  const Text(
                    'आपकी शिल्प विधा (Your Craft Specialty)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Palette.ink,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _craftOptions.map((craft) {
                      final isSelected = _selectedCraft == craft;
                      return InkWell(
                        onTap: () {
                          setState(() {
                            _selectedCraft = craft;
                          });
                        },
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Palette.terracotta
                                : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected
                                  ? Palette.terracotta
                                  : Palette.surfaceContainerHigh,
                              width: 1.5,
                            ),
                          ),
                          child: Text(
                            craft,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: isSelected
                                  ? Colors.white
                                  : Palette.ink,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: Sizes.gapLarge),
                ] else
                  const SizedBox(height: Sizes.gapMedium),

                // Error Message Card (if validation fails)
                if (authState.errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Palette.reviseLight,
                      borderRadius: BorderRadius.circular(Sizes.radius),
                      border: Border.all(color: Palette.revise, width: 1.5),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.error_outline_rounded,
                          color: Palette.revise,
                          size: 24,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            authState.errorMessage!,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Palette.revise,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: Sizes.gapMedium),
                ],

                // 4. Primary Submit / Continue Button (96dp target)
                SpokenActionButton(
                  onPressed: authState.isLoading ? null : _submit,
                  icon: _isRegisterMode
                      ? Icons.check_circle_rounded
                      : Icons.arrow_forward_rounded,
                  label: authState.isLoading
                      ? 'सत्यापित कर रहे हैं... (Verifying...)'
                      : _isRegisterMode
                          ? 'शुरू करें • Register & Enter'
                          : 'लॉग इन करें • Login & Enter',
                  subtitle: 'Directly opens camera capture studio',
                  backgroundColor: _isRegisterMode
                      ? Palette.affirm
                      : Palette.primary,
                  isLarge: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
