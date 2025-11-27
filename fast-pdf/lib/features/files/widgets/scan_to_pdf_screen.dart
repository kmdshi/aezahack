import 'dart:io';
import 'dart:typed_data';

import 'package:fast_pdf/core/services/files_history.dart';
import 'package:fast_pdf/core/services/notifier.dart';
import 'package:fast_pdf/features/files/blocs/scan/scan_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fast_pdf/core/widgets/appbar.dart';
import 'package:fast_pdf/core/widgets/button_widget.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
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
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },

      child: Scaffold(
        body: SafeArea(
          child: BlocBuilder<ScanBloc, ScanState>(
            builder: (context, state) {
              if (state is! PdfCreatedState) {
                return const Center(child: CupertinoActivityIndicator());
              }

              final Uint8List pdfBytes = state.pdfBytes;
              final int pages = state.pages;

              final controller = PdfController(
                document: PdfDocument.openData(pdfBytes),
              );

              return Stack(
                children: [
                  Positioned(
                    top: 16,
                    left: 0,
                    right: 0,
                    child: CustomAppBar(
                      titleWidget: Text(
                        "SCAN TO PDF",
                        style: TextStyle(color: Colors.white),
                      ),
                      left: ButtonWidget(
                        asset: 'assets/images/icons/cross.svg',
                        onTap: () => Navigator.pop(context),
                      ),
                      right: ButtonWidget(
                        asset: 'assets/images/icons/done.svg',
                        iconSize: 10,
                        onTap: () {
                          context.read<ScanBloc>().add(ExportPdfEvent());
                        },
                      ),
                    ),
                  ),

                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 435,
                          width: 322,
                          child: PdfView(
                            controller: controller,
                            onPageChanged: (page) => curPage.value = page,
                            scrollDirection: Axis.horizontal,
                          ),
                        ),

                        const SizedBox(height: 20),

                        ValueListenableBuilder(
                          valueListenable: curPage,
                          builder: (_, value, __) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                pages,
                                (i) => AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  width: 22,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: value == i + 1
                                        ? Colors.white
                                        : const Color(0xFF929292),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
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

class _ChipButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final String? svgAsset;
  final VoidCallback onTap;

  const _ChipButton({
    required this.label,
    this.icon,
    this.svgAsset,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFEFF4FF),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            if (svgAsset != null)
              SvgPicture.asset(
                svgAsset!,
                width: 16,
                height: 16,
                colorFilter: const ColorFilter.mode(
                  Color(0xFF929292),
                  BlendMode.srcIn,
                ),
              )
            else if (icon != null)
              Icon(icon, size: 16, color: const Color(0xFF929292)),

            const SizedBox(width: 6),

            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF3386FF),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
