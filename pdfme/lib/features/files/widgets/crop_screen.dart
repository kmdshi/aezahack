import 'dart:typed_data';
import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image/image.dart' as img;
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import 'package:pdf_app/features/files/blocs/scan_to_pdf/scantopdf_bloc.dart';

class CustomCropScreen extends StatefulWidget {
  final Uint8List image;

  const CustomCropScreen({super.key, required this.image});

  @override
  State<CustomCropScreen> createState() => _CustomCropScreenState();
}

class _CustomCropScreenState extends State<CustomCropScreen> {
  final cropController = CropController();
  bool _flashOn = false;
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
    final cropped = _manualCrop(widget.image, currentRect!);
    context.read<ScantopdfBloc>().add(CropPhotoEvent(cropped));
  }

  void _pickFromGallery() {}

  void _toggleFlash() {
    setState(() {
      _flashOn = !_flashOn;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: Crop(
                    image: widget.image,
                    controller: cropController,
                    onMoved: (viewportRect, imageRect) {
                      currentRect = imageRect;
                    },
                    cornerDotBuilder: (size, edgeAlign) {
                      return SizedBox(
                        width: 30,
                        height: 30,
                        child: SvgPicture.asset(
                          'assets/images/icons/polz.svg',
                          width: 30,
                          height: 30,
                          fit: BoxFit.cover,
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
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                              decoration: BoxDecoration(shape: BoxShape.circle),
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
                      InkWell(
                        onTap: _scan,
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
                      LiquidGlassLayer(
                        child: LiquidGlass(
                        
                          shape: LiquidRoundedSuperellipse(borderRadius: 100),
                          child: InkWell(
                            onTap: _toggleFlash,
                            borderRadius: BorderRadius.circular(50),
                            child: Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(shape: BoxShape.circle),
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
                        thickness: 0.5,
                      ),
                      child: LiquidGlass(
                        shape: LiquidRoundedSuperellipse(borderRadius: 100),
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
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Spacer(),

                    const SizedBox(width: 12),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
