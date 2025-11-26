import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'main_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  double _sliderPosition = 0.0;
  bool _isDragging = false;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.light,
      ),
    );
    
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF6B73FF),
              Color(0xFF4F5BDA),
              Color(0xFF3B47C4),
              Color(0xFF2A35A8),
              Color(0xFF1A2388),
            ],
          ),
        ),
        child: Column(
          children: [
            SizedBox(height: MediaQuery.of(context).padding.top + 20),
            _buildLogo(),
            const Spacer(),
            _buildWelcomeText(),
            const Spacer(),
            _buildBottomSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Container(
              width: 20,
              height: 20,
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF007AFF),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'FAST PDF',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeText() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        children: [
          Text(
            'Welcome to the',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w300,
            ),
          ),
          Text(
            'Fast PDF!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 40),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Terms of Use',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                Text(
                  'Privacy Policy',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          _buildSlider(),
        ],
      ),
    );
  }

  Widget _buildSlider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 60,
      child: Stack(
        children: [
          // Серая дорожка
          Container(
            height: 60,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Center(
              child: Text(
                'Start',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          // Ползунок (голубая кнопка)
          AnimatedPositioned(
            duration: _isDragging ? Duration.zero : const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            left: _sliderPosition * (MediaQuery.of(context).size.width - 40 - 60), // Track width minus button width
            top: 5,
            child: GestureDetector(
              onPanStart: (details) {
                setState(() {
                  _isDragging = true;
                });
              },
              onPanUpdate: (details) {
                setState(() {
                  final RenderBox box = context.findRenderObject() as RenderBox;
                  final localPosition = box.globalToLocal(details.globalPosition);
                  final trackWidth = MediaQuery.of(context).size.width - 40 - 60; // Account for margins and button width
                  final relativePosition = (localPosition.dx - 20) / trackWidth; // 20 is left margin
                  _sliderPosition = relativePosition.clamp(0.0, 1.0);
                });
              },
              onPanEnd: (details) {
                setState(() {
                  _isDragging = false;
                });
                
                if (_sliderPosition > 0.8) {
                  _navigateToMain();
                } else {
                  setState(() {
                    _sliderPosition = 0.0;
                  });
                }
              },
              child: Container(
                width: 50,
                height: 50,
                decoration: const BoxDecoration(
                  color: Color(0xFF007AFF),
                  shape: BoxShape.circle,
                ),
                child: Container(
                  width: 20,
                  height: 20,
                  margin: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToMain() {
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const MainScreen(),
        transitionDuration: const Duration(milliseconds: 500),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
      (route) => false,
    );
  }
}