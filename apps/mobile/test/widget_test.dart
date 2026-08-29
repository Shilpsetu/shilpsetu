import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shilpsetu/main.dart';

void main() {
  testWidgets('ShilpsetuApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: ShilpsetuApp(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(ShilpsetuApp), findsOneWidget);
  });
}
