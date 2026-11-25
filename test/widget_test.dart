import 'package:flutter_test/flutter_test.dart';

import 'package:soildex/main.dart';

void main() {
  testWidgets('Login screen is the first screen', (WidgetTester tester) async {
    await tester.pumpWidget(const SoilDexApp());

    expect(find.text('SoilDex'), findsOneWidget);
    expect(find.text('Log In'), findsOneWidget);
  });
}
