import '../models/invoice.dart';
import '../services/api_service.dart';
import 'invoice_repository.dart';

class HttpInvoiceRepository implements InvoiceRepository {
  @override
  Future<List<Invoice>> getInvoices() => ApiService.getInvoices();

  @override
  Future<Invoice> getInvoiceDetails(int id) => ApiService.getInvoiceDetails(id);

  @override
  Future<Map<String, dynamic>> uploadInvoice(String filePath) =>
      ApiService.uploadInvoice(filePath);

  @override
  Future<Invoice> createFacture(Map<String, dynamic> factureData) =>
      ApiService.createFacture(factureData);

  @override
  Future<void> updateInvoiceStatus(int id, String status) =>
      ApiService.updateInvoiceStatus(id, status);

  @override
  Future<Map<String, dynamic>> getDashboardStats() =>
      ApiService.getDashboardStats();
}
