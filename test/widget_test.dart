// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_companion_pro/screens/role_selection_screen.dart';

void main() {
  testWidgets('Role selection screen displays correctly', (
    WidgetTester tester,
  ) async {
    // Build our role selection screen widget directly
    await tester.pumpWidget(const MaterialApp(home: RoleSelectionScreen()));

    // Verify that the role selection screen loads with expected content
    expect(find.text('Who are you?'), findsOneWidget);
    expect(find.text('Select your role to continue'), findsOneWidget);
    expect(find.text('Doctor'), findsOneWidget);
    expect(find.text('Pharmacy'), findsOneWidget);
  });
}
