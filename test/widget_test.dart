// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:yolo_web_demo/main.dart';

void main() {
  // Note: This test is limited because it cannot grant camera permissions.
  testWidgets('App shows initial loading indicator',
      (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the app shows a loading indicator while initializing.
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
