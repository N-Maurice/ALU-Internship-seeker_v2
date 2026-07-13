import 'package:alu_internship_seeker_ii/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows a friendly message when Firebase is not configured',
      (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: AluVentureConnectApp(initError: 'placeholder config'),
      ),
    );

    expect(find.text('Could not connect to Firebase.'), findsOneWidget);
    expect(find.byIcon(Icons.cloud_off), findsOneWidget);
  });
}
