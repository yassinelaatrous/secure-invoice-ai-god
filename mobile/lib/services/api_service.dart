import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/invoice.dart';
import 'auth_service.dart';

class ApiService {
  // Get invoices list
  static Future<List<Invoice>> getInvoices() async {
    try {
      final headers = await AuthService.getAuthHeaders();
      final response = await http.get(
        Uri.parse('${AuthService.baseUrl}/invoices'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Invoice.fromJson(json)).toList();
      } else {
        throw Exception('Erreur lors du chargement des factures (Code ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Erreur réseau : $e');
    }
  }

  // Get invoice details by id
  static Future<Invoice> getInvoiceDetails(int id) async {
    try {
      final headers = await AuthService.getAuthHeaders();
      final response = await http.get(
        Uri.parse('${AuthService.baseUrl}/invoices/$id'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return Invoice.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Facture introuvable (Code ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Erreur réseau : $e');
    }
  }

  // Upload an invoice file/image and parse via OCR
  static Future<Invoice> uploadInvoice(String filePath, {bool isMock = false}) async {
    try {
      final token = await AuthService.getToken();
      final uri = Uri.parse('${AuthService.baseUrl}/invoices/upload');
      
      final request = http.MultipartRequest('POST', uri);
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      request.files.add(await http.MultipartFile.fromPath('file', filePath));
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Invoice.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Erreur lors du traitement OCR de la facture (Code ${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      throw Exception('Erreur de transmission : $e');
    }
  }

  // Update invoice fields
  static Future<Invoice> updateInvoice(int id, Map<String, dynamic> fields) async {
    try {
      final headers = await AuthService.getAuthHeaders();
      final response = await http.put(
        Uri.parse('${AuthService.baseUrl}/invoices/$id'),
        headers: headers,
        body: jsonEncode(fields),
      );

      if (response.statusCode == 200) {
        return Invoice.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Erreur de mise à jour (Code ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Erreur réseau : $e');
    }
  }

  // Change invoice status (valider/rejeter/archiver)
  static Future<Invoice> updateInvoiceStatus(int id, String status, {String? comment}) async {
    try {
      final headers = await AuthService.getAuthHeaders();
      final response = await http.patch(
        Uri.parse('${AuthService.baseUrl}/invoices/$id/status'),
        headers: headers,
        body: jsonEncode({
          'statut': status,
          if (comment != null) 'commentaire': comment,
        }),
      );

      if (response.statusCode == 200) {
        return Invoice.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Erreur lors du changement de statut (Code ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Erreur de requête : $e');
    }
  }

  // Get KPI dashboard metrics
  static Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final headers = await AuthService.getAuthHeaders();
      final response = await http.get(
        Uri.parse('${AuthService.baseUrl}/dashboard/stats'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Erreur de statistiques (Code ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Erreur de connexion : $e');
    }
  }
}
