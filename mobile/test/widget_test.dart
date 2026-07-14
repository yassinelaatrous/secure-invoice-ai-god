import 'package:flutter_test/flutter_test.dart';
import 'package:secure_invoice_mobile/main.dart';

void main() {
  testWidgets('App smoke test - LoginScreen loads', (WidgetTester tester) async {
    await tester.pumpWidget(const SecureInvoiceApp(isLoggedIn: false));
    await tester.pump(const Duration(milliseconds: 200));

    // Verify login screen renders
    expect(find.text('Ledger'), findsOneWidget);
    expect(find.text('Continue with Email'), findsOneWidget);
  });
}
