import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../models/invoice.dart';
import '../theme/app_theme.dart';
import '../widgets/ai_processing_overlay.dart';

enum CaptureMode { camera, gallery, pdf }

class CaptureScreen extends StatefulWidget {
  const CaptureScreen({Key? key}) : super(key: key);

  @override
  State<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends State<CaptureScreen>
    with TickerProviderStateMixin {
  CaptureMode _selectedMode = CaptureMode.camera;
  bool _isProcessing = false;
  String? _capturedFilePath;
  Invoice? _ocrResult;

  // Form Controllers for OCR Editing
  final _formKey = GlobalKey<FormState>();
  final _fournisseurController = TextEditingController();
  final _numeroController = TextEditingController();
  final _dateController = TextEditingController();
  final _htController = TextEditingController();
  final _tvaController = TextEditingController();
  final _ttcController = TextEditingController();
  final _ibanController = TextEditingController();

  late AnimationController _entranceController;
  late AnimationController _processingController;

  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();

    _processingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _processingController.dispose();
    _fournisseurController.dispose();
    _numeroController.dispose();
    _dateController.dispose();
    _htController.dispose();
    _tvaController.dispose();
    _ttcController.dispose();
    _ibanController.dispose();
    super.dispose();
  }

  double _toDouble(dynamic val) {
    if (val == null) return 0.0;
    if (val is int) return val.toDouble();
    if (val is double) return val;
    return double.tryParse(val.toString()) ?? 0.0;
  }

