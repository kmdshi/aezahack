import 'dart:io';
import 'dart:typed_data';

import 'package:fast_pdf/core/services/files_history.dart';
import 'package:fast_pdf/core/services/notifier.dart';
import 'package:fast_pdf/core/theme/cupertino_dropbox_theme.dart';
import 'package:fast_pdf/core/widgets/appbar.dart';
import 'package:fast_pdf/features/files/blocs/scan/scan_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdfx/pdfx.dart';

class ScanViewerScreen extends StatefulWidget {
  const ScanViewerScreen({super.key});

  @override
  State<ScanViewerScreen> createState() => _ScanViewerScreenState();
}

class _ScanViewerScreenState extends State<ScanViewerScreen> {
  final ValueNotifier<int> curPage = ValueNotifier(1);

  @override
  Widget build(BuildContext context) {
    return BlocListener<ScanBloc, ScanState>(
      listener: (context, state) async {
        if (state is PdfExportSuccessState) {
          await _savePdf(state.pdfBytes);
          Navigator.of(context).pop();
        }

        if (state is ScanErrorState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: CupertinoDropboxTheme.error,
            ),
          );
        }
      },
      child: BlocBuilder<ScanBloc, ScanState>(
        builder: (context, state) {
          if (state is! PdfCreatedState) {
            return Scaffold(
              backgroundColor: CupertinoDropboxTheme.background,
              appBar: CustomAppBar.dropboxAppBar(
                title: "Scan to PDF",
                onBack: () => Navigator.pop(context),
              ),
              body: const Center(
                child: CupertinoActivityIndicator(
                  color: CupertinoDropboxTheme.primary,
                ),
              ),
            );
          }

          final Uint8List pdfBytes = state.pdfBytes;
          final int pages = state.pages;

          final controller = PdfController(
            document: PdfDocument.openData(pdfBytes),
          );

          return Scaffold(
            backgroundColor: CupertinoDropboxTheme.background,
            appBar: CustomAppBar.dropboxAppBar(
              title: "Scan to PDF",
              onBack: () => Navigator.pop(context),
              actions: [
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    context.read<ScanBloc>().add(ExportPdfEvent());
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: CupertinoDropboxTheme.spacing12,
                      vertical: CupertinoDropboxTheme.spacing6,
                    ),
                    decoration: BoxDecoration(
                      color: CupertinoDropboxTheme.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "Save",
                      style: CupertinoDropboxTheme.footnoteStyle.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: CupertinoDropboxTheme.spacing16),
              ],
            ),
            body: Column(
              children: [
                const SizedBox(height: CupertinoDropboxTheme.spacing24),
                
                // Document title
                Text(
                  "Scanned Document",
                  style: CupertinoDropboxTheme.title3Style,
                ),
                
                const SizedBox(height: CupertinoDropboxTheme.spacing8),
                
                Text(
                  "Review your document before saving",
                  style: CupertinoDropboxTheme.calloutStyle.copyWith(
                    color: CupertinoDropboxTheme.textSecondary,
                  ),
                ),
                
                const SizedBox(height: CupertinoDropboxTheme.spacing32),
                
                // PDF viewer
                Expanded(
                  child: Center(
                    child: Container(
                      width: 320,
                      height: 450,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: CupertinoDropboxTheme.elevatedCardShadow,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: PdfView(
                          controller: controller,
                          onPageChanged: (page) => curPage.value = page,
                          scrollDirection: Axis.horizontal,
                        ),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: CupertinoDropboxTheme.spacing24),
                
                // Page indicator
                if (pages > 1)
                  ValueListenableBuilder(
                    valueListenable: curPage,
                    builder: (_, value, __) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: CupertinoDropboxTheme.spacing16,
                          vertical: CupertinoDropboxTheme.spacing8,
                        ),
                        decoration: BoxDecoration(
                          color: CupertinoDropboxTheme.gray100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Page $value of $pages",
                              style: CupertinoDropboxTheme.footnoteStyle,
                            ),
                            const SizedBox(width: CupertinoDropboxTheme.spacing12),
                            ...List.generate(
                              pages,
                              (i) => AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                margin: const EdgeInsets.symmetric(horizontal: 2),
                                width: value == i + 1 ? 16 : 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: value == i + 1
                                    ? CupertinoDropboxTheme.primary
                                    : CupertinoDropboxTheme.gray300,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                
                const SizedBox(height: CupertinoDropboxTheme.spacing40),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _savePdf(Uint8List bytes) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileName = "scanned_$timestamp.pdf";

    final downloadDir = await getApplicationDocumentsDirectory();
    final path = "${downloadDir.path}/$fileName";

    final file = File(path);
    await file.writeAsBytes(bytes);

    final savedPath = await savePdfToLocal(fileName, bytes);
    await RecentFilesService.add(savedPath);

    GlobalStreamController.notify();
  }

  Future<String> savePdfToLocal(String name, Uint8List bytes) async {
    final downloadDir = await getApplicationDocumentsDirectory();
    final path = "${downloadDir.path}/$name";

    final file = File(path);
    await file.writeAsBytes(bytes);

    return path;
  }
}