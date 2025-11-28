import 'dart:io';

import 'package:camera/camera.dart';
import 'package:fast_pdf/core/services/files_history.dart';
import 'package:fast_pdf/core/services/notifier.dart';
import 'package:fast_pdf/core/widgets/button_widget.dart';
import 'package:fast_pdf/features/files/blocs/pdf_editor/pdf_editor_bloc.dart';
import 'package:fast_pdf/features/files/widgets/edit_pdf_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:share_plus/share_plus.dart';
import 'package:toastification/toastification.dart';

class FileCardWidget extends StatefulWidget {
  final String path;

  const FileCardWidget({super.key, required this.path});

  @override
  State<FileCardWidget> createState() => _FileCardWidgetState();
}

class _FileCardWidgetState extends State<FileCardWidget> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,

      onTap: () {
        if (expanded) {
          setState(() => expanded = false);
        }
      },

      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,

        height: expanded ? 230 : 80,
        width: double.infinity,

        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: Color(0xFF1A1A1A),
        ),

        child: expanded ? _buildExpanded() : _buildCollapsed(),
      ),
    );
  }

  Widget _buildCollapsed() {
    final fileName = widget.path.split('/').last;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          Container(
            width: 39,
            height: 53,
            decoration: BoxDecoration(color: Colors.white),
            child: const Icon(
              Icons.picture_as_pdf,
              size: 26,
              color: Color(0xff929292),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  fileName,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),

          ButtonWidget(
            asset: 'assets/images/icons/options.svg',
            onTap: () => setState(() {
              expanded = true;
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildExpanded() {
    return Row(
      children: [
        Container(
          width: 130,
          height: double.infinity,
          decoration: BoxDecoration(color: Colors.white),
          child: const Icon(Icons.picture_as_pdf, size: 60),
        ),

        const SizedBox(width: 16),

        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: _actionButton(
                    'assets/images/icons/save.svg',
                    "Save",
                    onTap: () {
                      toastification.show(
                        context: context,
                        type: ToastificationType.success,
                        title: Text('File saved to your files.'),
                        autoCloseDuration: const Duration(seconds: 5),
                      );
                    },
                  ),
                ),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: _actionButton(
                    'assets/images/icons/share.svg',
                    "Share",
                    onTap: () async {
                      try {
                        final file = XFile(widget.path);
                        await Share.shareXFiles([
                          file,
                        ], text: 'Check out this PDF file!');
                      } catch (e) {
                        toastification.show(
                          type: ToastificationType.error,
                          context: context,
                          title: Text('Ошибка при шаринге: $e'),
                          autoCloseDuration: const Duration(seconds: 5),
                        );
                      }
                    },
                  ),
                ),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: _actionButton(
                    'assets/images/icons/edit.svg',
                    "Edit",
                    onTap: () {
                      context.read<PdfEditorBloc>().add(
                        LoadPdfFromPathEvent(widget.path),
                      );
                      Navigator.of(context).push(
                        CupertinoPageRoute(builder: (_) => EditPdfScreen()),
                      );
                    },
                  ),
                ),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: _actionButton(
                    'assets/images/icons/delete.svg',
                    "Delete",

                    onTap: () => _confirmDelete(context),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _confirmDelete(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoTheme(
        data: const CupertinoThemeData(
          brightness: Brightness.dark,
          primaryColor: CupertinoColors.destructiveRed,
          barBackgroundColor: Color(0xFF1C1C1E),
          scaffoldBackgroundColor: Color(0xFF1C1C1E),
          textTheme: CupertinoTextThemeData(
            primaryColor: CupertinoColors.white,
          ),
        ),
        child: CupertinoAlertDialog(
          title: Text("Delete file?", style: TextStyle(color: Colors.white)),
          content: Text(
            "This action cannot be undone.",
            style: TextStyle(color: CupertinoColors.white),
          ),
          actions: [
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () async {
                Navigator.of(context).pop();
                await _deleteFile();
              },
              child: Text(
                "Delete",
                style: TextStyle(color: CupertinoColors.destructiveRed),
              ),
            ),
            CupertinoDialogAction(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                "Cancel",
                style: TextStyle(color: CupertinoColors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteFile() async {
    try {
      final file = File(widget.path);

      if (await file.exists()) {
        await file.delete();
      }

      await RecentFilesService.remove(widget.path);

      GlobalStreamController.notify();

      if (mounted) {
        toastification.show(
          type: ToastificationType.success,
          context: context,
          title: Text('Файл удален.'),
          autoCloseDuration: const Duration(seconds: 5),
        );
      }
    } catch (e) {
      if (mounted) {
        toastification.show(
          type: ToastificationType.error,
          context: context,
          title: Text('Ошибка удаления $e.'),
          autoCloseDuration: const Duration(seconds: 5),
        );
      }
    }
  }

  Widget _actionButton(String path, String label, {VoidCallback? onTap}) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Color(0xFF3D3D3D)),
        ),
        child: Row(
          children: [
            SvgPicture.asset(path),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
