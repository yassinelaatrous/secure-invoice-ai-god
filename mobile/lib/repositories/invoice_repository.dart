import '../models/invoice.dart';

abstract class InvoiceRepository {
  Future<List<Invoice>> getInvoices();
  Future<Invoice> getInvoiceDetails(int id);
  Future<Map<String, dynamic>> uploadInvoice(String filePath);
  Future<Invoice> createFacture(Map<String, dynamic> factureData);
  Future<void> updateInvoiceStatus(int id, String status);
  Future<Map<String, dynamic>> getDashboardStats();
}
