import 'package:fast_pdf/features/start/onboarding_screen.dart';
import 'package:fast_pdf/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  double _scale = 1.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final width = c.maxWidth;

        /// 🔥 Масштаб под iPhone SE → 15 Pro Max → iPad
        _scale = (width / 390).clamp(0.75, 1.5);

        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: FadeTransition(
              opacity: _fade,
              child: SlideTransition(
                position: _slide,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24 * _scale),
                  child: Column(
                    children: [
                      SizedBox(height: 36 * _scale),

                      /// Верхняя часть
                      _buildTitleSection(),

                      SizedBox(height: 30 * _scale),

                      /// Сетка — занимает всё доступное
                      Expanded(child: _buildFeatureGrid()),

                      SizedBox(height: 30 * _scale),

                      /// Нижняя кнопка — всегда снизу
                      _buildBottom(),

                      SizedBox(height: 20 * _scale),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTitleSection() {
    return Column(
      children: [
        Text(
          "Welcome to Pdfly\nPowerful PDF Tools",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 32 * _scale,
            fontWeight: FontWeight.w700,
            height: 1.1,
          ),
        ),
        SizedBox(height: 14 * _scale),
        Text(
          "Scan, convert, edit, and sign documents\nwith professional-quality results",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16 * _scale,
            color: Colors.grey[600],
            height: 1.3,
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureGrid() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Expanded(
                child: _feature(
                  "Scan",
                  CupertinoIcons.doc_text_search,
                  Colors.blue,
                ),
              ),
              SizedBox(width: 12 * _scale),
              Expanded(
                child: _feature(
                  "Convert",
                  CupertinoIcons.arrow_2_circlepath,
                  Colors.green,
                ),
              ),
            ],
          ),
          SizedBox(height: 12 * _scale),
          Row(
            children: [
              Expanded(
                child: _feature("Edit", CupertinoIcons.pencil, Colors.orange),
              ),
              SizedBox(width: 12 * _scale),
              Expanded(
                child: _feature(
                  "Sign",
                  CupertinoIcons.signature,
                  Colors.indigo,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _feature(String title, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(20 * _scale),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18 * _scale),
        border: Border.all(color: Colors.black.withOpacity(0.08), width: 0.6),

        /// 🔥 Самая важная часть — iOS-style градиент
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFFFFFF),
            Color(0xFFF6F6F7), // нежная тень снизу
          ],
        ),

        /// внутренняя тень как у Apple карточек
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 20,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 52 * _scale,
            height: 52 * _scale,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14 * _scale),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [color.withOpacity(0.22), color.withOpacity(0.12)],
              ),
            ),
            child: Icon(icon, color: color, size: 26 * _scale),
          ),
          SizedBox(height: 12 * _scale),
          Text(
            title,
            style: TextStyle(
              fontSize: 16 * _scale,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottom() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: terms,
              child: Text(
                "Terms",
                style: TextStyle(
                  fontSize: 13 * _scale,
                  color: Colors.grey[600],
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            SizedBox(width: 16 * _scale),
            Container(width: 1, height: 14 * _scale, color: Colors.grey[400]),
            SizedBox(width: 16 * _scale),
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: privacy,
              child: Text(
                "Privacy",
                style: TextStyle(
                  fontSize: 13 * _scale,
                  color: Colors.grey[600],
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),

        SizedBox(height: 26 * _scale),

        SizedBox(
          height: 54 * _scale,
          width: double.infinity,
          child: CupertinoButton(
            padding: EdgeInsets.zero,
            borderRadius: BorderRadius.circular(14 * _scale),
            color: Theme.of(context).primaryColor,
            onPressed: () => Navigator.of(
              context,
            ).push(CupertinoPageRoute(builder: (_) => OnboardingScreen())),
            child: Text(
              "Get Started",
              style: TextStyle(
                fontSize: 18 * _scale,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
