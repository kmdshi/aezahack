import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import 'package:pdf_app/features/start/onboarding_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.blueAccent,
      body: LiquidGlassLayer(
        settings: const LiquidGlassSettings(
          thickness: 20,
          blur: 10,
          glassColor: Color(0x33FFFFFF),
        ),

        child: Stack(
          children: [
            Positioned.fill(
              child: SvgPicture.asset(
                'assets/images/bg_line.svg',
                fit: BoxFit.cover,
              ),
            ),

            Positioned.fill(
              child: SafeArea(
                child: Column(
                  children: [
                    SizedBox(height: MediaQuery.sizeOf(context).height * 0.05),
                    Text(
                      'Welcome to the',
                      style: TextStyle(
                        color: Color(0xFF383838),
                        fontSize: h * 0.06,
                        fontWeight: FontWeight.w600,
                        height: 1,
                      ),
                    ),
                    Text(
                      'PDF Me',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: h * 0.09,
                        fontWeight: FontWeight.w600,
                        height: 1,
                      ),
                    ),
                    const Spacer(),

                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        LiquidGlass(
                          shape: LiquidRoundedSuperellipse(borderRadius: 30),
                          child: SizedBox(
                            height: h * 0.10,
                            width: w * 0.40,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Center(
                                child: Image.asset(
                                  'assets/images/start/button_1.png',
                                  height: 160 * 0.4,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        LiquidGlass(
                          shape: LiquidRoundedSuperellipse(borderRadius: 30),
                          child: SizedBox(
                            height: h * 0.10,
                            width: w * 0.55,
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Center(
                                child: Image.asset(
                                  'assets/images/start/button_2.png',
                                  height: 240 * 0.4,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        LiquidGlass(
                          shape: LiquidRoundedSuperellipse(borderRadius: 30),
                          child: SizedBox(
                            height: h * 0.10,
                            width: w * 0.80,
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Image.asset(
                                'assets/images/start/button_3.png',
                                height: 360 * 0.4,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const Spacer(),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: 48,
                                  child: ElevatedButton(
                                    onPressed: () {},
                                    style: ButtonStyle(
                                      backgroundColor: WidgetStateProperty.all(
                                        Colors.transparent,
                                      ),
                                      shape: WidgetStateProperty.all(
                                        RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          side: const BorderSide(
                                            color: Colors.white,
                                            width: 1,
                                          ),
                                        ),
                                      ),

                                      surfaceTintColor: WidgetStateProperty.all(
                                        Colors.transparent,
                                      ),
                                      foregroundColor: WidgetStateProperty.all(
                                        Colors.white,
                                      ),
                                      elevation: WidgetStateProperty.all(0),
                                    ),
                                    child: const Text(
                                      "Terms of use",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: SizedBox(
                                  height: 48,
                                  child: ElevatedButton(
                                    onPressed: () {},
                                    style: ButtonStyle(
                                      backgroundColor: WidgetStateProperty.all(
                                        Colors.transparent,
                                      ),
                                      shape: WidgetStateProperty.all(
                                        RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          side: const BorderSide(
                                            color: Colors.white,
                                            width: 1,
                                          ),
                                        ),
                                      ),

                                      surfaceTintColor: WidgetStateProperty.all(
                                        Colors.transparent,
                                      ),
                                      foregroundColor: WidgetStateProperty.all(
                                        Colors.white,
                                      ),
                                      elevation: WidgetStateProperty.all(0),
                                    ),
                                    child: const Text(
                                      "Privacy Policy",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          SizedBox(
                            height: 64,
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () =>
                                  Navigator.of(context).pushReplacement(
                                    CupertinoPageRoute(
                                      builder: (_) => OnboardingScreen(),
                                    ),
                                  ),
                              style: ButtonStyle(
                                backgroundColor: WidgetStateProperty.all(
                                  Colors.white,
                                ),
                                shape: WidgetStateProperty.all(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                    side: const BorderSide(
                                      color: Colors.white,
                                      width: 1,
                                    ),
                                  ),
                                ),

                                surfaceTintColor: WidgetStateProperty.all(
                                  Colors.transparent,
                                ),
                                foregroundColor: WidgetStateProperty.all(
                                  Color(0xFF55A4FF),
                                ),
                                elevation: WidgetStateProperty.all(0),
                              ),
                              child: Text(
                                "Start Onboarding",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
