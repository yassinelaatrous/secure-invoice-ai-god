import 'package:flutter/material.dart';
import '../services/auth_service.dart';
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
        backgroundColor: const Color(0xFF4F46E5),
        content: Text('URL du serveur configurée : ${AuthService.baseUrl}'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String fullName = _user != null ? _user!['full_name'] ?? 'Utilisateur' : 'Utilisateur';
    final String username = _user != null ? _user!['username'] ?? '' : '';
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
      backgroundColor: const Color(0xFFEAEAEE),
      appBar: AppBar(
        title: const Text('Mon Profil', style: TextStyle(fontWeight: FontWeight.w800, fontFamily: 'Outfit')),
        backgroundColor: Colors.white,
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
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE5E5EB)),
              ),
              child: Column(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: const BoxDecoration(
                      color: Color(0xFF4F46E5),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        fullName.substring(0, 1).toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    fullName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '@$username',
                    style: const TextStyle(
                      color: Color(0xFF8F9199),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F5FF),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(roleIcon, size: 14, color: const Color(0xFF4F46E5)),
                        const SizedBox(width: 6),
                        Text(
                          roleLabel,
                          style: const TextStyle(
                            color: Color(0xFF4F46E5),
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
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE5E5EB)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Informations Générales',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      fontFamily: 'Outfit',
                    ),
                  ),
                  const Divider(height: 24, color: Color(0xFFE5E5EB)),
                  _buildProfileRow('E-mail', email.isNotEmpty ? email : 'Non renseigné'),
                  const SizedBox(height: 12),
                  _buildProfileRow('Identifiant', username),
                  const SizedBox(height: 12),
                  _buildProfileRow('Organisation', 'CEO-IT Cabinet'),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Server Settings Card (Important for local mobile testing)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE5E5EB)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.between,
                    children: [
                      const Text(
                        'Configuration Serveur API',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          fontFamily: 'Outfit',
                        ),
                      ),
                      if (!_isEditingServer)
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 18, color: Color(0xFF4F46E5)),
                          onPressed: () {
                            setState(() {
                              _isEditingServer = true;
                            });
                          },
                        ),
                    ],
                  ),
                  const Divider(height: 16, color: Color(0xFFE5E5EB)),
                  if (_isEditingServer) ...[
                    TextField(
                      controller: _serverUrlController,
                      decoration: InputDecoration(
                        labelText: 'Adresse IP du serveur API',
                        hintText: 'ex: http://192.168.1.50:8000/api',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
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
                          child: const Text('Annuler', style: TextStyle(color: Colors.redAccent)),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _saveServerUrl,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4F46E5),
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Enregistrer'),
                        ),
                      ],
                    ),
                  ] else ...[
                    Text(
                      AuthService.baseUrl,
                      style: const TextStyle(
                        fontFamily: 'IBM Plex Mono',
                        fontSize: 13,
                        color: Color(0xFF5F6168),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Indiquez l\'adresse IP locale du serveur uvicorn de votre ordinateur pour tester l\'application sur appareil réel.',
                      style: TextStyle(
                        color: Color(0xFF8F9199),
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
              label: const Text('Se déconnecter'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.between,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF8F9199),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
