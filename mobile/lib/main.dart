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
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF5F7FA), // Clean, light background
        colorScheme: ColorScheme.fromSeed(
          brightness: Brightness.light,
          seedColor: const Color(0xFF22C55E), // Modern vibrant green
          primary: const Color(0xFF22C55E),
          secondary: const Color(0xFF10B981),
          surface: Colors.white,
          onSurface: const Color(0xFF111827),
        ),
        fontFamily: 'Inter',
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w800, color: Color(0xFF111827)),
          displayMedium: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w800, color: Color(0xFF111827)),
          displaySmall: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w800, color: Color(0xFF111827)),
          headlineLarge: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w700, color: Color(0xFF111827)),
          headlineMedium: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w700, color: Color(0xFF111827)),
          titleLarge: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold, color: Color(0xFF111827)),
          bodyLarge: TextStyle(color: Color(0xFF374151)),
          bodyMedium: TextStyle(color: Color(0xFF4B5563)),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF3F4F6),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF22C55E), width: 2),
          ),
          labelStyle: const TextStyle(
            color: Color(0xFF6B7280),
            fontWeight: FontWeight.w500,
          ),
          hintStyle: const TextStyle(
            color: Color(0xFF9CA3AF),
          ),
        ),
      ),
      home: isLoggedIn ? const DashboardScreen() : const LoginScreen(),
    );
  }
}
