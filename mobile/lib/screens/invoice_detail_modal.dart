import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/invoice.dart';

class InvoiceDetailModal extends StatelessWidget {
  final Invoice invoice;

  const InvoiceDetailModal({Key? key, required this.invoice}) : super(key: key);

  static void show(BuildContext context, Invoice invoice) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => InvoiceDetailModal(invoice: invoice),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Hardcoded demo values matching mockup screenshot
    const double riskScore = 75.0; 
    const Color riskColor = Color(0xFFA4161A); // error-crimson

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFCF9F6), // bg-background
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 8,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: FractionallySizedBox(
        heightFactor: 0.9,
        child: Column(
          children: [
            // Grab handle
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFE5E2DF),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Back button breadcrumb
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Row(
                children: [
                  const Icon(Icons.arrow_back, color: Color(0xFF012D1D), size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Back to Invoices',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF414844),
                      letterSpacing: 0.05 * 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Header Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Invoice #INV-2024-082',
                        style: GoogleFonts.inter(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF012D1D),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            'Best Trade Corp',
                            style: GoogleFonts.inter(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1C1C1A),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFA0F4C8).withOpacity(0.3), // secondary-container
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Verified Vendor',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF005236),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    // Risk Assessment Circular Gauge Card
                    _buildRiskGaugeCard(riskScore, riskColor),
                    const SizedBox(height: 16),

                    // Extracted Fields & Confidence
                    _buildExtractedFieldsCard(),
                    const SizedBox(height: 16),

                    // Fraud Analysis Explanation Card
                    _buildFraudExplanationCard(),
                    const SizedBox(height: 16),

                    // Invoice Visual Scan Mockup
                    _buildVisualScanCard(),
                    const SizedBox(height: 100), // padding for sticky bottom
                  ],
                ),
              ),
            ),

            // Sticky Bottom Buttons
            Container(
              padding: const EdgeInsets.only(top: 16),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Color(0xFFE5E2DF))),
              ),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.check_circle, color: Colors.white),
                      label: Text(
                        'Validate Invoice',
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF012D1D),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.block, color: Color(0xFFA4161A)),
                      label: Text(
                        'Reject with Comment',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFA4161A),
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFA4161A)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRiskGaugeCard(double score, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEAE8E5)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A1C1B).withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Risk Assessment',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF717973),
              letterSpacing: 0.05 * 12,
            ),
          ),
          const SizedBox(height: 16),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 128,
                height: 128,
                child: CircularProgressIndicator(
                  value: score / 100,
                  strokeWidth: 8,
                  backgroundColor: const Color(0xFFEAE8E5),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${score.toInt()}%',
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                  Text(
                    'High Risk',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'High risk detected in VAT reconciliation and bank details.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF414844),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExtractedFieldsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E2DF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'EXTRACTED FIELDS & CONFIDENCE',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF717973),
              letterSpacing: 0.05 * 12,
            ),
          ),
          const SizedBox(height: 16),
          _buildExtractedRow('Vendor', 'Best Trade Corp', '99%', const Color(0xFFB7E4C7), const Color(0xFF0E6C4A), Icons.check_circle),
          const Divider(height: 24, color: Color(0xFFE5E2DF)),
          _buildExtractedRow('IBAN', 'IE 45 BKRY 9001 2345 6789 01', '65%', const Color(0xFFFFE0B2), Colors.orange[800]!, Icons.warning),
          const Divider(height: 24, color: Color(0xFFE5E2DF)),
          _buildExtractedRow('VAT Amount', '€2,614.50', '40%', const Color(0xFFFFDAD6), const Color(0xFFA4161A), Icons.error),
          const Divider(height: 24, color: Color(0xFFE5E2DF)),
          _buildExtractedRow('Total HT', '€9,835.50', '98%', const Color(0xFFB7E4C7), const Color(0xFF0E6C4A), Icons.check_circle),
          const Divider(height: 24, color: Color(0xFFE5E2DF)),
          _buildExtractedRow('Total TTC', '€12,450.00', '99%', const Color(0xFFB7E4C7), const Color(0xFF0E6C4A), Icons.check_circle),
        ],
      ),
    );
  }

  Widget _buildExtractedRow(String label, String value, String confidence, Color badgeBg, Color badgeText, IconData icon) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, color: const Color(0xFF414844)),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: const Color(0xFF1C1C1A)),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: badgeBg,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: [
              Icon(icon, color: badgeText, size: 14),
              const SizedBox(width: 4),
              Text(
                confidence,
                style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: badgeText),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFraudExplanationCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFFDAD6).withOpacity(0.3), // error-container/40
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFDAD6)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFA4161A).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.policy, color: Color(0xFFA4161A), size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Fraud Analysis Explanation',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFA4161A),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'The system has flagged this invoice as High Risk (75%) due to the following critical anomalies detected during extraction:',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: const Color(0xFF1C1C1A),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                _buildBulletPoint('Bank account mismatch detected:', ' The extracted IBAN (IE 45...) differs from the verified primary account stored in the vendor profile for Best Trade Corp.'),
                const SizedBox(height: 8),
                _buildBulletPoint('VAT Calculation Error:', ' The extracted VAT amount (21%) does not match the expected sum of itemized lines. Expected: €2,490.00 vs Extracted: €2,614.50.'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String boldPrefix, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('• ', style: TextStyle(fontSize: 14, color: Color(0xFF414844))),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF414844), height: 1.4),
              children: [
                TextSpan(text: boldPrefix, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1C1C1A))),
                TextSpan(text: text),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVisualScanCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E2DF)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: const Color(0xFFEAE8E5), // surface-container-high
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'INVOICE VISUAL SCAN',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF414844),
                    letterSpacing: 0.05 * 12,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.zoom_in, color: Color(0xFF414844), size: 20),
                      onPressed: () {},
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.zero,
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.open_in_full, color: Color(0xFF414844), size: 20),
                      onPressed: () {},
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            height: 256,
            color: const Color(0xFFF8FAFC), // slate-50
            child: Center(
              child: Container(
                width: 192,
                height: 240,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Mock invoice layout lines
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(width: 48, height: 16, color: const Color(0xFFF1F5F9)),
                        const SizedBox(height: 16),
                        Container(width: double.infinity, height: 8, color: const Color(0xFFF8FAFC)),
                        const SizedBox(height: 6),
                        Container(width: 120, height: 8, color: const Color(0xFFF8FAFC)),
                        const SizedBox(height: 6),
                        Container(width: double.infinity, height: 8, color: const Color(0xFFF8FAFC)),
                        const Spacer(),
                        Container(height: 1, color: const Color(0xFFF1F5F9)),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(width: 32, height: 8, color: const Color(0xFFF1F5F9)),
                            Container(width: 48, height: 16, color: const Color(0xFFE2E8F0)),
                          ],
                        ),
                      ],
                    ),
                    // Red highlight overlay
                    Positioned(
                      top: 96,
                      left: 16,
                      right: 16,
                      height: 32,
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFA4161A).withOpacity(0.1),
                          border: Border.all(color: const Color(0xFFA4161A), width: 2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    // Orange highlight overlay
                    Positioned(
                      bottom: 40,
                      left: 16,
                      right: 16,
                      height: 24,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          border: Border.all(color: Colors.orange, width: 2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
