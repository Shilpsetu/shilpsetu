import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shilpsetu/features/auth/domain/models/artisan_user.dart';

/// State of the artisan authentication and registration session.
class AuthState {
  const AuthState({
    required this.isLoading,
    this.currentUser,
    this.errorMessage,
    this.isAuthenticated = false,
  });

  factory AuthState.initial() => const AuthState(isLoading: false);

  final bool isLoading;
  final ArtisanUser? currentUser;
  final String? errorMessage;
  final bool isAuthenticated;

  AuthState copyWith({
    bool? isLoading,
    ArtisanUser? currentUser,
    String? errorMessage,
    bool? isAuthenticated,
    bool clearError = false,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      currentUser: currentUser ?? this.currentUser,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

class AuthController extends StateNotifier<AuthState> {
  AuthController() : super(AuthState.initial());

  /// Validates Indian 10-digit mobile number.
  bool isValidPhoneNumber(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'\D'), '');
    return cleaned.length == 10 && RegExp(r'^[6-9]\d{9}$').hasMatch(cleaned);
  }

  /// Validates artisan name (minimum 2 characters).
  bool isValidName(String name) {
    return name.trim().length >= 2;
  }

  /// Registers a new artisan with Name and Phone number.
  Future<bool> register({
    required String name,
    required String phoneNumber,
    String? craftType,
    String? location,
  }) async {
    final trimmedName = name.trim();
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'\D'), '');

    if (!isValidName(trimmedName)) {
      state = state.copyWith(
        errorMessage: 'कृपया सही नाम दर्ज करें (कम से कम 2 अक्षर)',
      );
      return false;
    }

    if (!isValidPhoneNumber(cleanPhone)) {
      state = state.copyWith(
        errorMessage: 'कृपया 10 अंकों का वैध मोबाइल नंबर दर्ज करें',
      );
      return false;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    // Simulate network verification
    await Future<void>.delayed(const Duration(milliseconds: 400));

    final user = ArtisanUser(
      id: 'artisan_${DateTime.now().millisecondsSinceEpoch}',
      name: trimmedName,
      phoneNumber: cleanPhone,
      craftType: craftType ?? 'हस्तशिल्प (Crafts)',
      location: location ?? 'भारत (India)',
    );

    state = state.copyWith(
      isLoading: false,
      currentUser: user,
      isAuthenticated: true,
      clearError: true,
    );

    return true;
  }

  /// Logs in an existing artisan with phone number.
  Future<bool> login({
    required String phoneNumber,
    String? existingName,
  }) async {
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'\D'), '');

    if (!isValidPhoneNumber(cleanPhone)) {
      state = state.copyWith(
        errorMessage: 'कृपया 10 अंकों का वैध मोबाइल नंबर दर्ज करें',
      );
      return false;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    await Future<void>.delayed(const Duration(milliseconds: 350));

    final user = ArtisanUser(
      id: 'artisan_existing',
      name: (existingName?.isNotEmpty ?? false)
          ? existingName!
          : 'कारीगर (Artisan)',
      phoneNumber: cleanPhone,
      craftType: 'हथकरघा एवं शिल्प',
    );

    state = state.copyWith(
      isLoading: false,
      currentUser: user,
      isAuthenticated: true,
      clearError: true,
    );

    return true;
  }

  void logout() {
    state = AuthState.initial();
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController();
});
