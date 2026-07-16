import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'invoice_detail_modal.dart';
import '../models/invoice.dart';
import '../widgets/fade_in_slide.dart';

class SecureChatScreen extends StatefulWidget {
  const SecureChatScreen({Key? key}) : super(key: key);

  @override
  State<SecureChatScreen> createState() => _SecureChatScreenState();
}

class _SecureChatScreenState extends State<SecureChatScreen> {
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _showMockDocument() {
    final mockInvoice = Invoice(
      id: 89,
      numero: 'INV-2023-089',
      fournisseur: 'Apex Tech Solutions',
      dateFacture: DateTime.now(),
      dateReception: DateTime.now(),
      devise: 'USD',
      montantHt: 10375.0,
      tva: 2075.0,
      montantTtc: 12450.0,
      iban: 'IE 45 BKRY 9001 2345 6789 01',
      statut: 'nouveau',
      fraudScore: 0.75,
      confidenceScore: 0.98,
    );
    InvoiceDetailModal.show(context, mockInvoice);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF9F6), // bg-background
      appBar: AppBar(
        backgroundColor: const Color(0xFFFCF9F6).withOpacity(0.85),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF012D1D)),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            Stack(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: NetworkImage(
                        'https://lh3.googleusercontent.com/aida-public/AB6AXuDi2095aYbjKmyGCP2FB5AqQND0ihHd6wP7gkSYVxrPXCh4UFB9qF7JnOIqID-vkPFv7V2wWWH6doTHxzXpxM9o8d5rCPzZaGgSjznNeEI_SoLq3ahzC6I-jJC-WczNMasmZxekyIZmpq3oZhL7cvsKzxGWC73Z4RpdO_erOQEBc0dqcj5i3uoLXg1hp14dflfnX4KCoZLPRJloqEDT7IyzJlHykMGBrtnFVnXEuDHTv2616EraWIDgQK6sxMzq9mbZUXPvWy_ewi0L',
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0E6C4A), // secondary
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFFCF9F6), width: 2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Sarah Jenkins',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF012D1D),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.verified, color: Color(0xFF0E6C4A), size: 16),
                  ],
                ),
                Text(
                  'Senior Tax Advisor',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: const Color(0xFF414844),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Color(0xFF414844)),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  // Date Header
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0EDE9), // surface-container-high
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFE5E2DF)),
                      ),
                      child: Text(
                        'Today, 10:42 AM',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF414844),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Encryption note
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF6F3F0), // surface-container-low
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.lock, color: Color(0xFF414844), size: 14),
                          const SizedBox(width: 6),
                          Text(
                            'Messages are end-to-end encrypted.',
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
                  const SizedBox(height: 24),

                  // Message 1 (Incoming)
                  FadeInSlide(
                    delay: const Duration(milliseconds: 150),
                    child: _buildIncomingMessage(
                      'Good morning! I\'ve reviewed your latest quarterly expenses. Everything looks solid, but we need to verify one specific vendor invoice from August.',
                      '10:45 AM',
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Message 2 (Outgoing)
                  FadeInSlide(
                    delay: const Duration(milliseconds: 300),
                    child: _buildOutgoingMessage(
                      'Hi Sarah, sure thing. Which invoice are you referring to?',
                      '10:48 AM',
                      statusIcon: Icons.done_all,
                      statusColor: const Color(0xFFB8F04A),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Message 3 (Incoming with PDF preview)
                  FadeInSlide(
                    delay: const Duration(milliseconds: 450),
                    child: _buildIncomingMessageWithDoc(
                      'It\'s the one from Apex Tech Solutions. I\'ve attached a secure preview below. Could you confirm if this was for software licensing?',
                      '10:52 AM',
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Message 4 (Outgoing)
                  FadeInSlide(
                    delay: const Duration(milliseconds: 600),
                    child: _buildOutgoingMessage(
                      'Yes, that was for the annual CRM renewal. I have the signed agreement if you need it attached.',
                      '10:55 AM',
                      statusIcon: Icons.done,
                      statusColor: const Color(0xFF414844),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),

          // Bottom Input Area
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFE5E2DF))),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.add_circle, color: Color(0xFF414844)),
                  onPressed: () {},
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.only(bottom: 12, right: 8),
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF6F3F0), // surface-container-low
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE5E2DF)),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: TextField(
                      controller: _messageController,
                      maxLines: null,
                      decoration: InputDecoration(
                        hintText: 'Type a secure message...',
                        hintStyle: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF717973)),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF012D1D),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIncomingMessage(String text, String time) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(right: 48),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF0EDE9), // surface-cream-dark
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
            bottomLeft: Radius.circular(4),
          ),
          border: Border.all(color: const Color(0xFFE5E2DF)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF012D1D).withOpacity(0.03),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: const Color(0xFF1C1C1A),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                time,
                style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF414844)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIncomingMessageWithDoc(String text, String time) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(right: 32),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF0EDE9), // surface-cream-dark
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
            bottomLeft: Radius.circular(4),
          ),
          border: Border.all(color: const Color(0xFFE5E2DF)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF012D1D).withOpacity(0.03),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: const Color(0xFF1C1C1A),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFC1C8C2)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0EDE5),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(Icons.description, color: Color(0xFF012D1D), size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Invoice #INV-2023-089',
                              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF012D1D)),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Apex Tech Solutions • 2.4 MB • PDF',
                              style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF414844)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 36,
                    child: ElevatedButton.icon(
                      onPressed: _showMockDocument,
                      icon: const Icon(Icons.visibility, size: 18),
                      label: Text(
                        'View Document',
                        style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF0EDE5),
                        foregroundColor: const Color(0xFF012D1D),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                time,
                style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF414844)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOutgoingMessage(String text, String time, {required IconData statusIcon, required Color statusColor}) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(left: 48),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF012D1D), // primary
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(4),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF012D1D).withOpacity(0.15),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.white,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  time,
                  style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFFA5D0B9)), // primary-fixed-dim
                ),
                const SizedBox(width: 4),
                Icon(statusIcon, color: statusColor, size: 14),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
