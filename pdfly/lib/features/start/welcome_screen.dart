import 'package:fast_pdf/core/theme/cupertino_dropbox_theme.dart';
import 'package:fast_pdf/core/widgets/cupertino_dropbox_widgets.dart';
import 'package:fast_pdf/features/start/onboarding_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(curve: Curves.easeOut, parent: _fadeController));

    _slideAnimation = Tween(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(
          CurvedAnimation(curve: Curves.easeOutCubic, parent: _slideController),
        );

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: CupertinoDropboxTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: CupertinoDropboxTheme.spacing24,
                ),
                child: Column(
                  children: [
                    SizedBox(height: size.height * 0.08),

                    /// 🔥 Главный фикс — убираем Expanded.
                    /// Делаем обычный контейнер фиксированной высоты
                    SizedBox(
                      height: size.height * 0.55,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildTitleSection(),
                          SizedBox(height: size.height * 0.06),
                          _buildFeaturesGrid(),
                        ],
                      ),
                    ),

                    _buildBottomSection(),

                    const SizedBox(height: CupertinoDropboxTheme.spacing32),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitleSection() {
    return Column(
      children: [
        Text(
          "Welcome to the Pdfly\nPowerful PDF Tools",
          textAlign: TextAlign.center,
          style: CupertinoDropboxTheme.largeTitleStyle,
        ),
        const SizedBox(height: CupertinoDropboxTheme.spacing16),
        Text(
          "Scan, convert, edit, and sign documents\nwith professional-quality results",
          textAlign: TextAlign.center,
          style: CupertinoDropboxTheme.bodyStyle.copyWith(
            color: CupertinoDropboxTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturesGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildFeatureCard(
                icon: CupertinoIcons.doc_text_search,
                title: "Scan",
                color: CupertinoDropboxTheme.primary,
              ),
            ),
            const SizedBox(width: CupertinoDropboxTheme.spacing12),
            Expanded(
              child: _buildFeatureCard(
                icon: CupertinoIcons.arrow_2_circlepath,
                title: "Convert",
                color: CupertinoDropboxTheme.success,
              ),
            ),
          ],
        ),
        const SizedBox(height: CupertinoDropboxTheme.spacing12),
        Row(
          children: [
            Expanded(
              child: _buildFeatureCard(
                icon: CupertinoIcons.pencil,
                title: "Edit",
                color: CupertinoDropboxTheme.warning,
              ),
            ),
            const SizedBox(width: CupertinoDropboxTheme.spacing12),
            Expanded(
              child: _buildFeatureCard(
                icon: CupertinoIcons.signature,
                title: "Sign",
                color: CupertinoDropboxTheme.primaryDark,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required Color color,
  }) {
    return CupertinoDropboxCard(
      padding: const EdgeInsets.all(CupertinoDropboxTheme.spacing20),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: CupertinoDropboxTheme.spacing12),
          Text(title, style: CupertinoDropboxTheme.headlineStyle),
        ],
      ),
    );
  }

  Widget _buildBottomSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLegalLink("Terms", () {}),
            Container(
              width: 1,
              height: 16,
              margin: const EdgeInsets.symmetric(
                horizontal: CupertinoDropboxTheme.spacing16,
              ),
              color: CupertinoDropboxTheme.divider,
            ),
            _buildLegalLink("Privacy", () {}),
          ],
        ),
        const SizedBox(height: CupertinoDropboxTheme.spacing32),
        CupertinoDropboxButton(
          onPressed: () {
            Navigator.of(context).push(
              CupertinoPageRoute(builder: (_) => const OnboardingScreen()),
            );
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Get Started",
                style: CupertinoDropboxTheme.headlineStyle.copyWith(
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: CupertinoDropboxTheme.spacing8),
              const Icon(
                CupertinoIcons.arrow_right,
                color: Colors.white,
                size: 18,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLegalLink(String text, VoidCallback onTap) {
    return CupertinoButton(
      padding: const EdgeInsets.symmetric(
        horizontal: CupertinoDropboxTheme.spacing12,
        vertical: CupertinoDropboxTheme.spacing8,
      ),
      onPressed: onTap,
      child: Text(
        text,
        style: CupertinoDropboxTheme.footnoteStyle.copyWith(
          decoration: TextDecoration.underline,
          decorationColor: CupertinoDropboxTheme.textSecondary,
        ),
      ),
    );
  }
}
