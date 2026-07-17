import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final config = _statusConfig(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: config.background.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: config.background.withValues(alpha: 0.4), width: 1),
      ),
      child: Text(
        _statusLabel(status).toUpperCase(),
        style: GoogleFonts.dmSans(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          color: config.foreground,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  String _statusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
      case 'paye':
        return 'Payé';
      case 'validee':
      case 'valide':
        return 'Validée';
      case 'pending':
      case 'brouillon':
      case 'en_attente':
        return 'En attente';
      case 'overdue':
      case 'rejete':
      case 'rejetee':
        return 'Rejeté';
      case 'processing':
        return 'Traitement';
      case 'nouveau':
        return 'Nouveau';
      case 'captured':
      case 'controlee':
      case 'reviewed':
        return 'Vérifié';
      case 'en_verification':
        return 'En vérification';
      default:
        return status;
    }
  }

  _StatusConfig _statusConfig(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
      case 'paye':
      case 'validee':
      case 'valide':
        return _StatusConfig(AppTheme.accentGreen, AppTheme.accentGreen);
      case 'pending':
      case 'brouillon':
      case 'en_attente':
        return _StatusConfig(AppTheme.warning, AppTheme.warning);
      case 'overdue':
      case 'rejete':
      case 'rejetee':
        return _StatusConfig(AppTheme.error, AppTheme.error);
      case 'processing':
      case 'nouveau':
        return _StatusConfig(AppTheme.accent, AppTheme.textPrimary);
      case 'captured':
      case 'controlee':
      case 'reviewed':
        return _StatusConfig(AppTheme.primary, AppTheme.primary);
      case 'en_verification':
        return _StatusConfig(const Color(0xFF2196F3), const Color(0xFF2196F3));
      default:
        return _StatusConfig(AppTheme.textMuted, AppTheme.textMuted);
    }
  }
}

class _StatusConfig {
  final Color background;
  final Color foreground;
  const _StatusConfig(this.background, this.foreground);
}
