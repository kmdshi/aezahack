import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ios_color_picker/show_ios_color_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signature/signature.dart';

class NewSignatureScreen extends StatefulWidget {
  final Uint8List? savedSignature;
  const NewSignatureScreen({super.key, this.savedSignature});

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
  TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _savedSignature = widget.savedSignature;

    _controller = SignatureController(
      penColor: _penColor,
      penStrokeWidth: _penStroke,
    );
    _loadCounter();
  }

  Future<void> _loadCounter() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      signatureCounter = prefs.getInt("signature_counter") ?? 0;

      String? savedName = prefs.getString("signature_name_$signatureCounter");
      _nameController.text = savedName ?? '';
    });
  }

  Future<void> _saveSignature() async {
    if (_controller.isEmpty) return;

    final data = await _controller.toPngBytes();
    if (data == null) return;

    final prefs = await SharedPreferences.getInstance();

    signatureCounter++;

    await prefs.setString("signature_$signatureCounter", base64Encode(data));

    await prefs.setInt("signature_counter", signatureCounter);

    String fileName = _nameController.text.trim();
    await prefs.setString("signature_name_$signatureCounter", fileName);

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) => setState(() {}),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F6FA),

        body: SafeArea(
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
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(
                            CupertinoIcons.xmark,
                            size: 24,
                            color: Color(0xFF383838),
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),

                      Spacer(),

                      Expanded(
                        child: TextField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            hintText: 'Enter signature name',
                            border: InputBorder.none,
                            hintStyle: TextStyle(color: Color(0xFF383838)),
                          ),
                          style: TextStyle(
                            fontSize: 32,
                            color: Color(0xFF383838),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Spacer(),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(
                            CupertinoIcons.check_mark,
                            size: 24,
                            color: Color(0xFF383838),
                          ),
                          onPressed: _saveSignature,
                        ),
                      ),

                      const SizedBox(width: 12),
                    ],
                  ),
                ),
              ),

              Positioned(
                top: 80,
                left: 0,
                right: 0,
                bottom: 0,
                child: _savedSignature != null
                    ? Transform.scale(
                        scale: 0.7,
                        child: Image.memory(
                          _savedSignature!,
                          fit: BoxFit.contain,
                        ),
                      )
                    : Signature(
                        controller: _controller,
                        backgroundColor: Colors.transparent,
                      ),
              ),

              Positioned(
                bottom: 20,
                left: 16,
                right: 16,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildIconButton('assets/images/icons/color.svg', () {
                      iosColorPickerController.showIOSCustomColorPicker(
                        onColorChanged: (value) {
                          setState(() => _penColor = value);
                          _createController();
                        },
                        context: context,
                      );
                    }),

                    _buildIconButton('assets/images/icons/stroke.svg', () {
                      _openStrokePicker();
                    }),
                  ],
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
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _StrokePickerSheet(currentWidth: _penStroke),
    );

    if (result != null) {
      setState(() {
        _penStroke = result;
        _createController();
      });
    }
  }

  ButtonStyle _btn({Color bg = const Color(0xFFDDDDDD)}) {
    return ElevatedButton.styleFrom(
      backgroundColor: bg,
      foregroundColor: Colors.black,
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  void _createController() {
    try {
      _controller.dispose();
    } catch (_) {}
    _controller = SignatureController(
      penStrokeWidth: _penStroke,
      penColor: _penColor,
      exportBackgroundColor: Colors.white,
    );
  }
}

Widget _buildIconButton(String iconPath, VoidCallback onPressed) {
  return Container(
    width: 62,
    height: 62,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
    ),
    child: InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: SvgPicture.asset(
          iconPath,
          width: 42,
          height: 42,
          fit: BoxFit.contain,
        ),
      ),
    ),
  );
}

class _StrokePickerSheet extends StatefulWidget {
  final double currentWidth;

  const _StrokePickerSheet({required this.currentWidth});

  @override
  State<_StrokePickerSheet> createState() => _StrokePickerSheetState();
}

class _StrokePickerSheetState extends State<_StrokePickerSheet> {
  late double _value;

  @override
  void initState() {
    super.initState();
    _value = widget.currentWidth;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Stroke thickness",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),

          const SizedBox(height: 20),

          Container(
            height: 40,
            alignment: Alignment.center,
            child: Container(
              width: 180,
              height: _value,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(50),
              ),
            ),
          ),

          const SizedBox(height: 20),

          Slider(
            value: _value,
            min: 1,
            max: 20,
            divisions: 19,
            label: _value.toStringAsFixed(0),
            onChanged: (v) => setState(() => _value = v),
          ),

          const SizedBox(height: 10),

          ElevatedButton(
            onPressed: () => Navigator.pop(context, _value),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text("Apply"),
          ),

          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
