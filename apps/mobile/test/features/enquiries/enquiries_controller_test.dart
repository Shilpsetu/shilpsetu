import 'package:flutter_test/flutter_test.dart';
import 'package:shilpsetu/features/enquiries/domain/models/enquiry_item.dart';
import 'package:shilpsetu/features/enquiries/domain/repository/enquiries_repository.dart';
import 'package:shilpsetu/features/enquiries/presentation/controllers/enquiries_controller.dart';

class MockEnquiriesRepository implements EnquiriesRepository {
  List<EnquiryItem> items = [
    EnquiryItem(
      id: 'enq_1',
      buyerName: 'Ravi Kumar',
      messageText: 'I want 5 pieces',
      status: EnquiryStatus.unread,
      receivedAt: DateTime.now(),
    ),
    EnquiryItem(
      id: 'enq_2',
      buyerName: 'Sneha Patel',
      messageText: 'Is custom size available?',
      status: EnquiryStatus.read,
      receivedAt: DateTime.now(),
    ),
  ];

  @override
  Future<List<EnquiryItem>> fetchEnquiries() async => List.from(items);

  @override
  Future<void> markAsRead(String id) async {
    final idx = items.indexWhere((e) => e.id == id);
    if (idx != -1) items[idx] = items[idx].copyWith(status: EnquiryStatus.read);
  }

  @override
  Future<void> acceptEnquiry(String id) async {
    final idx = items.indexWhere((e) => e.id == id);
    if (idx != -1) items[idx] = items[idx].copyWith(status: EnquiryStatus.accepted);
  }
}

void main() {
  group('EnquiriesController', () {
    late MockEnquiriesRepository repository;
    late EnquiriesController controller;

    setUp(() {
      repository = MockEnquiriesRepository();
      controller = EnquiriesController(repository: repository);
    });

    test('loads enquiries and counts unread accurately', () async {
      await controller.loadEnquiries();

      expect(controller.state.isLoading, isFalse);
      expect(controller.state.enquiries.length, equals(2));
      expect(controller.state.unreadCount, equals(1));
    });

    test('markRead updates item status to read', () async {
      await controller.loadEnquiries();
      await controller.markRead('enq_1');

      expect(controller.state.unreadCount, equals(0));
      expect(
        controller.state.enquiries.firstWhere((e) => e.id == 'enq_1').status,
        equals(EnquiryStatus.read),
      );
    });

    test('accept updates item status to accepted', () async {
      await controller.loadEnquiries();
      await controller.accept('enq_1');

      expect(
        controller.state.enquiries.firstWhere((e) => e.id == 'enq_1').status,
        equals(EnquiryStatus.accepted),
      );
    });
  });
}
