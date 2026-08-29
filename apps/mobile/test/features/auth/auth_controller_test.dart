import 'package:flutter_test/flutter_test.dart';
import 'package:shilpsetu/features/auth/presentation/controllers/auth_controller.dart';

void main() {
  group('AuthController & Validation Criteria', () {
    late AuthController controller;

    setUp(() {
      controller = AuthController();
    });

    test('initial state is unauthenticated', () {
      expect(controller.state.isAuthenticated, isFalse);
      expect(controller.state.currentUser, isNull);
      expect(controller.state.isLoading, isFalse);
    });

    test('validates 10-digit Indian mobile number correctly', () {
      expect(controller.isValidPhoneNumber('9876543210'), isTrue);
      expect(controller.isValidPhoneNumber('8123456789'), isTrue);
      expect(controller.isValidPhoneNumber('7012345678'), isTrue);
      expect(controller.isValidPhoneNumber('6987654321'), isTrue);

      // Invalid phone numbers
      expect(controller.isValidPhoneNumber('1234567890'), isFalse); // starts with 1
      expect(controller.isValidPhoneNumber('98765'), isFalse); // < 10 digits
      expect(controller.isValidPhoneNumber('987654321012'), isFalse); // > 10 digits
      expect(controller.isValidPhoneNumber('abcdefghij'), isFalse); // non-digits
    });

    test('validates artisan name with minimum 2 characters', () {
      expect(controller.isValidName('राम किशोर'), isTrue);
      expect(controller.isValidName('Anand'), isTrue);
      expect(controller.isValidName('A'), isFalse);
      expect(controller.isValidName('   '), isFalse);
    });

    test('register rejects invalid name and keeps unauthenticated', () async {
      final success = await controller.register(
        name: 'A',
        phoneNumber: '9876543210',
      );

      expect(success, isFalse);
      expect(controller.state.isAuthenticated, isFalse);
      expect(controller.state.errorMessage, contains('नाम'));
    });

    test('register rejects invalid phone and keeps unauthenticated', () async {
      final success = await controller.register(
        name: 'राम किशोर',
        phoneNumber: '12345',
      );

      expect(success, isFalse);
      expect(controller.state.isAuthenticated, isFalse);
      expect(controller.state.errorMessage, contains('मोबाइल नंबर'));
    });

    test('register succeeds with valid name and phone number', () async {
      final success = await controller.register(
        name: 'राम किशोर',
        phoneNumber: '9876543210',
        craftType: 'मिट्टी शिल्प (Terracotta)',
      );

      expect(success, isTrue);
      expect(controller.state.isAuthenticated, isTrue);
      expect(controller.state.currentUser, isNotNull);
      expect(controller.state.currentUser!.name, equals('राम किशोर'));
      expect(controller.state.currentUser!.phoneNumber, equals('9876543210'));
    });

    test('login succeeds with valid phone number', () async {
      final success = await controller.login(
        phoneNumber: '9876543210',
      );

      expect(success, isTrue);
      expect(controller.state.isAuthenticated, isTrue);
      expect(controller.state.currentUser, isNotNull);
    });
  });
}
