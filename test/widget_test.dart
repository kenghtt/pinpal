// This file intentionally keeps the generated smoke test minimal.
import 'package:flutter_test/flutter_test.dart';

import 'package:pinpal/main.dart';

void main() {
  testWidgets('Number Practice app starts', (WidgetTester tester) async {
    await tester.pumpWidget(const NumberPracticeApp());

    expect(find.text('Number\nPractice'), findsOneWidget);
  });
}
