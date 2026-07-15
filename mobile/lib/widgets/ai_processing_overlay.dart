import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import 'file_fetching_loader.dart';

class AiProcessingOverlay extends StatefulWidget {
  final AnimationController controller;

  const AiProcessingOverlay({super.key, required this.controller});

  @override
  State<AiProcessingOverlay> createState() => _AiProcessingOverlayState();
}

class _AiProcessingOverlayState extends State<AiProcessingOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressController;
  late Animation<double> _progressAnim;

  final List<String> _steps = [
    'Detecting invoice boundaries…',
    'Extracting text with OCR…',
    'Parsing invoice fields…',
    'Validating with AI model…',
    'Finalizing extraction…',
  ];

  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..forward();

    _progressAnim = CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeOutCubic,
    );

    // Cycle through steps
    Future.delayed(const Duration(milliseconds: 500), _cycleStep);
  }

  void _cycleStep() {
    if (!mounted) return;
    for (int i = 0; i < _steps.length; i++) {
      Future.delayed(Duration(milliseconds: 500 * i), () {
        if (mounted && i < _steps.length) {
          setState(() => _currentStep = i);
        }
      });
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Container(
        color: AppTheme.backgroundLight.withOpacity(0.85),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Custom File Fetching Loader
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: FileFetchingLoader(),
              ),
              const SizedBox(height: 32),
              Text(
                'AI Processing',
                style: GoogleFonts.fraunces(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  _steps[_currentStep],
                  key: ValueKey(_currentStep),
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Progress bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 60),
                child: AnimatedBuilder(
                  animation: _progressAnim,
                  builder: (context, _) => Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: _progressAnim.value,
                          backgroundColor: AppTheme.cardBorder,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppTheme.primary,
                          ),
                          minHeight: 5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${(_progressAnim.value * 100).toInt()}%',
                            style: GoogleFonts.dmSans(
                              fontSize: 12,
                              color: AppTheme.primary,
                              fontWeight: FontWeight.w800,
                              fontFeatures: const [FontFeature.tabularFigures()],
                            ),
                          ),
                          Text(
                            'AI Extraction',
                            style: GoogleFonts.dmSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textSecondary.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnimatedAiOrb extends StatelessWidget {
  final AnimationController controller;
  const _AnimatedAiOrb({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final t = controller.value;
        return SizedBox(
          width: 120,
          height: 120,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer ring pulse
              Transform.scale(
                scale: 0.85 + (math.sin(t * math.pi * 2) * 0.15),
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF7C6FF7).withAlpha(77),
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              // Middle ring
              Transform.scale(
                scale: 0.9 + (math.cos(t * math.pi * 2) * 0.1),
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF00E5FF).withAlpha(102),
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              // Core orb
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: SweepGradient(
                    transform: GradientRotation(t * math.pi * 2),
                    colors: const [
                      Color(0xFF7C6FF7),
                      Color(0xFF00E5FF),
                      Color(0xFF00C896),
                      Color(0xFF7C6FF7),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF7C6FF7).withAlpha(128),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'AI',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
