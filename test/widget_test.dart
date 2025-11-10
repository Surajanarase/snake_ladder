// test/widget_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:health_snake_ladder/main.dart';

void main() {
  testWidgets('app builds and shows title', (WidgetTester tester) async {
    // Use MyApp which is the actual class name in main.dart
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Expect the header text (Health Quest) to be present
    expect(find.text('Health Quest'), findsOneWidget);
  });
}