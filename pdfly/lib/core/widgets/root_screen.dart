import 'dart:io';
import 'dart:typed_data';

import 'package:fast_pdf/core/services/files_history.dart';
import 'package:fast_pdf/core/services/notifier.dart';
import 'package:fast_pdf/core/theme/cupertino_dropbox_theme.dart';
import 'package:fast_pdf/core/widgets/cupertino_dropbox_widgets.dart';
import 'package:fast_pdf/core/widgets/file_components.dart';
import 'package:fast_pdf/core/widgets/appbar.dart';
import 'package:fast_pdf/features/files/blocs/pdf_editor/pdf_editor_bloc.dart';
import 'package:fast_pdf/features/files/blocs/scan/scan_bloc.dart';
import 'package:fast_pdf/features/files/widgets/edit_pdf_screen.dart';
import 'package:fast_pdf/features/files/widgets/pdf_converter_screen.dart';
import 'package:fast_pdf/features/files/widgets/scan_to_pdf_screen.dart';
import 'package:fast_pdf/features/settings/widgets/screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_doc_scanner/flutter_doc_scanner.dart';
import 'package:pdf/widgets.dart' as pw;

class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> with TickerProviderStateMixin {
  List<String> history = [];
  bool _isLoading = false;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _loadRecentFiles();

