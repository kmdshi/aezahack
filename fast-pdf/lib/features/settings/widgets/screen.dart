import 'dart:io';
import 'package:fast_pdf/core/widgets/appbar.dart';
import 'package:fast_pdf/core/widgets/button_widget.dart';
import 'package:fast_pdf/features/settings/widgets/prem.dart';
import 'package:fast_pdf/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 16,
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

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                children: [
                  const SizedBox(height: 80),

                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        CupertinoPageRoute(builder: (_) => const PremScreen()),
                      );
                    },
                    child: Container(
                      height: 60,
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          colors: [Color(0xFF3093FF), Color(0xFF027BFF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Align(
                        alignment: AlignmentGeometry.centerLeft,
                        child: const Text(
                          "Premium",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  _settingsContainer(title: "Terms of Use", onTap: terms),

                  const SizedBox(height: 14),

                  _settingsContainer(title: "Privacy Policy", onTap: privacy),

                  const SizedBox(height: 14),

                  _settingsContainer(title: "Share App", onTap: shareApp),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _settingsContainer({
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 60,
        padding: EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
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
