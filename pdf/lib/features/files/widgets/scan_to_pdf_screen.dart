import 'dart:io';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf_app/features/files/blocs/scan_to_pdf/scantopdf_bloc.dart';
import 'package:pdf_app/features/files/widgets/crop_screen.dart';
import 'package:pdfx/pdfx.dart';

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
      appBar: AppBar(
        title: const Text("Scan to PDF"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),

      body: BlocBuilder<ScantopdfBloc, ScantopdfState>(
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
                  bottom: 32,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FloatingActionButton(
                        heroTag: "gallery_btn",
                        backgroundColor: Colors.grey.shade800,
                        onPressed: _pickFromGallery,
                        child: const Icon(Icons.photo_library, size: 26),
                      ),

                      const SizedBox(width: 32),

                      FloatingActionButton.large(
                        heroTag: "camera_btn",
                        backgroundColor: Colors.blue,
                        onPressed: _takePhoto,
                        child: const Icon(Icons.camera_alt, size: 32),
                      ),

                      const SizedBox(width: 32),

                      FloatingActionButton(
                        heroTag: "flash_btn",
                        backgroundColor: Colors.grey.shade800,
                        onPressed: _toggleFlash,
                        child: Icon(
                          _flashOn ? Icons.flash_on : Icons.flash_off,
                          size: 26,
                          color: _flashOn ? Colors.yellow : Colors.white,
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

          if (state is PhotoCroppedState) {
            return Column(
              children: [
                Expanded(child: Image.memory(state.bytes)),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () async {
                          final pdfBytes = Uint8List(10);
                          context.read<ScantopdfBloc>().add(
                            CreatePdfEvent(pdfBytes),
                          );
                        },
                        icon: const Icon(Icons.document_scanner),
                        label: const Text("Сканировать в PDF"),
                      ),
                      const SizedBox(width: 16),
                      TextButton(
                        onPressed: () {
                          context.read<ScantopdfBloc>().add(InitCameraEvent());
                        },
                        child: const Text("Новое фото"),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }

          if (state is PdfCreatedState) {
            final controller = PdfController(
              document: PdfDocument.openData(state.pdfBytes),
            );

            return Stack(
              children: [
                Positioned.fill(
                  child: PdfView(
                    controller: controller,
                    scrollDirection: Axis.vertical,
                  ),
                ),

                Positioned(
                  bottom: 32,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FloatingActionButton(
                        heroTag: "share_pdf_btn",
                        backgroundColor: Colors.grey.shade800,
                        onPressed: () {},
                        child: const Icon(Icons.share, size: 26),
                      ),

                      const SizedBox(width: 32),

                      FloatingActionButton.large(
                        heroTag: "save_pdf_btn",
                        backgroundColor: Colors.blue,
                        onPressed: () async {
                          final bytes = state.pdfBytes;

                          final dir = await getApplicationDocumentsDirectory();
                          final path =
                              "${dir.path}/scan_${DateTime.now().millisecondsSinceEpoch}.pdf";

                          final file = File(path);
                          await file.writeAsBytes(bytes);

                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("PDF сохранён: $path")),
                            );
                          }
                        },
                        child: const Icon(Icons.download, size: 32),
                      ),

                      const SizedBox(width: 32),

                      FloatingActionButton(
                        heroTag: "add_page_btn",
                        backgroundColor: Colors.grey.shade800,
                        onPressed: () {
                          context.read<ScantopdfBloc>().add(InitCameraEvent());
                        },
                        child: const Icon(Icons.add_a_photo, size: 26),
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
    );
  }

  Future<void> _takePhoto() async {
    if (_camera == null || !_camera!.value.isInitialized) return;

    final file = await _camera!.takePicture();
    final bytes = await file.readAsBytes();

    context.read<ScantopdfBloc>().add(TakePhotoEvent(bytes));
  }

  Future<void> _toggleFlash() async {
    if (_camera == null) return;

    _flashOn = !_flashOn;

    await _camera!.setFlashMode(_flashOn ? FlashMode.torch : FlashMode.off);

    setState(() {});
  }

  Future<void> _pickFromGallery() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked == null) return;

    final bytes = await picked.readAsBytes();

    context.read<ScantopdfBloc>().add(TakePhotoEvent(bytes));
  }
}
