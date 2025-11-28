import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ButtonSetWidget extends StatefulWidget {
  final VoidCallback onCenterButtonTap;
  final Function(int) onSurroundingButtonTap;

  const ButtonSetWidget({
    super.key,
    required this.onCenterButtonTap,
    required this.onSurroundingButtonTap,
  });

  @override
  State<ButtonSetWidget> createState() => _ButtonSetWidgetState();
}

class _ButtonSetWidgetState extends State<ButtonSetWidget> {
  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    final double btnSize = w * 0.15;
    final double centerBtn = w * 0.20;
    final double spacing = w * 0.02;
    final double topOffset = w * 0.22;
    final double totalSize = w * 0.7;

    return SizedBox(
      width: totalSize,
      height: totalSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            bottom: topOffset,
            child: GestureDetector(
              onTap: () => widget.onSurroundingButtonTap(1),
              child: Container(
                width: btnSize,
                height: btnSize,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/re_b.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            bottom: 0,
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => widget.onSurroundingButtonTap(2),
                  child: Container(
                    width: btnSize,
                    height: btnSize,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/ers_b.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),

                SizedBox(width: spacing),

                GestureDetector(
                  onTap: () => widget.onSurroundingButtonTap(3),
                  child: Container(
                    width: btnSize,
                    height: btnSize,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/cut_b.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),

                SizedBox(width: spacing),

                GestureDetector(
                  onTap: widget.onCenterButtonTap,
                  child: Container(
                    width: centerBtn,
                    height: centerBtn,
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        'assets/images/icons/check.svg',
                        width: centerBtn * 0.45,
                        height: centerBtn * 0.45,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                SizedBox(width: spacing),

                GestureDetector(
                  onTap: () => widget.onSurroundingButtonTap(4),
                  child: Container(
                    width: btnSize,
                    height: btnSize,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/copy_b.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),

                SizedBox(width: spacing),

                GestureDetector(
                  onTap: () => widget.onSurroundingButtonTap(5),
                  child: Container(
                    width: btnSize,
                    height: btnSize,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/sign_b.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
