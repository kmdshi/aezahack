import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fast_pdf/core/theme/cupertino_dropbox_theme.dart';

class ButtonSetWidget extends StatelessWidget {
  final List<String> icons;
  final List<String> labels;
  final Function(int) onTap;

  const ButtonSetWidget({
    super.key,
    required this.icons,
    required this.labels,
    required this.onTap,
  }) : assert(icons.length == labels.length, "Icons and labels must match");

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          icons.length,
          (i) => Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: CupertinoDropboxTheme.spacing8,
            ),
            child: _ToolButton(
              icon: icons[i],
              label: labels[i],
              onTap: () => onTap(i),
            ),
          ),
        ),
      ),
    );
  }
}

class _ToolButton extends StatefulWidget {
  final String icon;
  final String label;
  final VoidCallback onTap;

  const _ToolButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  State<_ToolButton> createState() => _ToolButtonState();
}

class _ToolButtonState extends State<_ToolButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 48,
        width: 120,
        decoration: BoxDecoration(
          color: _isPressed
              ? CupertinoDropboxTheme.gray100
              : CupertinoDropboxTheme.background,
          borderRadius: CupertinoDropboxTheme.buttonRadius,
          border: Border.all(color: CupertinoDropboxTheme.cardBorder, width: 1),
          boxShadow: _isPressed
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon with proper size and color
            SizedBox(
              width: 18,
              height: 18,
              child: SvgPicture.asset(
                widget.icon,
                colorFilter: const ColorFilter.mode(
                  CupertinoDropboxTheme.textSecondary,
                  BlendMode.srcIn,
                ),
              ),
            ),
            const SizedBox(width: CupertinoDropboxTheme.spacing8),
            Text(
              widget.label,
              style: CupertinoDropboxTheme.footnoteStyle.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
