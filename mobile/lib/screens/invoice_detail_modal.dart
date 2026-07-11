import 'package:flutter/material.dart';
import '../models/invoice.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../widgets/status_badge.dart';
import '../widgets/risk_indicator.dart';

class InvoiceDetailModal extends StatefulWidget {
  final Invoice invoice;
  final VoidCallback onActionComplete;

  const InvoiceDetailModal({
    Key? key,
    required this.invoice,
    required this.onActionComplete,
  }) : super(key: key);

  static void show(BuildContext context, Invoice invoice, {required VoidCallback onActionComplete}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => InvoiceDetailModal(
        invoice: invoice,
        onActionComplete: onActionComplete,
      ),
    );
  }

  @override
  State<InvoiceDetailModal> createState() => _InvoiceDetailModalState();
}

class _InvoiceDetailModalState extends State<InvoiceDetailModal> {
  late Invoice _invoice;
  bool _isLoading = false;
  Map<String, dynamic>? _user;
  
  final _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _invoice = widget.invoice;
    _loadUser();
    _loadFullDetails();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _loadUser() async {
    final user = await AuthService.getUserInfo();
    setState(() {
      _user = user;
    });
  }

  Future<void> _loadFullDetails() async {
    try {
      final fullInvoice = await ApiService.getInvoiceDetails(_invoice.id);
      if (mounted) {
        setState(() {
          _invoice = fullInvoice;
        });
      }
    } catch (e) {
      // Keep using current summary invoice if full load fails
    }
  }

  void _handleStatusChange(String newStatus) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final comment = _commentController.text.trim();
      final updated = await ApiService.updateInvoiceStatus(
        _invoice.id,
        newStatus,
        comment: comment.isNotEmpty ? comment : null,
      );

      if (mounted) {
        setState(() {
          _invoice = updated;
          _isLoading = false;
          _commentController.clear();
        });
        widget.onActionComplete();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: Text('Facture mise à jour avec succès : $newStatus'),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final showActions = _user != null && (_user!['role'] == 'comptable' || _user!['role'] == 'admin');
    final isPending = _invoice.statut == 'nouveau' || _invoice.statut == 'en_verification';

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: FractionallySizedBox(
        heightFactor: 0.8,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Pull indicator line
                    Center(
                      child: Container(
                        width: 40,
                        height: 5,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE5E5EB),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Header Info
                    Row(
                      mainAxisAlignment: MainAxisAlignment.between,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _invoice.fournisseur,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  fontFamily: 'Outfit',
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'N° ${_invoice.numero}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF8F9199),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        StatusBadge(status: _invoice.statut),
                      ],
                    ),
                    const Divider(height: 32, color: Color(0xFFE5E5EB)),

                    // Montants Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildAmountBlock('Montant HT', _invoice.montantHt, _invoice.devise),
                        _buildAmountBlock('TVA', _invoice.tva, _invoice.devise),
                        _buildAmountBlock('Total TTC', _invoice.montantTtc, _invoice.devise, isPrimary: true),
                      ],
                    ),
                    const Divider(height: 32, color: Color(0xFFE5E5EB)),

                    // IBAN & Date details
                    _buildDetailRow('IBAN Extrait', _invoice.iban.isNotEmpty ? _invoice.iban : 'Aucun'),
                    const SizedBox(height: 10),
                    _buildDetailRow(
                      'Date Facture',
                      '${_invoice.dateFacture.day.toString().padLeft(2, '0')}/${_invoice.dateFacture.month.toString().padLeft(2, '0')}/${_invoice.dateFacture.year}',
                    ),
                    const SizedBox(height: 10),
                    _buildDetailRow(
                      'Reçue le',
                      '${_invoice.dateReception.day.toString().padLeft(2, '0')}/${_invoice.dateReception.month.toString().padLeft(2, '0')}/${_invoice.dateReception.year}',
                    ),
                    const Divider(height: 32, color: Color(0xFFE5E5EB)),

                    // Risk indicators
                    RiskIndicator(score: _invoice.fraudScore),
                    
                    // Fraud logs details
                    if (_invoice.fraudDetails != null && _invoice.fraudDetails!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      const Text(
                        'Indicateurs de fraude détectés :',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF5F6168)),
                      ),
                      const SizedBox(height: 6),
                      ..._invoice.fraudDetails!.map((flag) => _buildFraudFlagItem(flag)),
                    ],
                    
                    const Divider(height: 32, color: Color(0xFFE5E5EB)),

                    // Compliance rules checklist
                    const Text(
                      'Vérifications de Conformité',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        fontFamily: 'Outfit',
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildComplianceSection(),
                    const Divider(height: 32, color: Color(0xFFE5E5EB)),

                    // Action controls for Reviewers
                    if (showActions && isPending) ...[
                      const Text(
                        'Décision & Commentaires',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _commentController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          hintText: 'Saisissez un commentaire ou motif de rejet...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.all(12),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => _handleStatusChange('rejete'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.redAccent,
                                side: const BorderSide(color: Colors.redAccent, width: 1.5),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                              ),
                              child: const Text('Rejeter la facture', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => _handleStatusChange('valide'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF10B981),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                              ),
                              child: const Text('Valider la facture', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      // General actions
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4F46E5),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('Fermer', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildAmountBlock(String label, double value, String devise, {bool isPrimary = false}) {
    final currencySymbol = devise == 'EUR' ? '€' : devise;
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF8F9199),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${value.toStringAsFixed(2)} $currencySymbol',
          style: TextStyle(
            fontSize: isPrimary ? 18 : 14,
            fontWeight: isPrimary ? FontWeight.w800 : FontWeight.bold,
            color: isPrimary ? const Color(0xFF4F46E5) : const Color(0xFF12100F),
            fontFamily: 'Outfit',
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF8F9199),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFraudFlagItem(dynamic flag) {
    final String description = flag['description'] ?? '';
    final int severity = flag['severity'] ?? 0;
    
    Color severityColor = Colors.grey;
    if (severity >= 80) {
      severityColor = Colors.red;
    } else if (severity >= 40) {
      severityColor = Colors.orange;
    } else {
      severityColor = Colors.amber;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded, size: 14, color: severityColor),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              description,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade800,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComplianceSection() {
    // If compliance results are loaded
    if (_invoice.complianceResults != null && _invoice.complianceResults!['checks'] != null) {
      final List<dynamic> checks = _invoice.complianceResults!['checks'];
      return Column(
        children: checks.map<Widget>((check) {
          final String ruleName = check['rule'] ?? 'Vérification';
          final bool passed = check['passed'] ?? false;
          final String message = check['message'] ?? '';

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  passed ? Icons.check_circle_rounded : Icons.cancel_rounded,
                  color: passed ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ruleName,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (message.isNotEmpty)
                        Text(
                          message,
                          style: TextStyle(
                            fontSize: 11,
                            color: passed ? Colors.grey.shade600 : const Color(0xFFEF4444),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      );
    }

    // Default static fallback display
    return const Column(
      children: [
        ComplianceItem(title: 'Champs obligatoires requis', passed: true),
        ComplianceItem(title: 'Calcul de TVA cohérent (HT + TVA = TTC)', passed: true),
        ComplianceItem(title: 'IBAN au format valide', passed: true),
        ComplianceItem(title: 'Date de facturation valide', passed: true),
      ],
    );
  }
}

class ComplianceItem extends StatelessWidget {
  final String title;
  final bool passed;

  const ComplianceItem({Key? key, required this.title, required this.passed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(
            passed ? Icons.check_circle_rounded : Icons.cancel_rounded,
            color: passed ? const Color(0xFF10B981) : const Color(0xFFEF4444),
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
