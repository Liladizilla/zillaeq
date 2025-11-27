// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:equalizer_app/main.dart';

void main() {
  testWidgets('App builds and shows title', (WidgetTester tester) async {
    // Build the app and wait for it to settle.
    await tester.pumpWidget(const EqualizerApp());
    await tester.pumpAndSettle();

    // The app bar title from `EqualizerApp` should be present.
    expect(find.text('⚡ Futuristic Equalizer'), findsOneWidget);
  });
}
