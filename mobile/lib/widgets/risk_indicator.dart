import 'package:flutter/material.dart';

class RiskIndicator extends StatelessWidget {
  final double score; // 0.0 to 100.0

  const RiskIndicator({Key? key, required this.score}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;

    if (score < 30) {
      color = const Color(0xFF10B981); // Green
      label = 'Faible';
    } else if (score < 60) {
      color = const Color(0xFFF59E0B); // Amber
      label = 'Moyen';
    } else if (score < 80) {
      color = const Color(0xFFEA580C); // Orange
      label = 'Élevé';
    } else {
      color = const Color(0xFFEF4444); // Red
      label = 'Critique';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.between,
          children: [
            Text(
              'Score de Risque : ${score.toStringAsFixed(0)}%',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
            Text(
              label,
              style: TextStyle(
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
            backgroundColor: const Color(0xFFE5E5EB),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}
