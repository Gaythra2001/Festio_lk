import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:festio_lk/main.dart';

void main() {
  testWidgets('App smoke test - Widget tree builds', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the app builds without errors
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}