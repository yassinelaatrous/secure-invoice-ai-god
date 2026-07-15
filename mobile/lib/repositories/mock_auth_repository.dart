import 'auth_repository.dart';

class MockAuthRepository implements AuthRepository {
  String _baseUrl = 'http://offline-mock.local';
  Map<String, dynamic>? _currentUser;
  String? _token;

  @override
  String get baseUrl => _baseUrl;

  @override
  Future<void> setBaseUrl(String url) async {
    _baseUrl = url;
  }

  @override
  Future<void> discoverBaseUrl() async {
    print('[OFFLINE MOCK] Auto-discovery bypassed. App is running in standalone sandbox mode.');
  }

  @override
  Future<Map<String, dynamic>> login(String username, String password) async {
    await Future.delayed(const Duration(milliseconds: 600)); // Artificial latency for realism
    
    final normalizedUser = username.trim().toLowerCase();
    if (normalizedUser == 'admin@demo.com' || 
        normalizedUser == 'comptable@demo.com' || 
        normalizedUser == 'client@demo.com') {
      
      String role = 'client';
      if (normalizedUser.startsWith('admin')) role = 'admin';
      if (normalizedUser.startsWith('comptable')) role = 'comptable';

      _currentUser = {
        'email': normalizedUser,
        'nom': normalizedUser.split('@')[0].toUpperCase(),
        'role': role,
      };
      _token = 'mock_jwt_token_for_$role';
      
      return {'success': true, 'user': _currentUser};
    } else {
      return {
        'success': false, 
        'error': 'Identifiants de démonstration incorrects. Utilisez admin@demo.com, comptable@demo.com ou client@demo.com'
      };
    }
  }

  @override
  Future<void> logout() async {
    _currentUser = null;
    _token = null;
  }

  @override
  Future<String?> getToken() async {
    return _token;
  }

  @override
  Future<Map<String, dynamic>?> getUserInfo() async {
    return _currentUser;
  }

  @override
  Future<bool> isLoggedIn() async {
    return _token != null;
  }

  @override
  Future<Map<String, String>> getAuthHeaders() async {
    return {
      'Content-Type': 'application/json',
      if (_token != null) 'Authorization': 'Bearer $_token',
    };
  }
}
