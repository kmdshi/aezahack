import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:fast_pdf/core/widgets/appbar.dart';
import 'package:fast_pdf/core/widgets/button_widget.dart';
import 'package:fast_pdf/features/signature/widgets/buttons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ios_color_picker/show_ios_color_picker.dart';
import 'package:fast_pdf/core/services/notifier.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signature/signature.dart';

enum ToolType { draw, size, color, erase }

class NewSignatureScreen extends StatefulWidget {
  final Uint8List? savedSignature;
  final int? savedSignatureId;

  const NewSignatureScreen({
    super.key,
    this.savedSignature,
    this.savedSignatureId,
  });

  @override
  State<NewSignatureScreen> createState() => _SignatureScreenState();
}

class _SignatureScreenState extends State<NewSignatureScreen> {
  late SignatureController _controller;
  final iosColorPickerController = IOSColorPickerController();
  Color _penColor = Colors.black;
  double _penStroke = 3.0;
  Uint8List? _savedSignature;
  int signatureCounter = 0;
  final TextEditingController _nameController = TextEditingController();
  ToolType _activeTool = ToolType.draw;
  int selected = 0;

  int? currentId;

  @override
  void initState() {
    super.initState();

    _savedSignature = widget.savedSignature;
    currentId = widget.savedSignatureId;

    _controller = SignatureController(
      penColor: _penColor,
      penStrokeWidth: _penStroke,
      exportBackgroundColor: Colors.transparent,
    );

    _loadCounterAndName();
  }

  @override
  void dispose() {
    _controller.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadCounterAndName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      signatureCounter = prefs.getInt("signature_counter") ?? 0;
    });

    if (currentId != null) {
      final savedName = prefs.getString("signature_name_$currentId");
      _nameController.text = savedName ?? 'signature_$currentId';
    } else {
      _nameController.text = '';
    }
  }

  Future<void> _saveSignature() async {
    if (_controller.isEmpty) return;

    final data = await _controller.toPngBytes();
    if (data == null) return;

    final prefs = await SharedPreferences.getInstance();

    if (currentId != null) {
      await prefs.setString("signature_$currentId", base64Encode(data));
    } else {
      signatureCounter++;
      final id = signatureCounter;

      await prefs.setString("signature_$id", base64Encode(data));
      await prefs.setInt("signature_counter", signatureCounter);

      currentId = id;
    }

    GlobalStreamController.notify();
    Navigator.pop(context, true);
  }

  

  Future<void> deleteSignature(int id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("signature_$id");

    GlobalStreamController.notify();
  }

  void _applyPenSettings() {
    try {
      _controller.dispose();
    } catch (_) {}
    _controller = SignatureController(
      penStrokeWidth: _penStroke,
      penColor: _penColor,
      exportBackgroundColor: Colors.transparent,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) => setState(() {}),
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: 16,
                left: 0,
                right: 0,
                child: CustomAppBar(
                  titleWidget: Text(
                    "REORDER PAGES",
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
                      _saveSignature();
                    },
                  ),
                ),
              ),
              Positioned(
                top: 100,
                left: 20,
                right: 20,
                bottom: 120,
                child: Center(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(16),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: _savedSignature != null
                          ? Image.memory(_savedSignature!, fit: BoxFit.contain)
                          : IgnorePointer(
                              ignoring: _activeTool != ToolType.draw,
                              child: Signature(
                                controller: _controller,
                                backgroundColor: Colors.transparent,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 20,
                left: 16,
                right: 16,
                child: SignButtons(
                  activeIndex: selected,

                  icons: [
                    'assets/images/icons/draw.svg',
                    'assets/images/icons/tolsh.svg',
                    'assets/images/icons/color.svg',
                    'assets/images/icons/earse.svg',
                  ],
                  labels: ['Draw', 'Thickness', 'Palette', 'Clear'],
                  onTap: (index) {
                    setState(() => selected = index);

                    switch (index) {
                      case 0:
                        setState(() => _activeTool = ToolType.draw);
                        break;

                      case 1:
                        setState(() => _activeTool = ToolType.size);
                        _openStrokePicker();
                        break;

                      case 2:
                        setState(() => _activeTool = ToolType.color);
                        Platform.isIOS
                            ? iosColorPickerController.showNativeIosColorPicker(
                                darkMode: true,
                                onColorChanged: (color) {
                                  setState(() {
                                    _penColor = color;
                                    _applyPenSettings();
                                  });
                                },
                              )
                            : iosColorPickerController.showIOSCustomColorPicker(
                                context: context,
                                onColorChanged: (color) {
                                  setState(() {
                                    _penColor = color;
                                    _applyPenSettings();
                                  });
                                },
                              );
                        break;

                      case 3:
                        setState(() => _activeTool = ToolType.erase);
                        _controller.clear();
                        break;
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openStrokePicker() async {
    final result = await showModalBottomSheet<double>(
      context: context,
      backgroundColor: Color(0xFF0A0A0A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _StrokePickerSheet(currentWidth: _penStroke),
    );

    if (result != null) {
      setState(() {
        _penStroke = result;
        _applyPenSettings();
      });
    }
  }
}

class _StrokePickerSheet extends StatefulWidget {
  final double currentWidth;

  const _StrokePickerSheet({required this.currentWidth});

  @override
  State<_StrokePickerSheet> createState() => _StrokePickerSheetState();
}

class _StrokePickerSheetState extends State<_StrokePickerSheet> {
  late double _value;

  final Color accent = const Color(0xFF3093FF);

  @override
  void initState() {
    super.initState();
    _value = widget.currentWidth;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(22),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Stroke thickness",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 24),

          Container(
            height: 50,
            alignment: Alignment.center,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 200,
              height: _value,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),

          const SizedBox(height: 24),

          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 6,
              activeTrackColor: accent,
              inactiveTrackColor: Colors.grey.shade300,

              thumbShape: _SquareThumbShape(),
              thumbColor: accent,

              overlayColor: accent.withOpacity(0.2),
              overlayShape: SliderComponentShape.noOverlay,
            ),
            child: Slider(
              value: _value,
              min: 1,
              max: 20,
              divisions: 19,
              onChanged: (v) => setState(() => _value = v),
            ),
          ),

          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context, _value),
              style: ElevatedButton.styleFrom(
                backgroundColor: accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                "Apply",
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
              ),
            ),
          ),

          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

class _SquareThumbShape extends SliderComponentShape {
  static const double _size = 18;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) =>
      const Size(_size, _size);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final paint = Paint()
      ..color = sliderTheme.thumbColor!
      ..style = PaintingStyle.fill;

    final rect = Rect.fromCenter(center: center, width: _size, height: _size);

    context.canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(4)),
      paint,
    );
  }
}
