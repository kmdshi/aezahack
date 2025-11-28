import 'dart:io';
import 'dart:typed_data';

import 'package:crop_your_image/crop_your_image.dart';
import 'package:fast_pdf/core/theme/cupertino_dropbox_theme.dart';
import 'package:fast_pdf/core/widgets/appbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:fast_pdf/core/services/files_history.dart';
import 'package:fast_pdf/core/services/notifier.dart';
import 'package:fast_pdf/features/files/blocs/pdf_editor/pdf_editor_bloc.dart';
import 'package:fast_pdf/features/files/widgets/button_set_widget.dart';
import 'package:fast_pdf/features/files/widgets/reordable_pages.dart';
import 'package:fast_pdf/features/files/widgets/signatures_bottom.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditPdfScreen extends StatefulWidget {
  const EditPdfScreen({super.key});

  @override
  State<EditPdfScreen> createState() => _EditPdfScreenState();
}

class _EditPdfScreenState extends State<EditPdfScreen> {
  ViewportBasedRect? currentRect;
  final _cropController = CropController();
  bool isCropping = false;
  Uint8List? croppingImage;
  int croppingIndex = 0;
  late TextEditingController fileNameController;
  late PageController _pageController;
  int _currentPageIndex = 0;
  String oldName = '';

  @override
  void initState() {
    fileNameController = TextEditingController(text: 'Edit PDF');
    _pageController = PageController();

    _pageController.addListener(() {
      setState(() {
        _currentPageIndex = _pageController.page?.round() ?? 0;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    fileNameController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PdfEditorBloc, PdfEditorState>(
      listener: (context, state) async {
        if (state is PdfExported) {
          await _savePdf(state.pdfBytes);
          Navigator.pop(context);
        } else if (state is PdfEditorLoaded) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() {
              fileNameController.text = state.fileName;
              oldName = state.fileName;
            });
          });
        }
      },
      child: BlocBuilder<PdfEditorBloc, PdfEditorState>(
        builder: (context, state) {
          if (state is PdfEditorLoading) {
            return Scaffold(
              backgroundColor: CupertinoDropboxTheme.background,
              appBar: CustomAppBar.dropboxAppBar(
                title: "Loading...",
                onBack: () => Navigator.pop(context),
              ),
              body: const Center(
                child: CupertinoActivityIndicator(
                  color: CupertinoDropboxTheme.primary,
                ),
              ),
            );
          }

          if (state is PdfEditorError) {
            return Scaffold(
              backgroundColor: CupertinoDropboxTheme.background,
              appBar: CustomAppBar.dropboxAppBar(
                title: "Error",
                onBack: () => Navigator.pop(context),
              ),
              body: Center(
                child: Text(
                  state.message,
                  style: CupertinoDropboxTheme.bodyStyle.copyWith(
                    color: CupertinoDropboxTheme.error,
                  ),
                ),
              ),
            );
          }

          if (state is PdfEditorLoaded) {
            return Scaffold(
              backgroundColor: CupertinoDropboxTheme.background,
              resizeToAvoidBottomInset: false,
              appBar: CustomAppBar.dropboxAppBar(
                title: fileNameController.text.isNotEmpty
                    ? fileNameController.text
                    : "Edit PDF",
                onBack: () => Navigator.pop(context),
                actions: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      if (isCropping) {
                        _cropController.crop();
                        return;
                      } else {
                        context.read<PdfEditorBloc>().add(ExportPdfEvent());
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: CupertinoDropboxTheme.spacing12,
                        vertical: CupertinoDropboxTheme.spacing4,
                      ),
                      decoration: BoxDecoration(
                        color: CupertinoDropboxTheme.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isCropping ? "Crop" : "Save",
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
                  // Main content area
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.all(
                        CupertinoDropboxTheme.spacing16,
                      ),
                      decoration: BoxDecoration(
                        color: CupertinoDropboxTheme.gray100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: CupertinoDropboxTheme.cardBorder,
                        ),
                      ),
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: state.pages.length,
                        itemBuilder: (context, index) {
                          final page = state.pages[index];

                          return Padding(
                            padding: const EdgeInsets.all(
                              CupertinoDropboxTheme.spacing16,
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: CupertinoDropboxTheme.cardShadow,
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: (isCropping && croppingIndex == index)
                                    ? Crop(
                                        controller: _cropController,
                                        initialRectBuilder:
                                            InitialRectBuilder.withArea(
                                              const Rect.fromLTWH(
                                                100,
                                                200,
                                                500,
                                                400,
                                              ),
                                            ),
                                        image: croppingImage!,
                                        onMoved: (viewportRect, imageRect) {
                                          currentRect = imageRect;
                                        },

                                        cornerDotBuilder:
                                            (size, edgeAlignment) =>
                                                const DotControl(
                                                  color: CupertinoDropboxTheme
                                                      .primary,
                                                ),
                                        onCropped: (croppedBytes) {
                                          context.read<PdfEditorBloc>().add(
                                            CropPageEvent(
                                              index: index,
                                              original: page,
                                              cropRect: currentRect!,
                                            ),
                                          );

                                          setState(() {
                                            isCropping = false;
                                            currentRect = null;
                                          });
                                        },
                                      )
                                    : Image.memory(page, fit: BoxFit.contain),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  if (state.pages.length > 1)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: CupertinoDropboxTheme.spacing8,
                      ),
                      child: Text(
                        "Page ${_currentPageIndex + 1} of ${state.pages.length}",
                        style: CupertinoDropboxTheme.footnoteStyle,
                      ),
                    ),

                  Container(
                    padding: const EdgeInsets.all(
                      CupertinoDropboxTheme.spacing16,
                    ),
                    decoration: BoxDecoration(
                      color: CupertinoDropboxTheme.background,
                      border: Border(
                        top: BorderSide(
                          color: CupertinoDropboxTheme.divider,
                          width: 0.5,
                        ),
                      ),
                    ),
                    child: ButtonSetWidget(
                      icons: const [
                        'assets/images/icons/reorder.svg',
                        'assets/images/icons/delete.svg',
                        'assets/images/icons/cut.svg',
                        'assets/images/icons/copy.svg',
                        'assets/images/icons/sign.svg',
                      ],
                      labels: const [
                        'Reorder',
                        'Delete',
                        'Crop',
                        'Copy',
                        'Sign',
                      ],
                      onTap: (index) {
                        final pageIndex = _currentPageIndex;
                        final currentState = context
                            .read<PdfEditorBloc>()
                            .state;
                        if (currentState is! PdfEditorLoaded) return;

                        switch (index) {
                          case 0:
                            Navigator.of(context).push(
                              CupertinoPageRoute(
                                fullscreenDialog: true,
                                builder: (_) => const ReorderPagesScreen(),
                              ),
                            );
                            break;
                          case 1:
                            context.read<PdfEditorBloc>().add(
                              DeletePageEvent(pageIndex),
                            );
                            break;

                          case 2:
                            final pages = currentState.pages;
                            if (pages.isEmpty) return;

                            final safeIndex = _currentPageIndex.clamp(
                              0,
                              pages.length - 1,
                            );
                            setState(() {
                              croppingIndex = safeIndex;
                              croppingImage = pages[safeIndex];
                              isCropping = true;
                            });

                            break;

                          case 3:
                            context.read<PdfEditorBloc>().add(
                              CopyPageEvent(pageIndex),
                            );
                            break;

                          case 4:
                            showSignatureSelector(
                              context: context,
                              onDeleteSignature: (id) async {
                                final prefs =
                                    await SharedPreferences.getInstance();

                                final signatures =
                                    prefs.getStringList('signatures') ?? [];
                                final names =
                                    prefs.getStringList('signatureNames') ?? [];

                                if (id < signatures.length) {
                                  signatures.removeAt(id);
                                }

                                if (id < names.length) {
                                  names.removeAt(id);
                                }

                                await prefs.setStringList(
                                  'signatures',
                                  signatures,
                                );
                                await prefs.setStringList(
                                  'signatureNames',
                                  names,
                                );
                              },

                              onSignatureSelected:
                                  (Uint8List selectedSignature, _) {
                                    context.read<PdfEditorBloc>().add(
                                      AddSignatureEvent(
                                        signature: selectedSignature,
                                      ),
                                    );
                                  },
                            );
                            break;
                        }
                      },
                    ),
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Future<void> _savePdf(Uint8List bytes) async {
    String finalFileName = fileNameController.text.trim();

    final downloadDir = await getApplicationDocumentsDirectory();
    final path = "${downloadDir.path}/$finalFileName.pdf";

    final file = File(path);
    await file.writeAsBytes(bytes);

    final savedPath = await savePdfToLocal(
      finalFileName != oldName ? finalFileName : oldName,
      bytes,
    );

    await RecentFilesService.add(savedPath);

    GlobalStreamController.notify();
    setState(() {
      fileNameController.text = 'Edit PDF';
    });
  }

  Future<String> savePdfToLocal(String name, Uint8List bytes) async {
    final downloadDir = await getApplicationDocumentsDirectory();
    final path = "${downloadDir.path}/$name.pdf";

    final file = File(path);
    await file.writeAsBytes(bytes);
    return path;
  }
}
