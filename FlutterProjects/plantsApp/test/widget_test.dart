import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:plantsapp/widgets/primary_button.dart';

void main() {
  testWidgets('PrimaryButton shows a progress indicator when loading', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: PrimaryButton(
              label: 'Submit',
              onPressed: null,
              isLoading: true,
            ),
          ),
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Submit'), findsNothing);
  });
}
