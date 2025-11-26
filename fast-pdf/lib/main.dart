import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/onboarding_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PDF Scanner',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF1C1C1E),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1C1C1E),
          foregroundColor: Colors.white,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.light,
        ),
        primaryColor: const Color(0xFF007AFF),
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: Color(0xFF2C2C2E),
          modalBackgroundColor: Color(0xFF2C2C2E),
        ),
      ),
      home: const OnboardingScreen(),
    );
  }
}
