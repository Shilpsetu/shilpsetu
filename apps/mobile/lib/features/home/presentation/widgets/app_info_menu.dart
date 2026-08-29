import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:go_router/go_router.dart';
import 'package:shilpsetu/core/localization/language_provider.dart';
import 'package:shilpsetu/core/theme/accessible_widgets.dart';
import 'package:shilpsetu/core/theme/tokens.dart';
import 'package:shilpsetu/features/auth/presentation/controllers/auth_controller.dart';

/// Top right Info Icon Button that opens Account, Language, About, and Logout options.
class AppInfoIconButton extends ConsumerWidget {
  const AppInfoIconButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(languageProvider).selectedLanguage;
    final isEnglish = lang == AppLanguage.english;

    return Container(
      margin: const EdgeInsets.only(right: 12),
      child: IconButton.filledTonal(
        icon: const Icon(Icons.info_outline_rounded, size: 26),
        style: IconButton.styleFrom(
          backgroundColor: Palette.primary.withValues(alpha: 0.1),
          foregroundColor: Palette.primary,
        ),
        tooltip: isEnglish ? 'App Info & Account' : 'जानकारी और खाता',
        onPressed: () {
          showModalBottomSheet<void>(
            context: context,
            backgroundColor: Colors.transparent,
            isScrollControlled: true,
            builder: (context) => const AppInfoBottomSheet(),
          );
        },
      ),
    );
  }
}

/// The Info & Settings Bottom Sheet containing Account, Language, About, and Logout.
class AppInfoBottomSheet extends ConsumerStatefulWidget {
  const AppInfoBottomSheet({super.key});

  @override
  ConsumerState<AppInfoBottomSheet> createState() =>
      _AppInfoBottomSheetState();
}

