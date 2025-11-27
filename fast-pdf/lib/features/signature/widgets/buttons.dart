import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SignButtons extends StatelessWidget {
  final List<String> icons;
  final List<String> labels;
  final Function(int) onTap;
  final int activeIndex;

  const SignButtons({
    super.key,
    required this.icons,
    required this.labels,
    required this.onTap,
    required this.activeIndex,
  }) : assert(icons.length == labels.length, "Icons and labels must match");

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(icons.length, (i) {
          final bool isActive = i == activeIndex;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: GestureDetector(
              onTap: () => onTap(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 48,
                width: 125,
                decoration: BoxDecoration(
                  color: isActive
                      ? const Color(0xFF3093FF)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isActive
                        ? const Color(0xFF3093FF)
                        : Color(0xFF3D3D3D),
                    width: isActive ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      icons[i],
                      colorFilter: ColorFilter.mode(
                        isActive ? Colors.white : Colors.grey.shade300,
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      labels[i],
                      style: TextStyle(
                        color: isActive ? Colors.white : Colors.grey.shade300,
                        fontWeight: isActive
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
