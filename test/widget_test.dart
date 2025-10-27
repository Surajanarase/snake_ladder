// test/widget_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:health_snake_ladder/main.dart';

void main() {
  testWidgets('app builds and shows title', (WidgetTester tester) async {
    await tester.pumpWidget(const HealthSnakeLadderApp());
    await tester.pumpAndSettle();

    // Expect the header text (Health Heroes) to be present
    expect(find.text('Health Heroes'), findsOneWidget);
  });
}
