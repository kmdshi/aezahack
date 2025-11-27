import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ButtonWidget extends StatelessWidget {
  final String asset;
  final VoidCallback? onTap;

  final double size;

  final double iconSize;

  const ButtonWidget({
    super.key,
    required this.asset,
    this.onTap,
    this.size = 36,
    this.iconSize = 20,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: size,
        width: size,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(size / 3),
          border: Border.all(color: const Color(0xFF3D3D3D)),
        ),
        alignment: Alignment.center,
        child: SvgPicture.asset(
          asset,
          width: iconSize,
          height: iconSize,
          colorFilter: const ColorFilter.mode(
            Color(0xFF929292),
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }
}
