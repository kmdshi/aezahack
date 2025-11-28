import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fast_pdf/core/theme/cupertino_dropbox_theme.dart';
import 'package:fast_pdf/core/widgets/cupertino_dropbox_widgets.dart';

class CupertinoFileCard extends StatelessWidget {
  final String path;
  final VoidCallback? onTap;

  const CupertinoFileCard({super.key, required this.path, this.onTap});

  @override
  Widget build(BuildContext context) {
    final file = File(path);
    final fileName = file.path.split('/').last;
    String fileSize = '—';
    String modifiedDate = '—';

    if (file.existsSync()) {
      fileSize = _formatFileSize(file.lengthSync());
      modifiedDate = _formatDate(file.lastModifiedSync());
    }

    return CupertinoDropboxCard(
      onTap: onTap,
      padding: const EdgeInsets.all(CupertinoDropboxTheme.spacing16),
      child: Row(
        children: [
          // File icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: CupertinoDropboxTheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              CupertinoIcons.doc_text_fill,
              color: CupertinoDropboxTheme.primary,
              size: 24,
            ),
          ),

          const SizedBox(width: CupertinoDropboxTheme.spacing12),

          // File details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fileName,
                  style: CupertinoDropboxTheme.headlineStyle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: CupertinoDropboxTheme.spacing2),
                Row(
                  children: [
                    Text(fileSize, style: CupertinoDropboxTheme.footnoteStyle),
                    Text(' • ', style: CupertinoDropboxTheme.footnoteStyle),
                    Text(
                      modifiedDate,
                      style: CupertinoDropboxTheme.footnoteStyle,
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: CupertinoDropboxTheme.spacing12),

          // Chevron
          const Icon(
            CupertinoIcons.chevron_right,
            color: CupertinoDropboxTheme.textTertiary,
            size: 16,
          ),
        ],
      ),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    }
    if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    }
    return '${date.day}/${date.month}/${date.year}';
  }
}

class DropboxActionSheet extends StatelessWidget {
  final List<ActionSheetItem> actions;

  const DropboxActionSheet({super.key, required this.actions});

  static Future<void> show(
    BuildContext context,
    List<ActionSheetItem> actions,
  ) {
    return showCupertinoModalPopup(
      context: context,
      builder: (context) => DropboxActionSheet(actions: actions),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoActionSheet(
      actions: actions
          .map(
            (action) => CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
                action.onPressed();
              },
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: action.color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(action.icon, size: 18, color: action.color),
                  ),
                  const SizedBox(width: CupertinoDropboxTheme.spacing12),
                  Text(
                    action.title,
                    style: CupertinoDropboxTheme.bodyStyle.copyWith(
                      color: CupertinoDropboxTheme.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
      cancelButton: CupertinoActionSheetAction(
        isDefaultAction: true,
        onPressed: () => Navigator.pop(context),
        child: Text(
          'Cancel',
          style: CupertinoDropboxTheme.bodyStyle.copyWith(
            color: CupertinoDropboxTheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class ActionSheetItem {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const ActionSheetItem({
    required this.title,
    required this.icon,
    required this.color,
    required this.onPressed,
  });
}
