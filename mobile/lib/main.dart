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
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        colorScheme: ColorScheme.fromSeed(
          brightness: Brightness.dark,
          seedColor: const Color(0xFF8B5CF6), // Neon Purple Accent
          primary: const Color(0xFF8B5CF6),
          secondary: const Color(0xFFD8B4FE),
          surface: const Color(0xFF1E1E1E),
          onSurface: Colors.white,
        ),
        fontFamily: 'Inter',
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w800, color: Colors.white),
          displayMedium: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w800, color: Colors.white),
          displaySmall: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w800, color: Colors.white),
          headlineLarge: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w700, color: Colors.white),
          headlineMedium: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w700, color: Colors.white),
          titleLarge: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold, color: Colors.white),
          bodyLarge: TextStyle(color: Colors.white70),
          bodyMedium: TextStyle(color: Colors.white70),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF2A2A2A),
          focusColor: const Color(0xFF2A2A2A),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF8B5CF6), width: 2),
          ),
          labelStyle: const TextStyle(
            color: Color(0xFFA1A1AA),
            fontWeight: FontWeight.w500,
          ),
          hintStyle: const TextStyle(
            color: Color(0xFFA1A1AA),
          ),
        ),
      ),
      home: isLoggedIn ? const DashboardScreen() : const LoginScreen(),
    );
  }
}
