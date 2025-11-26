import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import 'package:pdf_app/features/actions/widgets/screen.dart';
import 'package:pdf_app/features/files/widgets/screen.dart';
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
    // const FilesScreen(),
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
          refractiveIndex: 1,
          thickness: 10,
          visibility: 2,
          blur: 10,
          glassColor: Color(0x33FFFFFF),
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
                      horizontal: 20,
                      vertical: 15,
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
                        // SizedBox(width: 10),
                        // _navItem(
                        //   asset: 'assets/images/icons/files_i.svg',
                        //   index: 1,
                        //   text: 'Files',
                        // ),
                        SizedBox(width: 10),

                        _navItem(
                          asset: 'assets/images/icons/sign_i.svg',
                          index: 1,
                          text: 'Signature',
                        ),
                        SizedBox(width: 10),
                        _navItem(
                          asset: 'assets/images/icons/settings_i.svg',
                          index: 2,
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
                      case (1):
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
                      padding: const EdgeInsets.all(24),
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
    final Color color = _tabColor(index, isActive);

    return GestureDetector(
      onTap: () => _changeTab(index),
      child: isActive
          ? LiquidGlass(
              shape: LiquidRoundedSuperellipse(borderRadius: 40),
              child: Container(
                key: ValueKey('active_$index'),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      asset,
                      width: 24,
                      height: 24,
                      color: color,
                    ),
                    const SizedBox(height: 4),
                    Text(text, style: TextStyle(color: color)),
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

  Color _tabColor(int index, bool isActive) {
    switch (index) {
      case 0:
        return const Color(0xFF55A4FF);
      // case 1:
      //   return const Color(0xFFF5D142);
      case 1:
        return const Color(0xFF4EE046);
      case 2:
        return const Color(0xFFFF81BE);
      default:
        return const Color(0xFF5D5D5D);
    }
  }

  void _changeTab(int newIndex) {
    setState(() => _index = newIndex);
  }
}
