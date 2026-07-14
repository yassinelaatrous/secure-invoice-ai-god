import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _user;
  final _serverUrlController = TextEditingController();
  
  bool _isEditingServer = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _serverUrlController.text = AuthService.baseUrl;
  }

  @override
  void dispose() {
    _serverUrlController.dispose();
    super.dispose();
  }

  void _loadUser() async {
    final user = await AuthService.getUserInfo();
    setState(() {
      _user = user;
    });
  }

  void _saveServerUrl() {
    AuthService.setBaseUrl(_serverUrlController.text);
    setState(() {
      _isEditingServer = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppTheme.primary,
        content: Text('URL du serveur configurée : ${AuthService.baseUrl}', style: GoogleFonts.dmSans(color: Colors.white)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String fullName = _user != null ? _user!['nom'] ?? 'Utilisateur' : 'Utilisateur';
    final String username = _user != null ? _user!['email'] ?? '' : '';
    final String email = _user != null ? _user!['email'] ?? '' : '';
    final String role = _user != null ? _user!['role'] ?? 'client' : 'client';
    
    String roleLabel = 'Client';
    IconData roleIcon = Icons.person_rounded;
    if (role == 'comptable') {
      roleLabel = 'Comptable / Collaborateur';
      roleIcon = Icons.work_outline_rounded;
    } else if (role == 'admin') {
      roleLabel = 'Administrateur';
      roleIcon = Icons.admin_panel_settings_outlined;
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: Text('Mon Profil', style: GoogleFonts.dmSans(fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
        backgroundColor: AppTheme.backgroundLight,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Avatar card
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.6),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.cardBorder),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: const BoxDecoration(
                      color: AppTheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        fullName.substring(0, 1).toUpperCase(),
                        style: GoogleFonts.fraunces(
                          color: AppTheme.accent,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    fullName,
                    style: GoogleFonts.dmSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '@$username',
                    style: GoogleFonts.dmSans(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.accent.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(roleIcon, size: 14, color: AppTheme.primary),
                        const SizedBox(width: 6),
                        Text(
                          roleLabel,
                          style: GoogleFonts.dmSans(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            // Detail Settings Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.6),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.cardBorder),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Informations Générales',
                    style: GoogleFonts.fraunces(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const Divider(height: 24, color: AppTheme.cardBorder),
                  _buildProfileRow('E-mail', email.isNotEmpty ? email : 'Non renseigné'),
                  const SizedBox(height: 12),
                  _buildProfileRow('Identifiant', username),
                  const SizedBox(height: 12),
                  _buildProfileRow('Rôle', roleLabel),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Server Settings Card (Important for local mobile testing)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.6),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.cardBorder),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Configuration Serveur API',
                        style: GoogleFonts.fraunces(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      if (!_isEditingServer)
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 18, color: AppTheme.primary),
                          onPressed: () {
                            setState(() {
                              _isEditingServer = true;
                            });
                          },
                        ),
                    ],
                  ),
                  const Divider(height: 16, color: AppTheme.cardBorder),
                  if (_isEditingServer) ...[
                    TextField(
                      controller: _serverUrlController,
                      style: GoogleFonts.dmSans(color: AppTheme.textPrimary),
                      decoration: InputDecoration(
                        labelText: 'Adresse IP du serveur API',
                        labelStyle: GoogleFonts.dmSans(color: AppTheme.textSecondary),
                        hintText: 'ex: http://192.168.1.50:8000/api',
                        hintStyle: GoogleFonts.dmSans(color: AppTheme.textMuted),
                        fillColor: AppTheme.surfaceCard,
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppTheme.cardBorder),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppTheme.cardBorder),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _isEditingServer = false;
                              _serverUrlController.text = AuthService.baseUrl;
                            });
                          },
                          child: Text('Annuler', style: GoogleFonts.dmSans(color: AppTheme.error)),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _saveServerUrl,
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
                  ] else ...[
                    Text(
                      AuthService.baseUrl,
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Indiquez l\'adresse IP locale du serveur uvicorn de votre ordinateur pour tester l\'application sur appareil réel.',
                      style: GoogleFonts.dmSans(
                        color: AppTheme.textMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Logout action button
            ElevatedButton.icon(
              onPressed: () async {
                await AuthService.logout();
                if (mounted) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  );
                }
              },
              icon: const Icon(Icons.logout_rounded),
              label: Text('Se déconnecter', style: GoogleFonts.dmSans(fontWeight: FontWeight.w700)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.error,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.dmSans(
            color: AppTheme.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.dmSans(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }
}
