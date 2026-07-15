import '../core/service_locator.dart';

class AuthService {
  static String get baseUrl => locator.authRepository.baseUrl;
  
  static Future<void> setBaseUrl(String url) => 
      locator.authRepository.setBaseUrl(url);
  
  static Future<void> discoverBaseUrl() => 
      locator.authRepository.discoverBaseUrl();
  
  static Future<Map<String, dynamic>> login(String username, String password) => 
      locator.authRepository.login(username, password);
  
  static Future<void> logout() => 
      locator.authRepository.logout();
  
  static Future<String?> getToken() => 
      locator.authRepository.getToken();
  
  static Future<Map<String, dynamic>?> getUserInfo() => 
      locator.authRepository.getUserInfo();
  
  static Future<bool> isLoggedIn() => 
      locator.authRepository.isLoggedIn();
  
  static Future<Map<String, String>> getAuthHeaders() => 
      locator.authRepository.getAuthHeaders();
}
