import 'package:fast_pdf/core/widgets/appbar.dart';
import 'package:fast_pdf/core/widgets/button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_xlider/flutter_xlider.dart';

class PremScreen extends StatelessWidget {
  const PremScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double w = size.width;
    final double h = size.height;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/welcome.png', fit: BoxFit.cover),
          ),

          Positioned(
            top: h * 0.07,
            left: 0,
            right: 0,
            child: CustomAppBar(
              titleWidget: const Text(
                "SETTINGS",
                style: TextStyle(color: Colors.white),
              ),
              left: ButtonWidget(
                asset: 'assets/images/icons/back.svg',
                onTap: () => Navigator.pop(context),
              ),
            ),
          ),

          Center(
            child: Image.asset(
              'assets/images/prem.png',
              width: w * 0.75,
              fit: BoxFit.contain,
            ),
          ),

          Positioned(
            left: 0,
            right: 0,
            bottom: h * 0.05,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    "Restore",
                    style: TextStyle(
                      color: Colors.white.withOpacity(.5),
                      fontSize: 16,
                    ),
                  ),
                ),

                SizedBox(
                  height: h * 0.10,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: w * 0.02),
                        child: FlutterSlider(
                          values: [0],
                          max: 100,
                          min: 0,
                          handlerHeight: h * 0.07,
                          handlerWidth: h * 0.07,
                          tooltip: FlutterSliderTooltip(disabled: true),

                          handler: FlutterSliderHandler(
                            decoration: const BoxDecoration(),
                            child: Container(
                              width: h * 0.075,
                              height: h * 0.075,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                              child: Image.asset(
                                'assets/images/sl_but.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),

                          trackBar: FlutterSliderTrackBar(
                            activeTrackBarHeight: h * 0.065,
                            inactiveTrackBarHeight: h * 0.065,
                            activeTrackBar: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF3093FF), Color(0xFF027BFF)],
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            inactiveTrackBar: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),

                          onDragging: (i, low, high) {
                            if (low > 60) {
                              Navigator.of(context).pop();
                            }
                          },
                        ),
                      ),

                      IgnorePointer(
                        child: Text(
                          "Get premium for \$0.99",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: w * 0.04,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
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
