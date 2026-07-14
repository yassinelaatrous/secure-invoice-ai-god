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
        scaffoldBackgroundColor: const Color(0xFFF5F4F0), // Warm Cream background
        colorScheme: ColorScheme.fromSeed(
          brightness: Brightness.light,
          seedColor: const Color(0xFF14251F), // Deep Forest Green
          primary: const Color(0xFF14251F),
          secondary: const Color(0xFFD2FA5A), // Electric Lime Green
          surface: const Color(0xFFFCFBF9), // Lighter Warm Cream Card
          onSurface: const Color(0xFF14251F), // Ink text
        ),
        fontFamily: 'Inter',
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w800, color: Color(0xFF14251F)),
          displayMedium: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w800, color: Color(0xFF14251F)),
          displaySmall: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w800, color: Color(0xFF14251F)),
          headlineLarge: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w700, color: Color(0xFF14251F)),
          headlineMedium: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w700, color: Color(0xFF14251F)),
          titleLarge: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold, color: Color(0xFF14251F)),
          bodyLarge: TextStyle(color: Color(0xFF455550)),
          bodyMedium: TextStyle(color: Color(0xFF455550)),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFEBEAE5), // Secondary cream gray fill
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: const Color(0xFF14251F).withOpacity(0.12), width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: const Color(0xFF14251F).withOpacity(0.12), width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF14251F), width: 2),
          ),
          labelStyle: const TextStyle(
            color: Color(0xFF455550),
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
