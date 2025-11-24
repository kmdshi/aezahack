import 'package:flutter/material.dart';
import 'package:pdf/core/theme/app_theme.dart';
import 'package:pdf/core/widgets/root_screen.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: RootScreen(), theme: AppTheme.lightTheme);
  }
}