    GlobalStreamController.stream.listen((event) {
      _loadRecentFiles();
    });

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadRecentFiles() async {
    final recent = await RecentFilesService.getRecent();

    setState(() {
      history = recent;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CupertinoDropboxTheme.background,
      appBar: CustomAppBar.dropboxAppBar(
        title: "Documents",
        centerTitle: false,
        actions: [
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () => Navigator.of(
              context,
            ).push(CupertinoPageRoute(builder: (_) => const SettingsScreen())),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: CupertinoDropboxTheme.gray100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                CupertinoIcons.settings,
                color: CupertinoDropboxTheme.textSecondary,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: CupertinoDropboxTheme.spacing16),
        ],
      ),
      body: Stack(
        children: [
          // Main content
          FadeTransition(
            opacity: _fadeAnimation,
            child: history.isEmpty ? _buildEmptyState() : _buildFilesList(),
          ),

          // Floating action button for quick actions
          _buildFloatingActionButton(),

          // Loading overlay
          if (_isLoading) _buildLoadingOverlay(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: CupertinoDropboxTheme.spacing24,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Empty state illustration
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: CupertinoDropboxTheme.gray100,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(
              CupertinoIcons.doc_text,
              size: 48,
              color: CupertinoDropboxTheme.gray400,
            ),
          ),

          const SizedBox(height: CupertinoDropboxTheme.spacing32),

          Text("No Documents", style: CupertinoDropboxTheme.title2Style),

          const SizedBox(height: CupertinoDropboxTheme.spacing8),

          Text(
            "Scan documents or convert files to get started.\nTap the + button to begin.",
            textAlign: TextAlign.center,
            style: CupertinoDropboxTheme.calloutStyle.copyWith(
              color: CupertinoDropboxTheme.textSecondary,
              height: 1.4,
            ),
          ),

          const SizedBox(height: CupertinoDropboxTheme.spacing48),

          // Quick action buttons in empty state
          Row(
            children: [
              Expanded(
                child: CupertinoDropboxButton(
                  isPrimary: false,
                  onPressed: () {
                    Navigator.of(context).push(
                      CupertinoPageRoute(
                        builder: (_) => const PdfConverterScreen(),
                      ),
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        CupertinoIcons.arrow_2_circlepath,
                        size: 18,
                        color: CupertinoDropboxTheme.textPrimary,
                      ),
                      const SizedBox(width: CupertinoDropboxTheme.spacing8),
                      Text(
                        "Convert",
                        style: CupertinoDropboxTheme.calloutStyle,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: CupertinoDropboxTheme.spacing12),

              Expanded(
                child: CupertinoDropboxButton(
                  onPressed: _takePhoto,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        CupertinoIcons.doc_text_viewfinder,
                        size: 18,
                        color: Colors.white,
                      ),
                      const SizedBox(width: CupertinoDropboxTheme.spacing8),
                      Text(
                        "Scan",
                        style: CupertinoDropboxTheme.calloutStyle.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilesList() {
    return ListView.builder(
      padding: const EdgeInsets.all(CupertinoDropboxTheme.spacing24),
      itemCount: history.length + 1, // +1 for header
      itemBuilder: (context, index) {
        if (index == 0) {
          // Files header section
          return Padding(
            padding: const EdgeInsets.only(
              bottom: CupertinoDropboxTheme.spacing16,
            ),
            child: Row(
              children: [
                Text("Recent Files", style: CupertinoDropboxTheme.title3Style),
                const Spacer(),
                Text(
                  "${history.length} ${history.length == 1 ? 'file' : 'files'}",
                  style: CupertinoDropboxTheme.calloutStyle.copyWith(
                    color: CupertinoDropboxTheme.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }

        final fileIndex = index - 1;
        return Padding(
          padding: const EdgeInsets.only(
            bottom: CupertinoDropboxTheme.spacing12,
          ),
          child: CupertinoFileCard(
            path: history[fileIndex],
            onTap: () {
              context.read<PdfEditorBloc>().add(
                LoadPdfFromPathEvent(history[fileIndex]),
              );
              Navigator.of(
                context,
              ).push(CupertinoPageRoute(builder: (_) => EditPdfScreen()));
            },
          ),
        );
      },
    );
  }

  Widget _buildFloatingActionButton() {
    return Positioned(
      right: CupertinoDropboxTheme.spacing24,
      bottom: CupertinoDropboxTheme.spacing40,
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: _showActionSheet,
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: CupertinoDropboxTheme.primary,
            borderRadius: BorderRadius.circular(16),
            boxShadow: CupertinoDropboxTheme.buttonShadow,
          ),
          child: const Icon(CupertinoIcons.add, color: Colors.white, size: 24),
        ),
      ),
    );
  }

  void _showActionSheet() {
    DropboxActionSheet.show(context, [
      ActionSheetItem(
        title: "Scan Document",
        icon: CupertinoIcons.doc_text_viewfinder,
        color: CupertinoDropboxTheme.primary,
        onPressed: _takePhoto,
      ),
      ActionSheetItem(
        title: "Convert Files",
        icon: CupertinoIcons.arrow_2_circlepath,
        color: CupertinoDropboxTheme.success,
        onPressed: () {
          Navigator.of(context).push(
            CupertinoPageRoute(builder: (_) => const PdfConverterScreen()),
          );
        },
      ),
    ]);
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.3),
      child: Center(
        child: CupertinoDropboxCard(
          padding: const EdgeInsets.all(CupertinoDropboxTheme.spacing32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CupertinoActivityIndicator(
                color: CupertinoDropboxTheme.primary,
                radius: 20,
              ),
              const SizedBox(height: CupertinoDropboxTheme.spacing24),
              Text(
                "Processing Document",
                style: CupertinoDropboxTheme.headlineStyle,
              ),
              const SizedBox(height: CupertinoDropboxTheme.spacing8),
              Text(
                "Please wait while we scan your document",
                style: CupertinoDropboxTheme.calloutStyle.copyWith(
                  color: CupertinoDropboxTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _takePhoto() async {
    try {
      setState(() => _isLoading = true);

      final result = await FlutterDocScanner().getScanDocuments(page: 1);

      if (result == null) {
        setState(() => _isLoading = false);
        return;
      }

      if (result is String && result.endsWith(".pdf")) {
        final file = File(result);
        final bytes = await file.readAsBytes();

        context.read<ScanBloc>().add(ScanFileReceivedEvent(bytes, 1));

        setState(() => _isLoading = false);
        Navigator.push(
          context,
          CupertinoPageRoute(builder: (_) => const ScanViewerScreen()),
        );
        return;
      }

      if (result is List) {
        final pdfBytes = await _convertIosImagesToPdf(result.cast<String>());

        context.read<ScanBloc>().add(
          ScanFileReceivedEvent(pdfBytes.bytes, pdfBytes.pages),
        );

        setState(() => _isLoading = false);
        Navigator.push(
          context,
          CupertinoPageRoute(builder: (_) => const ScanViewerScreen()),
        );
        return;
      }

      setState(() => _isLoading = false);
    } catch (e) {
      print("Scan error: $e");
      setState(() => _isLoading = false);
    }
  }

  Future<PdfConversionResult> _convertIosImagesToPdf(List<String> paths) async {
    final pdf = pw.Document();

    for (final path in paths) {
      final file = File.fromUri(Uri.file(path));
      final bytes = await file.readAsBytes();
      final image = pw.MemoryImage(bytes);

      pdf.addPage(
        pw.Page(
          build: (_) =>
              pw.Center(child: pw.Image(image, fit: pw.BoxFit.contain)),
        ),
      );
    }
    final pdfBytes = await pdf.save();

    return PdfConversionResult(pdfBytes, paths.length);
  }
}

class PdfConversionResult {
  final Uint8List bytes;
  final int pages;

  PdfConversionResult(this.bytes, this.pages);
}
