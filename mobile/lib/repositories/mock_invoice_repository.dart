import '../models/invoice.dart';
import 'invoice_repository.dart';

class MockInvoiceRepository implements InvoiceRepository {
  // In-memory invoice database populated with seed data from specifications
  final List<Invoice> _invoices = [
    Invoice(
      id: 1,
      numero: 'FAC-2024-0012',
      fournisseur: 'Société Générale SARL',
      dateFacture: DateTime.now().subtract(const Duration(days: 90)),
      dateReception: DateTime.now().subtract(const Duration(days: 90)),
      devise: 'TND',
      montantHt: 4000.0,
      tva: 800.0,
      montantTtc: 4800.0,
      iban: 'TN5912000000123456789012',
      statut: 'en_retard',
      fraudScore: 15.0,
      confidenceScore: 0.98,
      conformiteValide: true,
      conformiteDetails: 'Toutes les validations arithmétiques et fiscales ont été approuvées.',
      fraudeJustification: 'Faible risque. Ce fournisseur a un historique de transaction validé de plus de 12 mois.',
      fraudeAlertes: [],
    ),
    Invoice(
      id: 2,
      numero: 'FAC-2024-0011',
      fournisseur: 'Alpha Industrie',
      dateFacture: DateTime.now().subtract(const Duration(days: 85)),
      dateReception: DateTime.now().subtract(const Duration(days: 85)),
      devise: 'TND',
      montantHt: 6000.0,
      tva: 1200.0,
      montantTtc: 7200.0,
      iban: 'TN5999000000123456789099', // Incorrect IBAN (different from registered)
      statut: 'en_retard',
      fraudScore: 85.0, // High Risk!
      confidenceScore: 0.99,
      conformiteValide: true,
      conformiteDetails: 'Toutes les validations de calculs (TVA 20%) sont correctes.',
      fraudeJustification: 'Changement de coordonnées bancaires suspect : l\'IBAN figurant sur la facture ne correspond pas à l\'IBAN enregistré dans notre référentiel fournisseur.',
      fraudeAlertes: ['IBAN_MISMATCH', 'SUSPICIOUS_IBAN'],
    ),
    Invoice(
      id: 3,
      numero: 'FAC-2024-0010',
      fournisseur: 'Best Trade',
      dateFacture: DateTime.now().subtract(const Duration(days: 78)),
      dateReception: DateTime.now().subtract(const Duration(days: 78)),
      devise: 'TND',
      montantHt: 3000.0,
      tva: 500.0, // Mismatch (should be 600.0 for 20%)
      montantTtc: 3600.0,
      iban: 'TN5921000000345678901234',
      statut: 'en_retard',
      fraudScore: 35.0,
      confidenceScore: 0.95,
      conformiteValide: false, // Inconsequent Compliance!
      conformiteDetails: 'COHERENCE_TVA : Écart de calcul détecté sur la TVA. Le calcul théorique à 20% donne 600.0 TND au lieu de 500.0 TND sur la pièce.',
      fraudeJustification: 'Risque modéré dû à des incohérences de calculs financiers. Aucune tentative de fraude directe n\'a été détectée.',
      fraudeAlertes: ['ARITHMETIC_ERROR'],
    ),
    Invoice(
      id: 4,
      numero: 'FAC-2024-0009',
      fournisseur: 'Office Material',
      dateFacture: DateTime.now().subtract(const Duration(days: 55)),
      dateReception: DateTime.now().subtract(const Duration(days: 54)),
      devise: 'TND',
      montantHt: 2058.82,
      tva: 391.18,
      montantTtc: 2450.0,
      iban: 'TN5934000000567890123456',
      statut: 'validee',
      fraudScore: 5.0,
      confidenceScore: 0.97,
      conformiteValide: true,
      conformiteDetails: 'Toutes les validations arithmétiques et fiscales ont été approuvées.',
      fraudeJustification: 'Aucun comportement suspect identifié.',
      fraudeAlertes: [],
    ),
    Invoice(
      id: 5,
      numero: 'FAC-2024-0008',
      fournisseur: 'Le Bon Goût Traiteur',
      dateFacture: DateTime.now().subtract(const Duration(days: 50)),
      dateReception: DateTime.now().subtract(const Duration(days: 50)),
      devise: 'TND',
      montantHt: 1134.45,
      tva: 215.55,
      montantTtc: 1350.0,
      iban: 'TN5945000000789012345678',
      statut: 'controlee',
      fraudScore: 8.0,
      confidenceScore: 0.94,
      conformiteValide: true,
      conformiteDetails: 'Validation de conformité OK (TVA 19%).',
      fraudeJustification: 'Facture conforme. Fournisseur habituel.',
      fraudeAlertes: [],
    ),
    Invoice(
      id: 6,
      numero: 'FAC-2024-0007',
      fournisseur: 'Global Printing',
      dateFacture: DateTime.now().subtract(const Duration(days: 47)),
      dateReception: DateTime.now().subtract(const Duration(days: 47)),
      devise: 'TND',
      montantHt: 798.32,
      tva: 151.68,
      montantTtc: 950.0,
      iban: 'TN5956000000901234567890',
      statut: 'controlee',
      fraudScore: 10.0,
      confidenceScore: 0.95,
      conformiteValide: true,
      conformiteDetails: 'Facture conforme.',
      fraudeJustification: 'Facture régulière. Pas d\'anomalie détectée.',
      fraudeAlertes: [],
    ),
  ];

