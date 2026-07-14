import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _showEmailForm = false;
  bool _obscurePassword = true;
  String _errorMessage = '';

  late AnimationController _floatController;
  late AnimationController _entranceController;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideUp;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeIn = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOutCubic,
    );
    _slideUp = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: Curves.easeOutCubic,
          ),
        );

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _entranceController.forward();
    });
  }

  @override
  void dispose() {
    _floatController.dispose();
    _entranceController.dispose();
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

  void _showServerConfigDialog() {
    final controller = TextEditingController(text: AuthService.baseUrl);
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: AppTheme.backgroundLight,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Configuration Serveur API',
                  style: GoogleFonts.fraunces(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Si l\'adresse par défaut (10.0.2.2) ne fonctionne pas, entrez l\'adresse IP locale de votre machine (ex: http://192.168.1.50:8000/api).',
                  style: GoogleFonts.dmSans(fontSize: 12, color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  style: GoogleFonts.dmSans(color: AppTheme.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'Adresse du serveur',
                    labelStyle: GoogleFonts.dmSans(color: AppTheme.textSecondary),
                    filled: true,
                    fillColor: AppTheme.surfaceCard,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppTheme.cardBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppTheme.cardBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: Text('Annuler', style: GoogleFonts.dmSans(color: AppTheme.error)),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        AuthService.setBaseUrl(controller.text);
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: AppTheme.primary,
                            content: Text(
                              'Serveur configuré : ${AuthService.baseUrl}',
                              style: GoogleFonts.dmSans(color: Colors.white),
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text('Enregistrer', style: GoogleFonts.dmSans(fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F0EB),
      body: Stack(
        children: [
          // Floating invoice icons scattered around
          ..._buildFloatingIcons(size),

          // Server configuration settings button
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            right: 16,
            child: GestureDetector(
              onTap: _showServerConfigDialog,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(color: AppTheme.cardBorder),
                ),
                child: const Center(
                  child: Icon(
                    Icons.settings_outlined,
                    color: AppTheme.primary,
                    size: 22,
                  ),
                ),
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: FadeTransition(
              opacity: _fadeIn,
              child: SlideTransition(
                position: _slideUp,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const Spacer(flex: 2),
                      _buildLogo(),
                      const SizedBox(height: 12),
                      _buildTagline(),
                      const Spacer(flex: 2),
                      _showEmailForm ? _buildEmailForm() : _buildLoginButtons(),
                      const Spacer(flex: 1),
                      _buildFooter(),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildFloatingIcons(Size size) {
    final icons = [
      _FloatingIconData(
        icon: Icons.receipt_long_outlined,
        x: 0.08,
        y: 0.08,
        size: 52,
        delay: 0.0,
      ),
      _FloatingIconData(
        icon: Icons.qr_code_scanner_outlined,
        x: 0.78,
        y: 0.06,
        size: 44,
        delay: 0.5,
      ),
      _FloatingIconData(
        icon: Icons.verified_outlined,
        x: 0.85,
        y: 0.22,
        size: 38,
        delay: 1.0,
      ),
      _FloatingIconData(
        icon: Icons.account_balance_outlined,
        x: 0.05,
        y: 0.28,
        size: 40,
        delay: 1.5,
      ),
      _FloatingIconData(
        icon: Icons.auto_awesome_outlined,
        x: 0.72,
        y: 0.38,
        size: 36,
        delay: 0.8,
      ),
      _FloatingIconData(
        icon: Icons.shield_outlined,
        x: 0.12,
        y: 0.42,
        size: 34,
        delay: 0.3,
      ),
      _FloatingIconData(
        icon: Icons.bar_chart_outlined,
        x: 0.80,
        y: 0.55,
        size: 42,
        delay: 1.2,
      ),
      _FloatingIconData(
        icon: Icons.attach_money_outlined,
        x: 0.06,
        y: 0.60,
        size: 38,
        delay: 0.7,
      ),
    ];

    return icons.map((data) {
      return AnimatedBuilder(
        animation: _floatController,
        builder: (context, child) {
          final offset =
              math.sin((_floatController.value + data.delay) * math.pi) * 6.0;
          return Positioned(
            left: data.x * size.width,
            top: data.y * size.height + offset,
            child: Container(
              width: data.size,
              height: data.size,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(data.size * 0.28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  data.icon,
                  size: data.size * 0.45,
                  color: AppTheme.primary,
                ),
              ),
            ),
          );
        },
      );
    }).toList();
  }

  Widget _buildLogo() {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: AppTheme.primary,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: Text(
              'C',
              style: GoogleFonts.fraunces(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: AppTheme.accent,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'CEO IT',
          style: GoogleFonts.fraunces(
            fontSize: 34,
            fontWeight: FontWeight.w700,
            color: AppTheme.primary,
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'SECURE · INVOICE · AI',
          style: GoogleFonts.dmSans(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: AppTheme.textMuted,
            letterSpacing: 2.0,
          ),
        ),
      ],
    );
  }

  Widget _buildTagline() {
    return Text(
      'Smart invoice management\nfor modern finance teams.',
      textAlign: TextAlign.center,
      style: GoogleFonts.dmSans(
        fontSize: 15,
        color: AppTheme.textSecondary,
        height: 1.5,
      ),
    );
  }

  Widget _buildLoginButtons() {
    return Column(
      children: [
        // Email login - primary filled
        _PillButton(
          onTap: () {
            setState(() {
              _showEmailForm = true;
            });
          },
          backgroundColor: AppTheme.primary,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.email_outlined,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 10),
              Text(
                'Continue with Email',
                style: GoogleFonts.dmSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Google login - outlined
        _PillButton(
          onTap: () => _handleLogin('client@demo.com', 'client123'),
          backgroundColor: Colors.white,
          border: Border.all(color: AppTheme.cardBorder, width: 1.5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(shape: BoxShape.circle),
                child: const Center(
                  child: Text(
                    'G',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF4285F4),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Continue with Google',
                style: GoogleFonts.dmSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Apple login - outlined
        _PillButton(
          onTap: () => _handleLogin('comptable@demo.com', 'comptable123'),
          backgroundColor: Colors.white,
          border: Border.all(color: AppTheme.cardBorder, width: 1.5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.apple, color: AppTheme.textPrimary, size: 22),
              const SizedBox(width: 10),
              Text(
                'Continue with Apple',
                style: GoogleFonts.dmSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmailForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _usernameController,
            style: const TextStyle(color: AppTheme.textPrimary, fontSize: 15),
            decoration: const InputDecoration(
              labelText: 'Email Address',
              hintText: 'name@example.com',
              prefixIcon: Icon(Icons.mail_outline_rounded, size: 20, color: AppTheme.textSecondary),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your email';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            style: const TextStyle(color: AppTheme.textPrimary, fontSize: 15),
            decoration: InputDecoration(
              labelText: 'Password',
              hintText: 'Enter password',
              prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20, color: AppTheme.textSecondary),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  color: AppTheme.textSecondary,
                  size: 20,
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
                return 'Please enter your password';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          if (_errorMessage.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                _errorMessage,
                style: const TextStyle(color: AppTheme.error, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          _isLoading
              ? Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: const Center(
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    ),
                  ),
                )
              : _PillButton(
                  onTap: () {
                    if (_formKey.currentState!.validate()) {
                      _handleLogin(_usernameController.text, _passwordController.text);
                    }
                  },
                  backgroundColor: AppTheme.primary,
                  child: Center(
                    child: Text(
                      'Sign in',
                      style: GoogleFonts.dmSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
          const SizedBox(height: 12),
          
          // Row of quick dev logins
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () {
                    _usernameController.text = 'client@demo.com';
                    _passwordController.text = 'client123';
                    _handleLogin('client@demo.com', 'client123');
                  },
                  child: Text('Client', style: GoogleFonts.dmSans(fontSize: 12, color: AppTheme.textSecondary, fontWeight: FontWeight.bold)),
                ),
              ),
              Expanded(
                child: TextButton(
                  onPressed: () {
                    _usernameController.text = 'comptable@demo.com';
                    _passwordController.text = 'comptable123';
                    _handleLogin('comptable@demo.com', 'comptable123');
                  },
                  child: Text('Comptable', style: GoogleFonts.dmSans(fontSize: 12, color: AppTheme.textSecondary, fontWeight: FontWeight.bold)),
                ),
              ),
              Expanded(
                child: TextButton(
                  onPressed: () {
                    _usernameController.text = 'admin@demo.com';
                    _passwordController.text = 'admin123';
                    _handleLogin('admin@demo.com', 'admin123');
                  },
                  child: Text('Admin', style: GoogleFonts.dmSans(fontSize: 12, color: AppTheme.textSecondary, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
          
          // Back button
          TextButton(
            onPressed: () {
              setState(() {
                _showEmailForm = false;
                _errorMessage = '';
              });
            },
            child: Text(
              'Back to other options',
              style: GoogleFonts.dmSans(
                fontSize: 13,
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Text(
      'By continuing, you agree to our Terms of Service\nand Privacy Policy.',
      textAlign: TextAlign.center,
      style: GoogleFonts.dmSans(
        fontSize: 11,
        color: AppTheme.textMuted,
        height: 1.5,
      ),
    );
  }
}

class _PillButton extends StatelessWidget {
  final VoidCallback onTap;
  final Color backgroundColor;
  final Widget child;
  final BoxBorder? border;

  const _PillButton({
    required this.onTap,
    required this.backgroundColor,
    required this.child,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(28),
          border: border,
          boxShadow: backgroundColor == Colors.white
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: child,
      ),
    );
  }
}

class _FloatingIconData {
  final IconData icon;
  final double x;
  final double y;
  final double size;
  final double delay;

  const _FloatingIconData({
    required this.icon,
    required this.x,
    required this.y,
    required this.size,
    required this.delay,
  });
}

