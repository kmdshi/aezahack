import 'package:fast_pdf/core/theme/cupertino_dropbox_theme.dart';
import 'package:fast_pdf/core/widgets/appbar.dart';
import 'package:fast_pdf/core/widgets/cupertino_dropbox_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PremScreen extends StatelessWidget {
  const PremScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CupertinoDropboxTheme.background,
      appBar: CustomAppBar.dropboxAppBar(
        title: "Premium",
        onBack: () => Navigator.pop(context),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(CupertinoDropboxTheme.spacing24),
        child: Column(
          children: [
            const SizedBox(height: CupertinoDropboxTheme.spacing40),
            
            // Premium illustration
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: CupertinoDropboxTheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(100),
              ),
              child: const Icon(
                CupertinoIcons.star_circle_fill,
                size: 100,
                color: CupertinoDropboxTheme.primary,
              ),
            ),
            
            const SizedBox(height: CupertinoDropboxTheme.spacing40),
            
            // Title
            Text(
              "Unlock Premium",
              style: CupertinoDropboxTheme.title1Style,
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: CupertinoDropboxTheme.spacing12),
            
            Text(
              "Get unlimited access to all features and remove restrictions",
              style: CupertinoDropboxTheme.calloutStyle.copyWith(
                color: CupertinoDropboxTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: CupertinoDropboxTheme.spacing48),
            
            // Features
            _buildFeatureCard(
              icon: CupertinoIcons.infinite,
              title: "Unlimited Scans",
              description: "Scan as many documents as you want",
            ),
            
            const SizedBox(height: CupertinoDropboxTheme.spacing16),
            
            _buildFeatureCard(
              icon: CupertinoIcons.doc_text_fill,
              title: "Advanced Editing",
              description: "Access all editing tools and features",
            ),
            
            const SizedBox(height: CupertinoDropboxTheme.spacing16),
            
            _buildFeatureCard(
              icon: CupertinoIcons.cloud,
              title: "Cloud Sync",
              description: "Sync your documents across devices",
            ),
            
            const SizedBox(height: CupertinoDropboxTheme.spacing48),
            
            // Pricing card
            CupertinoDropboxCard(
              padding: const EdgeInsets.all(CupertinoDropboxTheme.spacing24),
              backgroundColor: CupertinoDropboxTheme.primary,
              child: Column(
                children: [
                  Text(
                    "\$0.99",
                    style: CupertinoDropboxTheme.title1Style.copyWith(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  
                  Text(
                    "One-time purchase",
                    style: CupertinoDropboxTheme.calloutStyle.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  
                  const SizedBox(height: CupertinoDropboxTheme.spacing24),
                  
                  CupertinoDropboxButton(
                    isPrimary: false,
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          CupertinoIcons.star_fill,
                          color: CupertinoDropboxTheme.primary,
                          size: 18,
                        ),
                        const SizedBox(width: CupertinoDropboxTheme.spacing8),
                        Text(
                          "Get Premium",
                          style: CupertinoDropboxTheme.headlineStyle.copyWith(
                            color: CupertinoDropboxTheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: CupertinoDropboxTheme.spacing24),
            
            // Restore button
            CupertinoButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                "Restore Purchase",
                style: CupertinoDropboxTheme.calloutStyle.copyWith(
                  color: CupertinoDropboxTheme.textSecondary,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            
            const SizedBox(height: CupertinoDropboxTheme.spacing40),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return CupertinoDropboxCard(
      padding: const EdgeInsets.all(CupertinoDropboxTheme.spacing16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: CupertinoDropboxTheme.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: CupertinoDropboxTheme.primary,
              size: 24,
            ),
          ),
          
          const SizedBox(width: CupertinoDropboxTheme.spacing16),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: CupertinoDropboxTheme.headlineStyle,
                ),
                const SizedBox(height: CupertinoDropboxTheme.spacing4),
                Text(
                  description,
                  style: CupertinoDropboxTheme.calloutStyle.copyWith(
                    color: CupertinoDropboxTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}