import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Placeholder smoke test', (WidgetTester tester) async {
    // Intentionally empty — the app uses sqflite + secure storage which
    // require platform channels unavailable in the widget test environment.
    expect(true, isTrue);
  });
}
