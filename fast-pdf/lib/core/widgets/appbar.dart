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
      height: 68,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          left,

          const SizedBox(width: 12),

          Expanded(child: Center(child: titleWidget)),

          const SizedBox(width: 12),

          right ?? const SizedBox(width: 24),
        ],
      ),
    );
  }
}
