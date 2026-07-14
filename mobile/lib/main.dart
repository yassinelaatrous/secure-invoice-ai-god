import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'services/auth_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Auto-discover the active backend server IP address
  await AuthService.discoverBaseUrl();
  
  // Check if session token is already stored in shared preferences
  final bool loggedIn = await AuthService.isLoggedIn();
  
  runApp(SecureInvoiceApp(isLoggedIn: loggedIn));
}

class SecureInvoiceApp extends StatelessWidget {
  final bool isLoggedIn;

  const SecureInvoiceApp({Key? key, required this.isLoggedIn}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SecureInvoice AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: isLoggedIn ? const DashboardScreen() : const LoginScreen(),
    );
  }
}
