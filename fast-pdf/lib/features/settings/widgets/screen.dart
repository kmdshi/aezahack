import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fast_pdf/features/prem/screen.dart';
import 'package:fast_pdf/main.dart';
import 'package:share_plus/share_plus.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F6FA),
      appBar: AppBar(
        title: Text(
          'Settings',
          style: TextStyle(
            fontSize: 32,
            color: Color(0xFF383838),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: SvgPicture.asset(
              "assets/images/bg_line.svg",
              fit: BoxFit.fill,
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(24),
                      onTap: () => Navigator.of(
                        context,
                      ).push(CupertinoPageRoute(builder: (_) => PremScreen())),
                      child: Container(
                        height: 163,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          image: const DecorationImage(
                            image: AssetImage("assets/images/prem/prem.png"),
                            fit: BoxFit.cover,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: SizedBox.expand(),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: terms,
                          child: Container(
                            height: 148,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              image: const DecorationImage(
                                image: AssetImage(
                                  "assets/images/prem/terms.png",
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: SizedBox.expand(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: InkWell(
                          onTap: privacy,
                          child: Container(
                            height: 148,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              image: const DecorationImage(
                                image: AssetImage(
                                  "assets/images/prem/policy.png",
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: SizedBox.expand(),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  InkWell(
                    onTap: shareApp,
                    child: Container(
                      height: 112,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        image: const DecorationImage(
                          image: AssetImage("assets/images/prem/share.png"),
                          fit: BoxFit.cover,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: SizedBox.expand(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void shareApp() {
    const androidLink =
        'https://play.google.com/store/apps/details?id=com.my.app';
    const iosLink = 'https://apps.apple.com/app/id0000000000';

    final link = Platform.isIOS ? iosLink : androidLink;

    SharePlus.instance.share(
      ShareParams(
        title: 'Все работает!',
        subject: 'Ставь максимальный балл скорее<3',
        uri: Uri.parse(link),
      ),
    );
  }
}
