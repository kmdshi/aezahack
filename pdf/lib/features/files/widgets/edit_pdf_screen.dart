import 'dart:io';
import 'dart:typed_data';

import 'package:crop_your_image/crop_your_image.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pdf_app/features/files/blocs/pdf_editor/pdf_editor_bloc.dart';
import 'package:pdf_app/features/files/widgets/reordable_pages.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

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

  @override
  void initState() {
    fileNameController = TextEditingController(text: 'Edit PDF');
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

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("PDF успешно сохранён!")),
          );
          context.read<PdfEditorBloc>().add(LoadPdfIdleEvent());
        }
      },
      child: Stack(
        children: [
          Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: TextField(
                readOnly: fileNameController.text == 'Edit PDF' ? true : false,
                controller: fileNameController,
                decoration: const InputDecoration(border: InputBorder.none),
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            body: BlocBuilder<PdfEditorBloc, PdfEditorState>(
              builder: (context, state) {
                if (state is PdfEditorInitial) {
                  return Center(
                    child: FilledButton.icon(
                      icon: const Icon(Icons.upload_file),
                      label: const Text("Выбрать PDF"),
                      onPressed: _pickPdf,
                    ),
                  );
                }

                if (state is PdfEditorLoading) {
                  return const Center(child: CircularProgressIndicator());
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
                  final pageController = PageController();

                  return Column(
                    children: [
                      SizedBox(
                        height: MediaQuery.sizeOf(context).height * 0.6,
                        child: PageView.builder(
                          controller: pageController,
                          itemCount: state.pages.length,
                          itemBuilder: (context, index) {
                            final page = state.pages[index];

                            return Padding(
                              padding: const EdgeInsets.all(16),
                              child: DottedBorder(
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  child: (isCropping && croppingIndex == index)
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
                                      : Image.memory(page, fit: BoxFit.contain),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: SmoothPageIndicator(
                          controller: pageController,
                          count: state.pages.length,
                          effect: WormEffect(dotHeight: 12, dotWidth: 12),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: FilledButton(
                          onPressed: () {
                            if (isCropping) {
                              _cropController.crop();
                              return;
                            }

                            final index = pageController.page!.round();
                            setState(() {
                              croppingIndex = index;
                              croppingImage = state.pages[index];
                              isCropping = true;
                            });
                          },
                          child: const Text("Обрезать страницу"),
                        ),
                      ),

                      FilledButton(
                        onPressed: () {
                          context.read<PdfEditorBloc>().add(
                            DeletePageEvent(pageController.page!.round()),
                          );
                        },
                        child: const Text("Удалить страницу"),
                      ),

                      FilledButton(
                        onPressed: () {
                          final state = context.read<PdfEditorBloc>().state;
                          if (state is! PdfEditorLoaded) return;
                          Navigator.of(context).push(
                            CupertinoPageRoute(
                              fullscreenDialog: true,
                              builder: (_) => ReorderPagesScreen(),
                            ),
                          );
                        },
                        child: const Text("порядок странц"),
                      ),

                      FilledButton(
                        onPressed: () {
                          context.read<PdfEditorBloc>().add(ExportPdfEvent());
                        },
                        child: const Text("Сохранить PDF"),
                      ),
                    ],
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
    );

    if (result == null) return;

    final bytes = result.files.first.bytes!;
    final rawName = result.files.first.name;
    final name = rawName.toLowerCase().endsWith('.pdf')
        ? rawName.substring(0, rawName.length - 4)
        : rawName;

    setState(() {
      fileNameController.text = name;
    });

    context.read<PdfEditorBloc>().add(
      LoadPdfEvent(pdfBytes: bytes, fileName: name),
    );
  }

  Future<void> _savePdf(Uint8List bytes) async {
    final downloadDir = Directory("/storage/emulated/0/Download");
    final path = "${downloadDir.path}/${fileNameController.text}.pdf";

    final file = File(path);
    await file.writeAsBytes(bytes);
    setState(() {
      fileNameController.text = 'Edit PDF';
    });
  }
}
