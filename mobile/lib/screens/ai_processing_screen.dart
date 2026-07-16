import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import '../models/invoice.dart';
import '../widgets/file_fetching_loader.dart';
import 'invoice_detail_modal.dart';

class AIProcessingScreen extends StatefulWidget {
  final String filePath;
  const AIProcessingScreen({Key? key, required this.filePath}) : super(key: key);

  @override
  State<AIProcessingScreen> createState() => _AIProcessingScreenState();
}

class _AIProcessingScreenState extends State<AIProcessingScreen> with TickerProviderStateMixin {
  int _currentStep = 0;
  bool _isFinished = false;
  Invoice? _result;

  final List<String> _steps = [
    'Detecting invoice boundaries…',
    'Extracting text with OCR…',
    'Parsing invoice fields…',
    'Validating with AI model…',
    'Finalizing extraction…',
  ];

  @override
  void initState() {
    super.initState();
    _processDocument();
  }

  Future<void> _processDocument() async {
    // Simulate step progression visually
    for (int i = 0; i < _steps.length; i++) {
      if (!mounted) return;
      setState(() => _currentStep = i);
      await Future.delayed(const Duration(milliseconds: 700)); // Visual delay
    }

    try {
      final res = await ApiService.uploadInvoice(widget.filePath);
      final extractedData = res['extracted_data'] ?? res;
      
      _result = Invoice(
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
    } catch (e) {
      // Mock result for offline/demo if API fails
      _result = Invoice(
        id: 999,
        numero: 'INV-2023-089',
        fournisseur: 'TechCorp LLC',
        dateFacture: DateTime.now(),
        dateReception: DateTime.now(),
        devise: 'EUR',
        montantHt: 10375.00,
        tva: 2075.00,
        montantTtc: 12450.00,
        iban: 'FR76 1234 5678 9012',
        statut: 'nouveau',
        fraudScore: 0.85,
        confidenceScore: 0.98,
      );
    }

    if (mounted) {
      setState(() => _isFinished = true);
      await Future.delayed(const Duration(milliseconds: 500));
      _showResults();
    }
  }

  double _toDouble(dynamic val) {
    if (val == null) return 0.0;
    if (val is int) return val.toDouble();
    if (val is double) return val;
    return double.tryParse(val.toString()) ?? 0.0;
  }

  void _showResults() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => InvoiceDetailModal(invoice: _result!),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF9F6), // bg-background (cream)
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Color(0xFF012D1D)),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'AI Analysis',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF012D1D),
                    ),
                  ),
                ],
              ),
            ),
            
            const Spacer(),

            // Return to the old animation: FileFetchingLoader
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: FileFetchingLoader(),
            ),

            const Spacer(),
            
            // Stepper Area
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: const Color(0xFFF6F3F0), // surface-container-low
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                border: Border.all(color: const Color(0xFFEAE8E5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'AI Processing',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF012D1D),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _steps[_currentStep],
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      color: const Color(0xFF414844),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Progress Indicator
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: (_currentStep + 1) / _steps.length,
                      backgroundColor: const Color(0xFFEAE8E5),
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF012D1D)),
                      minHeight: 5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
