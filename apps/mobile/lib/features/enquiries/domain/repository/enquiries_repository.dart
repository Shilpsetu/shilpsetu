import 'package:shilpsetu/features/enquiries/domain/models/enquiry_item.dart';

/// Repository interface for buyer enquiries and purchase orders.
abstract class EnquiriesRepository {
  /// Fetches latest enquiries from the server.
  Future<List<EnquiryItem>> fetchEnquiries();

  /// Marks an enquiry as read.
  Future<void> markAsRead(String id);

  /// Accepts a buyer order / enquiry.
  Future<void> acceptEnquiry(String id);
}
