import 'dart:convert';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_doc_scanner/flutter_doc_scanner.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf_app/features/files/blocs/scan_to_pdf/scantopdf_bloc.dart';
import 'package:pdf_app/features/files/widgets/crop_screen.dart';
import 'package:pdfx/pdfx.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';
import 'package:toastification/toastification.dart';

final cur = ValueNotifier(0);

class ScanToPdfScreen extends StatefulWidget {
  const ScanToPdfScreen({super.key});

  @override
  State<ScanToPdfScreen> createState() => _ScanToPdfScreenState();
}

class _ScanToPdfScreenState extends State<ScanToPdfScreen> {
  CameraController? _camera;
  late Future<void> _initCameraFuture;
  bool _flashOn = false;

  @override
  void initState() {
    super.initState();
    _initCameraFuture = _initCamera();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    final back = cameras.first;

    _camera = CameraController(back, ResolutionPreset.max, enableAudio: false);

    await _camera!.initialize();
    context.read<ScantopdfBloc>().add(InitCameraEvent());
  }

  @override
  void dispose() {
    _camera?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: SafeArea(
        child: BlocBuilder<ScantopdfBloc, ScantopdfState>(
          builder: (context, state) {
            if (state is CameraReadyState) {
              return Stack(
                children: [
                  Positioned.fill(
                    child: FutureBuilder(
                      future: _initCameraFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done &&
                            _camera != null &&
                            _camera!.value.isInitialized) {
                          return CameraPreview(_camera!);
                        }
                        return const Center(child: CircularProgressIndicator());
                      },
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
                                  onPressed: () => Navigator.pop(context),
                                ),
                              ),
                            ),
                          ),
                          Spacer(),
                          Text(
                            'SCAN TO PDF',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Spacer(),
                        ],
                      ),
                    ),
                  ),

