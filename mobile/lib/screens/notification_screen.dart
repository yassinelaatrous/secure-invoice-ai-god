import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  String _selectedCategory = 'All';

  final List<Map<String, dynamic>> _notifications = [
    {
      'type': 'Security',
      'title': 'Suspicious Invoice Detected',
      'description': "Invoice #INV-2023-089 from 'TechCorp LLC' shows unusual billing patterns and a mismatched IBAN.",
      'time': '2m ago',
      'icon': Icons.warning_amber_rounded,
      'color': AppTheme.error,
      'isHighRisk': true,
    },
    {
      'type': 'Financial',
      'title': 'Invoice Validated',
      'description': "Invoice #INV-2023-088 for €12,450.00 has been successfully validated by the accounting team.",
      'time': '1h ago',
      'icon': Icons.check_circle_outline,
      'color': AppTheme.secondary,
      'isHighRisk': false,
    },
    {
      'type': 'System',
      'title': 'MFA Policy Update',
      'description': "Your organization requires Multi-Factor Authentication setup for enhanced security.",
      'time': 'Yesterday',
      'icon': Icons.lock_outline,
      'color': AppTheme.textMuted,
      'isHighRisk': false,
    },
    {
      'type': 'Security',
      'title': 'IBAN Mismatch Alert',
      'description': "The IBAN provided for vendor 'Global Supplies Ltd' does not match their historical records.",
      'time': '2 days ago',
      'icon': Icons.account_balance_outlined,
      'color': AppTheme.textPrimary,
      'isHighRisk': false,
    }
  ];

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filtered = _selectedCategory == 'All' 
        ? _notifications 
        : _notifications.where((n) => n['type'] == _selectedCategory).toList();

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundLight,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.primary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Notifications', style: AppTheme.headlineMedium.copyWith(color: AppTheme.primary)),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: AppTheme.primary),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          _buildCategoryTabs(),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(24),
              itemCount: filtered.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                return _buildNotificationCard(filtered[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs() {
    final categories = ['All', 'Security', 'Financial', 'System'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        children: categories.map((cat) {
          final isSelected = _selectedCategory == cat;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => _selectedCategory = cat),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.primary.withOpacity(0.1) : AppTheme.surfaceCard,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? AppTheme.primary.withOpacity(0.5) : AppTheme.cardBorder,
                  ),
                ),
                child: Text(
                  cat,
                  style: AppTheme.labelLarge.copyWith(
                    color: isSelected ? AppTheme.primary : AppTheme.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> data) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.backgroundLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: data['isHighRisk'] ? AppTheme.error.withOpacity(0.5) : AppTheme.cardBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: data['color'].withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(data['icon'], color: data['color'], size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      (data['type'] as String).toUpperCase(),
                      style: AppTheme.labelMedium.copyWith(color: data['color'], letterSpacing: 1.2),
                    ),
                    Text(
                      data['time'],
                      style: AppTheme.labelMedium.copyWith(color: AppTheme.textMuted),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  data['title'],
                  style: AppTheme.bodyLarge.copyWith(color: AppTheme.textPrimary, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  data['description'],
                  style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      'Review Details',
                      style: AppTheme.labelMedium.copyWith(color: data['color']),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.arrow_forward, size: 14, color: data['color']),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
