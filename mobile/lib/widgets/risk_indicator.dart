import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class RiskIndicator extends StatelessWidget {
  final double score; // 0.0 to 100.0

  const RiskIndicator({super.key, required this.score});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;

    if (score < 30) {
      color = AppTheme.accentGreen;
      label = 'Faible';
    } else if (score < 60) {
      color = AppTheme.warning;
      label = 'Moyen';
    } else if (score < 80) {
      color = const Color(0xFFEA580C);
      label = 'Élevé';
    } else {
      color = AppTheme.error;
      label = 'Critique';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Score de Risque : ${score.toStringAsFixed(0)}%',
              style: GoogleFonts.dmSans(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: AppTheme.textPrimary,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.dmSans(
                color: color,
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: score / 100.0,
            backgroundColor: AppTheme.cardBorder,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}
