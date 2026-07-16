import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../../theme/app_theme.dart';
import 'ai_processing_screen.dart';
import 'notification_screen.dart';

class CaptureScreen extends StatefulWidget {
  const CaptureScreen({Key? key}) : super(key: key);

  @override
  State<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends State<CaptureScreen> with TickerProviderStateMixin {
  String _selectedCategory = 'Invoice';
  late AnimationController _scanController;
  late Animation<double> _scanAnimation;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    
    _scanAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scanController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scanController.dispose();
    super.dispose();
  }

  void _processFile(String path) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AIProcessingScreen(filePath: path),
      ),
    );
  }

  Future<void> _handleCameraCapture() async {
    final XFile? file = await _imagePicker.pickImage(source: ImageSource.camera, imageQuality: 90);
    if (file != null) _processFile(file.path);
  }

  Future<void> _handleGalleryPick() async {
    final XFile? file = await _imagePicker.pickImage(source: ImageSource.gallery, imageQuality: 90);
    if (file != null) _processFile(file.path);
  }

  Future<void> _handlePdfImport() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
    if (result != null && result.files.first.path != null) {
      _processFile(result.files.first.path!);
    }
  }

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
                          'https://lh3.googleusercontent.com/aida-public/AB6AXuCxlcbwgeP_OOS8-diEWalyZUdPBLj5f8PJzfHjZbQVC-1DeuftFBpnWuEiiIhFTZn8a8kEe03tHVDSH5Xt_VqH4EmZtdGBAse46vxzNaDlbOMMe--1T7tB6y4tv201zepspYhGuwWHN17ims896XIG190GdOEl6KPQWCby7F-Hw_LoJ3FtUc2iPDzM3qgC7ew_dTcZxd3Ty8veNNumpG94G9JCaolq-uPobrv-BK-TLvD3m-eISWPxfJETWiZNDgimLPNYKBpVgLNo',
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

              // Category Selector
              Text(
                'Document Category',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF414844),
                  letterSpacing: 0.05 * 12,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF6F3F0), // surface-container-low
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFEAE8E5).withOpacity(0.5)),
                ),
                child: Row(
                  children: [
                    _buildCategorySegment('Invoice'),
                    _buildCategorySegment('Receipt'),
                    _buildCategorySegment('Contract'),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Viewfinder Section
              AspectRatio(
                aspectRatio: 3 / 4,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1C1B), // deep-charcoal
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Simulated Camera Feed Image
                      Positioned.fill(
                        child: Opacity(
                          opacity: 0.8,
                          child: Image.network(
                            'https://lh3.googleusercontent.com/aida-public/AB6AXuAtFVZHcCfbUX_cLuNW_u73w_EWH9uGjCHjGh4dTZgismgQ4-bSTw_BlMiT43u8hT5umsdM8ENp5ZzPirgkgpXTtx9m4Ct-aVh39Kaiu6ImEQZ26R7olbMducYfs0_6OHRrtalKnUjACmef62-d7VOqYpleZZBlD5jUvqUssqE-GMkv_qqLW7GELaxh7Wipd0_hgUZFmahKETH_rin5ZNOLLmuKatfmJrjjYbfpS8YbX9TsnLYHUHTQIZkJGenp6pR0YIn4XCfYzk1c',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),

                      // Scanning Frame UI
                      Positioned.fill(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Stack(
                            children: [
                              // Border
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: const Color(0xFFB7E4C7).withOpacity(0.4),
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),

                              // Scanning Line Animation
                              AnimatedBuilder(
                                animation: _scanAnimation,
                                builder: (context, child) {
                                  return Positioned(
                                    top: _scanAnimation.value * (MediaQuery.of(context).size.width * 0.9), // rough height estimate
                                    left: 0,
                                    right: 0,
                                    child: Opacity(
                                      opacity: _scanAnimation.value < 0.1 || _scanAnimation.value > 0.9 ? 0.0 : 1.0,
                                      child: Container(
                                        height: 2,
                                        decoration: const BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              Colors.transparent,
                                              Color(0xFFB7E4C7),
                                              Colors.transparent,
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),

                              // Corner Accents
                              _buildCornerMarker(top: 0, left: 0),
                              _buildCornerMarker(top: 0, right: 0),
                              _buildCornerMarker(bottom: 0, left: 0),
                              _buildCornerMarker(bottom: 0, right: 0),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Capture Controls
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: _handleCameraCapture,
                        icon: const Icon(Icons.center_focus_strong, color: Colors.white),
                        label: Text(
                          'TAKE PHOTO',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: 0.05 * 12,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF012D1D),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: OutlinedButton.icon(
                        onPressed: _handlePdfImport,
                        icon: const Icon(Icons.upload_file, color: Color(0xFF1C1C1A)),
                        label: Text(
                          'UPLOAD PDF',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1C1C1A),
                            letterSpacing: 0.05 * 12,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: const Color(0xFFF0EDE5),
                          side: const BorderSide(color: Color(0xFFC1C8C2)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Select Multiple Files
              GestureDetector(
                onTap: _handleGalleryPick,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.library_add, color: Color(0xFF0E6C4A), size: 18),
                    const SizedBox(width: 6),
                    Text(
                      'Select Multiple Files',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF0E6C4A),
                        letterSpacing: 0.05 * 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Drag & Drop Area
              GestureDetector(
                onTap: _handleGalleryPick,
                child: CustomPaint(
                  painter: _DashRectPainter(color: const Color(0xFF717973).withOpacity(0.3)),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFFFF), // surface-container-lowest
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.cloud_upload, color: Color(0xFFC1C8C2), size: 32),
                        const SizedBox(height: 8),
                        Text(
                          'Tap to browse or drag & drop files here',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF414844),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Supports PDF, JPG, PNG up to 10MB',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF717973),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Capture Tips Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFF6F3F0), // surface-container-low
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFEAE8E5).withOpacity(0.5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.verified, color: Color(0xFF0E6C4A), size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Smart Capture Tips',
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF0E6C4A),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildTipRow(Icons.brightness_high, 'Ensure bright, even lighting to avoid shadows on text.'),
                    const SizedBox(height: 12),
                    _buildTipRow(Icons.align_horizontal_center, 'Keep the document flat and centered within the frame.'),
                    const SizedBox(height: 12),
                    _buildTipRow(
                      Icons.document_scanner,
                      'OCR Quality Detection active',
                      subtext: 'The AI will automatically enhance low-contrast documents for better extraction.',
                      isBoldHeader: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 100), // Padding for bottom nav
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySegment(String label) {
    final isSelected = _selectedCategory == label;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedCategory = label),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            textAlign: Alignment.center.x == 0 ? TextAlign.center : TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected ? const Color(0xFF012D1D) : const Color(0xFF414844),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCornerMarker({double? top, double? bottom, double? left, double? right}) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          border: Border(
            top: top != null ? const BorderSide(color: Color(0xFFB7E4C7), width: 4) : BorderSide.none,
            bottom: bottom != null ? const BorderSide(color: Color(0xFFB7E4C7), width: 4) : BorderSide.none,
            left: left != null ? const BorderSide(color: Color(0xFFB7E4C7), width: 4) : BorderSide.none,
            right: right != null ? const BorderSide(color: Color(0xFFB7E4C7), width: 4) : BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildTipRow(IconData icon, String text, {String? subtext, bool isBoldHeader = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: const Color(0xFF012D1D).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: const Color(0xFF012D1D), size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                text,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: isBoldHeader ? FontWeight.w600 : FontWeight.w400,
                  color: const Color(0xFF414844),
                ),
              ),
              if (subtext != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtext,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF717973),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _DashRectPainter extends CustomPainter {
  final double strokeWidth;
  final double gap;
  final Color color;

  _DashRectPainter({
    this.strokeWidth = 2.0,
    this.gap = 5.0,
    this.color = Colors.grey,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final double width = size.width;
    final double height = size.height;

    // Draw horizontal dashed lines
    double x = 0;
    while (x < width) {
      canvas.drawLine(Offset(x, 0), Offset(x + gap, 0), paint);
      canvas.drawLine(Offset(x, height), Offset(x + gap, height), paint);
      x += gap * 2;
    }

    // Draw vertical dashed lines
    double y = 0;
    while (y < height) {
      canvas.drawLine(Offset(0, y), Offset(0, y + gap), paint);
      canvas.drawLine(Offset(width, y), Offset(width, y + gap), paint);
      y += gap * 2;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
