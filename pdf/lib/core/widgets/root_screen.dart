import 'package:flutter/material.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import 'package:pdf/core/widgets/nav_bar.dart';
import 'package:pdf/features/actions/widgets/screen.dart';
import 'package:pdf/features/files/widgets/screen.dart';
import 'package:pdf/features/settings/widgets/screen.dart';
import 'package:pdf/features/signature/widgets/screen.dart';

class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  int _index = 0;

  final List<Widget> _screens = [
    const ActionsScreen(),
    const FilesScreen(),
    const SignatureScreen(),
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
          thickness: 20,
          blur: 10,
          glassColor: Color(0x33FFFFFF),
        ),

        child: LiquidGlass(
          glassContainsChild: true,
          shape: LiquidRoundedSuperellipse(borderRadius: 50),
          child: CustomNavBar(
            index: _index,
            onTap: (i) => setState(() => _index = i),
            items: [
              CustomNavItemData('assets/images/icons/actions_i.svg', "Actions"),
              CustomNavItemData('assets/images/icons/files_i.svg', "Files"),
              CustomNavItemData('assets/images/icons/sign_i.svg', "Signature"),
              CustomNavItemData(
                'assets/images/icons/settings_i.svg',
                "Settings",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
