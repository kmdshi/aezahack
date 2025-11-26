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
    return SizedBox(
      width: 300,
      height: 300,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            bottom: 90,
            child: GestureDetector(
              onTap: () => widget.onSurroundingButtonTap(1),
              child: Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () => widget.onSurroundingButtonTap(2),

                  child: Container(
                    width: 62,
                    height: 62,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/ers_b.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 5),
                GestureDetector(
                  onTap: () => widget.onSurroundingButtonTap(3),

                  child: Container(
                    width: 62,
                    height: 62,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/cut_b.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 5),

                GestureDetector(
                  onTap: widget.onCenterButtonTap,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        'assets/images/icons/add.svg',
                        fit: BoxFit.cover,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 5),

                GestureDetector(
                  onTap: () => widget.onSurroundingButtonTap(4),

                  child: Container(
                    width: 62,
                    height: 62,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/copy_b.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 5),

                GestureDetector(
                  onTap: () => widget.onSurroundingButtonTap(5),
                  child: Container(
                    width: 62,
                    height: 62,
                    decoration: BoxDecoration(
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
