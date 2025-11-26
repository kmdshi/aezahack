import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ios_color_picker/show_ios_color_picker.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import 'package:pdf_app/core/services/notifier.dart';
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

  Future<void> _confirmAndDeleteSignature() async {
    if (currentId == null) return;

    final should = await showCupertinoDialog<bool>(
      context: context,
      builder: (c) => CupertinoAlertDialog(
        title: const Text('Delete signature?'),
        content: const Text('Are you sure you want to delete this signature?'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (should == true) {
      await deleteSignature(currentId!);
      Navigator.pop(context, true);
    }
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
                      const Spacer(),
                      Expanded(
                        child: TextField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            hintText: 'Enter signature name',
                            border: InputBorder.none,
                          ),
                          style: const TextStyle(
                            fontSize: 32,
                            color: Color(0xFF383838),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: Icon(
                            _savedSignature == null
                                ? CupertinoIcons.check_mark
                                : CupertinoIcons.delete,
                            size: 24,
                            color: _savedSignature == null
                                ? const Color(0xFF383838)
                                : Colors.red,
                          ),
                          onPressed: _savedSignature == null
                              ? _saveSignature
                              : _confirmAndDeleteSignature,
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
                    : IgnorePointer(
                        ignoring: _activeTool != ToolType.draw,
                        child: Signature(
                          controller: _controller,
                          backgroundColor: Colors.transparent,
                        ),
                      ),
              ),
              Positioned(
                bottom: 20,
                left: 16,
                right: 16,
                child: Row(
                  children: [
                    _buildIconButton(
                      _activeTool == ToolType.draw,
                      'assets/images/icons/draw.svg',
                      () {
                        setState(() => _activeTool = ToolType.draw);
                      },
                    ),
                    const SizedBox(width: 10),
                    _buildIconButton(
                      _activeTool == ToolType.size,
                      'assets/images/icons/line_i.svg',
                      () {
                        setState(() {
                          _activeTool = ToolType.size;
                        });
                        _openStrokePicker();
                      },
                    ),
                    const SizedBox(width: 10),
                    _buildIconButton(
                      _activeTool == ToolType.color,
                      'assets/images/icons/color_i.svg',
                      () {
                        setState(() {
                          _activeTool = ToolType.color;
                        });
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
                                onColorChanged: (color) {
                                  setState(() {
                                    _penColor = color;
                                    _applyPenSettings();
                                  });
                                },
                                context: context,
                              );
                      },
                    ),
                    const SizedBox(width: 10),
                    _buildIconButton(
                      _activeTool == ToolType.erase,
                      'assets/images/icons/erse_i.svg',
                      () {
                        setState(() {
                          _activeTool = ToolType.erase;
                        });
                        // лучше показывать подтверждение очистки, чем очищать сразу:
                        showDialog<bool>(
                          context: context,
                          builder: (c) => AlertDialog(
                            title: const Text('Clear drawing?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(c, false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  _controller.clear();
                                  Navigator.pop(c, true);
                                },
                                child: const Text(
                                  'Clear',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
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
        _applyPenSettings();
      });
    }
  }
}

Widget _buildIconButton(
  bool isActive,
  String iconPath,
  VoidCallback onPressed,
) {
  return isActive
      ? Container(
          width: 62,
          height: 62,
          decoration: BoxDecoration(
            color: const Color(0xFF55A4FF),
            borderRadius: BorderRadius.circular(100),
          ),
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(100),
            child: Center(
              child: SvgPicture.asset(
                iconPath,
                width: 24,
                height: 24,
                fit: BoxFit.contain,
                color: Colors.white,
              ),
            ),
          ),
        )
      : LiquidGlassLayer(
          settings: LiquidGlassSettings(glassColor: Colors.white),
          child: LiquidGlass(
            shape: LiquidRoundedSuperellipse(borderRadius: 100),
            child: Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
              ),
              child: InkWell(
                onTap: onPressed,
                borderRadius: BorderRadius.circular(100),
                child: Center(
                  child: SvgPicture.asset(
                    iconPath,
                    width: 24,
                    height: 24,
                    fit: BoxFit.contain,
                    color: const Color(0xFF5D5D5D),
                  ),
                ),
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
