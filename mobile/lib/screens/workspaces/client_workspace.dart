import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ClientWorkspace extends StatelessWidget {
  const ClientWorkspace({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF9F6), // bg-background
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header (Mobile style)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'My Workspace',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF012D1D),
                    ),
                  ),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFEAE8E5), // surface-container-high
                    ),
                    child: const Icon(Icons.person, color: Color(0xFF414844), size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Upload Document Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE5E2DF)),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1A1C1B).withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Upload Document',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1C1C1A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Securely deposit your invoices, receipts, or contracts for processing.',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: const Color(0xFF414844),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.cloud_upload, color: Colors.white),
                        label: Text(
                          'Select File',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: 0.05 * 12,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0E6C4A), // secondary
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildUploadTypeButton(Icons.receipt_long, 'Invoice'),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildUploadTypeButton(Icons.article, 'Contract'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Dossier Status (Progress Tracker)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE5E2DF)),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1A1C1B).withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Dossier Status',
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1C1C1A),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0EDE9), // surface-container
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Q3 2023',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF414844),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Process Line Tracker
                    Stack(
                      children: [
                        Positioned(
                          top: 14,
                          left: 20,
                          right: 20,
                          child: Container(
                            height: 4,
                            color: const Color(0xFFE5E2DF),
                          ),
                        ),
                        Positioned(
                          top: 14,
                          left: 20,
                          right: 20,
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              return Align(
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  width: constraints.maxWidth / 3, // Processing step
                                  height: 4,
                                  color: const Color(0xFF0E6C4A),
                                ),
                              );
                            },
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildProgressStep('Initiated', Icons.check, true),
                            _buildProgressStep('Processing', Icons.refresh, true),
                            _buildProgressStep('Validation', Icons.fact_check, false),
                            _buildProgressStep('Complete', Icons.done_all, false),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Note box
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFCF9F6), // bg-background
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE5E2DF)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.info, color: Color(0xFF0E6C4A), size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Currently reviewing uploaded receipts.',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF1C1C1A),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Last updated: Oct 24, 2023',
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w400,
                                    color: const Color(0xFF717973),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Action Required Section
              Text(
                'Action Required',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1C1C1A),
                ),
              ),
              const SizedBox(height: 16),

              // Missing ID Copy
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFDAD6).withOpacity(0.3), // error-container
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFFDAD6)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFFFDAD6),
                      ),
                      child: const Icon(Icons.warning, color: Color(0xFFA4161A), size: 20),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Missing ID Copy',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1C1C1A),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Required for onboarding completion.',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF414844),
                            ),
                          ),
                        ],
                      ),
                    ),
                    OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFA4161A),
                        side: const BorderSide(color: Color(0xFFFFDAD6)),
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      child: Text(
                        'Upload Now',
                        style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Rejected Doc Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE5E2DF)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFEAE8E5),
                      ),
                      child: const Icon(Icons.find_in_page, color: Color(0xFF414844), size: 20),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Invoice #INV-2023-089',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1C1C1A),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Blurry scan. Please re-upload.',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFFA4161A),
                            ),
                          ),
                        ],
                      ),
                    ),
                    OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF1C1C1A),
                        side: const BorderSide(color: Color(0xFFC1C8C2)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      child: Text(
                        'Replace',
                        style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Assigned Accountant Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE5E2DF)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'YOUR ACCOUNTANT',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF414844),
                        letterSpacing: 0.05 * 12,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              image: NetworkImage(
                                'https://lh3.googleusercontent.com/aida-public/AB6AXuAvvD-NuPMDxiX7qTxmw_Mr90AIeDNLWboPPRfCD9-nZsc0GV1jyPZKzvGXZzF9Y-mmAN7fqlgVRAwr50TrOtzFJFDHJu-FwTwTGyvUaTJXC8RJ-SG7kjqIMLofewOGZZJlNP7eKOYxuve995rmFhBCJksUgyGhFdWeKxaDog4aGfN99NX9NyH1C3qZxmyPfCqzOJpa97_ZLR0Ll_D67EnIQYa1juKEXdnvneQ25ikdureDBSAjnY4X_3pFYvu7SmXB7VInikmnUBR0',
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Sarah Jenkins',
                              style: GoogleFonts.inter(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF1C1C1A),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Senior Tax Advisor',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: const Color(0xFF414844),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 40,
                            child: OutlinedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.chat, size: 18),
                              label: Text(
                                'Send Message',
                                style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF1C1C1A),
                                side: const BorderSide(color: Color(0xFFC1C8C2)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SizedBox(
                            height: 40,
                            child: ElevatedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.calendar_month, size: 18),
                              label: Text(
                                'Book Meeting',
                                style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFF0EDE5),
                                foregroundColor: const Color(0xFF414844),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Quick Stats Grid
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE5E2DF)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.folder_open, color: Color(0xFF0E6C4A), size: 24),
                          const SizedBox(height: 12),
                          Text(
                            '12',
                            style: GoogleFonts.inter(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1C1C1A),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Docs Uploaded',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF414844),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE5E2DF)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.pending_actions, color: Color(0xFF0E6C4A), size: 24),
                          const SizedBox(height: 12),
                          Text(
                            '2',
                            style: GoogleFonts.inter(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1C1C1A),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Pending Review',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF414844),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 100), // Padding for bottom nav
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUploadTypeButton(IconData icon, String label) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: const Color(0xFFFCF9F6),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E2DF)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: const Color(0xFF0E6C4A), size: 24),
              const SizedBox(height: 4),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF414844),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressStep(String label, IconData icon, bool isActive) {
    final stepColor = isActive ? const Color(0xFF0E6C4A) : const Color(0xFFE5E2DF);
    final iconColor = isActive ? Colors.white : const Color(0xFF717973);

    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: stepColor,
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: stepColor.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            color: isActive ? const Color(0xFF1C1C1A) : const Color(0xFF717973),
          ),
        ),
      ],
    );
  }
}