  Future<void> _processFile(String filePath) async {
    setState(() {
      _isProcessing = true;
      _ocrResult = null;
    });

    try {
      final result = await ApiService.uploadInvoice(filePath);
      final extractedData = result['extracted_data'] ?? result;

      setState(() {
        _ocrResult = Invoice(
          id: 0,
          numero: extractedData['numero']?.toString() ?? 'N/A',
          fournisseur: extractedData['fournisseur']?.toString() ?? 'N/A',
          dateFacture: DateTime.tryParse(extractedData['date_facture']?.toString() ?? '') ?? DateTime.now(),
          dateReception: DateTime.now(),
          devise: extractedData['devise']?.toString() ?? 'TND',
          montantHt: _toDouble(extractedData['ht']),
          tva: _toDouble(extractedData['tva']),
          montantTtc: _toDouble(extractedData['ttc']),
          iban: extractedData['iban']?.toString() ?? '',
          statut: 'nouveau',
          fraudScore: _toDouble(extractedData['fraude_score']),
          confidenceScore: _toDouble(extractedData['confiance'] ?? 0.95),
        );
        
        _fournisseurController.text = _ocrResult!.fournisseur;
        _numeroController.text = _ocrResult!.numero;
        _dateController.text = '${_ocrResult!.dateFacture.day.toString().padLeft(2, '0')}/${_ocrResult!.dateFacture.month.toString().padLeft(2, '0')}/${_ocrResult!.dateFacture.year}';
        _htController.text = _ocrResult!.montantHt.toStringAsFixed(2);
        _tvaController.text = _ocrResult!.tva.toStringAsFixed(2);
        _ttcController.text = _ocrResult!.montantTtc.toStringAsFixed(2);
        _ibanController.text = _ocrResult!.iban;

        _isProcessing = false;
      });

      _showExtractionResult();
    } catch (e) {
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur de traitement: $e')),
      );
    }
  }

  Future<void> _handleCameraCapture() async {
    final XFile? file = await _imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 90,
    );
    if (file != null && mounted) {
      setState(() => _capturedFilePath = file.path);
      _processFile(file.path);
    }
  }

  Future<void> _handleGalleryPick() async {
    final XFile? file = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );
    if (file != null && mounted) {
      setState(() => _capturedFilePath = file.path);
      _processFile(file.path);
    }
  }

  Future<void> _handlePdfImport() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null && mounted) {
      final path = result.files.first.path;
      if (path != null) {
        setState(() => _capturedFilePath = path);
        _processFile(path);
      }
    }
  }

  void _saveInvoice() async {
    if (_formKey.currentState!.validate()) {
      try {
        final double ht = double.tryParse(_htController.text) ?? 0.0;
        final double tva = double.tryParse(_tvaController.text) ?? 0.0;
        final double ttc = double.tryParse(_ttcController.text) ?? 0.0;

        await ApiService.createFacture({
          'fournisseur': _fournisseurController.text,
          'numero': _numeroController.text,
          'date_facture': _ocrResult?.dateFacture.toIso8601String().split('T')[0] ?? '',
          'ht': ht,
          'tva': tva,
          'ttc': ttc,
          'iban': _ibanController.text,
          'devise': _ocrResult?.devise ?? 'TND',
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: AppTheme.accentGreen,
              content: Text('Facture sauvegardée avec succès !', style: TextStyle(color: Colors.white)),
            ),
          );
          _resetState();
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la validation: $e')),
        );
      }
    }
  }

  void _resetState() {
    setState(() {
      _capturedFilePath = null;
      _ocrResult = null;
      _fournisseurController.clear();
      _numeroController.clear();
      _dateController.clear();
      _htController.clear();
      _tvaController.clear();
      _ttcController.clear();
      _ibanController.clear();
    });
  }

  void _showExtractionResult() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _ExtractionResultSheet(
        ocrResult: _ocrResult!,
        onSave: () {
          Navigator.pop(context);
          _saveInvoice();
        },
        onEdit: () {
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: Stack(
        children: [
          // Background – solid cream, no gradient needed
          Container(
            color: AppTheme.backgroundLight,
          ),

          // Main Content
          SafeArea(
            child: FadeTransition(
              opacity: CurvedAnimation(
                parent: _entranceController,
                curve: Curves.easeOutCubic,
              ),
              child: Column(
                children: [
                  _buildTopBar(),
                  const SizedBox(height: 16),
                  
                  if (_ocrResult == null) ...[
                    _buildModeSelector(),
                    const SizedBox(height: 16),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _buildCaptureArea(),
                      ),
                    ),
                    _buildBottomBar(),
                  ] else ...[
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: _buildReviewEditor(),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // AI Processing overlay
          if (_isProcessing)
            AiProcessingOverlay(controller: _processingController),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          if (_ocrResult != null)
            GestureDetector(
              onTap: _resetState,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.cardBorder),
                ),
                child: const Icon(Icons.arrow_back_ios_new, color: AppTheme.textPrimary, size: 18),
              ),
            ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _ocrResult == null ? 'Capture Invoice' : 'Review OCR Fields',
              style: GoogleFonts.fraunces(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                fontStyle: FontStyle.italic,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.surfaceCard,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.cardBorder),
            ),
            child: Row(
              children: [
                Icon(Icons.help_outline, color: AppTheme.textSecondary, size: 14),
                const SizedBox(width: 4),
                Text(
                  'Help',
                  style: GoogleFonts.dmSans(fontSize: 12, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Row(
        children: [
          _buildModeTab('Camera', CaptureMode.camera),
          _buildModeTab('Gallery', CaptureMode.gallery),
          _buildModeTab('PDF', CaptureMode.pdf),
        ],
      ),
    );
  }

  Widget _buildModeTab(String label, CaptureMode mode) {
    final active = _selectedMode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedMode = mode;
          });
          if (mode == CaptureMode.gallery) _handleGalleryPick();
          if (mode == CaptureMode.pdf) _handlePdfImport();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? AppTheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 13,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                color: active ? Colors.white : AppTheme.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCaptureArea() {
    if (_selectedMode == CaptureMode.camera) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.6),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppTheme.cardBorder, width: 1.5),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.camera_alt_outlined, color: AppTheme.textSecondary.withOpacity(0.4), size: 64),
                  const SizedBox(height: 16),
                  Text(
                    'Position invoice in center',
                    style: GoogleFonts.dmSans(color: AppTheme.textSecondary, fontSize: 14),
                  ),
                ],
              ),
            ),
            ..._buildCorners(),
          ],
        ),
      );
    } else {
      return _buildDropZone();
    }
  }

  List<Widget> _buildCorners() {
    const double size = 24;
    const double thickness = 3.0;
    const Color color = AppTheme.primary;

    return [
      Positioned(
        top: 20,
        left: 20,
        child: Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: color, width: thickness),
              left: BorderSide(color: color, width: thickness),
            ),
          ),
        ),
      ),
      Positioned(
        top: 20,
        right: 20,
        child: Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: color, width: thickness),
              right: BorderSide(color: color, width: thickness),
            ),
          ),
        ),
      ),
      Positioned(
        bottom: 20,
        left: 20,
        child: Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: color, width: thickness),
              left: BorderSide(color: color, width: thickness),
            ),
          ),
        ),
      ),
      Positioned(
        bottom: 20,
        right: 20,
        child: Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: color, width: thickness),
              right: BorderSide(color: color, width: thickness),
            ),
          ),
        ),
      ),
    ];
  }

  Widget _buildDropZone() {
    final isPdf = _selectedMode == CaptureMode.pdf;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.cardBorder, width: 1.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.08),
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
            ),
            child: Center(
              child: Icon(
                isPdf ? Icons.picture_as_pdf : Icons.photo_library,
                color: AppTheme.primary,
                size: 36,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            isPdf ? 'Import PDF Invoice' : 'Select from Gallery',
            style: GoogleFonts.fraunces(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              fontStyle: FontStyle.italic,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isPdf
                ? 'Tap below to browse PDF files\nfrom your device'
                : 'Tap below to choose an invoice\nimage from your gallery',
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
              fontSize: 13,
              color: AppTheme.textSecondary,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 32),
          GestureDetector(
            onTap: isPdf ? _handlePdfImport : _handleGalleryPick,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withOpacity(0.25),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(isPdf ? Icons.folder_open : Icons.collections, color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    isPdf ? 'Browse Files' : 'Open Gallery',
                    style: GoogleFonts.dmSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.surfaceCard,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.cardBorder),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb_outline, color: AppTheme.warning, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Ensure invoice is well-lit and flat',
                      style: GoogleFonts.dmSans(fontSize: 11, color: AppTheme.textSecondary),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_selectedMode == CaptureMode.camera) ...[
            const SizedBox(width: 12),
            GestureDetector(
              onTap: _handleCameraCapture,
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primary, AppTheme.accent],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withOpacity(0.4),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(Icons.camera_alt, color: Colors.white, size: 24),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReviewEditor() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.cardBorder),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: AppTheme.primary, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Modify the OCR fields below if needed before validating saving.',
                    style: GoogleFonts.dmSans(color: AppTheme.textSecondary, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildTextField('Fournisseur / Vendor', _fournisseurController, Icons.business),
          const SizedBox(height: 14),
          _buildTextField('Numéro de facture', _numeroController, Icons.tag),
          const SizedBox(height: 14),
          _buildTextField('Date de facture', _dateController, Icons.calendar_today),
          const SizedBox(height: 14),
          _buildTextField('Montant HT', _htController, Icons.money, keyboardType: TextInputType.number),
          const SizedBox(height: 14),
          _buildTextField('Montant TVA', _tvaController, Icons.percent, keyboardType: TextInputType.number),
          const SizedBox(height: 14),
          _buildTextField('Montant TTC', _ttcController, Icons.payments, keyboardType: TextInputType.number),
          const SizedBox(height: 14),
          _buildTextField('IBAN', _ibanController, Icons.credit_card),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _saveInvoice,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: Text('Save Invoice to Database', style: GoogleFonts.dmSans(fontWeight: FontWeight.bold, fontSize: 15)),
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: _resetState,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppTheme.cardBorder),
              foregroundColor: AppTheme.textPrimary,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: Text(
              'Reset and Scan Again',
              style: GoogleFonts.dmSans(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, {TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      style: GoogleFonts.dmSans(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textPrimary),
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.dmSans(color: AppTheme.textSecondary),
        prefixIcon: Icon(icon, size: 20, color: AppTheme.textMuted),
        fillColor: AppTheme.surfaceCard,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'This field is required';
        }
        return null;
      },
    );
  }
}

