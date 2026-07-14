import 'dart:convert';

class Invoice {
  final int id;
  final String numero;
  final String fournisseur;
  final DateTime dateFacture;
  final DateTime dateReception;
  final String devise;
  final double montantHt;
  final double tva;
  final double montantTtc;
  final String iban;
  final String statut;
  final double fraudScore;
  final double confidenceScore;
  final String? imagePath;
  final bool? conformiteValide;
  final String? conformiteDetails;
  final String? fraudeJustification;
  final List<dynamic>? fraudeAlertes;

  Invoice({
    required this.id,
    required this.numero,
    required this.fournisseur,
    required this.dateFacture,
    required this.dateReception,
    required this.devise,
    required this.montantHt,
    required this.tva,
    required this.montantTtc,
    required this.iban,
    required this.statut,
    required this.fraudScore,
    required this.confidenceScore,
    this.imagePath,
    this.conformiteValide,
    this.conformiteDetails,
    this.fraudeJustification,
    this.fraudeAlertes,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) {
    // Helper to parse double fields safely
    double toDouble(dynamic val) {
      if (val == null) return 0.0;
      if (val is int) return val.toDouble();
      if (val is double) return val;
      return double.tryParse(val.toString()) ?? 0.0;
    }

    // Helper to parse dates safely
    DateTime toDateTime(dynamic val) {
      if (val == null) return DateTime.now();
      return DateTime.tryParse(val.toString()) ?? DateTime.now();
    }

    // Parse fraude_alertes which can be a JSON string or already a list
    List<dynamic>? parseAlertes(dynamic val) {
      if (val == null) return null;
      if (val is List) return val;
      if (val is String) {
        try { return jsonDecode(val); } catch (_) { return null; }
      }
      return null;
    }

    return Invoice(
      id: json['id'] ?? 0,
      numero: json['numero'] ?? 'Inconnu',
      fournisseur: json['fournisseur'] ?? 'Inconnu',
      dateFacture: toDateTime(json['date_facture']),
      dateReception: toDateTime(json['date_reception'] ?? json['created_at']),
      devise: json['devise'] ?? 'TND',
      // Backend uses 'ht', 'tva', 'ttc' — NOT 'montant_ht', 'montant_ttc'
      montantHt: toDouble(json['ht'] ?? json['montant_ht']),
      tva: toDouble(json['tva']),
      montantTtc: toDouble(json['ttc'] ?? json['montant_ttc']),
      iban: json['iban'] ?? '',
      statut: json['statut'] ?? 'nouveau',
      fraudScore: toDouble(json['fraude_score'] ?? json['fraud_score']),
      confidenceScore: toDouble(json['confiance'] ?? json['confidence_score'] ?? 0.95),
      imagePath: json['image_path'],
      conformiteValide: json['conformite_valide'],
      conformiteDetails: json['conformite_details'],
      fraudeJustification: json['fraude_justification'],
      fraudeAlertes: parseAlertes(json['fraude_alertes']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'numero': numero,
      'fournisseur': fournisseur,
      'date_facture': dateFacture.toIso8601String(),
      'devise': devise,
      'ht': montantHt,
      'tva': tva,
      'ttc': montantTtc,
      'iban': iban,
      'statut': statut,
    };
  }
}