  @override
  Future<List<Invoice>> getInvoices() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_invoices);
  }

  @override
  Future<Invoice> getInvoiceDetails(int id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _invoices.firstWhere(
      (inv) => inv.id == id,
      orElse: () => throw Exception('Facture introuvable (ID: $id)'),
    );
  }

  @override
  Future<Map<String, dynamic>> uploadInvoice(String filePath) async {
    // Simulate Gemini API / Tesseract OCR background processing latency
    await Future.delayed(const Duration(seconds: 2));

    // Extract basic filename to make mock response feel alive
    final filename = filePath.split('/').last.split('\\').last.toUpperCase();
    
    // Return a mock parsed invoice schema matching backend OCR returns
    return {
      'id': _invoices.length + 1,
      'numero': 'FAC-2026-${1000 + _invoices.length}',
      'fournisseur': filename.contains('MEDIA') ? 'MediaPlus' : 'MEDIA PLUS SARL',
      'date_facture': DateTime.now().toIso8601String(),
      'devise': 'TND',
      'ht': 1500.0,
      'tva': 285.0, // 19%
      'ttc': 1785.0,
      'iban': 'TN5967000000123456789012',
      'statut': 'nouveau',
      'fraude_score': 12.0,
      'confidence': 0.97,
      'conformite_valide': true,
      'conformite_details': 'Tous les champs obligatoires sont extraits. Validation de cohérence TVA 19% réussie.',
      'fraude_justification': 'Faible risque détecté. L\'IBAN et le fournisseur correspondent à un tiers régulier.',
      'fraude_alertes': [],
    };
  }

  @override
  Future<Invoice> createFacture(Map<String, dynamic> factureData) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    // Read fields and insert to local in-memory DB
    final double ht = (factureData['ht'] ?? 0.0).toDouble();
    final double tva = (factureData['tva'] ?? 0.0).toDouble();
    final double ttc = (factureData['ttc'] ?? 0.0).toDouble();

    final newInvoice = Invoice(
      id: _invoices.length + 1,
      numero: factureData['numero'] ?? 'FAC-NEW',
      fournisseur: factureData['fournisseur'] ?? 'Nouveau Fournisseur',
      dateFacture: DateTime.tryParse(factureData['date_facture'] ?? '') ?? DateTime.now(),
      dateReception: DateTime.now(),
      devise: factureData['devise'] ?? 'TND',
      montantHt: ht,
      tva: tva,
      montantTtc: ttc,
      iban: factureData['iban'] ?? '',
      statut: 'nouveau',
      fraudScore: (factureData['fraude_score'] ?? 10.0).toDouble(),
      confidenceScore: (factureData['confidence'] ?? 0.95).toDouble(),
      conformiteValide: factureData['conformite_valide'] ?? true,
      conformiteDetails: factureData['conformite_details'] ?? 'Création manuelle validée.',
      fraudeJustification: factureData['fraude_justification'] ?? 'Aucun risque signalé.',
      fraudeAlertes: factureData['fraude_alertes'] ?? [],
    );

    _invoices.insert(0, newInvoice); // Prepend to show on top of dashboard
    return newInvoice;
  }

  @override
  Future<void> updateInvoiceStatus(int id, String status) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _invoices.indexWhere((inv) => inv.id == id);
    if (index != -1) {
      final old = _invoices[index];
      _invoices[index] = Invoice(
        id: old.id,
        numero: old.numero,
        fournisseur: old.fournisseur,
        dateFacture: old.dateFacture,
        dateReception: old.dateReception,
        devise: old.devise,
        montantHt: old.montantHt,
        tva: old.tva,
        montantTtc: old.montantTtc,
        iban: old.iban,
        statut: status, // Changed status
        fraudScore: old.fraudScore,
        confidenceScore: old.confidenceScore,
        conformiteValide: old.conformiteValide,
        conformiteDetails: old.conformiteDetails,
        fraudeJustification: old.fraudeJustification,
        fraudeAlertes: old.fraudeAlertes,
      );
    } else {
      throw Exception('Facture introuvable');
    }
  }

  @override
  Future<Map<String, dynamic>> getDashboardStats() async {
    await Future.delayed(const Duration(milliseconds: 300));
    final total = _invoices.length;
    final totalTtc = _invoices.fold<double>(0, (sum, inv) => sum + inv.montantTtc);
    final validated = _invoices.where((inv) => inv.statut == 'validee' || inv.statut == 'controlee').length;
    final pending = _invoices.where((inv) => inv.statut == 'brouillon' || inv.statut == 'nouveau').length;
    final avgFraud = total > 0 ? _invoices.fold<double>(0, (sum, inv) => sum + inv.fraudScore) / total : 0.0;
    
    return {
      'total_factures': total,
      'total_montant': totalTtc,
      'factures_validees': validated,
      'factures_en_attente': pending,
      'risque_moyen': avgFraud,
      'invoices': List<Invoice>.from(_invoices),
    };
  }
}
