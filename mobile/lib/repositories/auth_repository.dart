abstract class AuthRepository {
  Future<Map<String, dynamic>> login(String username, String password);
  Future<void> logout();
  Future<String?> getToken();
  Future<Map<String, dynamic>?> getUserInfo();
  Future<bool> isLoggedIn();
  Future<Map<String, String>> getAuthHeaders();
  Future<void> discoverBaseUrl();
  String get baseUrl;
  Future<void> setBaseUrl(String url);
}
