import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';

class CustomNavBar extends StatelessWidget {
  final int index;
  final Function(int) onTap;
  final List<CustomNavItemData> items;

  const CustomNavBar({
    super.key,
    required this.index,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return LiquidGlass(
      shape: LiquidRoundedSuperellipse(borderRadius: 50),
      child: Container(
        height: 70,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            items.length,
            (i) => _NavItem(
              data: items[i],
              selected: index == i,
              onPressed: () => onTap(i),
            ),
          ),
        ),
      ),
    );
  }
}

class CustomNavItemData {
  final String iconPath;
  final String label;

  CustomNavItemData(this.iconPath, this.label);
}

class _NavItem extends StatelessWidget {
  final CustomNavItemData data;
  final bool selected;
  final VoidCallback onPressed;

  const _NavItem({
    required this.data,
    required this.selected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? Color(0xFF3B96FF) : Colors.white.withOpacity(0.7);

    Widget content = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            data.iconPath,
            colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
            width: 22,
            height: 22,
          ),
          const SizedBox(height: 2),
          Text(data.label, style: TextStyle(color: color, fontSize: 11)),
        ],
      ),
    );

    if (selected) {
      content = IntrinsicWidth(
        child: IntrinsicHeight(
          child: LiquidGlass(
            shape: LiquidRoundedSuperellipse(borderRadius: 30),
            child: content,
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: onPressed,
      behavior: HitTestBehavior.translucent,
      child: content,
    );
  }
}
