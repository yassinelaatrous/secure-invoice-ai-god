import '../core/service_locator.dart';
import '../models/invoice.dart';

class ApiService {
  static Future<List<Invoice>> getInvoices() => 
      locator.invoiceRepository.getInvoices();

  static Future<Invoice> getInvoiceDetails(int id) => 
      locator.invoiceRepository.getInvoiceDetails(id);

  static Future<Map<String, dynamic>> uploadInvoice(String filePath) => 
      locator.invoiceRepository.uploadInvoice(filePath);

  static Future<Invoice> createFacture(Map<String, dynamic> factureData) => 
      locator.invoiceRepository.createFacture(factureData);

  static Future<void> updateInvoiceStatus(int id, String status) => 
      locator.invoiceRepository.updateInvoiceStatus(id, status);

  static Future<Map<String, dynamic>> getDashboardStats() => 
      locator.invoiceRepository.getDashboardStats();
}
