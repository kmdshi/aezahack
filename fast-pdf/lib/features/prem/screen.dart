import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';

class PremScreen extends StatefulWidget {
  const PremScreen({super.key});

  @override
  State<PremScreen> createState() => _PremScreenState();
}

class _PremScreenState extends State<PremScreen> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final h = size.height;
    final w = size.width;

    double adaptive(double value) => value * (w / 390);
    double ah(double value) => value * (h / 844);

    return Scaffold(
      backgroundColor: const Color(0xFF55A4FF),
      body: Stack(
        children: [
          Positioned.fill(
            child: SvgPicture.asset(
              "assets/images/bg_line.svg",
              fit: BoxFit.cover,
            ),
          ),

          LiquidGlassLayer(
            settings: const LiquidGlassSettings(
              thickness: 80,
              blur: 5,
              glassColor: Color(0x33FFFFFF),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: LiquidGlass(
                            shape: LiquidRoundedSuperellipse(borderRadius: 100),
                            child: Container(
                              height: 62,
                              width: 62,
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                CupertinoIcons.xmark,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),

                        const Text(
                          "Premium",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),

                        GestureDetector(
                          onTap: () {},
                          child: const Text(
                            "Restore",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: MediaQuery.of(context).size.height * 0.05),

                  Container(
                    height: 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      image: const DecorationImage(
                        image: AssetImage("assets/images/prem/prem_banner.png"),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                  Text(
                    "Unlock Premium",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: adaptive(36),
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 30),
                  Container(
                    height: ah(180),
                    decoration: BoxDecoration(
                      image: const DecorationImage(
                        image: AssetImage(
                          "assets/images/prem/prem_text_banner.png",
                        ),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),

          Positioned(
            left: 20,
            right: 20,
            bottom: 20,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                backgroundColor: Colors.white,
                foregroundColor: Color(0xFF55A4FF),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Get premium for \$0.99",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
