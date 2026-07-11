import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({Key? key, required this.status}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    String label;

    switch (status.toLowerCase()) {
      case 'nouveau':
        bgColor = const Color(0xFFF0F5FF);
        textColor = const Color(0xFF2563EB);
        label = 'Nouveau';
        break;
      case 'en_verification':
        bgColor = const Color(0xFFFFFBEB);
        textColor = const Color(0xFFD97706);
        label = 'En vérification';
        break;
      case 'valide':
        bgColor = const Color(0xFFECFDF5);
        textColor = const Color(0xFF059669);
        label = 'Validé';
        break;
      case 'rejete':
        bgColor = const Color(0xFFFEF2F2);
        textColor = const Color(0xFFDC2626);
        label = 'Rejeté';
        break;
      case 'archive':
        bgColor = const Color(0xFFF3F4F6);
        textColor = const Color(0xFF4B5563);
        label = 'Archivé';
        break;
      case 'paye':
        bgColor = const Color(0xFFECFDF5);
        textColor = const Color(0xFF10B981);
        label = 'Payé';
        break;
      case 'en_litige':
        bgColor = const Color(0xFFFFF7ED);
        textColor = const Color(0xFFEA580C);
        label = 'En litige';
        break;
      default:
        bgColor = const Color(0xFFF3F4F6);
        textColor = const Color(0xFF9CA3AF);
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
