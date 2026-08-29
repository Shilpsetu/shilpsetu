import 'package:drift/drift.dart';

/// Products cached locally (ADR-0001: Device is UI source of truth).
class LocalProducts extends Table {
  TextColumn get id => text()();
  TextColumn get craftId => text().nullable()();
  TextColumn get title => text().nullable()();
  TextColumn get description => text().nullable()();
  TextColumn get localImagePath => text().nullable()();
  TextColumn get remoteImageUrl => text().nullable()();
  TextColumn get price => text().nullable()(); // Stored as Decimal string
  TextColumn get status => text().withDefault(const Constant('draft'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// Outbox table for offline-first sync (ADR-0001).
class OutboxRecords extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get idempotencyKey => text().unique()();
  TextColumn get actionType =>
      text()(); // e.g. 'CREATE_PRODUCT', 'UPDATE_PRICE'
  TextColumn get payloadJson => text()();
  TextColumn get status => text()
      .withDefault(const Constant('pending'))(); // pending, synced, failed
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// Buyer enquiries table for offline playback.
class LocalEnquiries extends Table {
  TextColumn get id => text()();
  TextColumn get productId => text().nullable()();
  TextColumn get productTitle => text().nullable()();
  TextColumn get buyerName => text()();
  TextColumn get buyerLocation => text().nullable()();
  TextColumn get audioUrl => text().nullable()();
  TextColumn get messageText => text()();
  TextColumn get status => text().withDefault(const Constant('unread'))();
  DateTimeColumn get receivedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
