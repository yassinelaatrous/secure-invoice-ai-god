import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
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
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4F46E5), // Indigo Accent
          primary: const Color(0xFF4F46E5),
          secondary: const Color(0xFF8B5CF6),
          background: const Color(0xFFEAEAEE),
        ),
        fontFamily: 'Inter', // Default fallback font
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w800),
          displayMedium: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w800),
          displaySmall: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w800),
          headlineLarge: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w700),
          headlineMedium: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w700),
          titleLarge: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          focusColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE5E5EB)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 2),
          ),
          labelStyle: const TextStyle(
            color: Color(0xFF5F6168),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      home: isLoggedIn ? const DashboardScreen() : const LoginScreen(),
    );
  }
}
