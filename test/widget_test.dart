import 'package:flutter_test/flutter_test.dart';
import 'package:mako/main.dart';

void main() {
  testWidgets('shows the discovery dashboard and main navigation', (
    tester,
  ) async {
    await tester.pumpWidget(const AnimalDiscoveryApp());

    expect(find.text('Hello, explorer.'), findsOneWidget);
    expect(find.text('Identify an animal'), findsOneWidget);
    expect(find.text('Collection'), findsOneWidget);

    await tester.tap(find.text('Collection').last);
    await tester.pumpAndSettle();
    expect(find.text('Your collection is waiting'), findsOneWidget);
  });
}
