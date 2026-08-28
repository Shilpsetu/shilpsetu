/// Status of a buyer enquiry or order.
enum EnquiryStatus {
  unread,
  read,
  accepted,
  completed,
}

/// Represents an incoming buyer purchase enquiry or order (ADR-0001).
class EnquiryItem {
  const EnquiryItem({
    required this.id,
    required this.buyerName,
    required this.messageText,
    required this.status,
    required this.receivedAt,
    this.productId,
    this.productTitle,
    this.buyerLocation,
    this.offeredPrice,
    this.audioUrl,
    this.quantity = 1,
  });

  final String id;
  final String? productId;
  final String? productTitle;
  final String buyerName;
  final String? buyerLocation;
  final String messageText;
  final String? offeredPrice;
  final String? audioUrl;
  final int quantity;
  final EnquiryStatus status;
  final DateTime receivedAt;

  bool get isUnread => status == EnquiryStatus.unread;

  EnquiryItem copyWith({
    String? id,
    String? productId,
    String? productTitle,
    String? buyerName,
    String? buyerLocation,
    String? messageText,
    String? offeredPrice,
    String? audioUrl,
    int? quantity,
    EnquiryStatus? status,
    DateTime? receivedAt,
  }) {
    return EnquiryItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productTitle: productTitle ?? this.productTitle,
      buyerName: buyerName ?? this.buyerName,
      buyerLocation: buyerLocation ?? this.buyerLocation,
      messageText: messageText ?? this.messageText,
      offeredPrice: offeredPrice ?? this.offeredPrice,
      audioUrl: audioUrl ?? this.audioUrl,
      quantity: quantity ?? this.quantity,
      status: status ?? this.status,
      receivedAt: receivedAt ?? this.receivedAt,
    );
  }
}