                  Positioned(
                    bottom: 32,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        LiquidGlassLayer(
                          child: LiquidGlass(
                            shape: LiquidRoundedSuperellipse(borderRadius: 100),
                            child: InkWell(
                              onTap: _pickFromGallery,
                              borderRadius: BorderRadius.circular(50),
                              child: Container(
                                width: 70,
                                height: 70,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: const Icon(
                                    Icons.photo_library,
                                    size: 26,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 32),

                        InkWell(
                          onTap: _takePhoto,
                          borderRadius: BorderRadius.circular(50),
                          child: Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: SvgPicture.asset(
                                'assets/images/icons/scan.svg',
                                width: 32,
                                height: 32,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 32),

                        LiquidGlassLayer(
                          child: LiquidGlass(
                            shape: LiquidRoundedSuperellipse(borderRadius: 100),
                            child: InkWell(
                              onTap: _toggleFlash,
                              borderRadius: BorderRadius.circular(50),
                              child: Container(
                                width: 70,
                                height: 70,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Icon(
                                    _flashOn
                                        ? CupertinoIcons.sun_max
                                        : CupertinoIcons.sun_min,
                                    size: 26,
                                    color: _flashOn
                                        ? Colors.yellow
                                        : Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }

            if (state is PhotoTakenState) {
              return CustomCropScreen(image: state.bytes);
            }

            if (state is PdfCreatedState) {
              final controller = PdfController(
                document: PdfDocument.openData(state.pdfBytes),
              );

              int count = state.pages;
              return Stack(
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
                              blur: 200,
                              thickness: 200,
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
                                  onPressed: () => Navigator.pop(context),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Center(
                              child: Text(
                                'SCAN TO PDF',
                                style: TextStyle(
                                  color: Color(0xFF383838),
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 62),
                        ],
                      ),
                    ),
                  ),

                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        DottedBorder(
                          child: SizedBox(
                            height: 435,
                            width: 322,
                            child: PdfView(
                              onPageChanged: (page) {
                                cur.value = page;
                              },
                              controller: controller,
                              scrollDirection: Axis.horizontal,
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        CustomPageIndicator(count: count),
                      ],
                    ),
                  ),

                  Positioned(
                    bottom: 32,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        LiquidGlassLayer(
                          settings: LiquidGlassSettings(
                            glassColor: Colors.white,
                            blur: 200,
                            thickness: 200,
                          ),
                          child: LiquidGlass(
                            shape: LiquidRoundedSuperellipse(borderRadius: 100),
                            child: InkWell(
                              onTap: () async {
                                final tempDir = await getTemporaryDirectory();
                                final path = p.join(
                                  tempDir.path,
                                  "scan_${DateTime.now().millisecondsSinceEpoch}.pdf",
                                );

                                final file = File(path);
                                await file.writeAsBytes(state.pdfBytes);

                                await SharePlus.instance.share(
                                  ShareParams(
                                    files: [XFile(path)],
                                    text: "My scanned PDF",
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(50),
                              child: Container(
                                width: 70,
                                height: 70,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: SvgPicture.asset(
                                    'assets/images/icons/share.svg',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 32),

                        InkWell(
                          onTap: () async {
                            final bytes = state.pdfBytes;
                            String path;
                            if (Platform.isAndroid) {
                              final dir = await getDownloadsDirectory();
                              path = p.join(
                                dir!.path,
                                'scan_${DateTime.now().millisecondsSinceEpoch}.pdf',
                              );
                            } else if (Platform.isIOS) {
                              final dir =
                                  await getApplicationDocumentsDirectory();
                              path = p.join(
                                dir.path,
                                'scan_${DateTime.now().millisecondsSinceEpoch}.pdf',
                              );
                            } else {
                              final dir =
                                  await getApplicationDocumentsDirectory();
                              path = p.join(
                                dir.path,
                                'scan_${DateTime.now().millisecondsSinceEpoch}.pdf',
                              );
                            }
                            final file = File(path);
                            await file.writeAsBytes(bytes);
                            if (context.mounted) {
                              toastification.show(
                                type: ToastificationType.success,
                                title: Text("PDF saved succsefully"),
                                autoCloseDuration: Duration(seconds: 3),
                              );
                            }
                          },
                          borderRadius: BorderRadius.circular(50),
                          child: Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              color: Color(0xFF55A4FF),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: SvgPicture.asset(
                                'assets/images/icons/download.svg',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 32),

                        LiquidGlassLayer(
                          settings: LiquidGlassSettings(
                            glassColor: Colors.white,
                            blur: 200,
                            thickness: 200,
                          ),
                          child: LiquidGlass(
                            shape: LiquidRoundedSuperellipse(borderRadius: 100),
                            child: InkWell(
                              onTap: () {
                                context.read<ScantopdfBloc>().add(
                                  InitCameraEvent(),
                                );
                              },
                              borderRadius: BorderRadius.circular(50),
                              child: Container(
                                width: 70,
                                height: 70,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: SvgPicture.asset(
                                    'assets/images/icons/add.svg',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }

            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  Future<void> _takePhoto() async {
    try {
      final result = await FlutterDocScanner().getScanDocuments(page: 1);

      if (result == null) return;

      if (result is String && result.endsWith(".pdf")) {
        final file = File(result);
        final bytes = await file.readAsBytes();

        context.read<ScantopdfBloc>().add(ScanFileReceivedEvent(bytes));
        return;
      }

      if (result is List) {
        final pdfBytes = await _convertIosImagesToPdf(result.cast<String>());

        context.read<ScantopdfBloc>().add(ScanFileReceivedEvent(pdfBytes));
        return;
      }

      print("Unknown scan format: $result");
    } catch (e) {
      print("Scan error: $e");
    }
  }

  Future<Uint8List> _convertIosImagesToPdf(List<String> paths) async {
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

    return pdf.save();
  }

  Future<void> _toggleFlash() async {
    if (_camera == null) return;

    _flashOn = !_flashOn;

    await _camera!.setFlashMode(_flashOn ? FlashMode.torch : FlashMode.off);

    setState(() {});
  }

  Future<void> _pickFromGallery() async {
    final picker = ImagePicker();

    final pickedFiles = await picker.pickMultiImage();

    if (pickedFiles == null || pickedFiles.isEmpty) return;

    if (pickedFiles.length > 1) {
      final bytesList = await Future.wait(
        pickedFiles.map((picked) => picked.readAsBytes()),
      );

      context.read<ScantopdfBloc>().add(MultiplePhotosPickedEvent(bytesList));
    } else {
      final bytes = await pickedFiles.first.readAsBytes();
      context.read<ScantopdfBloc>().add(TakePhotoEvent(bytes));
    }
  }
}

class CustomPageIndicator extends StatelessWidget {
  final int count;

  const CustomPageIndicator({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: cur,
      builder: (context, value, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            count,
            (index) => AnimatedContainer(
              duration: Duration(milliseconds: 300),
              margin: EdgeInsets.symmetric(horizontal: 5),
              height: 12,
              width: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: value == index + 1 ? Colors.blue : Colors.grey,
              ),
            ),
          ),
        );
      },
    );
  }
}
