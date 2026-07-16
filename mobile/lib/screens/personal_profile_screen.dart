import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'notification_screen.dart';

class PersonalProfileScreen extends StatefulWidget {
  const PersonalProfileScreen({Key? key}) : super(key: key);

  @override
  State<PersonalProfileScreen> createState() => _PersonalProfileScreenState();
}

class _PersonalProfileScreenState extends State<PersonalProfileScreen> {
  Map<String, dynamic>? _user;
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  void _loadUser() async {
    final user = await AuthService.getUserInfo();
    setState(() {
      _user = user;
    });
  }

  void _logout() async {
    await AuthService.logout();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final String role = _user != null ? _user!['role'] ?? 'client' : 'client';
    final String name = _user != null ? _user!['nom'] ?? 'Demo User' : 'Demo User';
    final String email = _user != null ? _user!['email'] ?? 'user@demo.com' : 'user@demo.com';

    String displayRole = 'Client Partner';
    IconData roleIcon = Icons.person;
    if (role == 'accountant' || role == 'comptable') {
      displayRole = 'Certified Accountant';
      roleIcon = Icons.account_balance_wallet_rounded;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFCF9F6), // bg-background (cream)
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Custom Top App Bar (Stitch style)
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFE5E2DF),
                      image: DecorationImage(
                        image: NetworkImage(
                          'https://lh3.googleusercontent.com/aida-public/AB6AXuCHer2fd8fIdpC7E46qINZ7zGThzIJaI_HHIoWRrwKb9mGbEVG7bnHZZU4qIyS_pLKUljhePnYl1ZIFKxoMhK8hBZ2wK7Mri3ihQSzwdXd_izZVcZv2xS5HYzRa-Tr6LYvJNLrlQXHeP2_CWJFqvTgZ_vS7G8yh1skVS9UB5NCUY1gQMPzakPlHiWNd4lHHjGY_3aDgl12LM6km7KBp7kFATPw8HcJVUTQ4LEt836cLEfloxfLyixvigsDLRjYmJUbdTDT1kPBdGxFE',
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'CEO-IT',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF012D1D),
                      letterSpacing: -0.01 * 20,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.notifications_none_rounded, color: Color(0xFF414844)),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const NotificationScreen()),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Profile Card Header
              Center(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF012D1D), // primary (forest green)
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            name.isNotEmpty ? name.substring(0, 1).toUpperCase() : 'U',
                            style: GoogleFonts.fraunces(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFFB8F04A), // lime green accent
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Color(0xFFB8F04A),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(roleIcon, size: 16, color: const Color(0xFF012D1D)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      name,
                      style: GoogleFonts.fraunces(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1C1C1A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      displayRole,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF414844),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Account settings card
              Text(
                'Account Settings',
                style: GoogleFonts.fraunces(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF012D1D),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE5E2DF), width: 1.2),
                ),
                child: Column(
                  children: [
                    _buildSettingsTile(
                      icon: Icons.alternate_email_rounded,
                      title: 'Email Address',
                      subtitle: email,
                    ),
                    const Divider(color: Color(0xFFE5E2DF), height: 1),
                    _buildSwitchTile(
                      icon: Icons.notifications_active_outlined,
                      title: 'Push Notifications',
                      subtitle: 'Alerts for secure transactions',
                      value: _notificationsEnabled,
                      onChanged: (val) => setState(() => _notificationsEnabled = val),
                    ),
                    const Divider(color: Color(0xFFE5E2DF), height: 1),
                    _buildSettingsTile(
                      icon: Icons.security_rounded,
                      title: 'Data Privacy & Security',
                      subtitle: 'End-to-end encryption active',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Sandbox Role Simulations (Subtle developer switchers, kept clean!)
              Text(
                'Sandbox Options',
                style: GoogleFonts.fraunces(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF012D1D),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildRoleSimulationButton('Client', active: role == 'client'),
                  const SizedBox(width: 8),
                  _buildRoleSimulationButton('Accountant', active: role == 'accountant' || role == 'comptable'),
                  const SizedBox(width: 8),
                  _buildRoleSimulationButton('Admin', active: role == 'admin'),
                ],
              ),
              const SizedBox(height: 40),

              // Logout Button
              ElevatedButton(
                onPressed: _logout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFBA1A1A), // error red
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Log Out',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF414844), size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1C1C1A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: const Color(0xFF414844),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF414844), size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1C1C1A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: const Color(0xFF414844),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF012D1D),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleSimulationButton(String label, {required bool active}) {
    return Expanded(
      child: InkWell(
        onTap: () async {
          if (active) return;
          final targetRole = label == 'Accountant' ? 'accountant' : label.toLowerCase();
          
          // Mimic simulation reload
          final current = await AuthService.getUserInfo();
          if (current != null) {
            await AuthService.logout();
            await AuthService.login(targetRole, 'sandbox');
          }
          if (mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
            );
          }
        },
        child: Container(
          height: 38,
          decoration: BoxDecoration(
            color: active ? const Color(0xFF012D1D) : const Color(0xFFF0EDE9),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: active ? Colors.transparent : const Color(0xFFE5E2DF),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: active ? Colors.white : const Color(0xFF414844),
            ),
          ),
        ),
      ),
    );
  }
}
