import 'dart:io';
import 'dart:typed_data';

import 'package:crop_your_image/crop_your_image.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf_app/core/services/files_history.dart';
import 'package:pdf_app/core/services/notifier.dart';
import 'package:pdf_app/features/files/blocs/pdf_editor/pdf_editor_bloc.dart';
import 'package:pdf_app/features/files/widgets/button_set_widget.dart';
import 'package:pdf_app/features/files/widgets/reordable_pages.dart';
import 'package:pdf_app/features/files/widgets/signatures_bottom.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:toastification/toastification.dart';

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
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    return BlocListener<PdfEditorBloc, PdfEditorState>(
      listener: (context, state) async {
        if (state is PdfExported) {
          await _savePdf(state.pdfBytes, state.filename, oldName);
          toastification.show(
            type: ToastificationType.success,
            title: Text("PDF успешно сохранён."),
            autoCloseDuration: Duration(seconds: 3),
          );

          context.read<PdfEditorBloc>().add(LoadPdfIdleEvent());
        } else if (state is PdfEditorInitial) {
          setState(() {
            fileNameController.text = 'Edit PDF';
          });
        } else if (state is PdfEditorLoaded) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() {
              fileNameController.text = state.fileName;
              oldName = state.fileName;
            });
          });
        }
      },
      child: Stack(
        children: [
          Positioned.fill(
            child: SvgPicture.asset(
              'assets/images/bg_line.svg',
              fit: BoxFit.cover,
            ),
          ),
          Scaffold(
            resizeToAvoidBottomInset: false,
            body: BlocBuilder<PdfEditorBloc, PdfEditorState>(
              builder: (context, state) {
                if (state is PdfEditorInitial) {
                  return SafeArea(
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: SvgPicture.asset(
                            'assets/images/bg_line.svg',
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 16,
                          left: 0,
                          right: 0,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children: [
                                LiquidGlassLayer(
                                  settings: LiquidGlassSettings(
                                    glassColor: Colors.white,
                                  ),
                                  child: LiquidGlass(
                                    shape: LiquidRoundedSuperellipse(
                                      borderRadius: 100,
                                    ),
                                    child: SizedBox(
                                      width: w * 0.16,
                                      height: w * 0.16,
                                      child: IconButton(
                                        icon: Icon(
                                          CupertinoIcons.xmark,
                                          size: w * 0.07,
                                          color: Color(0xFF383838),
                                        ),
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: TextField(
                                    textAlign: TextAlign.center,
                                    readOnly:
                                        fileNameController.text == 'Edit PDF',
                                    controller: fileNameController,
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                    ),
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: w * 0.055,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                LiquidGlassLayer(
                                  settings: LiquidGlassSettings(
                                    glassColor: Colors.white,
                                  ),
                                  child: LiquidGlass(
                                    shape: LiquidRoundedSuperellipse(
                                      borderRadius: 100,
                                    ),
                                    child: SizedBox(
                                      width: w * 0.16,
                                      height: w * 0.16,
                                      child: IconButton(
                                        icon: SvgPicture.asset(
                                          'assets/images/icons/check.svg',
                                          fit: BoxFit.cover,
                                          color:
                                              fileNameController.text ==
                                                  'Edit PDF'
                                              ? Color(0xFF5D5D5D)
                                              : Color(0xFF55A4FF),
                                        ),
                                        onPressed: () {},
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Center(
                          child: Container(
                            alignment: Alignment.center,
                            height: h * 0.5,
                            width: w * 0.8,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage(
                                  'assets/images/actions/import.png',
                                ),
                                fit: BoxFit.cover,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 20,
                          left: MediaQuery.of(context).size.width / 2 - 35,
                          child: InkWell(
                            onTap: _pickPdf,
                            child: Container(
                              width: w * 0.22,
                              height: w * 0.22,
                              decoration: BoxDecoration(
                                color: Color(0xFF55A4FF),
                                shape: BoxShape.circle,
                              ),
                              child: SvgPicture.asset(
                                'assets/images/icons/import.svg',
                                fit: BoxFit.scaleDown,
                                width: w * 0.09,
                                height: w * 0.09,
                              ),
                            ),
                          ),
                        ),
                      ],
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
                  return SafeArea(
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: SvgPicture.asset(
                            'assets/images/bg_line.svg',
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 16,
                          left: 0,
                          right: 0,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children: [
                                LiquidGlassLayer(
                                  settings: LiquidGlassSettings(
                                    glassColor: Colors.white,
                                  ),
                                  child: LiquidGlass(
                                    shape: LiquidRoundedSuperellipse(
                                      borderRadius: 100,
                                    ),
                                    child: SizedBox(
                                      width: 62,
                                      height: 62,
                                      child: IconButton(
                                        icon: const Icon(
                                          CupertinoIcons.xmark,
                                          size: 24,
                                          color: Color(0xFF383838),
                                        ),
                                        onPressed: () {
                                          context.read<PdfEditorBloc>().add(
                                            LoadPdfIdleEvent(),
                                          );
                                          Navigator.pop(context);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Spacer(),
                                Expanded(
                                  child: TextField(
                                    readOnly:
                                        fileNameController.text == 'Edit PDF',
                                    controller: fileNameController,
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                    ),
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 24,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                                Spacer(),
                                LiquidGlassLayer(
                                  settings: LiquidGlassSettings(
                                    glassColor: Colors.white,
                                  ),
                                  child: LiquidGlass(
                                    shape: LiquidRoundedSuperellipse(
                                      borderRadius: 100,
                                    ),
                                    child: SizedBox(
                                      width: 62,
                                      height: 62,
                                      child: IconButton(
                                        icon: SvgPicture.asset(
                                          'assets/images/icons/check.svg',
                                          fit: BoxFit.cover,
                                          color: isCropping
                                              ? Color(0xFF55A4FF)
                                              : Color(0xFF5D5D5D),
                                        ),
                                        onPressed: isCropping
                                            ? () {
                                                _cropController.crop();
                                              }
                                            : () => context
                                                  .read<PdfEditorBloc>()
                                                  .add(ExportPdfEvent()),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        Positioned(
                          top: 80,
                          left: 0,
                          right: 0,
                          height: h * 0.6,
                          child: Column(
                            children: [
                              SizedBox(
                                height: h * 0.55,
                                child: PageView.builder(
                                  controller: _pageController,
                                  itemCount: state.pages.length,
                                  itemBuilder: (context, index) {
                                    final page = state.pages[index];

                                    return Padding(
                                      padding: EdgeInsets.all(w * 0.04),
                                      child: DottedBorder(
                                        child: Container(
                                          child:
                                              (isCropping &&
                                                  croppingIndex == index)
                                              ? Crop(
                                                  controller: _cropController,
                                                  initialRectBuilder:
                                                      InitialRectBuilder.withArea(
                                                        Rect.fromLTWH(
                                                          w * 0.15,
                                                          h * 0.20,
                                                          w * 0.7,
                                                          h * 0.25,
                                                        ),
                                                      ),
                                                  onMoved:
                                                      (
                                                        viewportRect,
                                                        imageRect,
                                                      ) {
                                                        currentRect = imageRect;
                                                      },
                                                  image: page,
                                                  onCropped: (croppedBytes) {
                                                    if (currentRect == null)
                                                      return;

                                                    context
                                                        .read<PdfEditorBloc>()
                                                        .add(
                                                          CropPageEvent(
                                                            index: index,
                                                            original: page,
                                                            cropRect:
                                                                currentRect!,
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
                                                      (
                                                        context,
                                                        error,
                                                        stackTrace,
                                                      ) {
                                                        return Center(
                                                          child: Text(
                                                            "Ошибка при загрузке изображения",
                                                          ),
                                                        );
                                                      },
                                                ),
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
                          bottom: h * 0.02,
                          left: 0,
                          right: 0,
                          child: ButtonSetWidget(
                            onCenterButtonTap: () {
                              context.read<PdfEditorBloc>().add(
                                ExportPdfEvent(),
                              );
                            },
                            onSurroundingButtonTap: (i) {
                              switch (i) {
                                // context.read<PdfEditorBloc>().add(ExportPdfEvent());

                                case 1:
                                  final state = context
                                      .read<PdfEditorBloc>()
                                      .state;
                                  if (state is! PdfEditorLoaded) return;
                                  Navigator.of(context).push(
                                    CupertinoPageRoute(
                                      fullscreenDialog: true,
                                      builder: (_) => ReorderPagesScreen(),
                                    ),
                                  );
                                case 2:
                                  context.read<PdfEditorBloc>().add(
                                    DeletePageEvent(_currentPageIndex),
                                  );
                                case 3:
                                  if (isCropping) {
                                    _cropController.crop();
                                    return;
                                  }

                                  setState(() {
                                    croppingIndex = _currentPageIndex;
                                    croppingImage =
                                        state.pages[_currentPageIndex];
                                    isCropping = true;
                                  });

                                case 4:
                                  context.read<PdfEditorBloc>().add(
                                    CopyPageEvent(_currentPageIndex),
                                  );
                                case 5:
                                  showSignatureSelector(
                                    context: context,
                                    onSignatureSelected:
                                        (Uint8List selectedSignature, _) {
                                          context.read<PdfEditorBloc>().add(
                                            AddSignatureEvent(
                                              signature: selectedSignature,
                                            ),
                                          );
                                        },
                                  );
                              }
                            },
                          ),
                        ),
                        Positioned(
                          top: MediaQuery.sizeOf(context).height * 0.64,
                          left: 0,
                          right: 0,
                          child: Padding(
                            padding: EdgeInsets.only(bottom: h * 0.03),
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: SmoothPageIndicator(
                                controller: _pageController,
                                count: state.pages.length,
                                effect: WormEffect(
                                  dotHeight: w * 0.03,
                                  dotWidth: w * 0.03,
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

    final savedPath = await savePdfToLocal(name, bytes);
    RecentFilesService.add(savedPath);
    GlobalStreamController.notify();

    context.read<PdfEditorBloc>().add(
      LoadPdfEvent(pdfBytes: bytes, fileName: name, savedPath: savedPath),
    );
  }

  Future<void> _savePdf(
    Uint8List bytes,
    String? fileName,
    String oldName,
  ) async {
    String finalFileName = fileNameController.text;

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
