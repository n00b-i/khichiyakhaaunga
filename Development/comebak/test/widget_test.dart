// ==============================================================================
// [TEST] App Boot Smoke Test
// ------------------------------------------------------------------------------
// PURPOSE: Verifies the app can instantiate and render its root widget
// without crashing. Replaces the default Flutter counter boilerplate.
// ==============================================================================
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:comebak/app/app.dart'; // Imports ComebakApp

void main() {
  testWidgets('App boots smoke test', (WidgetTester tester) async {
    // Build the app and trigger a frame.
    await tester.pumpWidget(const ComebakApp());

    // Verify that the app booted (it should render a MaterialApp).
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
