import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../models/invoice.dart';
import '../widgets/kpi_card.dart';
import '../widgets/status_badge.dart';
import 'login_screen.dart';
import 'capture_screen.dart';
import 'pdf_import_screen.dart';
import 'profile_screen.dart';
import 'invoice_detail_modal.dart'; // We'll create this details viewer

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  
  // Navigation tabs
  late List<Widget> _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = [
      const HomeTab(),
      const CaptureScreen(),
      const PdfImportScreen(),
      const ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 15,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF4F46E5), // Indigo
          unselectedItemColor: const Color(0xFF8F9199),
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 11),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard_rounded),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.camera_alt_outlined),
              activeIcon: Icon(Icons.camera_alt_rounded),
              label: 'Capture OCR',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.picture_as_pdf_outlined),
              activeIcon: Icon(Icons.picture_as_pdf_rounded),
              label: 'Import PDF',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person_rounded),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}

// HOME TAB CONTENT
class HomeTab extends StatefulWidget {
  const HomeTab({Key? key}) : super(key: key);

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

  @override
  Widget build(BuildContext context) {
    final String greeting = _user != null ? 'Bonjour, ${_user!['full_name']}' : 'Bonjour';
    final String roleLabel = _user != null 
        ? (_user!['role'] == 'client' ? 'Espace Client' : _user!['role'] == 'comptable' ? 'Espace Comptable' : 'Administrateur')
        : '';

    return Scaffold(
      backgroundColor: const Color(0xFFEAEAEE),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: Color(0xFF4F46E5),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  _user != null && _user!['full_name'] != null
                      ? _user!['full_name'].toString().substring(0, 1).toUpperCase()
                      : 'U',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  greeting,
                  style: const TextStyle(
                    color: Color(0xFF12100F),
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  roleLabel,
                  style: const TextStyle(
                    color: Color(0xFF5F6168),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF4F46E5)),
            onPressed: _loadData,
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
            onPressed: () async {
              await AuthService.logout();
              if (mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? _buildErrorView()
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // KPI Grid (2x2 or row layout)
                        _buildKpisSection(),
                        const SizedBox(height: 24),
                        
                        // Recent Invoices Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.between,
                          children: [
                            const Text(
                              'Factures Récentes',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                fontFamily: 'Outfit',
                              ),
                            ),
                            TextButton(
                              onPressed: _loadData,
                              child: const Text('Tout voir'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

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
                              return _buildInvoiceCard(invoice);
                            },
                          ),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildKpisSection() {
    final int totalCount = _stats['total_invoices'] ?? _invoices.length;
    final double complianceRate = double.tryParse(_stats['compliance_rate']?.toString() ?? '') ?? 100.0;
    final double avgFraudScore = double.tryParse(_stats['avg_fraud_score']?.toString() ?? '') ?? 0.0;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: KpiCard(
                title: 'Total Factures',
                value: '$totalCount',
                icon: Icons.receipt_outlined,
                backgroundColor: Colors.white,
                textColor: const Color(0xFF12100F),
                iconBgColor: const Color(0xFFF0F5FF),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: KpiCard(
                title: 'Conformité',
                value: '${complianceRate.toStringAsFixed(0)}%',
                icon: Icons.check_circle_outline_rounded,
                backgroundColor: const Color(0xFFE6F7F5),
                textColor: const Color(0xFF0D9488),
                iconBgColor: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: KpiCard(
                title: 'Risque Fraude',
                value: '${avgFraudScore.toStringAsFixed(0)}%',
                icon: Icons.gpp_maybe_outlined,
                backgroundColor: const Color(0xFFFDF2F4),
                textColor: const Color(0xFFDB2777),
                iconBgColor: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: KpiCard(
                title: 'A vérifier',
                value: '${_invoices.where((i) => i.statut == 'nouveau' || i.statut == 'en_verification').length}',
                icon: Icons.pending_actions_rounded,
                backgroundColor: const Color(0xFFFFF7ED),
                textColor: const Color(0xFFEA580C),
                iconBgColor: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInvoiceCard(Invoice invoice) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE5E5EB)),
      ),
      color: Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          // Open details modal
          InvoiceDetailModal.show(context, invoice, onActionComplete: _loadData);
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.between,
                children: [
                  Expanded(
                    child: Text(
                      invoice.fournisseur,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '${invoice.montantTtc.toStringAsFixed(2)} ${invoice.devise == 'EUR' ? '€' : invoice.devise}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF4F46E5),
                      fontFamily: 'Outfit',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.between,
                children: [
                  Text(
                    'N° ${invoice.numero}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF5F6168),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  StatusBadge(status: invoice.statut),
                ],
              ),
              const Divider(height: 24, color: Color(0xFFE5E5EB)),
              Row(
                mainAxisAlignment: MainAxisAlignment.between,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.shield_outlined, size: 14, color: Color(0xFF8F9199)),
                      const SizedBox(width: 4),
                      Text(
                        'Score de Fraude: ${invoice.fraudScore.toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 12,
                          color: invoice.fraudScore > 50 ? Colors.red : const Color(0xFF5F6168),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined, size: 12, color: Color(0xFF8F9199)),
                      const SizedBox(width: 4),
                      Text(
                        '${invoice.dateFacture.day.toString().padLeft(2, '0')}/${invoice.dateFacture.month.toString().padLeft(2, '0')}/${invoice.dateFacture.year}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF8F9199),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyView() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E5EB)),
      ),
      child: const Column(
        children: [
          Icon(Icons.receipt_long_rounded, size: 48, color: Color(0xFF8F9199)),
          SizedBox(height: 12),
          Text(
            'Aucune facture trouvée',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 4),
          Text(
            'Déposez des documents dans l\'onglet Capture.',
            style: TextStyle(color: Color(0xFF8F9199), fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off_rounded, size: 64, color: Colors.redAccent),
            const SizedBox(height: 16),
            const Text(
              'Erreur de Chargement',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _error,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF5F6168), fontSize: 14),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadData,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4F46E5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: const Text('Réessayer', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
