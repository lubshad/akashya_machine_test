// portfolio_import_screen.dart
//
// Complete portfolio upload flow using Firebase:
//   1. Pick file (CSV / XLS / XLSX)
//   2. Validate file type & size
//   3. Upload to Firebase Storage bucket "portfolios"
//   4. Insert metadata into Firestore collection "uploads"
//   5. Parse holdings → save to Firestore
//   6. Record upload in Firebase uploads collection
//   7. Trigger AI analysis (stub)

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:file_picker/file_picker.dart';
import 'package:table_parser/table_parser.dart';
import '../../../core/theme.dart';
import '../../../core/services/portfolio_service.dart';
import '../../../core/services/firebase_portfolio_service.dart';
import '../services/portfolio_document_parser.dart';

class PortfolioImportScreen extends StatefulWidget {
  const PortfolioImportScreen({super.key});

  @override
  State<PortfolioImportScreen> createState() =>
      _PortfolioImportScreenState();
}

class _PortfolioImportScreenState extends State<PortfolioImportScreen>
    with TickerProviderStateMixin {
  // ── State ──────────────────────────────────────────────────────────────────
  _UploadPhase _phase = _UploadPhase.idle;
  String? _selectedFileName;
  double _progress = 0;
  String? _errorMessage;
  int _importedCount = 0;

  // Animations
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulse;
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fade;

  Timer? _progressTimer;

  // Services
  final _portfolioService = PortfolioService();
  final _firebaseService = FirebasePortfolioService.instance;

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();

    _pulseCtrl = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    _fadeCtrl = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    )..forward();
    _fade = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _fadeCtrl.dispose();
    _progressTimer?.cancel();
    super.dispose();
  }

  // ── Extension / type detection ─────────────────────────────────────────────

  static String _extFromName(String fileName) {
    final n = fileName.toLowerCase().trim();
    if (n.endsWith('.xlsx')) return 'xlsx';
    if (n.endsWith('.xls')) return 'xls';
    if (n.endsWith('.csv')) return 'csv';
    return '';
  }

  static String _extFromBytes(List<int> bytes) {
    if (bytes.length < 4) return '';

    if (bytes[0] == 0x50 &&
        bytes[1] == 0x4B &&
        bytes[2] == 0x03 &&
        bytes[3] == 0x04) {
      return 'xlsx';
    }

    if (bytes[0] == 0xD0 &&
        bytes[1] == 0xCF &&
        bytes[2] == 0x11 &&
        bytes[3] == 0xE0) {
      return 'xls';
    }

    if (bytes.length >= 3 &&
        bytes[0] == 0xEF &&
        bytes[1] == 0xBB &&
        bytes[2] == 0xBF) {
      return 'csv';
    }

    final probe = bytes.length < 512 ? bytes.length : 512;
    for (int i = 0; i < probe; i++) {
      final b = bytes[i];
      final isWhitespace = b == 0x09 || b == 0x0A || b == 0x0D;
      final isPrintableAscii = b >= 0x20 && b <= 0x7E;
      final isUtf8Multibyte = b >= 0x80;
      if (!isWhitespace && !isPrintableAscii && !isUtf8Multibyte) {
        return '';
      }
    }
    return 'csv';
  }

  static String _detectFileType(String fileName, List<int> bytes) {
    final fromName = _extFromName(fileName);
    if (fromName.isNotEmpty) return fromName;
    return _extFromBytes(bytes);
  }

  // ── pickFile ───────────────────────────────────────────────────────────────

  Future<PlatformFile?> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv', 'xlsx', 'xls'],
        withData: true,
      );
      if (result == null || result.files.isEmpty) return null;
      return result.files.first;
    } catch (e, stack) {
      debugPrint('[pickFile] ❌ $e\n$stack');
      _setError('[Picker error] $e');
      return null;
    }
  }

  // ── validateFile ───────────────────────────────────────────────────────────

  String? _validateFile(PlatformFile file) {
    final bytes = file.bytes;
    final fileName = file.name;

    if (bytes == null || bytes.isEmpty) {
      _setError('[Validation error] Could not read file data. Try again.');
      return null;
    }

    final ext = _detectFileType(fileName, bytes);

    if (ext.isEmpty) {
      _setError('[Validation error] Only CSV / XLS / XLSX files are allowed.');
      return null;
    }
    if (bytes.length > 10 * 1024 * 1024) {
      _setError('[Validation error] File exceeds 10 MB limit.');
      return null;
    }
    return ext;
  }

  // ── _pickAndUpload ─────────────────────────────────────────────────────────

  Future<void> _pickAndUpload() async {
    final file = await _pickFile();
    if (file == null) return;

    final ext = _validateFile(file);
    if (ext == null) return;

    final fileName = file.name;
    final bytes = file.bytes!;

    setState(() {
      _selectedFileName = fileName;
      _phase = _UploadPhase.uploading;
      _progress = 0;
      _errorMessage = null;
    });
    _startProgressAnimation(targetFraction: 0.70);

    // ── Step 3: upload file + insert DB (Firebase) ───────────────────────────
    FirebaseUploadResult uploadResult;
    try {
      debugPrint('[_pickAndUpload] ▶ uploadPortfolio() via Firebase');
      uploadResult = await _firebaseService.uploadPortfolio(
        fileName: fileName,
        bytes: bytes,
        fileExtension: ext,
      );
      debugPrint('[_pickAndUpload] ✅ uploadPortfolio() — id: ${uploadResult.id}');
      _advanceProgress(to: 0.78);
    } on PortfolioUploadException catch (e) {
      _setError(e.message);
      return;
    } catch (e, stack) {
      debugPrint('[_pickAndUpload] ❌ unexpected: $e\n$stack');
      _setError('[Unexpected upload error] $e');
      return;
    }

    // ── Step 4: parse holdings ────────────────────────────────────────────────
    List<PortfolioInvestment> investments;
    try {
      debugPrint('[_pickAndUpload] ▶ parsing file ($ext)');
      if (ext == 'csv') {
        investments =
            PortfolioDocumentParser.parseCsv(String.fromCharCodes(bytes));
      } else {
        final parser = TableParser.decodeBytes(bytes);
        final sheetName = parser.tables.keys.first;
        final rows = parser.tables[sheetName]!.rows;
        investments = PortfolioDocumentParser.parseExcelRows(rows);
      }
      debugPrint('[_pickAndUpload] parsed ${investments.length} investments');
    } catch (e, stack) {
      debugPrint('[_pickAndUpload] ❌ parse error: $e\n$stack');
      _setError('[Parse error] Could not read file contents: $e');
      return;
    }

    _advanceProgress(to: 0.85);

    if (investments.isEmpty) {
      _setError(
        'No valid rows found in the file.\n'
        'Expected columns: Name · Type · Amount · Current Value · Date.',
      );
      return;
    }

    // ── Step 5: AI analysis stub ──────────────────────────────────────────────
    _setPhase(_UploadPhase.analyzing);
    try {
      await _firebaseService.triggerAiAnalysis(uploadResult.fileUrl);
    } catch (e, stack) {
      debugPrint('[_pickAndUpload] ⚠ triggerAiAnalysis error: $e\n$stack');
    }
    _advanceProgress(to: 0.90);

    // ── Step 6: save holdings to Firestore ────────────────────────────────────
    int count;
    try {
      debugPrint('[_pickAndUpload] ▶ addBulk()');
      count = await _portfolioService.addBulk(investments);
      debugPrint('[_pickAndUpload] ✅ addBulk() saved $count holdings');
    } catch (e, stack) {
      debugPrint('[_pickAndUpload] ❌ addBulk() error: $e\n$stack');
      _setError('[Firestore error] Could not save holdings: $e');
      return;
    }

    _advanceProgress(to: 0.97);

    // ── Step 7: record upload metadata in Firebase ────────────────────────────
    try {
      debugPrint('[_pickAndUpload] ▶ recordUpload()');
      await _portfolioService.recordUpload(
        filename: fileName,
        fileType: ext,
        status: 'success',
        processingLog:
            '$count holdings imported · Firebase id: ${uploadResult.id}',
      );
      debugPrint('[_pickAndUpload] ✅ recordUpload() done');
    } catch (e, stack) {
      debugPrint('[_pickAndUpload] ⚠ recordUpload error: $e\n$stack');
    }

    _progressTimer?.cancel();
    if (mounted) {
      setState(() {
        _progress = 1.0;
        _importedCount = count;
        _phase = _UploadPhase.success;
      });
    }
  }

  // ── Progress helpers ───────────────────────────────────────────────────────

  void _startProgressAnimation({required double targetFraction}) {
    int step = 0;
    const steps = 40;
    _progressTimer?.cancel();
    _progressTimer =
        Timer.periodic(const Duration(milliseconds: 60), (timer) {
      step++;
      if (mounted) {
        setState(() {
          _progress =
              ((step / steps) * targetFraction).clamp(0.0, targetFraction);
        });
      }
      if (step >= steps) timer.cancel();
    });
  }

  void _advanceProgress({required double to}) {
    if (mounted) setState(() => _progress = to);
  }

  // ── State helpers ──────────────────────────────────────────────────────────

  void _setPhase(_UploadPhase phase) {
    if (mounted) setState(() => _phase = phase);
  }

  void _setError(String message) {
    _progressTimer?.cancel();
    if (mounted) {
      setState(() {
        _errorMessage = message;
        _phase = _UploadPhase.error;
      });
    }
  }

  void _reset() {
    setState(() {
      _phase = _UploadPhase.idle;
      _selectedFileName = null;
      _progress = 0;
      _errorMessage = null;
      _importedCount = 0;
    });
    _fadeCtrl.forward(from: 0);
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: AppTheme.mainGradient,
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context),
              Expanded(
                child: FadeTransition(
                  opacity: _fade,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        _buildHero(),
                        const SizedBox(height: 32),
                        _buildUploadArea(),
                        const SizedBox(height: 24),
                        if (_phase == _UploadPhase.idle) ...[
                          _buildFormatRow(),
                          const SizedBox(height: 32),
                          _buildManualBanner(context),
                        ],
                        if (_phase == _UploadPhase.error) ...[
                          const SizedBox(height: 8),
                          _buildErrorBanner(),
                          const SizedBox(height: 16),
                          _buildRetryButton(),
                        ],
                        if (_phase == _UploadPhase.success) ...[
                          const SizedBox(height: 8),
                          _buildSuccessSummary(),
                          const SizedBox(height: 24),
                          _buildSuccessActions(),
                        ],
                        const SizedBox(height: 32),
                        _buildPrivacyNote(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── App bar ────────────────────────────────────────────────────────────────

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon:
                const Icon(LucideIcons.chevronLeft, color: Colors.white),
            onPressed: () => context.pop(),
          ),
          const Expanded(
            child: Text(
              'Import Portfolio',
              style:
                  TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          _buildAiBadge(),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildAiBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.secondaryAccentColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.secondaryAccentColor.withValues(alpha: 0.4),
        ),
      ),
      child: const Row(
        children: [
          Icon(LucideIcons.sparkles,
              size: 14, color: AppTheme.secondaryAccentColor),
          SizedBox(width: 4),
          Text(
            'AI Powered',
            style: TextStyle(
              color: AppTheme.secondaryAccentColor,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ── Hero section ───────────────────────────────────────────────────────────

  Widget _buildHero() {
    return Column(
      children: [
        ScaleTransition(
          scale: _pulse,
          child: Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryColor.withValues(alpha: 0.3),
                  AppTheme.primaryColor.withValues(alpha: 0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.primaryColor.withValues(alpha: 0.5),
                width: 2,
              ),
            ),
            child: const Icon(LucideIcons.fileSpreadsheet,
                size: 40, color: AppTheme.primaryColor),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Upload Your Portfolio',
          style:
              TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        const Text(
          'Import your investment document and get\nAI-powered insights instantly',
          style: TextStyle(
              color: AppTheme.textSecondary, fontSize: 14, height: 1.5),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // ── Upload area (switches by phase) ───────────────────────────────────────

  Widget _buildUploadArea() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      child: switch (_phase) {
        _UploadPhase.idle || _UploadPhase.error => _buildDropZone(),
        _UploadPhase.uploading => _buildProgressCard(
            label: 'Uploading to cloud...',
          ),
        _UploadPhase.analyzing => _buildProgressCard(
            label: 'Analyzing portfolio...',
            icon: LucideIcons.sparkles,
          ),
        _UploadPhase.success => _buildSuccessCard(),
      },
    );
  }

  Widget _buildDropZone() {
    return GestureDetector(
      key: const ValueKey('drop-zone'),
      onTap: _pickAndUpload,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        padding:
            const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppTheme.primaryColor.withValues(alpha: 0.4),
            width: 2,
          ),
          gradient: LinearGradient(
            colors: [
              AppTheme.primaryColor.withValues(alpha: 0.06),
              AppTheme.primaryColor.withValues(alpha: 0.02),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(LucideIcons.uploadCloud,
                  size: 36, color: AppTheme.primaryColor),
            ),
            const SizedBox(height: 20),
            const Text(
              'Tap to Upload File',
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Supports CSV and Excel (.xlsx / .xls)',
              style: TextStyle(
                  color: AppTheme.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: ['XLSX', 'XLS', 'CSV']
                  .map((f) => Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 4),
                        child: _buildBadge(f),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String label) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
            color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: AppTheme.textSecondary,
        ),
      ),
    );
  }

  Widget _buildProgressCard({
    required String label,
    IconData icon = LucideIcons.fileUp,
  }) {
    return Container(
      key: ValueKey(label),
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: AppTheme.glassDecoration,
      child: Column(
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.8, end: 1.0),
            duration: const Duration(milliseconds: 600),
            curve: Curves.elasticOut,
            builder: (_, v, child) =>
                Transform.scale(scale: v, child: child),
            child: Icon(icon, size: 44, color: AppTheme.primaryColor),
          ),
          const SizedBox(height: 16),
          Text(
            _selectedFileName ?? '',
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 15),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
                color: AppTheme.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: _progress,
              backgroundColor:
                  Colors.white.withValues(alpha: 0.08),
              valueColor: const AlwaysStoppedAnimation(
                  AppTheme.primaryColor),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '${(_progress * 100).toInt()}%',
            style: const TextStyle(
              color: AppTheme.primaryColor,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessCard() {
    return Container(
      key: const ValueKey('success-card'),
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
            color: AppTheme.primaryColor.withValues(alpha: 0.5)),
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor.withValues(alpha: 0.12),
            AppTheme.primaryColor.withValues(alpha: 0.04),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(LucideIcons.checkCircle2,
                size: 40, color: AppTheme.primaryColor),
          ),
          const SizedBox(height: 16),
          const Text(
            'Upload Successful!',
            style:
                TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            _selectedFileName ?? '',
            style: const TextStyle(
                color: AppTheme.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$_importedCount holding${_importedCount == 1 ? '' : 's'} imported · Saved to portfolio',
              style: const TextStyle(
                color: AppTheme.primaryColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormatRow() {
    return Row(
      children: [
        _buildFormatItem(LucideIcons.fileSpreadsheet,
            'Excel\n(.xlsx / .xls)', AppTheme.primaryColor),
        const SizedBox(width: 12),
        _buildFormatItem(LucideIcons.fileText, 'CSV\nFormat',
            const Color(0xFF60A5FA)),
        const SizedBox(width: 12),
        _buildFormatItem(LucideIcons.info,
            'Columns:\nName, Type, Amount…', AppTheme.secondaryAccentColor),
      ],
    );
  }

  Widget _buildFormatItem(IconData icon, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: AppTheme.glassDecoration,
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                color: AppTheme.textSecondary,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManualBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(LucideIcons.pencil, size: 18, color: AppTheme.textSecondary),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Prefer manual entry?',
                    style: TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600)),
                SizedBox(height: 2),
                Text('Add holdings one by one for more control',
                    style: TextStyle(
                        fontSize: 12, color: AppTheme.textSecondary)),
              ],
            ),
          ),
          IconButton(
            onPressed: () => context.push('/add-investment'),
            icon: const Icon(LucideIcons.chevronRight,
                size: 18, color: AppTheme.primaryColor),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(LucideIcons.alertCircle,
              color: Colors.redAccent, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _errorMessage ?? 'An error occurred during upload',
              style: const TextStyle(
                  color: Colors.redAccent, fontSize: 13, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRetryButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _reset,
        icon: const Icon(LucideIcons.refreshCcw, size: 16),
        label: const Text('Try Again'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white.withValues(alpha: 0.05),
        ),
      ),
    );
  }

  Widget _buildSuccessSummary() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.glassDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Next Steps',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildStepItem(LucideIcons.sparkles,
              'AI analysis will appear in your reports soon'),
          const SizedBox(height: 12),
          _buildStepItem(LucideIcons.lineChart,
              'View performance and diversification charts'),
        ],
      ),
    );
  }

  Widget _buildStepItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppTheme.primaryColor),
        const SizedBox(width: 10),
        Expanded(
          child: Text(text,
              style: const TextStyle(
                  fontSize: 13, color: AppTheme.textSecondary)),
        ),
      ],
    );
  }

  Widget _buildSuccessActions() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => context.pop(),
            child: const Text('Back'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: () => context.go('/reports'),
            child: const Text('View Reports'),
          ),
        ),
      ],
    );
  }

  Widget _buildPrivacyNote() {
    return const Column(
      children: [
        Icon(LucideIcons.shieldCheck, size: 20, color: AppTheme.textSecondary),
        SizedBox(height: 12),
        Text(
          'Your data is private and secure. Documents are encrypted and\nstored only to provide insights and reporting for you.',
          style: TextStyle(
              color: AppTheme.textSecondary, fontSize: 11, height: 1.5),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

enum _UploadPhase {
  idle,
  uploading,
  analyzing,
  success,
  error,
}
