import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fast_pdf/core/theme/cupertino_dropbox_theme.dart';

class CupertinoDropboxCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final bool isPressed;
  final Color? backgroundColor;
  final List<BoxShadow>? shadows;
  final BorderRadius? borderRadius;
  final Border? border;

  const CupertinoDropboxCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.isPressed = false,
    this.backgroundColor,
    this.shadows,
    this.borderRadius,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final decoration = CupertinoDropboxTheme.cardDecoration(
      backgroundColor: backgroundColor,
      shadows: isPressed 
        ? [] 
        : (shadows ?? CupertinoDropboxTheme.cardShadow),
      borderRadius: borderRadius,
      border: border,
    );

    Widget cardContent = AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,
      padding: padding ?? const EdgeInsets.all(CupertinoDropboxTheme.spacing16),
      margin: margin,
      transform: Matrix4.identity()
        ..scale(isPressed ? 0.98 : 1.0),
      decoration: decoration,
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: cardContent,
      );
    }

    return cardContent;
  }
}

class CupertinoDropboxButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final bool isPrimary;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final double? minHeight;

  const CupertinoDropboxButton({
    super.key,
    required this.child,
    this.onPressed,
    this.isPrimary = true,
    this.padding,
    this.margin,
    this.borderRadius,
    this.minHeight,
  });

  @override
  State<CupertinoDropboxButton> createState() => _CupertinoDropboxButtonState();
}

class _CupertinoDropboxButtonState extends State<CupertinoDropboxButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        padding: widget.padding ?? const EdgeInsets.symmetric(
          horizontal: CupertinoDropboxTheme.spacing24,
          vertical: CupertinoDropboxTheme.spacing12,
        ),
        margin: widget.margin,
        constraints: BoxConstraints(
          minHeight: widget.minHeight ?? 44,
        ),
        decoration: widget.isPrimary
          ? CupertinoDropboxTheme.primaryButtonDecoration(isPressed: _isPressed)
          : CupertinoDropboxTheme.secondaryButtonDecoration(isPressed: _isPressed),
        child: Center(child: widget.child),
      ),
    );
  }
}

class CupertinoDropboxListTile extends StatefulWidget {
  final Widget? leading;
  final Widget title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final bool showChevron;

  const CupertinoDropboxListTile({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.padding,
    this.showChevron = false,
  });

  @override
  State<CupertinoDropboxListTile> createState() => _CupertinoDropboxListTileState();
}

class _CupertinoDropboxListTileState extends State<CupertinoDropboxListTile> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onTap != null ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: widget.onTap != null ? (_) => setState(() => _isPressed = false) : null,
      onTapCancel: widget.onTap != null ? () => setState(() => _isPressed = false) : null,
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: widget.padding ?? const EdgeInsets.symmetric(
          horizontal: CupertinoDropboxTheme.spacing16,
          vertical: CupertinoDropboxTheme.spacing12,
        ),
        color: _isPressed 
          ? CupertinoDropboxTheme.gray50
          : CupertinoDropboxTheme.background,
        child: Row(
          children: [
            if (widget.leading != null) ...[
              widget.leading!,
              const SizedBox(width: CupertinoDropboxTheme.spacing12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  widget.title,
                  if (widget.subtitle != null) ...[
                    const SizedBox(height: CupertinoDropboxTheme.spacing2),
                    widget.subtitle!,
                  ],
                ],
              ),
            ),
            if (widget.trailing != null) ...[
              const SizedBox(width: CupertinoDropboxTheme.spacing12),
              widget.trailing!,
            ] else if (widget.showChevron) ...[
              const SizedBox(width: CupertinoDropboxTheme.spacing12),
              const Icon(
                CupertinoIcons.chevron_right,
                size: 16,
                color: CupertinoDropboxTheme.textTertiary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}