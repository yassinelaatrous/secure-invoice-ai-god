import 'dart:ui';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../models/invoice.dart';
import '../widgets/status_badge.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';
import 'capture_screen.dart';
import 'profile_screen.dart';
import 'invoice_detail_modal.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  late List<Widget> _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = [
      HomeTab(onScanTap: () {
        setState(() {
          _currentIndex = 1;
        });
      }),
      const CaptureScreen(),
      const ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: Stack(
        children: [
          IndexedStack(
            index: _currentIndex,
            children: _tabs,
          ),

          // Liquid Glass Floating Bottom Navigation Bar
          Positioned(
            left: 20,
            right: 20,
            bottom: bottomPad + 12,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                child: Container(
                  height: 68,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.92),
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(color: Colors.white.withOpacity(0.15), width: 1.5),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildBottomTab(0, 'Home', Icons.home_filled, Icons.home_outlined),
                      _buildCaptureButton(),
                      _buildBottomTab(2, 'Profile', Icons.person, Icons.person_outline),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomTab(int index, String label, IconData activeIcon, IconData inactiveIcon) {
    final isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.accent.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : inactiveIcon,
              color: isActive ? AppTheme.accent : Colors.white.withOpacity(0.6),
              size: 24,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive ? AppTheme.accent : Colors.white.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCaptureButton() {
    final isActive = _currentIndex == 1;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = 1;
        });
      },
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: AppTheme.accent,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppTheme.accent.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: isActive ? Colors.white : Colors.transparent,
            width: 2,
          ),
        ),
        child: const Center(
          child: Icon(
            Icons.crop_free_rounded,
            color: AppTheme.primary,
            size: 26,
          ),
        ),
      ),
    );
  }
}

// HOME TAB CONTENT
class HomeTab extends StatefulWidget {
  final VoidCallback onScanTap;
  const HomeTab({Key? key, required this.onScanTap}) : super(key: key);

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  Map<String, dynamic>? _user;
  List<Invoice> _invoices = [];
  Map<String, dynamic> _stats = {};
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final user = await AuthService.getUserInfo();
      final invoices = await ApiService.getInvoices();
      final stats = await ApiService.getDashboardStats();

