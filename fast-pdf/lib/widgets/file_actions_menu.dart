import 'package:flutter/material.dart';

class FileActionsMenu extends StatelessWidget {
  final VoidCallback onSave;
  final VoidCallback onShare;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onClose;
  
  const FileActionsMenu({
    super.key,
    required this.onSave,
    required this.onShare,
    required this.onEdit,
    required this.onDelete,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black54,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF2C2C2E),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                _buildMenuItem(
                  icon: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  text: 'Save',
                  onTap: onSave,
                  showDivider: true,
                ),
                _buildMenuItem(
                  icon: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  text: 'Share',
                  onTap: onShare,
                  showDivider: true,
                ),
                _buildMenuItem(
                  icon: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  text: 'Edit',
                  onTap: onEdit,
                  showDivider: true,
                ),
                _buildMenuItem(
                  icon: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  text: 'Delete',
                  onTap: onDelete,
                  isDestructive: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required Widget icon,
    required String text,
    required VoidCallback onTap,
    bool showDivider = false,
    bool isDestructive = false,
  }) {
    return Column(
      children: [
        Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(0),
              onTap: onTap,
              child: Row(
                children: [
                  icon,
                  const SizedBox(width: 12),
                  Text(
                    text,
                    style: TextStyle(
                      color: isDestructive ? Colors.red : Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (showDivider)
          Container(
            height: 0.5,
            margin: const EdgeInsets.only(left: 48),
            color: Colors.grey[700],
          ),
      ],
    );
  }
}