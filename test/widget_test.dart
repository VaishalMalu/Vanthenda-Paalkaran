import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:vanthenda_paalkaran/main.dart';

void main() {
  testWidgets('App loads splash screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: VanthendaPaalkaranApp()));

    // Verify that splash screen text is shown.
    expect(find.text('Vanthenda Paalkaran'), findsOneWidget);
  });
}
