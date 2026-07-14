import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isLoading = false;
  String _errorMessage = '';
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin(String username, String password) async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final result = await AuthService.login(username, password);

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      if (result['success']) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
        );
      } else {
        setState(() {
          _errorMessage = result['error'] ?? 'Connexion échouée';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Stack(
        children: [
          // Dark Wavy Custom Painter Background
          Positioned.fill(
            child: CustomPaint(
              painter: WavePainter(),
            ),
          ),
          
          // Content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Premium Logo Icon
                    Center(
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1E1E),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
                              blurRadius: 30,
                              offset: const Offset(0, 10),
                            )
                          ],
                          border: Border.all(color: const Color(0xFF2A2A2A)),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.receipt_long_rounded,
                            size: 40,
                            color: Color(0xFF8B5CF6), // Neon Purple
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'SecureInvoice AI',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        fontFamily: 'Outfit',
                      ),
                    ),
                    const Text(
                      'Capture & Gestion intelligente de factures',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFFA1A1AA),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 40),
                    
                    // Glassmorphic Card Login Form
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E1E).withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.05),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'Connexion',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                fontFamily: 'Outfit',
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 20),
                            
                            // Username
                            TextFormField(
                              controller: _usernameController,
                              style: const TextStyle(color: Colors.white),
                              decoration: const InputDecoration(
                                labelText: 'Identifiant',
                                hintText: 'Entrez votre identifiant',
                                prefixIcon: Icon(Icons.person_outline, color: Color(0xFFA1A1AA)),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Veuillez saisir votre identifiant';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            
                            // Password
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: 'Mot de passe',
                                hintText: 'Entrez votre mot de passe',
                                prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFFA1A1AA)),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                    color: const Color(0xFFA1A1AA),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Veuillez saisir votre mot de passe';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),
                            
                            // Error banner
                            if (_errorMessage.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.all(10),
                                margin: const EdgeInsets.only(bottom: 16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF3F1919),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: const Color(0xFFEF4444)),
                                ),
                                child: Text(
                                  _errorMessage,
                                  style: const TextStyle(
                                    color: Color(0xFFFCA5A5),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            
                            // Submit Button
                            ElevatedButton(
                              onPressed: _isLoading ? null : () {
                                if (_formKey.currentState!.validate()) {
                                  _handleLogin(
                                    _usernameController.text,
                                    _passwordController.text,
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF8B5CF6),
                                foregroundColor: Colors.white,
                                shadowColor: const Color(0xFF8B5CF6).withValues(alpha: 0.4),
                                elevation: 8,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      'Se connecter',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // Demo Credentials Helper Panel
                    const Text(
                      'Comptes de Démo :',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFFA1A1AA),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildQuickLoginButton('Client', 'client@demo.com', 'client123'),
                        _buildQuickLoginButton('Comptable', 'comptable@demo.com', 'comptable123'),
                        _buildQuickLoginButton('Admin', 'admin@demo.com', 'admin123'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickLoginButton(String label, String username, String password) {
    return ActionChip(
      backgroundColor: const Color(0xFF2A2A2A),
      side: const BorderSide(color: Color(0xFF3A3A3A)),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      label: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          color: Color(0xFFD8B4FE),
          fontWeight: FontWeight.w700,
        ),
      ),
      onPressed: () {
        _usernameController.text = username;
        _passwordController.text = password;
        _handleLogin(username, password);
      },
    );
  }
}

// Background painter representing dark wavy lines
class WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1E1E1E).withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, size.height * 0.7)
      ..quadraticBezierTo(
        size.width * 0.25,
        size.height * 0.75,
        size.width * 0.5,
        size.height * 0.7,
      )
      ..quadraticBezierTo(
        size.width * 0.75,
        size.height * 0.65,
        size.width,
        size.height * 0.72,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, paint);

    final secondaryPaint = Paint()
      ..color = const Color(0xFF8B5CF6).withValues(alpha: 0.05)
      ..style = PaintingStyle.fill;

    final secondaryPath = Path()
      ..moveTo(0, size.height * 0.4)
      ..quadraticBezierTo(
        size.width * 0.3,
        size.height * 0.45,
        size.width * 0.6,
        size.height * 0.38,
      )
      ..quadraticBezierTo(
        size.width * 0.85,
        size.height * 0.32,
        size.width,
        size.height * 0.42,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(secondaryPath, secondaryPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

