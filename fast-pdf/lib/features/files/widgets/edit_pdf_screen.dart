import 'dart:io';
import 'dart:typed_data';

import 'package:crop_your_image/crop_your_image.dart';
import 'package:fast_pdf/core/widgets/appbar.dart';
import 'package:fast_pdf/core/widgets/button_widget.dart';
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
  final _cropController = CropController();
  ViewportBasedRect? currentRect;
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
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: BlocBuilder<PdfEditorBloc, PdfEditorState>(
          builder: (context, state) {
            if (state is PdfEditorLoading) {
              return const Center(child: CupertinoActivityIndicator());
            }

            if (state is PdfEditorError) {
              return Center(
                child: Text(
                  state.message,
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }

            if (state is PdfEditorLoaded) {
              return SafeArea(
                child: Stack(
                  children: [
                    Positioned(
                      top: 16,
                      left: 0,
                      right: 0,
                      child: CustomAppBar(
                        titleWidget: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextField(
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                              isCollapsed: true,
                            ),

                            textAlign: TextAlign.center,
                            controller: fileNameController,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        left: ButtonWidget(
                          asset: 'assets/images/icons/cross.svg',
                          onTap: () => Navigator.pop(context),
                        ),
                        right: ButtonWidget(
                          asset: 'assets/images/icons/done.svg',
                          iconSize: 10,
                          onTap: () {
                            if (isCropping) {
                              _cropController.crop();
                              return;
                            } else {
                              context.read<PdfEditorBloc>().add(
                                ExportPdfEvent(),
                              );
                            }
                          },
                        ),
                      ),
                    ),

                    Positioned(
                      top: 100,
                      left: 0,
                      right: 0,
                      height: MediaQuery.sizeOf(context).height * 0.6,
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Color(0xFF1A1A1A),
                            ),
                            height: MediaQuery.sizeOf(context).height * 0.6,
                            child: PageView.builder(
                              controller: _pageController,
                              itemCount: state.pages.length,
                              itemBuilder: (context, index) {
                                final page = state.pages[index];

                                return Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Container(
                                    child:
                                        (isCropping && croppingIndex == index)
                                        ? Crop(
                                            controller: _cropController,
                                            initialRectBuilder:
                                                InitialRectBuilder.withArea(
                                                  Rect.fromLTWH(
                                                    100,
                                                    200,
                                                    500,
                                                    400,
                                                  ),
                                                ),
                                            onMoved: (viewportRect, imageRect) {
                                              currentRect = imageRect;
                                            },
                                            image: page,
                                            onCropped: (croppedBytes) {
                                              if (currentRect == null) return;

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
                                        : Image.memory(
                                            page,
                                            fit: BoxFit.contain,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                                  return Center(
                                                    child: Text(
                                                      "Ошибка при загрузке изображения",
                                                    ),
                                                  );
                                                },
                                          ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    Positioned(
                      bottom: 50,
                      left: 0,
                      right: 0,
                      child: ButtonSetWidget(
                        icons: [
                          'assets/images/icons/reorder.svg',
                          'assets/images/icons/delete.svg',
                          'assets/images/icons/cut.svg',
                          'assets/images/icons/copy.svg',
                          'assets/images/icons/sign.svg',
                        ],
                        labels: [
                          'Reorder',
                          'Delete',
                          'Cut',
                          'Copy',
                          'Signature',
                        ],
                        onTap: (i) {
                          final pdfState = context.read<PdfEditorBloc>().state;
                          if (pdfState is! PdfEditorLoaded) return;

                          if (pdfState.pages.isEmpty) return;

                          final pageIndex = _currentPageIndex.clamp(
                            0,
                            pdfState.pages.length - 1,
                          );

                          switch (i) {
                            // context.read<PdfEditorBloc>().add(ExportPdfEvent());

                            case 0:
                              final state = context.read<PdfEditorBloc>().state;
                              if (state is! PdfEditorLoaded) return;
                              Navigator.of(context).push(
                                CupertinoPageRoute(
                                  fullscreenDialog: true,
                                  builder: (_) => ReorderPagesScreen(),
                                ),
                              );
                              break;
                            case 1:
                              context.read<PdfEditorBloc>().add(
                                DeletePageEvent(pageIndex),
                              );
                              break;

                            case 2:
                              if (isCropping) {
                                _cropController.crop();
                                return;
                              }

                              setState(() {
                                croppingIndex = _currentPageIndex;
                                croppingImage = state.pages[_currentPageIndex];
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
                                  await prefs.remove('signature_$id');
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
                    Positioned(
                      top: MediaQuery.sizeOf(context).height * 0.74,
                      left: 0,
                      right: 0,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              state.pages.length,
                              (i) => AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                width: 22,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: _currentPageIndex == i
                                      ? Colors.white
                                      : const Color(0xFF929292),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
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
    print(path);
    await file.writeAsBytes(bytes);
    return path;
  }
}
