// test/widget_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:serpent_strike/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SerpentStrikeApp());
    expect(find.byType(SerpentStrikeApp), findsOneWidget);
  });
}
