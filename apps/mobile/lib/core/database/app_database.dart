import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shilpsetu/core/database/tables.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [LocalProducts, OutboxRecords, LocalEnquiries])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 1;

  // Products queries
  Stream<List<LocalProduct>> watchAllProducts() {
    return (select(localProducts)
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch();
  }

  Future<int> insertProduct(LocalProductsCompanion product) {
    return into(localProducts).insertOnConflictUpdate(product);
  }

  // Outbox queries
  Future<int> enqueueOutbox(OutboxRecordsCompanion entry) {
    return into(outboxRecords).insert(entry);
  }

  Future<List<OutboxRecord>> getPendingOutbox() {
    return (select(outboxRecords)
          ..where((t) => t.status.equals('pending'))
          ..orderBy([(t) => OrderingTerm.asc(t.id)]))
        .get();
  }

  // Enquiries queries
  Stream<List<LocalEnquiry>> watchAllEnquiries() {
    return (select(localEnquiries)
          ..orderBy([(t) => OrderingTerm.desc(t.receivedAt)]))
        .watch();
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'shilpsetu.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
