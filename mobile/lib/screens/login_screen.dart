import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _mfaEnabled = false;
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin(String role) async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    // In a real app we'd validate credentials. Here we just use the selected sandbox role.
    // We'll update the AuthService to accept a role in the next step, for now just pass role as username.
    final result = await AuthService.login(role.toLowerCase(), 'password');

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
          _errorMessage = result['error'] ?? 'Login failed';
        });
      }
    }
  }

  Widget _buildLeftPanel() {
    return Container(
      width: double.infinity,
      color: AppTheme.surfaceCard, // surface-cream-dark
      padding: const EdgeInsets.all(48),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.stacked_bar_chart, color: AppTheme.primary, size: 32),
                  const SizedBox(width: 8),
                  Text('CEO-IT', style: AppTheme.headlineLarge.copyWith(color: AppTheme.primary)),
                ],
              ),
              const SizedBox(height: 32),
              Text(
                'Secure, intelligent invoice management for modern executives.',
                style: AppTheme.headlineMedium.copyWith(color: AppTheme.textSecondary),
              ),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            child: Row(
              children: [
                Icon(Icons.verified, size: 16, color: AppTheme.textSecondary),
                const SizedBox(width: 4),
                Text('ISO 27001 Certified', style: AppTheme.labelMedium.copyWith(color: AppTheme.textSecondary)),
                const SizedBox(width: 16),
                Icon(Icons.lock, size: 16, color: AppTheme.textSecondary),
                const SizedBox(width: 4),
                Text('End-to-End Encryption', style: AppTheme.labelMedium.copyWith(color: AppTheme.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRightPanel() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Mobile Header
              if (MediaQuery.of(context).size.width < 800) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.stacked_bar_chart, color: AppTheme.primary, size: 32),
                    const SizedBox(width: 8),
                    Text('CEO-IT', style: AppTheme.headlineLarge.copyWith(color: AppTheme.primary)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Secure Executive Platform',
                  textAlign: TextAlign.center,
                  style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 32),
              ],

              Text('Welcome back', style: AppTheme.headlineMedium.copyWith(color: AppTheme.textPrimary)),
              const SizedBox(height: 8),
              Text(
                'Please enter your credentials to access your secure space.',
                style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 32),

              // Email Field
              Text('Email Address', style: AppTheme.labelLarge.copyWith(color: AppTheme.textPrimary)),
              const SizedBox(height: 8),
              TextField(
                controller: _emailController,
                style: AppTheme.bodyMedium.copyWith(color: AppTheme.textPrimary),
                decoration: InputDecoration(
                  hintText: 'executive@company.com',
                  hintStyle: AppTheme.bodyMedium.copyWith(color: AppTheme.textMuted),
                  prefixIcon: Icon(Icons.mail_outline, color: AppTheme.textMuted),
                  filled: true,
                  fillColor: AppTheme.backgroundLight,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppTheme.cardBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppTheme.cardBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppTheme.primary, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Password Field
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Password', style: AppTheme.labelLarge.copyWith(color: AppTheme.textPrimary)),
                  Text('Forgot password?', style: AppTheme.labelMedium.copyWith(color: AppTheme.primary)),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                style: AppTheme.bodyMedium.copyWith(color: AppTheme.textPrimary),
                decoration: InputDecoration(
                  hintText: '••••••••',
                  hintStyle: AppTheme.bodyMedium.copyWith(color: AppTheme.textMuted),
                  prefixIcon: Icon(Icons.lock_outline, color: AppTheme.textMuted),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: AppTheme.textMuted,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  filled: true,
                  fillColor: AppTheme.backgroundLight,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppTheme.cardBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppTheme.cardBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppTheme.primary, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // MFA Toggle
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceCard, // surface-cream-dark
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.cardBorder),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.shield_outlined, color: AppTheme.textPrimary, size: 20),
                        const SizedBox(width: 8),
                        Text('Multi-Factor Auth', style: AppTheme.labelLarge.copyWith(color: AppTheme.textPrimary)),
                      ],
                    ),
                    Switch(
                      value: _mfaEnabled,
                      activeColor: AppTheme.primary,
                      onChanged: (val) {
                        setState(() {
                          _mfaEnabled = val;
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              if (_errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    _errorMessage,
                    style: AppTheme.bodyMedium.copyWith(color: AppTheme.error),
                    textAlign: TextAlign.center,
                  ),
                ),

              SizedBox(
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                  onPressed: _isLoading ? null : () => _handleLogin('client'),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          'Sign In',
                          style: AppTheme.labelLarge.copyWith(color: Colors.white, fontSize: 16),
                        ),
                ),
              ),
              const SizedBox(height: 32),

              // Sandbox Access
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('SANDBOX ROLE ACCESS', style: AppTheme.labelMedium.copyWith(color: AppTheme.textMuted)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildSandboxRoleBtn('Client'),
                      const SizedBox(width: 8),
                      _buildSandboxRoleBtn('Accountant'),
                      const SizedBox(width: 8),
                      _buildSandboxRoleBtn('Admin'),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSandboxRoleBtn(String role) {
    return InkWell(
      onTap: () => _handleLogin(role),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.surfaceCard,
          border: Border.all(color: AppTheme.cardBorder),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(role, style: AppTheme.labelMedium.copyWith(color: AppTheme.textSecondary)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight, // surface container lowest
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth >= 800) {
            return Row(
              children: [
                Expanded(child: _buildLeftPanel()),
                Expanded(child: _buildRightPanel()),
              ],
            );
          }
          return _buildRightPanel();
        },
      ),
    );
  }
}
