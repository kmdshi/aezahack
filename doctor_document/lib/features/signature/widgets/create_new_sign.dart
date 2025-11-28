import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:fast_pdf/core/theme/cupertino_dropbox_theme.dart';
import 'package:fast_pdf/core/widgets/appbar.dart';
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
    _nameController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadCounterAndName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      signatureCounter = prefs.getInt('signatureCounter') ?? 0;
      _nameController.text = 'Signature ${signatureCounter + 1}';
    });
  }

  Future<void> _saveSignature() async {
    try {
      Uint8List? signature = _savedSignature;

      signature ??= await _controller.toPngBytes();

      if (signature == null || signature.isEmpty) return;

      final prefs = await SharedPreferences.getInstance();
      final signatures = prefs.getStringList('signatures') ?? [];
      final names = prefs.getStringList('signatureNames') ?? [];

      if (currentId != null) {
        signatures[currentId!] = base64Encode(signature);
        names[currentId!] = _nameController.text;
      } else {
        signatures.add(base64Encode(signature));
        names.add(_nameController.text);
        signatureCounter++;
        await prefs.setInt('signatureCounter', signatureCounter);
      }

      await prefs.setStringList('signatures', signatures);
      await prefs.setStringList('signatureNames', names);

      GlobalStreamController.notify();
      Navigator.pop(context);
    } catch (e) {
      print('Error saving signature: $e');
    }
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
        backgroundColor: CupertinoDropboxTheme.background,
        appBar: CustomAppBar.dropboxAppBar(
          title: "Create Signature",
          onBack: () => Navigator.pop(context),
          actions: [
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: _saveSignature,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: CupertinoDropboxTheme.spacing12,
                  vertical: CupertinoDropboxTheme.spacing6,
                ),
                decoration: BoxDecoration(
                  color: CupertinoDropboxTheme.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "Save",
                  style: CupertinoDropboxTheme.footnoteStyle.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: CupertinoDropboxTheme.spacing16),
          ],
        ),
        body: Column(
          children: [
            // Title and description
            Padding(
              padding: const EdgeInsets.all(CupertinoDropboxTheme.spacing16),
              child: Column(
                children: [
                  Text(
                    "Draw Your Signature",
                    style: CupertinoDropboxTheme.title3Style,
                  ),
                  const SizedBox(height: CupertinoDropboxTheme.spacing8),
                  Text(
                    "Use your finger to draw your signature in the area below",
                    style: CupertinoDropboxTheme.calloutStyle.copyWith(
                      color: CupertinoDropboxTheme.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Signature canvas
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(CupertinoDropboxTheme.spacing16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: CupertinoDropboxTheme.elevatedCardShadow,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
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

            // Tool panel
            Container(
              padding: const EdgeInsets.all(CupertinoDropboxTheme.spacing16),
              decoration: BoxDecoration(
                color: CupertinoDropboxTheme.background,
                border: Border(
                  top: BorderSide(
                    color: CupertinoDropboxTheme.divider,
                    width: 0.5,
                  ),
                ),
              ),
              child: Column(
                children: [
                  // Current pen settings
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: _penColor,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: CupertinoDropboxTheme.gray300,
                          ),
                        ),
                      ),
                      const SizedBox(width: CupertinoDropboxTheme.spacing8),
                      Text(
                        "Stroke: ${_penStroke.toStringAsFixed(1)}pt",
                        style: CupertinoDropboxTheme.footnoteStyle,
                      ),
                    ],
                  ),

                  const SizedBox(height: CupertinoDropboxTheme.spacing12),

                  // Tool buttons
                  SignButtons(
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
                              ? iosColorPickerController
                                    .showNativeIosColorPicker(
                                      darkMode: false,
                                      onColorChanged: (color) {
                                        setState(() {
                                          _penColor = color;
                                          _applyPenSettings();
                                        });
                                      },
                                    )
                              : iosColorPickerController
                                    .showIOSCustomColorPicker(
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openStrokePicker() async {
    final result = await showCupertinoModalPopup<double>(
      context: context,
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

  @override
  void initState() {
    super.initState();
    _value = widget.currentWidth;
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoActionSheet(
      title: Text(
        "Select Stroke Width",
        style: CupertinoDropboxTheme.headlineStyle,
      ),
      message: Container(
        height: 150,
        padding: const EdgeInsets.all(CupertinoDropboxTheme.spacing16),
        child: Column(
          children: [
            // Preview stroke
            Container(
              height: 40,
              width: double.infinity,
              decoration: BoxDecoration(
                color: CupertinoDropboxTheme.gray100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Container(
                  height: _value,
                  width: 100,
                  decoration: BoxDecoration(
                    color: CupertinoDropboxTheme.textPrimary,
                    borderRadius: BorderRadius.circular(_value / 2),
                  ),
                ),
              ),
            ),

            const SizedBox(height: CupertinoDropboxTheme.spacing16),

            // Slider
            CupertinoSlider(
              value: _value,
              min: 1.0,
              max: 10.0,
              divisions: 90,
              activeColor: CupertinoDropboxTheme.primary,
              onChanged: (value) => setState(() => _value = value),
            ),

            Text(
              "${_value.toStringAsFixed(1)} pt",
              style: CupertinoDropboxTheme.footnoteStyle,
            ),
          ],
        ),
      ),
      actions: [
        CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context, _value),
          child: Text(
            'Select',
            style: CupertinoDropboxTheme.bodyStyle.copyWith(
              color: CupertinoDropboxTheme.primary,
            ),
          ),
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        isDefaultAction: true,
        onPressed: () => Navigator.pop(context),
        child: Text('Cancel', style: CupertinoDropboxTheme.bodyStyle),
      ),
    );
  }
}
