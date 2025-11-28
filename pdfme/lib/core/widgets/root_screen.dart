import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import 'package:pdf_app/features/actions/widgets/screen.dart';
import 'package:pdf_app/features/ai/widgets/screen.dart';
import 'package:pdf_app/features/settings/widgets/screen.dart';
import 'package:pdf_app/features/signature/widgets/create_new_sign.dart';
import 'package:pdf_app/features/signature/widgets/sign_screen.dart';

class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  int _index = 0;

  final List<Widget> _screens = [
    const ActionsScreen(),
    const AIScreen(),
    const SingScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: _index, children: _screens),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: LiquidGlassLayer(
        useBackdropGroup: true,
        settings: const LiquidGlassSettings(
          blur: 5,
          visibility: 1.0,
          thickness: 10,
          refractiveIndex: 1.35,
          saturation: 3,
        ),

        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                LiquidGlass(
                  shape: LiquidRoundedSuperellipse(borderRadius: 40),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 10,
                    ),

                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      children: [
                        _navItem(
                          asset: 'assets/images/icons/actions_i.svg',
                          index: 0,
                          text: 'Actions',
                        ),
                        SizedBox(width: 10),
                        _navItem(
                          asset: 'assets/images/icons/stars.svg',
                          index: 1,
                          text: 'PDF Me',
                        ),
                        SizedBox(width: 10),

                        _navItem(
                          asset: 'assets/images/icons/sign_i.svg',
                          index: 2,
                          text: 'Signature',
                        ),
                        SizedBox(width: 10),
                        _navItem(
                          asset: 'assets/images/icons/settings_i.svg',
                          index: 3,
                          text: 'Settings',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () {
                    switch (_index) {
                      case (2):
                        Navigator.of(context).push(
                          CupertinoPageRoute(
                            builder: (_) => NewSignatureScreen(),
                          ),
                        );
                    }
                  },
                  child: LiquidGlass(
                    glassContainsChild: true,
                    shape: LiquidRoundedSuperellipse(borderRadius: 100),
                    child: Container(
                      padding: const EdgeInsets.all(30),
                      child: !(_index == 1 || _index == 2)
                          ? SvgPicture.asset(
                              'assets/images/icons/scan.svg',
                              width: 26,
                              height: 26,
                              color: Color(0xFF55A4FF),
                            )
                          : Icon(
                              CupertinoIcons.add,
                              size: 24,
                              color: Color(0xFF55A4FF),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _navItem({
    required String asset,
    required int index,
    required String text,
  }) {
    final bool isActive = _index == index;
    final gradient = _tabGradient(index);

    return GestureDetector(
      onTap: () => _changeTab(index),
      child: isActive
          ? LiquidGlass(
              shape: LiquidRoundedSuperellipse(borderRadius: 40),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                key: ValueKey('active_$index'),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) => gradient.createShader(
                        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                      ),
                      child: SvgPicture.asset(
                        asset,
                        width: 24,
                        height: 24,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      text,
                      style: TextStyle(
                        foreground: Paint()
                          ..shader = gradient.createShader(
                            const Rect.fromLTWH(0, 0, 200, 24),
                          ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : Column(
              key: ValueKey('inactive_$index'),
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  asset,
                  width: 24,
                  height: 24,
                  colorFilter: const ColorFilter.mode(
                    Color(0xFF5D5D5D),
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  text,
                  style: const TextStyle(
                    color: Color(0xFF5D5D5D),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
    );
  }

  LinearGradient _tabGradient(int index) {
    switch (index) {
      case 0:
        return const LinearGradient(
          colors: [Color(0xFF55A4FF), Color(0xFF3B96FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 1:
        return const LinearGradient(
          colors: [Color(0xFF51A2FF), Color(0xFFFF7BC1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 2:
        return const LinearGradient(
          colors: [Color(0xFF4EE046), Color(0xFF61D449)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 3:
        return const LinearGradient(
          colors: [Color(0xFFFF81BE), Color(0xFFFF3BDB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      default:
        return const LinearGradient(
          colors: [Color(0xFF5D5D5D), Color(0xFF3D3D3D)],
        );
    }
  }

  void _changeTab(int newIndex) {
    setState(() => _index = newIndex);
  }
}
