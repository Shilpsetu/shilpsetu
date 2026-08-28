import 'package:shilpsetu/core/database/app_database.dart';
import 'package:shilpsetu/features/enquiries/domain/models/enquiry_item.dart';
import 'package:shilpsetu/features/enquiries/domain/repository/enquiries_repository.dart';

class EnquiriesRepositoryImpl implements EnquiriesRepository {
  EnquiriesRepositoryImpl({AppDatabase? database}) : _database = database;

  // ignore: unused_field
  final AppDatabase? _database;

  // In-memory server-authoritative mock store for initial Phase 0/1 development
  final List<EnquiryItem> _inMemoryEnquiries = [
    EnquiryItem(
      id: 'enq_101',
      buyerName: 'Priya Sharma (Mumbai)',
      buyerLocation: 'Mumbai, Maharashtra',
      productTitle: 'Handmade Terracotta Diya Set',
      messageText: 'मुझे 10 दीयों का सेट दिवाली के लिए चाहिए। क्या यह समय पर मिल सकता है? (I need 10 sets of diyas for Diwali. Can it be delivered by next week?)',
      offeredPrice: '₹1,200',
      quantity: 10,
      status: EnquiryStatus.unread,
      receivedAt: DateTime.now().subtract(const Duration(minutes: 15)),
    ),
    EnquiryItem(
      id: 'enq_102',
      buyerName: 'Anand Verma (Bengaluru)',
      buyerLocation: 'Bengaluru, Karnataka',
      productTitle: 'Pochampally Ikat Silk Scarf',
      messageText: 'क्या इस डिज़ाइन में नीला रंग उपलब्ध है? (Is this design available in royal blue color?)',
      offeredPrice: '₹2,800',
      quantity: 2,
      status: EnquiryStatus.unread,
      receivedAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    EnquiryItem(
      id: 'enq_103',
      buyerName: 'Craftsvilla Retail (Delhi)',
      buyerLocation: 'New Delhi',
      productTitle: 'Brass Dhokra Tribal Figurine',
      messageText: 'हम आपकी 5 मूर्तियां थोक में खरीदना चाहते हैं। (We would like to purchase 5 pieces for our exhibition).',
      offeredPrice: '₹7,500',
      quantity: 5,
      status: EnquiryStatus.read,
      receivedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  @override
  Future<List<EnquiryItem>> fetchEnquiries() async {
    // Return server-authoritative list
    await Future<void>.delayed(const Duration(milliseconds: 100));
    return List.unmodifiable(_inMemoryEnquiries);
  }

  @override
  Future<void> markAsRead(String id) async {
    final index = _inMemoryEnquiries.indexWhere((e) => e.id == id);
    if (index != -1) {
      final item = _inMemoryEnquiries[index];
      _inMemoryEnquiries[index] = item.copyWith(status: EnquiryStatus.read);
    }
  }

  @override
  Future<void> acceptEnquiry(String id) async {
    final index = _inMemoryEnquiries.indexWhere((e) => e.id == id);
    if (index != -1) {
      final item = _inMemoryEnquiries[index];
      _inMemoryEnquiries[index] = item.copyWith(status: EnquiryStatus.accepted);
    }
  }
}
