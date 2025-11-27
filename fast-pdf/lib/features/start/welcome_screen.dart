import 'package:fast_pdf/features/start/onboarding_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_xlider/flutter_xlider.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.width;

    final double fontSize = size * 0.1;

    return Scaffold(
      backgroundColor: Colors.blueAccent,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/welcome.png', fit: BoxFit.cover),
          ),

          Positioned(
            top: MediaQuery.sizeOf(context).height * 0.1,
            left: 20,
            child: Center(
              child: SvgPicture.asset(
                'assets/images/logo.svg',
                width: 150,
                height: 40,
              ),
            ),
          ),
          Positioned(
            left: 10,
            bottom: 200,
            child: RichText(
              textAlign: TextAlign.left,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "Welcome to the\n",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: fontSize,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  TextSpan(
                    text: "FastPDF!",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: fontSize,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Terms of use",
                        style: TextStyle(
                          color: Colors.white.withOpacity(.5),
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        "Privacy Policy",
                        style: TextStyle(
                          color: Colors.white.withOpacity(.5),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                SizedBox(
                  height: 70,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: FlutterSlider(
                      values: [0],
                      max: 100,
                      min: 0,

                      handlerHeight: 56,
                      handlerWidth: 56,

                      tooltip: FlutterSliderTooltip(disabled: true),

                      handler: FlutterSliderHandler(
                        decoration: const BoxDecoration(),
                        child: Container(
                          width: 60,
                          height: 60,
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
                        activeTrackBarHeight: 56,
                        inactiveTrackBarHeight: 56,
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
                          Navigator.of(context).pushReplacement(
                            CupertinoPageRoute(
                              builder: (_) => OnboardingScreen(),
                            ),
                          );
                        }
                      },
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
