import 'dart:io';

import 'package:fast_pdf/core/services/files_history.dart';
import 'package:fast_pdf/core/services/notifier.dart';
import 'package:fast_pdf/core/theme/cupertino_dropbox_theme.dart';
import 'package:fast_pdf/core/widgets/cupertino_dropbox_widgets.dart';
import 'package:fast_pdf/features/files/blocs/pdf_editor/pdf_editor_bloc.dart';
import 'package:fast_pdf/features/files/widgets/edit_pdf_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:toastification/toastification.dart';

class FileCardWidget extends StatefulWidget {
  final String path;

  const FileCardWidget({super.key, required this.path});

  @override
  State<FileCardWidget> createState() => _FileCardWidgetState();
}

class _FileCardWidgetState extends State<FileCardWidget> with TickerProviderStateMixin {
  bool expanded = false;
  
  late AnimationController _expandController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    
    _expandController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _expandAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _expandController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _expandController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        if (expanded) {
          setState(() => expanded = false);
          _expandController.reverse();
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        child: CupertinoDropboxCard(
          padding: EdgeInsets.zero,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: expanded ? 320 : 80,
            child: expanded ? _buildExpanded() : _buildCollapsed(),
          ),
        ),
      ),
    );
  }

  Widget _buildCollapsed() {
    final fileName = widget.path.split('/').last;

    return Padding(
      padding: const EdgeInsets.all(CupertinoDropboxTheme.spacing16),
      child: Row(
        children: [
          // File icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: CupertinoDropboxTheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              CupertinoIcons.doc_text_fill,
              size: 24,
              color: CupertinoDropboxTheme.primary,
            ),
          ),

          const SizedBox(width: CupertinoDropboxTheme.spacing12),

          // File info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  fileName,
                  style: CupertinoDropboxTheme.calloutStyle.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: CupertinoDropboxTheme.spacing2),
                Row(
                  children: [
                    const Icon(
                      CupertinoIcons.doc,
                      size: 14,
                      color: CupertinoDropboxTheme.textSecondary,
                    ),
                    const SizedBox(width: CupertinoDropboxTheme.spacing4),
                    Text(
                      "PDF Document",
                      style: CupertinoDropboxTheme.footnoteStyle,
                    ),
                    const SizedBox(width: CupertinoDropboxTheme.spacing8),
                    Container(
                      width: 3,
                      height: 3,
                      decoration: const BoxDecoration(
                        color: CupertinoDropboxTheme.textSecondary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: CupertinoDropboxTheme.spacing8),
                    Text(
                      _getFileSize(),
                      style: CupertinoDropboxTheme.footnoteStyle,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Expand button
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () {
              setState(() => expanded = true);
              _expandController.forward();
            },
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: CupertinoDropboxTheme.gray100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                CupertinoIcons.ellipsis,
                color: CupertinoDropboxTheme.textSecondary,
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpanded() {
    final fileName = widget.path.split('/').last;

    return Column(
      children: [
        // Header section
        Container(
          padding: const EdgeInsets.all(CupertinoDropboxTheme.spacing16),
          child: Row(
            children: [
              // Enhanced file icon
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: CupertinoDropboxTheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  CupertinoIcons.doc_text_fill,
                  size: 28,
                  color: CupertinoDropboxTheme.primary,
                ),
              ),

              const SizedBox(width: CupertinoDropboxTheme.spacing16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fileName,
                      style: CupertinoDropboxTheme.headlineStyle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: CupertinoDropboxTheme.spacing4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: CupertinoDropboxTheme.spacing8,
                            vertical: CupertinoDropboxTheme.spacing4,
                          ),
                          decoration: BoxDecoration(
                            color: CupertinoDropboxTheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            "PDF",
                            style: CupertinoDropboxTheme.caption2Style.copyWith(
                              color: CupertinoDropboxTheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: CupertinoDropboxTheme.spacing8),
                        Text(
                          "${_getFileSize()} • Modified ${_getModifiedDate()}",
                          style: CupertinoDropboxTheme.footnoteStyle,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Divider
        const Divider(height: 1),

        // Action buttons
        Expanded(
          child: FadeTransition(
            opacity: _expandAnimation,
            child: ListView(
              padding: const EdgeInsets.symmetric(
                vertical: CupertinoDropboxTheme.spacing8,
              ),
              children: [
                _buildActionTile(
                  icon: CupertinoIcons.square_arrow_down,
                  title: "Save to Files",
                  color: CupertinoDropboxTheme.primary,
                  onTap: () {
                    toastification.show(
                      context: context,
                      type: ToastificationType.success,
                      title: const Text('File saved to your files.'),
                      autoCloseDuration: const Duration(seconds: 3),
                    );
                  },
                ),
                _buildActionTile(
                  icon: CupertinoIcons.share,
                  title: "Share Document",
                  color: CupertinoDropboxTheme.success,
                  onTap: () {},
                ),
                _buildActionTile(
                  icon: CupertinoIcons.pencil,
                  title: "Edit PDF",
                  color: CupertinoDropboxTheme.warning,
                  onTap: () {
                    context.read<PdfEditorBloc>().add(
                      LoadPdfFromPathEvent(widget.path),
                    );
                    Navigator.of(context).push(
                      CupertinoPageRoute(builder: (_) => const EditPdfScreen()),
                    );
                  },
                ),
                _buildActionTile(
                  icon: CupertinoIcons.delete,
                  title: "Delete File",
                  color: CupertinoDropboxTheme.error,
                  onTap: () => _confirmDelete(context),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return CupertinoDropboxListTile(
      leading: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: color,
          size: 18,
        ),
      ),
      title: Text(
        title,
        style: CupertinoDropboxTheme.calloutStyle,
      ),
      onTap: onTap,
      showChevron: true,
    );
  }

  String _getFileSize() {
    try {
      final file = File(widget.path);
      if (file.existsSync()) {
        final bytes = file.lengthSync();
        if (bytes < 1024) return '${bytes}B';
        if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
        return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
      }
    } catch (e) {
      // Fallback
    }
    return "Unknown size";
  }

  String _getModifiedDate() {
    try {
      final file = File(widget.path);
      if (file.existsSync()) {
        final modified = file.lastModifiedSync();
        final now = DateTime.now();
        final difference = now.difference(modified);
        
        if (difference.inDays == 0) {
          if (difference.inHours == 0) {
            return '${difference.inMinutes}m ago';
          }
          return '${difference.inHours}h ago';
        }
        if (difference.inDays < 7) {
          return '${difference.inDays}d ago';
        }
        return '${modified.day}/${modified.month}/${modified.year}';
      }
    } catch (e) {
      // Fallback
    }
    return "today";
  }

  void _confirmDelete(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text("Delete file?"),
        content: const Text("This action cannot be undone."),
        actions: [
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () async {
              Navigator.of(context).pop();
              await _deleteFile();
            },
            child: const Text("Delete"),
          ),
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel"),
          ),
        ],
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
          title: const Text('File deleted successfully.'),
          autoCloseDuration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      if (mounted) {
        toastification.show(
          type: ToastificationType.error,
          context: context,
          title: Text('Error deleting file: $e'),
          autoCloseDuration: const Duration(seconds: 5),
        );
      }
    }
  }
}