      if (mounted) {
        setState(() {
          _user = user;
          _invoices = invoices;
          _stats = stats;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  // ── Computed values from real invoice data ───────────────────────

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return 'Good morning';
    if (hour >= 12 && hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String _getGreetingName() {
    if (_user == null) return 'there';
    final nom = _user!['nom']?.toString();
    if (nom == null || nom.isEmpty) return 'there';
    return nom;
  }

  double _computeInflow() {
    return _invoices
        .where((inv) => inv.statut == 'validee' || inv.statut == 'controlee')
        .fold(0.0, (sum, inv) => sum + inv.montantTtc);
  }

  double _computeOutflow() {
    return _invoices
        .where((inv) => inv.statut == 'rejete' || inv.statut == 'rejetee')
        .fold(0.0, (sum, inv) => sum + inv.montantTtc);
  }

  double _computePending() {
    return _invoices
        .where((inv) => inv.statut == 'brouillon' || inv.statut == 'nouveau')
        .fold(0.0, (sum, inv) => sum + inv.montantTtc);
  }

  double _computeTotalTtc() {
    return _invoices.fold(0.0, (sum, inv) => sum + inv.montantTtc);
  }

  String _formatCompact(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return value.toStringAsFixed(0);
  }

  List<double> _computeBarChartValues() {
    if (_invoices.isEmpty) return List.filled(7, 0.1);
    final recentInvoices = _invoices.take(13).toList();
    final amounts = recentInvoices.map((inv) => inv.montantTtc).toList();
    final maxVal = amounts.reduce(max);
    if (maxVal == 0) return List.filled(amounts.length, 0.1);
    return amounts.map((a) => max(0.05, a / maxVal)).toList();
  }

  String _computeAiInsight() {
    if (_invoices.isEmpty) {
      return 'No invoices available for analysis. Upload your first invoice to get started.';
    }
    final highFraud = _invoices.where((inv) => inv.fraudScore > 0.6).toList();
    if (highFraud.isNotEmpty) {
      final names = highFraud.take(3).map((inv) => inv.fournisseur).join(', ');
      return '${highFraud.length} invoice${highFraud.length > 1 ? 's' : ''} with elevated fraud risk detected: $names. Manual review recommended.';
    }
    final pendingCount = _invoices.where((inv) => inv.statut == 'nouveau' || inv.statut == 'brouillon').length;
    if (pendingCount > 0) {
      return '$pendingCount invoice${pendingCount > 1 ? 's' : ''} pending verification. All processed invoices pass compliance checks.';
    }
    return 'All invoices pass compliance checks. No anomalies detected.';
  }

  String _getSubtitleText() {
    final count = _invoices.length;
    final pendingCount = _invoices.where((inv) => inv.statut == 'nouveau' || inv.statut == 'brouillon').length;
    if (pendingCount > 0) {
      return '$count invoices reconciled. $pendingCount require${pendingCount > 1 ? '' : 's'} your attention.';
    }
    return '$count invoices reconciled. All clear.';
  }

  // ── Search dialog ───────────────────────────────────────────────

  void _showSearchDialog() {
    final searchController = TextEditingController();
    List<Invoice> filtered = List.from(_invoices);

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            void doFilter(String query) {
              final q = query.toLowerCase();
              setDialogState(() {
                filtered = _invoices.where((inv) {
                  return inv.fournisseur.toLowerCase().contains(q) ||
                      inv.numero.toLowerCase().contains(q);
                }).toList();
              });
            }

            return Dialog(
              backgroundColor: AppTheme.backgroundLight,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Search Invoices',
                      style: GoogleFonts.fraunces(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: searchController,
                      onChanged: doFilter,
                      style: GoogleFonts.dmSans(color: AppTheme.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'Fournisseur ou numéro...',
                        hintStyle: GoogleFonts.dmSans(color: AppTheme.textMuted),
                        prefixIcon: const Icon(Icons.search, color: AppTheme.textMuted),
                        filled: true,
                        fillColor: AppTheme.surfaceCard,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: AppTheme.cardBorder),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: AppTheme.cardBorder),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(ctx).size.height * 0.5,
                      ),
                      child: filtered.isEmpty
                          ? Padding(
                              padding: const EdgeInsets.symmetric(vertical: 24),
                              child: Text(
                                'No invoices found.',
                                style: GoogleFonts.dmSans(color: AppTheme.textMuted),
                              ),
                            )
                          : ListView.separated(
                              shrinkWrap: true,
                              itemCount: filtered.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 8),
                              itemBuilder: (_, i) {
                                final inv = filtered[i];
                                return _buildCompactInvoiceTile(inv, popOnTap: true);
                              },
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ── Notification bottom sheet ───────────────────────────────────

  void _showNotificationsSheet() {
    final now = DateTime.now();
    final todayInvoices = _invoices.where((inv) {
      return inv.dateReception.year == now.year &&
          inv.dateReception.month == now.month &&
          inv.dateReception.day == now.day;
    }).toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.backgroundLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.cardBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Recent Activity',
                style: GoogleFonts.fraunces(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Invoices created or modified today',
                style: GoogleFonts.dmSans(fontSize: 12, color: AppTheme.textMuted),
              ),
              const SizedBox(height: 16),
              if (todayInvoices.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text(
                      'No activity today.',
                      style: GoogleFonts.dmSans(fontSize: 14, color: AppTheme.textMuted),
                    ),
                  ),
                )
              else
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 300),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: todayInvoices.length,
                    separatorBuilder: (_, __) => const Divider(color: AppTheme.cardBorder, height: 1),
                    itemBuilder: (_, i) {
                      final inv = todayInvoices[i];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppTheme.accent.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.receipt_long_rounded, color: AppTheme.primary, size: 20),
                        ),
                        title: Text(
                          inv.fournisseur,
                          style: GoogleFonts.dmSans(fontWeight: FontWeight.w700, fontSize: 14, color: AppTheme.textPrimary),
                        ),
                        subtitle: Text(
                          'N° ${inv.numero} · ${inv.montantTtc.toStringAsFixed(2)} ${inv.devise}',
                          style: GoogleFonts.dmSans(fontSize: 12, color: AppTheme.textSecondary),
                        ),
                        trailing: StatusBadge(status: inv.statut),
                        onTap: () {
                          Navigator.pop(ctx);
                          InvoiceDetailModal.show(context, inv, onActionComplete: _loadData);
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  // ── Verify bottom sheet ─────────────────────────────────────────

  void _showVerifySheet() {
    final nouveauInvoices = _invoices.where((inv) => inv.statut == 'nouveau').toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.backgroundLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.3,
          maxChildSize: 0.85,
          expand: false,
          builder: (ctx, scrollController) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppTheme.cardBorder,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Invoices to Verify',
                    style: GoogleFonts.fraunces(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${nouveauInvoices.length} invoice${nouveauInvoices.length != 1 ? 's' : ''} with status "nouveau"',
                    style: GoogleFonts.dmSans(fontSize: 12, color: AppTheme.textMuted),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: nouveauInvoices.isEmpty
                        ? Center(
                            child: Text(
                              'All invoices have been verified.',
                              style: GoogleFonts.dmSans(fontSize: 14, color: AppTheme.textMuted),
                            ),
                          )
                        : ListView.separated(
                            controller: scrollController,
                            itemCount: nouveauInvoices.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 10),
                            itemBuilder: (_, i) {
                              return _buildCompactInvoiceTile(nouveauInvoices[i]);
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ── Pay bottom sheet ────────────────────────────────────────────

  void _showPaySheet() {
    final validatedInvoices = _invoices
        .where((inv) => inv.statut == 'validee' || inv.statut == 'controlee')
        .toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.backgroundLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.3,
          maxChildSize: 0.85,
          expand: false,
          builder: (ctx, scrollController) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppTheme.cardBorder,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Ready for Payment',
                    style: GoogleFonts.fraunces(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${validatedInvoices.length} validated invoice${validatedInvoices.length != 1 ? 's' : ''}',
                    style: GoogleFonts.dmSans(fontSize: 12, color: AppTheme.textMuted),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: validatedInvoices.isEmpty
                        ? Center(
                            child: Text(
                              'No validated invoices ready for payment.',
                              style: GoogleFonts.dmSans(fontSize: 14, color: AppTheme.textMuted),
                            ),
                          )
                        : ListView.separated(
                            controller: scrollController,
                            itemCount: validatedInvoices.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 10),
                            itemBuilder: (_, i) {
                              return _buildCompactInvoiceTile(validatedInvoices[i]);
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ── View all invoices dialog ────────────────────────────────────

  void _showViewAllDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: AppTheme.backgroundLight,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 32),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'All Invoices',
                      style: GoogleFonts.fraunces(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primary,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(ctx),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceCard,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppTheme.cardBorder),
                        ),
                        child: const Icon(Icons.close, size: 16, color: AppTheme.textPrimary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${_invoices.length} factures',
                    style: GoogleFonts.dmSans(fontSize: 12, color: AppTheme.textMuted),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: _invoices.isEmpty
                      ? Center(
                          child: Text(
                            'No invoices found.',
                            style: GoogleFonts.dmSans(color: AppTheme.textMuted),
                          ),
                        )
                      : ListView.separated(
                          itemCount: _invoices.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (_, i) {
                            return _buildCompactInvoiceTile(_invoices[i], popOnTap: true);
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Compact invoice tile used in sheets/dialogs ─────────────────

  Widget _buildCompactInvoiceTile(Invoice invoice, {bool popOnTap = false}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.cardBorder.withOpacity(0.5)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            if (popOnTap) Navigator.pop(context);
            InvoiceDetailModal.show(context, invoice, onActionComplete: _loadData);
          },
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Icon(Icons.business_outlined, color: AppTheme.primary.withOpacity(0.7), size: 18),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        invoice.fournisseur,
                        style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'N° ${invoice.numero}',
                        style: GoogleFonts.dmSans(fontSize: 11, color: AppTheme.textMuted),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${NumberFormat('#,##0.00', 'fr').format(invoice.montantTtc)} ${invoice.devise}',
                      style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
                    ),
                    const SizedBox(height: 4),
                    StatusBadge(status: invoice.statut),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Main build ──────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final String greetingName = _getGreetingName();
    final int invoiceCount = _invoices.length;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : _error.isNotEmpty
              ? _buildErrorView()
              : RefreshIndicator(
                  color: AppTheme.primary,
                  backgroundColor: Colors.white,
                  onRefresh: _loadData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 54, 20, 100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Header Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: const BoxDecoration(
                                    color: AppTheme.primary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Center(
                                    child: Text(
                                      'C',
                                      style: TextStyle(color: AppTheme.accent, fontWeight: FontWeight.w900, fontSize: 16, fontStyle: FontStyle.italic),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'CEO IT',
                                      style: GoogleFonts.fraunces(fontWeight: FontWeight.w800, fontSize: 16, color: AppTheme.primary),
                                    ),
                                    Text(
                                      'SECURE · INVOICE · AI',
                                      style: GoogleFonts.dmSans(fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 0.6, color: AppTheme.primary.withOpacity(0.6)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                _buildCircularIconButton(Icons.search_rounded, onTap: _showSearchDialog),
                                const SizedBox(width: 8),
                                _buildCircularIconButton(
                                  Icons.notifications_none_rounded,
                                  showBadge: _invoices.any((inv) =>
                                      inv.dateReception.year == DateTime.now().year &&
                                      inv.dateReception.month == DateTime.now().month &&
                                      inv.dateReception.day == DateTime.now().day),
                                  onTap: _showNotificationsSheet,
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Greeting
                        Text(
                          _getDateString(),
                          style: GoogleFonts.dmSans(fontSize: 13, color: AppTheme.primary.withOpacity(0.6), fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 4),
                        Text.rich(
                          TextSpan(
                            text: '${_getGreeting()},\n',
                            style: GoogleFonts.dmSans(fontSize: 26, fontWeight: FontWeight.w400, color: AppTheme.primary),
                            children: [
                              TextSpan(
                                text: '$greetingName.',
                                style: GoogleFonts.fraunces(fontWeight: FontWeight.w700, fontStyle: FontStyle.italic),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _getSubtitleText(),
                          style: GoogleFonts.dmSans(fontSize: 13, color: AppTheme.primary.withOpacity(0.6)),
                        ),
                        const SizedBox(height: 24),

                        // Cash Position Card
                        _buildCashPositionCard(),
                        const SizedBox(height: 20),

                        // Quick Actions
                        _buildQuickActionsRow(),
                        const SizedBox(height: 20),

                        // AI Insight Panel
                        _buildAiInsightPanel(),
                        const SizedBox(height: 24),

                        // Recent Invoices Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Recent invoices',
                              style: GoogleFonts.fraunces(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.primary),
                            ),
                            GestureDetector(
                              onTap: _showViewAllDialog,
                              child: Text(
                                'View all',
                                style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.primary.withOpacity(0.6)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Invoices List
                        if (_invoices.isEmpty)
                          _buildEmptyView()
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _invoices.take(5).length,
                            separatorBuilder: (context, index) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final invoice = _invoices[index];
                              return _buildInvoiceRowCard(invoice);
                            },
                          ),
                      ],
                    ),
                  ),
                ),
    );
  }

  // ── Error view with retry ───────────────────────────────────────

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.6),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppTheme.error.withOpacity(0.2)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppTheme.error.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.cloud_off_rounded, color: AppTheme.error, size: 28),
              ),
              const SizedBox(height: 16),
              Text(
                'Connection Error',
                style: GoogleFonts.fraunces(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _error,
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(fontSize: 13, color: AppTheme.textSecondary, height: 1.4),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _loadData,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: Text('Retry', style: GoogleFonts.dmSans(fontWeight: FontWeight.w700)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCircularIconButton(IconData icon, {bool showBadge = false, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.5),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.black.withOpacity(0.05)),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(icon, color: AppTheme.primary, size: 20),
            if (showBadge)
              Positioned(
                right: 10,
                top: 10,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppTheme.error,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCashPositionCard() {
    final double totalTtc = _computeTotalTtc();
    final currencyFormat = NumberFormat('#,##0', 'en_US');
    final String wholePart = currencyFormat.format(totalTtc.truncate());
    final String decimalPart = '.${(totalTtc - totalTtc.truncate()).toStringAsFixed(2).split('.').last}';

    final double inflow = _computeInflow();
    final double outflow = _computeOutflow();
    final double pending = _computePending();

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppTheme.primary,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              Text(
                'CASH POSITION',
                style: GoogleFonts.dmSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Colors.white.withOpacity(0.5),
                  letterSpacing: 1.2,
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  Icon(
                    Icons.verified_user_outlined,
                    size: 13,
                    color: Colors.white.withOpacity(0.5),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'SIGNED',
                    style: GoogleFonts.dmSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.white.withOpacity(0.5),
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Amount
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$$wholePart',
                style: GoogleFonts.fraunces(
                  fontSize: 36,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  height: 1.0,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text(
                  decimalPart,
                  style: GoogleFonts.fraunces(
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withOpacity(0.7),
                    height: 1.0,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Invoice count badge (replaces hardcoded +12.4%)
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.accent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.receipt_long_rounded,
                      size: 11,
                      color: AppTheme.primary,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      '${_invoices.length} factures',
                      style: GoogleFonts.dmSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'total portfolio',
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Bar Chart (dynamic from real data)
          _buildBarChart(),
          const SizedBox(height: 18),

          // Divider
          Divider(color: Colors.white.withOpacity(0.1), height: 1),
          const SizedBox(height: 14),

          // Stats Row (computed from real data)
          Row(
            children: [
              _StatItem(label: 'INFLOW', value: '\$${_formatCompact(inflow)}'),
              _StatItem(label: 'OUTFLOW', value: '\$${_formatCompact(outflow)}'),
              _StatItem(label: 'PENDING', value: '\$${_formatCompact(pending)}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart() {
    final values = _computeBarChartValues();
    return SizedBox(
      height: 48,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: values.asMap().entries.map((entry) {
          final isLast = entry.key == values.length - 1;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2.5),
              child: Container(
                height: 48 * entry.value,
                decoration: BoxDecoration(
                  color: isLast ? AppTheme.accent : Colors.white.withOpacity(0.15),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildQuickActionsRow() {
    final actions = [
      _ActionData(icon: Icons.crop_free_rounded, label: 'Scan', onTap: widget.onScanTap),
      _ActionData(icon: Icons.auto_awesome_outlined, label: 'Ask AI', onTap: widget.onScanTap),
      _ActionData(icon: Icons.verified_user_outlined, label: 'Verify', onTap: _showVerifySheet),
      _ActionData(icon: Icons.south_west_rounded, label: 'Pay', onTap: _showPaySheet),
    ];

    return Row(
      children: actions.map((action) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: GestureDetector(
              onTap: action.onTap,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.black.withOpacity(0.04)),
                ),
                child: Column(
                  children: [
                    Icon(action.icon, size: 22, color: AppTheme.primary),
                    const SizedBox(height: 6),
                    Text(
                      action.label,
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAiInsightPanel() {
    final now = DateTime.now();
    final timeStr = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withOpacity(0.04)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.accent.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.auto_awesome_outlined, color: AppTheme.primary, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'AI INSIGHT',
                      style: GoogleFonts.dmSans(fontSize: 10, fontWeight: FontWeight.w800, color: AppTheme.primary, letterSpacing: 0.8),
                    ),
                    const Spacer(),
                    Text(
                      timeStr,
                      style: GoogleFonts.dmSans(fontSize: 10, color: AppTheme.primary.withOpacity(0.4), fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '"${_computeAiInsight()}"',
                  style: GoogleFonts.dmSans(fontSize: 12, color: AppTheme.primary.withOpacity(0.8), height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceRowCard(Invoice invoice) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withOpacity(0.03)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            InvoiceDetailModal.show(context, invoice, onActionComplete: _loadData);
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Vendor Icon
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Icon(Icons.business_outlined, color: AppTheme.primary.withOpacity(0.7), size: 20),
                  ),
                ),
                const SizedBox(width: 12),

                // Invoice details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        invoice.fournisseur,
                        style: GoogleFonts.dmSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'N° ${invoice.numero}',
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          color: AppTheme.primary.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ),

                // Amount & Status Badge
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${NumberFormat('#,##0.00', 'fr').format(invoice.montantTtc)} ${invoice.devise}',
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.primary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    StatusBadge(status: invoice.statut),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyView() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withOpacity(0.04)),
      ),
      child: Column(
        children: [
          Icon(Icons.receipt_long_rounded, size: 40, color: AppTheme.primary.withOpacity(0.3)),
          const SizedBox(height: 12),
          Text(
            'No invoices found',
            style: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.primary),
          ),
          const SizedBox(height: 4),
          Text(
            'Upload a document in the Capture tab.',
            style: GoogleFonts.dmSans(color: AppTheme.primary.withOpacity(0.5), fontSize: 12),
          ),
        ],
      ),
    );
  }

  String _getDateString() {
    final now = DateTime.now();
    final weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${weekdays[now.weekday - 1]} · ${now.day} ${months[now.month - 1]}';
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Colors.white.withOpacity(0.4),
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: GoogleFonts.dmSans(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionData {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ActionData({
    required this.icon,
    required this.label,
    required this.onTap,
  });
}
