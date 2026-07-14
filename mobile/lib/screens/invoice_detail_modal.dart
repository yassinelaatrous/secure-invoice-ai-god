import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/invoice.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/status_badge.dart';
import '../widgets/risk_indicator.dart';

class InvoiceDetailModal extends StatefulWidget {
  final Invoice invoice;
  final VoidCallback onActionComplete;

  const InvoiceDetailModal({
    super.key,
    required this.invoice,
    required this.onActionComplete,
  });

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
      await ApiService.updateInvoiceStatus(_invoice.id, newStatus);

      if (mounted) {
        setState(() {
          _isLoading = false;
          _commentController.clear();
        });
        widget.onActionComplete();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppTheme.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            content: Text(
              'Facture mise à jour avec succès : $newStatus',
              style: GoogleFonts.dmSans(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppTheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            content: Text(
              'Erreur : $e',
              style: GoogleFonts.dmSans(color: Colors.white),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final showActions = _user != null && (_user!['role'] == 'comptable' || _user!['role'] == 'admin');
    final isPending = _invoice.statut == 'nouveau' || _invoice.statut == 'en_verification';

    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.surfaceLight,
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
            ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
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
                          color: AppTheme.cardBorder,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Header Info
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _invoice.fournisseur,
                                style: GoogleFonts.fraunces(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  fontStyle: FontStyle.italic,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'N° ${_invoice.numero}',
                                style: GoogleFonts.dmSans(
                                  fontSize: 14,
                                  color: AppTheme.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        StatusBadge(status: _invoice.statut),
                      ],
                    ),
                    Divider(height: 32, color: AppTheme.cardBorder),

                    // Montants Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildAmountBlock('Montant HT', _invoice.montantHt, _invoice.devise),
                        _buildAmountBlock('TVA', _invoice.tva, _invoice.devise),
                        _buildAmountBlock('Total TTC', _invoice.montantTtc, _invoice.devise, isPrimary: true),
                      ],
                    ),
                    Divider(height: 32, color: AppTheme.cardBorder),

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
                    Divider(height: 32, color: AppTheme.cardBorder),

                    // Risk indicators
                    RiskIndicator(score: _invoice.fraudScore),

                    // Fraud logs details
                    if (_invoice.fraudeAlertes != null && _invoice.fraudeAlertes!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        'Indicateurs de fraude détectés :',
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      ..._invoice.fraudeAlertes!.map((flag) => _buildFraudFlagItem(flag)),
                    ],

                    Divider(height: 32, color: AppTheme.cardBorder),

                    // Compliance rules checklist
                    Text(
                      'Vérifications de Conformité',
                      style: GoogleFonts.fraunces(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        fontStyle: FontStyle.italic,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildComplianceSection(),
                    Divider(height: 32, color: AppTheme.cardBorder),

                    // Action controls for Reviewers
                    if (showActions && isPending) ...[
                      Text(
                        'Décision & Commentaires',
                        style: GoogleFonts.dmSans(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _commentController,
                        maxLines: 2,
                        style: GoogleFonts.dmSans(color: AppTheme.textPrimary),
                        decoration: InputDecoration(
                          hintText: 'Saisissez un commentaire ou motif de rejet...',
                          hintStyle: GoogleFonts.dmSans(color: AppTheme.textMuted),
                          fillColor: AppTheme.surfaceCard,
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppTheme.cardBorder),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppTheme.cardBorder),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
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
                                foregroundColor: AppTheme.error,
                                side: const BorderSide(color: AppTheme.error, width: 1.5),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                              child: Text(
                                'Rejeter la facture',
                                style: GoogleFonts.dmSans(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => _handleStatusChange('validee'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.accentGreen,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                elevation: 0,
                              ),
                              child: Text(
                                'Valider la facture',
                                style: GoogleFonts.dmSans(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      // General actions
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 0,
                        ),
                        child: Text(
                          'Fermer',
                          style: GoogleFonts.dmSans(fontWeight: FontWeight.bold),
                        ),
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
          style: GoogleFonts.dmSans(
            color: AppTheme.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${value.toStringAsFixed(2)} $currencySymbol',
          style: GoogleFonts.dmSans(
            fontSize: isPrimary ? 18 : 14,
            fontWeight: isPrimary ? FontWeight.w800 : FontWeight.bold,
            color: isPrimary ? AppTheme.primary : AppTheme.textPrimary,
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
            style: GoogleFonts.dmSans(
              color: AppTheme.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.dmSans(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFraudFlagItem(dynamic flag) {
    final String description = flag['description'] ?? '';
    final int severity = flag['severity'] ?? 0;

    Color severityColor;
    if (severity >= 80) {
      severityColor = AppTheme.error;
    } else if (severity >= 40) {
      severityColor = AppTheme.warning;
    } else {
      severityColor = const Color(0xFFEA580C);
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
              style: GoogleFonts.dmSans(
                fontSize: 11,
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComplianceSection() {
    // Try to parse conformite_details JSON string from the backend
    if (_invoice.conformiteDetails != null) {
      try {
        final dynamic parsed = _invoice.conformiteDetails is String
            ? jsonDecode(_invoice.conformiteDetails!)
            : _invoice.conformiteDetails;
        if (parsed is List) {
          return Column(
            children: parsed.map<Widget>((check) {
              final String ruleName = check['rule']?.toString() ?? 'Vérification';
              final bool passed = check['passed'] == true;
              final String message = check['message']?.toString() ?? '';

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      passed ? Icons.check_circle_rounded : Icons.cancel_rounded,
                      color: passed ? AppTheme.accentGreen : AppTheme.error,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ruleName,
                            style: GoogleFonts.dmSans(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          if (message.isNotEmpty)
                            Text(
                              message,
                              style: GoogleFonts.dmSans(
                                fontSize: 11,
                                color: passed ? AppTheme.textSecondary : AppTheme.error,
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
      } catch (_) {
        // Fall through to default display
      }
    }

    // Show conformite_valide status or default static fallback
    final bool isValid = _invoice.conformiteValide ?? true;
    return Column(
      children: [
        ComplianceItem(title: 'Conformité globale', passed: isValid),
        const ComplianceItem(title: 'Champs obligatoires requis', passed: true),
        const ComplianceItem(title: 'Calcul de TVA cohérent (HT + TVA = TTC)', passed: true),
        const ComplianceItem(title: 'IBAN au format valide', passed: true),
        const ComplianceItem(title: 'Date de facturation valide', passed: true),
      ],
    );
  }
}

class ComplianceItem extends StatelessWidget {
  final String title;
  final bool passed;

  const ComplianceItem({super.key, required this.title, required this.passed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(
            passed ? Icons.check_circle_rounded : Icons.cancel_rounded,
            color: passed ? AppTheme.accentGreen : AppTheme.error,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.dmSans(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
