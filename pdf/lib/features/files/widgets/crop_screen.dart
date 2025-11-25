import 'dart:typed_data';
import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image/image.dart' as img;
import 'package:pdf_app/features/files/blocs/scan_to_pdf/scantopdf_bloc.dart';

class CustomCropScreen extends StatefulWidget {
  final Uint8List image;

  const CustomCropScreen({super.key, required this.image});

  @override
  State<CustomCropScreen> createState() => _CustomCropScreenState();
}

class _CustomCropScreenState extends State<CustomCropScreen> {
  final cropController = CropController();
  bool _loading = false;

  ViewportBasedRect? currentRect;

  Uint8List _manualCrop(Uint8List bytes, ViewportBasedRect rect) {
    final original = img.decodeImage(bytes)!;

    final x = rect.left.round();
    final y = rect.top.round();
    final w = rect.width.round();
    final h = rect.height.round();

    final cropped = img.copyCrop(original, x: x, y: y, width: w, height: h);

    return Uint8List.fromList(img.encodeJpg(cropped, quality: 90));
  }

  Future<void> _scan() async {
    if (currentRect == null) return;

    setState(() => _loading = true);

    final cropped = _manualCrop(widget.image, currentRect!);

    context.read<ScantopdfBloc>().add(CropPhotoEvent(cropped));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Crop(
                image: widget.image,
                controller: cropController,

                onMoved: (viewportRect, imageRect) {
                  currentRect = imageRect;
                },

                cornerDotBuilder: (size, edgeAlign) {
                  return Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  );
                },

                baseColor: Colors.black,
                maskColor: Colors.black.withOpacity(0.7),
                interactive: true,
                radius: 20,
                withCircleUi: false,

                onCropped: (_) {},
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: ElevatedButton(
                onPressed: _loading ? null : _scan,
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Сканировать"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
