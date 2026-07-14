import 'package:flutter_test/flutter_test.dart';
import 'package:secure_invoice_mobile/main.dart';

void main() {
  testWidgets('App smoke test - LoginScreen loads', (WidgetTester tester) async {
    await tester.pumpWidget(const SecureInvoiceApp(isLoggedIn: false));

    // Verify login screen renders
    expect(find.text('SecureInvoice AI'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
  });
}
