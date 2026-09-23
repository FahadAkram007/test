import 'package:flutter_test/flutter_test.dart';
import 'package:kollektivo/main.dart';

void main() {
  testWidgets('KollektivO app login smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const KollektivoApp());
    await tester.pump();

    expect(find.text('Welcome to KollektivO'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
  });
}
