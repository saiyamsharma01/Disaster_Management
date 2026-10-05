import 'package:flutter_test/flutter_test.dart';
import 'package:sahaaya/main.dart';
import 'package:sahaaya/router.dart';

void main() {
  testWidgets('App basic smoke test', (WidgetTester tester) async {
    final router = createRouterWithoutAuth();
    await tester.pumpWidget(MyApp(router: router));
    expect(find.byType(MyApp), findsOneWidget);
  });
}
