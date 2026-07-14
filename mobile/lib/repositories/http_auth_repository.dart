import '../services/auth_service.dart';
import 'auth_repository.dart';

class HttpAuthRepository implements AuthRepository {
  @override
  String get baseUrl => AuthService.baseUrl;

  @override
  Future<void> setBaseUrl(String url) => AuthService.setBaseUrl(url);

  @override
  Future<void> discoverBaseUrl() => AuthService.discoverBaseUrl();

  @override
  Future<Map<String, dynamic>> login(String username, String password) =>
      AuthService.login(username, password);

  @override
  Future<void> logout() => AuthService.logout();

  @override
  Future<String?> getToken() => AuthService.getToken();

  @override
  Future<Map<String, dynamic>?> getUserInfo() => AuthService.getUserInfo();

  @override
  Future<bool> isLoggedIn() => AuthService.isLoggedIn();

  @override
  Future<Map<String, String>> getAuthHeaders() => AuthService.getAuthHeaders();
}
