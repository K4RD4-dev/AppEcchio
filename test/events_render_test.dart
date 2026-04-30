import 'package:appecchio_mockup/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('events calendar renders on a phone viewport',
      (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(home: EventsScreen()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Calendario eventi'), findsOneWidget);
    expect(find.text('Lun'), findsOneWidget);
    expect(find.text('Mar'), findsOneWidget);
  });
}
