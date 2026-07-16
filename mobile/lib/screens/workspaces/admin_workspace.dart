import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../notification_screen.dart';
import '../../widgets/fade_in_slide.dart';

import '../../widgets/heavenly_interaction.dart';

class AdminWorkspace extends StatelessWidget {
  final VoidCallback onScanPressed;
  
  const AdminWorkspace({Key? key, required this.onScanPressed}) : super(key: key);

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
                          'https://lh3.googleusercontent.com/aida-public/AB6AXuCvvHJZhbJ0PcTUfHDjlcANCqwHNCwo6o3QeU5Wmmp4K5owz5g4m8t_PvzIr_-CcsUO1b-IBWs94yf6z8xT3jbJI4Xwkzw69NXtNE2njMg1V7aICuwUMH_IWMRbmsORClZ55Ql2pVE9iQ0vzedkD0AzUX48KooF347aKLSyB3MAN8zfKs4G1GUtu_VjjHl_Ojx55pLwQMbOMMUL0Pf1efNb-arO9BDvF6A8O72iwjS4uIDFBGgUpLql1zRdd3fRKenpMabMHGUsVlWy',
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

              // Greeting Section
              FadeInSlide(
                delay: const Duration(milliseconds: 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'WELCOME BACK',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF414844),
                        letterSpacing: 0.05 * 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Hello, Yassine',
                      style: GoogleFonts.inter(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1A1C1B),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // KPI Cards Grid (Bento Style)
              FadeInSlide(
                delay: const Duration(milliseconds: 200),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF6F3F0), // surface-container-low
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFEAE8E5)),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1A1C1B).withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Inflow',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF19724F), // on-secondary-container
                              letterSpacing: 0.05 * 12,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                '\$42,850',
                                style: GoogleFonts.inter(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF012D1D),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '+12.5%',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF0E6C4A), // secondary
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Positioned(
                        right: -10,
                        top: -10,
                        child: Opacity(
                          opacity: 0.05,
                          child: const Icon(
                            Icons.payments,
                            size: 80,
                            color: Color(0xFF012D1D),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              FadeInSlide(
                delay: const Duration(milliseconds: 300),
                child: Row(
                  children: [
                    // Outflow Card
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFFFF), // surface-container-lowest
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFEAE8E5)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Outflow',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF717973), // outline
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '\$12,400',
                              style: GoogleFonts.inter(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF1A1C1B),
                              ),
                            ),
                            const SizedBox(height: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(2),
                              child: const SizedBox(
                                height: 4,
                                child: LinearProgressIndicator(
                                  value: 0.45,
                                  backgroundColor: Color(0xFFF0EDE5),
                                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFA4161A)), // error-crimson
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Pending Card
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFFFF), // surface-container-lowest
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFEAE8E5)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pending',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF717973), // outline
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '\$8,210',
                              style: GoogleFonts.inter(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF1A1C1B),
                              ),
                            ),
                            const SizedBox(height: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(2),
                              child: const SizedBox(
                                height: 4,
                                child: LinearProgressIndicator(
                                  value: 0.25,
                                  backgroundColor: Color(0xFFF0EDE5),
                                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0E6C4A)), // secondary
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              FadeInSlide(
                delay: const Duration(milliseconds: 400),
                child: Container(
                  height: 220,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFF012D1D), // primary
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Stack(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Cashflow Analytics',
                            style: GoogleFonts.inter(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Visualizing last 30 days performance',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFFA5D0B9), // primary-fixed-dim
                            ),
                          ),
                          const Spacer(),
                          const _CashflowChart(),
                        ],
                      ),
                      Positioned(
                        right: -30,
                        top: -30,
                        child: Opacity(
                          opacity: 0.2,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFFA0F4C8), // secondary-fixed
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              FadeInSlide(
                delay: const Duration(milliseconds: 500),
                child: HeavenlyInteraction(
                  onTap: onScanPressed,
                  scaleDown: 0.96,
                  hoverScale: 1.02,
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: null, // Let HeavenlyInteraction handle the tap gesture
                      icon: const Icon(Icons.add_a_photo, color: Colors.white),
                      label: Text(
                        'Scan New Invoice',
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF012D1D),
                        disabledBackgroundColor: const Color(0xFF012D1D), // Keep color when disabled
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 4,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Recent Activity
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Activity',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A1C1B),
                    ),
                  ),
                  Text(
                    'View All',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF0E6C4A),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              _buildActivityItem(
                title: 'Global Logistics Inc.',
                subtitle: 'Today, 10:24 AM',
                amount: '\$1,240.00',
                status: 'Validated',
                statusBgColor: const Color(0xFFB7E4C7).withOpacity(0.2), // muted-sage
                statusTextColor: const Color(0xFF0E6C4A),
                icon: Icons.receipt_long,
              ),
              const SizedBox(height: 12),
              _buildActivityItem(
                title: 'Cloud Systems SA',
                subtitle: 'Yesterday, 4:45 PM',
                amount: '\$842.20',
                status: 'Pending',
                statusBgColor: const Color(0xFFEAE8E5), // surface-container-high
                statusTextColor: const Color(0xFF414844),
                icon: Icons.description,
              ),
              const SizedBox(height: 12),
              _buildActivityItem(
                title: 'Office Supplies Corp',
                subtitle: 'Nov 12, 09:12 AM',
                amount: '\$156.00',
                status: 'Rejected',
                statusBgColor: const Color(0xFFFFDAD6), // error-container (fallbacks to container error red)
                statusTextColor: const Color(0xFFA4161A), // error-crimson
                icon: Icons.request_quote,
              ),
              const SizedBox(height: 100), // Padding to avoid overlap with bottom nav
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityItem({
    required String title,
    required String subtitle,
    required String amount,
    required String status,
    required Color statusBgColor,
    required Color statusTextColor,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF), // surface-container-lowest
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEAE8E5)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFF0EDE5), // surface-container
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF012D1D)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF1A1C1B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF717973),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF1A1C1B),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: statusBgColor,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Text(
                  status,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: statusTextColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CashflowChart extends StatefulWidget {
  const _CashflowChart({Key? key}) : super(key: key);

  @override
  State<_CashflowChart> createState() => _CashflowChartState();
}

class _CashflowChartState extends State<_CashflowChart> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildBar(0.30 * _animation.value, isHighlight: false),
            _buildBar(0.45 * _animation.value, isHighlight: false),
            _buildBar(0.60 * _animation.value, isHighlight: false),
            _buildBar(0.85 * _animation.value, isHighlight: true),
            _buildBar(0.55 * _animation.value, isHighlight: false),
            _buildBar(0.70 * _animation.value, isHighlight: false),
            _buildBar(0.95 * _animation.value, isHighlight: true, hasGlow: true),
          ],
        );
      },
    );
  }

  Widget _buildBar(double heightFactor, {required bool isHighlight, bool hasGlow = false}) {
    return Container(
      width: 24,
      height: 96 * heightFactor,
      decoration: BoxDecoration(
        color: isHighlight
            ? const Color(0xFFB8F04A).withOpacity(0.8) // accent
            : const Color(0xFFA5D0B9).withOpacity(0.2), // primary-fixed-dim
        borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
        border: isHighlight
            ? const Border(top: BorderSide(color: Color(0xFFA0F4C8), width: 2)) // secondary-fixed
            : null,
        boxShadow: hasGlow
            ? [
                BoxShadow(
                  color: const Color(0xFFA0F4C8).withOpacity(0.3),
                  blurRadius: 15,
                  spreadRadius: 2,
                )
              ]
            : null,
      ),
    );
  }
}