class _AppInfoBottomSheetState extends ConsumerState<AppInfoBottomSheet> {
  late final FlutterTts _tts;

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
    } catch (_) {}
  }

  Future<void> _speak(String text) async {
    final lang = ref.read(languageProvider).selectedLanguage;
    try {
      await _tts.stop();
      await _tts.setLanguage(lang.ttsLocale);
      await _tts.speak(text);
    } catch (_) {}
  }

  @override
  void dispose() {
    unawaited(_tts.stop());
    super.dispose();
  }

  void _openAccountEditor() {
    final lang = ref.read(languageProvider).selectedLanguage;
    final isEnglish = lang == AppLanguage.english;
    final authState = ref.read(authControllerProvider);
    final currentName = authState.currentUser?.name ?? '';
    final currentPhone = authState.currentUser?.phoneNumber ?? '';

    final nameController = TextEditingController(text: currentName);
    final phoneController = TextEditingController(text: currentPhone);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                left: Sizes.gutter,
                right: Sizes.gutter,
                top: Sizes.gutter,
                bottom: MediaQuery.of(context).viewInsets.bottom + Sizes.gutter,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Palette.primary.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.manage_accounts_rounded,
                            color: Palette.primary,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          isEnglish ? 'Account Details' : 'खाता विवरण',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Palette.ink,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => Navigator.pop(modalContext),
                        ),
                      ],
                    ),
                    const SizedBox(height: Sizes.gapMedium),
                    Text(
                      isEnglish ? 'Full Name *' : 'कारीगर का पूरा नाम *',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Palette.ink,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: nameController,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Palette.surface,
                        prefixIcon: const Icon(Icons.person_rounded),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(Sizes.radius),
                        ),
                      ),
                    ),
                    const SizedBox(height: Sizes.gapMedium),
                    Text(
                      isEnglish ? 'Mobile Number *' : 'मोबाइल नंबर *',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Palette.ink,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(10),
                      ],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Palette.surface,
                        prefixIcon: const Icon(Icons.phone_rounded),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(Sizes.radius),
                        ),
                      ),
                    ),
                    const SizedBox(height: Sizes.gapLarge),
                    SpokenActionButton(
                      onPressed: () async {
                        final newName = nameController.text.trim();
                        final newPhone = phoneController.text.trim();

                        if (newName.length < 2 ||
                            newPhone.length != 10 ||
                            !RegExp(r'^[6-9]\d{9}$').hasMatch(newPhone)) {
                          final err = isEnglish
                              ? 'Please enter a valid name and 10-digit mobile number'
                              : 'कृपया सही नाम और 10 अंकों का मोबाइल नंबर दर्ज करें';
                          unawaited(_speak(err));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: Palette.revise,
                              content: Text(err),
                            ),
                          );
                          return;
                        }

                        await ref
                            .read(authControllerProvider.notifier)
                            .updateProfile(name: newName, phoneNumber: newPhone);

                        if (!context.mounted) return;
                        Navigator.pop(modalContext);

                        final successMsg = isEnglish
                            ? 'Account details updated successfully!'
                            : 'खाता विवरण सफलतापूर्वक अपडेट हुआ!';
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Palette.affirm,
                            content: Text(successMsg),
                          ),
                        );
                      },
                      icon: Icons.save_rounded,
                      label: isEnglish ? 'Save Changes' : 'बदलाव सहेजें',
                      backgroundColor: Palette.affirm,
                      isLarge: true,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _openAboutDialog() {
    final lang = ref.read(languageProvider).selectedLanguage;
    final isEnglish = lang == AppLanguage.english;

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Sizes.cardRadius),
          ),
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
                  size: 26,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                isEnglish ? 'About Shilpsetu' : 'शिल्पसेतु के बारे में',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isEnglish
                      ? 'Shilpsetu is an AI-powered market on-ramp designed specifically for Indian craft artisans.'
                      : 'शिल्पसेतु भारतीय शिल्पकारों और बुनकरों के लिए बनाया गया एक एआई-सक्षम बाज़ार सेतु है।',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  isEnglish
                      ? '• Voice-first zero-literacy cataloging\n• On-device studio camera enhancement\n• Fair wage protection against undercutting\n• Direct buyer order alerts in your native language'
                      : '• आवाज़ से आसान उत्पाद सूचीकरण\n• फ़ोन पर ही स्टूडियो फिनिशिंग\n• उचित मजदूरी सुरक्षा\n• आपकी अपनी भाषा में खरीदारों के सीधे ऑर्डर',
                  style: const TextStyle(
                    fontSize: 15,
                    color: Palette.muted,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Palette.surfaceContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isEnglish ? 'Version 1.0.0' : 'संस्करण 1.0.0',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Palette.ink,
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                isEnglish ? 'Close' : 'बंद करें',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Palette.primary,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _confirmLogout() {
    final lang = ref.read(languageProvider).selectedLanguage;
    final isEnglish = lang == AppLanguage.english;

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Sizes.cardRadius),
          ),
          title: Text(
            isEnglish ? 'Log Out?' : 'लॉग आउट करें?',
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 20,
            ),
          ),
          content: Text(
            isEnglish
                ? 'Are you sure you want to log out of Shilpsetu?'
                : 'क्या आप शिल्पसेतु से लॉग आउट करना चाहते हैं?',
            style: const TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                isEnglish ? 'Cancel' : 'रद्द करें',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Palette.muted,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Palette.revise,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(dialogContext);
                Navigator.pop(context); // close bottom sheet
                ref.read(authControllerProvider.notifier).logout();
                context.go('/language');
              },
              child: Text(
                isEnglish ? 'Log Out' : 'लॉग आउट',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(languageProvider).selectedLanguage;
    final isEnglish = lang == AppLanguage.english;
    final authState = ref.watch(authControllerProvider);
    final artisanName = authState.currentUser?.name ??
        (isEnglish ? 'Artisan Profile' : 'कारीगर प्रोफाइल');
    final phoneNumber = authState.currentUser?.phoneNumber ?? '';

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(Sizes.gutter),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header: Avatar & Artisan info
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Palette.primary.withValues(alpha: 0.12),
                  child: const Icon(
                    Icons.person_rounded,
                    color: Palette.primary,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        artisanName,
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          color: Palette.ink,
                        ),
                      ),
                      if (phoneNumber.isNotEmpty)
                        Text(
                          '+91 $phoneNumber',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Palette.muted,
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 28),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),

            const SizedBox(height: Sizes.gapMedium),
            const Divider(),
            const SizedBox(height: Sizes.gapSmall),

            // 1. Account Option
            _buildMenuItem(
              icon: Icons.account_circle_rounded,
              title: isEnglish ? 'Account Profile' : 'खाता प्रोफाइल',
              subtitle: isEnglish
                  ? 'Edit your name and mobile number'
                  : 'अपना नाम और मोबाइल नंबर बदलें',
              color: Palette.primary,
              onTap: () {
                Navigator.pop(context);
                _openAccountEditor();
              },
            ),

            const SizedBox(height: Sizes.gapSmall),

            // 2. Language Change Option
            _buildMenuItem(
              icon: Icons.translate_rounded,
              title: isEnglish ? 'Change Language' : 'भाषा बदलें',
              subtitle: '${lang.nameNative} (${lang.nameEnglish})',
              color: Palette.goldAccent,
              onTap: () {
                Navigator.pop(context);
                context.go('/language');
              },
            ),

            const SizedBox(height: Sizes.gapSmall),

            // 3. About Page Option
            _buildMenuItem(
              icon: Icons.info_outline_rounded,
              title: isEnglish ? 'About Shilpsetu' : 'ऐप के बारे में',
              subtitle: isEnglish
                  ? 'Mission, features, and version'
                  : 'मिशन, सुविधाएं और संस्करण',
              color: Palette.terracotta,
              onTap: () {
                Navigator.pop(context);
                _openAboutDialog();
              },
            ),

            const SizedBox(height: Sizes.gapSmall),

            // 4. Logout Option
            _buildMenuItem(
              icon: Icons.logout_rounded,
              title: isEnglish ? 'Log Out' : 'लॉग आउट',
              subtitle: isEnglish
                  ? 'Sign out from this phone'
                  : 'इस फ़ोन से खाता बंद करें',
              color: Palette.revise,
              onTap: _confirmLogout,
            ),

            const SizedBox(height: Sizes.gapSmall),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Sizes.radius),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Palette.surface,
            borderRadius: BorderRadius.circular(Sizes.radius),
            border: Border.all(
              color: Palette.surfaceContainerHigh,
              width: 1.2,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Palette.ink,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Palette.muted,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Palette.muted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
