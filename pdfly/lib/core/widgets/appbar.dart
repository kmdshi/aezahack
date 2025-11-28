import 'package:fast_pdf/core/theme/cupertino_dropbox_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget {
  final Widget left;
  final Widget? right;
  final Widget titleWidget;

  const CustomAppBar({
    super.key,
    required this.left,
    required this.titleWidget,
    this.right,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      margin: const EdgeInsets.symmetric(
        horizontal: CupertinoDropboxTheme.spacing16,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: CupertinoDropboxTheme.spacing20,
      ),
      alignment: Alignment.center,
      decoration: CupertinoDropboxTheme.cardDecoration(),
      child: Row(
        children: [
          left,

          const SizedBox(width: CupertinoDropboxTheme.spacing16),

          Expanded(child: Center(child: titleWidget)),

          const SizedBox(width: CupertinoDropboxTheme.spacing16),

          right ?? const SizedBox(width: 32),
        ],
      ),
    );
  }

  // Static Dropbox-style AppBar
  static PreferredSizeWidget dropboxAppBar({
    required String title,
    VoidCallback? onBack,
    List<Widget>? actions,
    bool centerTitle = true,
  }) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: CupertinoDropboxTheme.background,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: onBack != null
          ? CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: onBack,
              child: const Icon(
                CupertinoIcons.back,
                color: CupertinoDropboxTheme.textSecondary,
                size: 24,
              ),
            )
          : null,
      title: Text(title, style: CupertinoDropboxTheme.headlineStyle),
      centerTitle: centerTitle,
      actions: actions,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 0.5, color: CupertinoDropboxTheme.divider),
      ),
    );
  }
}
