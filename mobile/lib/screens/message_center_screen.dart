import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'secure_chat_screen.dart';
import '../widgets/fade_in_slide.dart';
import '../widgets/heavenly_interaction.dart';

class MessageCenterScreen extends StatefulWidget {
  const MessageCenterScreen({Key? key}) : super(key: key);

  @override
  State<MessageCenterScreen> createState() => _MessageCenterScreenState();
}

class _MessageCenterScreenState extends State<MessageCenterScreen> {
  String _activeFilter = 'All Messages';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF9F6), // bg-background
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top App Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFE5E2DF),
                      image: DecorationImage(
                        image: NetworkImage(
                          'https://lh3.googleusercontent.com/aida-public/AB6AXuCHer2fd8fIdpC7E46qINZ7zGThzIJaI_HHIoWRrwKb9mGbEVG7bnHZZU4qIyS_pLKUljhePnYl1ZIFKxoMhK8hBZ2wK7Mri3ihQSzwdXd_izZVcZv2xS5HYzRa-Tr6LYvJNLrlQXHeP2_CWJFqvTgZ_vS7G8yh1skVS9UB5NCUY1gQMPzakPlHiWNd4lHHjGY_3aDgl12LM6km7KBp7kFATPw8HcJVUTQ4LEt836cLEfloxfLyixvigsDLRjYmJUbdTDT1kPBdGxFE',
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
                      icon: const Icon(Icons.security, color: Color(0xFF414844)),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            ),

            // Messages Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                'Messages',
                style: GoogleFonts.inter(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A1C1B),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Search conversation bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0EDE9), // surface-cream-dark
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFC1C8C2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Color(0xFF717973), size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search conversations...',
                          hintStyle: GoogleFonts.inter(fontSize: 16, color: const Color(0xFF717973)),
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
            ),
            const SizedBox(height: 16),

            // Horizontal filters
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildFilterChip('All Messages'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Internal Team'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Clients'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Unread'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Message List
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  // Unread item 1: Sarah Jenkins
                  FadeInSlide(
                    delay: const Duration(milliseconds: 100),
                    child: _buildConversationItem(
                      name: 'Sarah Jenkins (CFO)',
                      message: 'IBAN mismatch resolved for Q3 invoice.',
                      time: '09:41 AM',
                      imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuB2P0mz9vcw675nfMW7uxtpn9RvUlVSOx2pldqTVWpy3HRpjS2EThKBcRqvGuh3xScWKuC4XJXwS5l5SmDANo9hiwMIeRqDN2z0Rsfs38PHAO7FWKbkvqSVGZht0ZGQL_BlUJIJ4eFY3v8REB1vgBVIfbnzCuZtTqxRXmFzpS7UJvydIsXQNsg_g0x6qyy8o0hExNP53bKpygkk7TCuczpiq1LR-9I1mORqz7rEYmLVwibztzmIVJ8lc83K6RKdY01PLYrvOO1WHil0',
                      unreadCount: 2,
                      isOnline: true,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SecureChatScreen()),
                        );
                      },
                    ),
                  ),
                  const Divider(indent: 24, endIndent: 24, color: Color(0xFFE5E2DF)),

                  // Item 2: Acme Corp Billing
                  FadeInSlide(
                    delay: const Duration(milliseconds: 200),
                    child: _buildConversationItem(
                      name: 'Acme Corp Billing',
                      message: 'The monthly report is ready for your review.',
                      time: 'Yesterday',
                      imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuC7sxzwPFaovqzlZS-lunBcbpV_mgihz4rnYpqvhLTzZkBZFO1nmhKuHEHnMulvdQ0cg_OdY47u3rjLSrMaAnF6MNwEdVvhJtJN-oy4C_wPYlJANY4pGQ-zmdk1pDvKUpLzZmwMJ2hoYlh-NGw-OSukGQsAk4Mpg7WZ160RBUG6pPiyiBme3v2l_lfZKfF63EcbbxvC6BlLhGlj156llP40_4q9sjOg09PdRytXKQ128WmlZRAbdJ9_OFxZUfLLKJvoWyuLw-zEEStL',
                      onTap: () {},
                    ),
                  ),
                  const Divider(indent: 24, endIndent: 24, color: Color(0xFFE5E2DF)),

                  // Item 3: Michael Ross (Legal)
                  FadeInSlide(
                    delay: const Duration(milliseconds: 300),
                    child: _buildConversationItem(
                      name: 'Michael Ross (Legal)',
                      message: 'Contracts have been uploaded to the vault.',
                      time: 'Tue',
                      fallbackInitials: 'MR',
                      onTap: () {},
                    ),
                  ),
                  const Divider(indent: 24, endIndent: 24, color: Color(0xFFE5E2DF)),

                  // Item 4: Emma Watson (Accountant)
                  FadeInSlide(
                    delay: const Duration(milliseconds: 400),
                    child: _buildConversationItem(
                      name: 'Emma Watson (Accountant)',
                      message: 'Please approve the pending wire transfer.',
                      time: 'Oct 12',
                      imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCAm-_ET7BeCjf2I3WP-DjiXn8IivggT98x6To9A_aYrewLHtx8nTpQTMkG2QDhaefzxHdSfN4yivrq1cse2yDGSxPVoEfMlJKX8GF0F5Dyd-QOV_wdxZCD55GT9cBudeYACPISPDId_UaZS9qfNMDGkU6R6aDEy9Kn9EUzcfYEwHGanPMPtajzn6ZN5m5BabP9qLK2fBOPAM0aQkMtl9ERHIsleuwgwb_2M5MEYLS6L1O5yqI2rJC3n8RsScTWnlwCMRNHj9Npv2TJ',
                      onTap: () {},
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

  Widget _buildFilterChip(String label) {
    final isActive = _activeFilter == label;
    return GestureDetector(
      onTap: () => setState(() => _activeFilter = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF012D1D) : const Color(0xFFE5E2DF),
          borderRadius: BorderRadius.circular(20),
          border: isActive ? null : Border.all(color: const Color(0xFFC1C8C2)),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isActive ? Colors.white : const Color(0xFF414844),
          ),
        ),
      ),
    );
  }

  Widget _buildConversationItem({
    required String name,
    required String message,
    required String time,
    String? imageUrl,
    String? fallbackInitials,
    int unreadCount = 0,
    bool isOnline = false,
    required VoidCallback onTap,
  }) {
    final isUnread = unreadCount > 0;
    return HeavenlyInteraction(
      onTap: onTap,
      scaleDown: 0.98,
      hoverScale: 1.01,
      child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            children: [
              // Avatar
              Stack(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: imageUrl == null ? const Color(0xFFF0EDE9) : Colors.transparent,
                      image: imageUrl != null
                          ? DecorationImage(
                              image: NetworkImage(imageUrl),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: imageUrl == null
                        ? Center(
                            child: Text(
                              fallbackInitials ?? '',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF012D1D),
                              ),
                            ),
                          )
                        : null,
                  ),
                  if (isOnline)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: const Color(0xFFB8F04A), // secondary-fixed
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),

              // Title, subtitle & badge
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: GoogleFonts.inter(
                              fontSize: isUnread ? 16 : 16,
                              fontWeight: isUnread ? FontWeight.w700 : FontWeight.w600,
                              color: const Color(0xFF1A1C1B),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          time,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: isUnread ? const Color(0xFF012D1D) : const Color(0xFF414844),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            message,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: isUnread ? FontWeight.w600 : FontWeight.w400,
                              color: isUnread ? const Color(0xFF1A1C1B) : const Color(0xFF414844),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isUnread) ...[
                          const SizedBox(width: 8),
                          Container(
                            width: 20,
                            height: 20,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF012D1D), // primary
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              unreadCount.toString(),
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
    );
  }
}
