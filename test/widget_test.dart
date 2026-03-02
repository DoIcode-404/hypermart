// Basic smoke test for HyperMart root widget.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:hypermart/app/app.dart';

void main() {
  testWidgets('App renders splash screen on launch', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: HyperMartApp()));

    // The initial route is the splash screen which shows the progress bar text.
    expect(find.text('Preparing your store...'), findsOneWidget);
  });
}
