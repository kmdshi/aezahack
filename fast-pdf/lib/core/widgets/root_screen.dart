import 'dart:io';
import 'dart:typed_data';

import 'package:fast_pdf/core/services/files_history.dart';
import 'package:fast_pdf/core/services/notifier.dart';
import 'package:fast_pdf/core/widgets/appbar.dart';
import 'package:fast_pdf/core/widgets/button_widget.dart';
import 'package:fast_pdf/core/widgets/file_card_widget.dart';
import 'package:fast_pdf/features/files/blocs/scan/scan_bloc.dart';
import 'package:fast_pdf/features/files/widgets/pdf_converter_screen.dart';
import 'package:fast_pdf/features/files/widgets/scan_to_pdf_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_doc_scanner/flutter_doc_scanner.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pdf/widgets.dart' as pw;

class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  List<String> history = [];
  bool _isLoading = false;
  bool _menuOpen = false;

  @override
  void initState() {
    super.initState();
    _loadRecentFiles();

    GlobalStreamController.stream.listen((event) {
      _loadRecentFiles();
    });
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
      extendBody: true,
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          Scaffold(
            extendBody: true,
            body: SafeArea(
              child: Column(
                children: [
                  CustomAppBar(
                    left: ButtonWidget(
                      asset: 'assets/images/icons/settings.svg',
                    ),
                    titleWidget: Text(
                      "Main",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      itemCount: history.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, i) {
                        return FileCardWidget(path: history[i]);
                      },
                    ),
                  ),
                ],
              ),
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
            floatingActionButton: _buildFabMenu(),
          ),

          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CupertinoActivityIndicator(radius: 16),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFabMenu() {
    return SizedBox(
      height: 300,
      width: 300,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          AnimatedPositioned(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            bottom: _menuOpen ? 130 : 64,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 180),
              opacity: _menuOpen ? 1 : 0,
              child: _miniButton(
                icon: 'assets/images/icons/blue_galery.svg',
                label: "Convert PDF",
                onTap: () {
                  setState(() {
                    _menuOpen = false;
                  });
                  Navigator.of(context).push(
                    CupertinoPageRoute(builder: (_) => PdfConverterScreen()),
                  );
                },
              ),
            ),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            bottom: _menuOpen ? 80 : 64,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 180),
              opacity: _menuOpen ? 1 : 0,
              child: _miniButton(
                icon: 'assets/images/icons/blue_scan.svg',
                label: "Scan Document",
                onTap: () {
                  setState(() {
                    _menuOpen = false;
                  });
                  _takePhoto();
                },
              ),
            ),
          ),
          SizedBox(
            width: 64,
            height: 64,
            child: FloatingActionButton(
              backgroundColor: const Color(0xFF3093FF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
              onPressed: () {
                setState(() => _menuOpen = !_menuOpen);
              },
              child: AnimatedRotation(
                turns: _menuOpen ? 0.125 : 0,
                duration: const Duration(milliseconds: 220),
                child: SvgPicture.asset(
                  _menuOpen
                      ? 'assets/images/icons/cross.svg'
                      : 'assets/images/icons/scan.svg',
                  width: 28,
                  height: 28,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniButton({
    required String icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF3093FF)),
        ),
        child: Row(
          children: [
            SvgPicture.asset(icon, width: 18, height: 18),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(color: Color(0xFF3093FF))),
          ],
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