class _ExtractionResultSheet extends StatelessWidget {
  final Invoice ocrResult;
  final VoidCallback onSave;
  final VoidCallback onEdit;

  const _ExtractionResultSheet({
    Key? key,
    required this.ocrResult,
    required this.onSave,
    required this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppTheme.surfaceLight,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: const Border(
              top: BorderSide(color: AppTheme.cardBorder, width: 1),
            ),
          ),
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
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.accentGreen.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.check_circle_outline_rounded,
                        color: AppTheme.accentGreen,
                        size: 22,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AI Extraction Complete',
                          style: GoogleFonts.fraunces(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            fontStyle: FontStyle.italic,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        Text(
                          'Confiance: ${(ocrResult.confidenceScore * 100).toInt()}%',
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            color: AppTheme.accentGreen,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _extractedField('Invoice #', ocrResult.numero),
              _extractedField('Vendor', ocrResult.fournisseur),
              _extractedField('Amount', '${ocrResult.montantTtc.toStringAsFixed(2)} ${ocrResult.devise}'),
              _extractedField('Date', '${ocrResult.dateFacture.day}/${ocrResult.dateFacture.month}/${ocrResult.dateFacture.year}'),
              _extractedField('IBAN', ocrResult.iban.isNotEmpty ? ocrResult.iban : 'Not found'),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onEdit,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppTheme.cardBorder),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        'Edit Fields',
                        style: GoogleFonts.dmSans(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onSave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accent,
                        foregroundColor: AppTheme.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        'Save Invoice',
                        style: GoogleFonts.dmSans(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _extractedField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.dmSans(
                fontSize: 13,
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: AppTheme.accentGreen.withOpacity(0.12),
              borderRadius: BorderRadius.circular(5),
            ),
            child: const Center(
              child: Icon(
                Icons.check_rounded,
                size: 12,
                color: AppTheme.accentGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
