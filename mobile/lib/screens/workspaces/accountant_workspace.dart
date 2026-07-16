import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../notification_screen.dart';

class AccountantWorkspace extends StatelessWidget {
  const AccountantWorkspace({Key? key}) : super(key: key);

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
              // Header
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF012D1D).withOpacity(0.1), width: 2),
                      image: const DecorationImage(
                        image: NetworkImage(
                          'https://lh3.googleusercontent.com/aida-public/AB6AXuCG3KdJDVrmQn-8uV8v31fD0K1oQBJi6bMPa8L9Q37tpFf0r-_cnqiOEEWoh7TgT4dLV_K5UfNWpXKthit3nDA3rEqtAxp2qAG7V8nxjY7Ovuu9kICDyA23wm7FMuyIUwd74mItigQsTtDYDvWum2J2bvs7IG_W5eCv6x_Dmu1IcBrIPC-TonpAT1VTC320hptA858gYIEFQRhrs0zShfgyhTTAkLGK_OdTf21hgpic8Vi_xpcyA94A3apsGnSkMNYnynlh9iJrH4ZD',
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'CEO-IT',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF012D1D),
                      letterSpacing: -0.01 * 20,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.notifications, color: Color(0xFF414844)),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const NotificationScreen()),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Title Section
              Text(
                'Accountant Workspace',
                style: GoogleFonts.inter(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF012D1D),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Review pending documents, manage client tasks, and monitor processing KPIs.',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: const Color(0xFF414844),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),

              // KPIs Grid
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.3,
                children: [
                  _buildKpiCard('PENDING INVOICES', '42',
                      trendText: '+5 today', trendColor: const Color(0xFFA4161A), isTrendUp: true),
                  _buildKpiCard('PROCESSING TIME', '1.2 hrs',
                      trendText: '-0.3 hrs', trendColor: const Color(0xFF0E6C4A), isTrendUp: false),
                  _buildKpiCard('ACCURACY RATE', '99.4%', isPercentage: true),
                  _buildKpiCard('URGENT CLIENT MSGS', '3', isUrgent: true),
                ],
              ),
              const SizedBox(height: 24),

              // Validation Queue Section
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE5E2DF)),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Validation Queue',
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF012D1D),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {},
                            child: Row(
                              children: [
                                Text(
                                  'View All',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF0E6C4A),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(Icons.arrow_forward, color: Color(0xFF0E6C4A), size: 14),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1, color: Color(0xFFE5E2DF)),
                    _buildQueueItem(
                      'INV-2026-089',
                      'TechFlow Solutions Inc. • Uploaded 2h ago',
                      Icons.description,
                      badgeText: 'Missing Info',
                      badgeBgColor: const Color(0xFFFFDAD6),
                      badgeTextColor: const Color(0xFFA4161A),
                      isApproveBtn: false,
                    ),
                    const Divider(height: 1, color: Color(0xFFE5E2DF)),
                    _buildQueueItem(
                      'EXP-004-JUL',
                      'Acme Corp • Uploaded 4h ago',
                      Icons.receipt_long,
                      badgeText: 'Pending AI Match',
                      badgeBgColor: const Color(0xFFEAE8E5),
                      badgeTextColor: const Color(0xFF414844),
                      isApproveBtn: false,
                    ),
                    const Divider(height: 1, color: Color(0xFFE5E2DF)),
                    _buildQueueItem(
                      'INV-2026-090',
                      'Global Logistics • Uploaded 5h ago',
                      Icons.description,
                      badgeText: 'Ready for Approval',
                      badgeBgColor: const Color(0xFFB7E4C7).withOpacity(0.3),
                      badgeTextColor: const Color(0xFF0E6C4A),
                      isApproveBtn: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Assigned Clients
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE5E2DF)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Assigned Clients',
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF012D1D),
                            ),
                          ),
                          // Search field mock
                          Container(
                            width: 150,
                            height: 32,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0EDE9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.search, size: 16, color: Color(0xFF717973)),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: TextField(
                                    decoration: InputDecoration(
                                      hintText: 'Search clients...',
                                      hintStyle: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF717973)),
                                      border: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      contentPadding: EdgeInsets.zero,
                                      isDense: true,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1, color: Color(0xFFE5E2DF)),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildClientCard('A', 'Acme Corp', '12 Active Folders', 'Action Required',
                                const Color(0xFFFFDAD6), const Color(0xFFA4161A), const Color(0xFF1B4332)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildClientCard('T', 'TechFlow Solutions', '5 Active Folders', 'Up to date',
                                const Color(0xFFEAE8E5), const Color(0xFF414844), const Color(0xFF0E6C4A)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Collaboration Feed Section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0EDE9), // surface-cream-dark
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE5E2DF)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Collaboration Feed',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF012D1D),
                          ),
                        ),
                        const Icon(Icons.forum, color: Color(0xFF414844), size: 20),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Note 1 Pinned
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE5E2DF)),
                      ),
                      child: Stack(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Color(0xFF012D1D),
                                    ),
                                    child: Center(
                                      child: Text(
                                        'ME',
                                        style: GoogleFonts.inter(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Internal Note (TechFlow)',
                                    style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF012D1D)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Awaiting updated W-9 before processing INV-2026-089.',
                                style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF414844)),
                              ),
                            ],
                          ),
                          const Positioned(
                            top: 0,
                            right: 0,
                            child: Icon(Icons.push_pin, color: Color(0xFF0E6C4A), size: 16),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Message
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE5E2DF)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Color(0xFFE5E2DF),
                                    ),
                                    child: const Icon(Icons.person, size: 14, color: Color(0xFF414844)),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Client: Acme Corp',
                                    style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF012D1D)),
                                  ),
                                ],
                              ),
                              Text(
                                '10:42 AM',
                                style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFF717973)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'We uploaded the missing receipts for July.',
                            style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF414844)),
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () {},
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Reply',
                                  style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF0E6C4A)),
                                ),
                                const SizedBox(width: 4),
                                const Icon(Icons.reply, size: 12, color: Color(0xFF0E6C4A)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Input mock
                    Text(
                      'New Internal Note / Message',
                      style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF414844)),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      height: 80,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE5E2DF)),
                      ),
                      child: TextField(
                        maxLines: null,
                        decoration: InputDecoration(
                          hintText: 'Type here...',
                          hintStyle: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF717973)),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF1C1C1A),
                            side: const BorderSide(color: Color(0xFFC1C8C2)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                          ),
                          child: Text('Attach', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600)),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF012D1D),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                            elevation: 0,
                          ),
                          child: Text('Post', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKpiCard(String label, String value,
      {String? trendText, Color? trendColor, bool? isTrendUp, bool isPercentage = false, bool isUrgent = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF414844),
              letterSpacing: 0.03 * 11,
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: isUrgent ? const Color(0xFFA4161A) : const Color(0xFF012D1D),
                ),
              ),
              if (trendText != null) ...[
                const SizedBox(width: 4),
                Row(
                  children: [
                    Icon(
                      isTrendUp! ? Icons.trending_up : Icons.trending_down,
                      size: 14,
                      color: trendColor,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      trendText,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: trendColor,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQueueItem(
    String id,
    String subtitle,
    IconData icon, {
    required String badgeText,
    required Color badgeBgColor,
    required Color badgeTextColor,
    required bool isApproveBtn,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFF0EDE5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFF717973)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      id,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF012D1D),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: badgeBgColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        badgeText,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: badgeTextColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: const Color(0xFF414844),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          isApproveBtn
              ? ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0E6C4A), // secondary
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: Text('Approve', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600)),
                )
              : OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF1C1C1A),
                    side: const BorderSide(color: Color(0xFF717973)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: Text('Review', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600)),
                ),
        ],
      ),
    );
  }

  Widget _buildClientCard(
    String initial,
    String name,
    String foldersText,
    String badgeText,
    Color badgeBgColor,
    Color badgeTextColor,
    Color avatarBgColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E2DF)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: avatarBgColor,
            ),
            child: Center(
              child: Text(
                initial,
                style: GoogleFonts.inter(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF012D1D),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  foldersText,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFF414844),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: badgeBgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    badgeText,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: badgeTextColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
