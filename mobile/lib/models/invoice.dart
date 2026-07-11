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
  final Map<String, dynamic>? complianceResults;
  final List<dynamic>? fraudDetails;

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
    this.complianceResults,
    this.fraudDetails,
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

    return Invoice(
      id: json['id'] ?? 0,
      numero: json['numero'] ?? 'Inconnu',
      fournisseur: json['fournisseur'] ?? 'Inconnu',
      dateFacture: toDateTime(json['date_facture']),
      dateReception: toDateTime(json['date_reception'] ?? json['created_at']),
      devise: json['devise'] ?? 'EUR',
      montantHt: toDouble(json['montant_ht']),
      tva: toDouble(json['tva']),
      montantTtc: toDouble(json['montant_ttc']),
      iban: json['iban'] ?? '',
      statut: json['statut'] ?? 'nouveau',
      fraudScore: toDouble(json['fraud_score']),
      confidenceScore: toDouble(json['confidence_score'] ?? 1.0),
      imagePath: json['image_path'],
      complianceResults: json['compliance_results'] != null 
          ? (json['compliance_results'] is String 
              ? jsonDecode(json['compliance_results']) 
              : Map<String, dynamic>.from(json['compliance_results']))
          : null,
      fraudDetails: json['fraud_details'] != null
          ? (json['fraud_details'] is String 
              ? jsonDecode(json['fraud_details']) 
              : List<dynamic>.from(json['fraud_details']))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'numero': numero,
      'fournisseur': fournisseur,
      'date_facture': dateFacture.toIso8601String(),
      'date_reception': dateReception.toIso8601String(),
      'devise': devise,
      'montant_ht': montantHt,
      'tva': tva,
      'montant_ttc': montantTtc,
      'iban': iban,
      'statut': statut,
      'fraud_score': fraudScore,
      'confidence_score': confidenceScore,
      'image_path': imagePath,
      'compliance_results': complianceResults != null ? jsonEncode(complianceResults) : null,
      'fraud_details': fraudDetails != null ? jsonEncode(fraudDetails) : null,
    };
  }
}
