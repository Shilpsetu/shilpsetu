import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Supported language configuration for Shilpsetu.
enum AppLanguage {
  hindi(
    code: 'hi',
    nameEnglish: 'Hindi',
    nameNative: 'हिन्दी',
    scriptGlyph: 'अ',
    ttsLocale: 'hi-IN',
    greeting: 'नमस्ते! अपनी भाषा चुनें।',
  ),
  english(
    code: 'en',
    nameEnglish: 'English',
    nameNative: 'English',
    scriptGlyph: 'A',
    ttsLocale: 'en-IN',
    greeting: 'Welcome! Please select your language.',
  ),
  bengali(
    code: 'bn',
    nameEnglish: 'Bengali',
    nameNative: 'বাংলা',
    scriptGlyph: 'অ',
    ttsLocale: 'bn-IN',
    greeting: 'স্বাগতম! আপনার ভাষা বেছে নিন।',
  ),
  telugu(
    code: 'te',
    nameEnglish: 'Telugu',
    nameNative: 'తెలుగు',
    scriptGlyph: 'అ',
    ttsLocale: 'te-IN',
    greeting: 'స్వాగతం! మీ భాషను ఎంచుకోండి.',
  ),
  tamil(
    code: 'ta',
    nameEnglish: 'Tamil',
    nameNative: 'தமிழ்',
    scriptGlyph: 'அ',
    ttsLocale: 'ta-IN',
    greeting: 'வணக்கம்! உங்கள் மொழியைத் தேர்ந்தெடுக்கவும்.',
  ),
  odia(
    code: 'or',
    nameEnglish: 'Odia',
    nameNative: 'ଓଡ଼ିଆ',
    scriptGlyph: 'ଅ',
    ttsLocale: 'or-IN',
    greeting: 'ସ୍ୱାଗତ! ଆପଣଙ୍କ ଭାଷା ବାଛନ୍ତୁ।',
  ),
  gujarati(
    code: 'gu',
    nameEnglish: 'Gujarati',
    nameNative: 'ગુજરાતી',
    scriptGlyph: 'અ',
    ttsLocale: 'gu-IN',
    greeting: 'સ્વાગત છે! તમારી ભાષા પસંદ કરો.',
  ),
  marathi(
    code: 'mr',
    nameEnglish: 'Marathi',
    nameNative: 'मराठी',
    scriptGlyph: 'म',
    ttsLocale: 'mr-IN',
    greeting: 'स्वागत आहे! तुमची भाषा निवडा.',
  );

  const AppLanguage({
    required this.code,
    required this.nameEnglish,
    required this.nameNative,
    required this.scriptGlyph,
    required this.ttsLocale,
    required this.greeting,
  });

  final String code;
  final String nameEnglish;
  final String nameNative;
  final String scriptGlyph;
  final String ttsLocale;
  final String greeting;

  Locale get locale => Locale(code, 'IN');
}

class LanguageState {
  const LanguageState({
    required this.selectedLanguage,
    required this.hasSelectedLanguage,
  });

  factory LanguageState.initial() => const LanguageState(
        selectedLanguage: AppLanguage.hindi,
        hasSelectedLanguage: false,
      );

  final AppLanguage selectedLanguage;
  final bool hasSelectedLanguage;

  LanguageState copyWith({
    AppLanguage? selectedLanguage,
    bool? hasSelectedLanguage,
  }) {
    return LanguageState(
      selectedLanguage: selectedLanguage ?? this.selectedLanguage,
      hasSelectedLanguage: hasSelectedLanguage ?? this.hasSelectedLanguage,
    );
  }
}

class LanguageNotifier extends StateNotifier<LanguageState> {
  LanguageNotifier() : super(LanguageState.initial());

  void setLanguage(AppLanguage language) {
    state = LanguageState(
      selectedLanguage: language,
      hasSelectedLanguage: true,
    );
  }

  /// Helper to get text in the active selected language.
  String text({
    required String hi,
    required String en,
    String? other,
  }) {
    if (state.selectedLanguage == AppLanguage.english) {
      return en;
    }
    return hi;
  }
}

final languageProvider =
    StateNotifierProvider<LanguageNotifier, LanguageState>((ref) {
  return LanguageNotifier();
});
