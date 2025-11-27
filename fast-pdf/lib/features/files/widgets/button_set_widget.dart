import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: GestureDetector(
              onTap: () => onTap(i),
              child: Container(
                height: 48,
                width: 125,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF3D3D3D)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(icons[i]),
                    const SizedBox(width: 5),
                    Text(
                      labels[i],
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
