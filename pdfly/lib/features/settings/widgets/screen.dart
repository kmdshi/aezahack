import 'dart:io';
import 'package:fast_pdf/core/theme/cupertino_dropbox_theme.dart';
import 'package:fast_pdf/core/widgets/cupertino_dropbox_widgets.dart';
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

class _SettingsScreenState extends State<SettingsScreen>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: CupertinoPageScaffold(
        backgroundColor: CupertinoDropboxTheme.background,
        navigationBar: CupertinoNavigationBar(
          backgroundColor: CupertinoDropboxTheme.background,
          border: null,
          leading: CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () => Navigator.pop(context),
            child: const Icon(
              CupertinoIcons.back,
              color: CupertinoDropboxTheme.primary,
            ),
          ),
          middle: Text("Settings", style: CupertinoDropboxTheme.headlineStyle),
        ),
        child: SafeArea(
          child: SlideTransition(
            position: _slideAnimation,
            child: CustomScrollView(
              slivers: [
                // Profile section
                SliverToBoxAdapter(child: _buildProfileSection()),

                // Premium card
                SliverToBoxAdapter(child: _buildPremiumCard()),

                // Settings sections
                SliverToBoxAdapter(child: _buildAccountSection()),
                SliverToBoxAdapter(child: _buildLegalSection()),
                SliverToBoxAdapter(child: _buildGeneralSection()),

                // Bottom spacing
                const SliverToBoxAdapter(
                  child: SizedBox(height: CupertinoDropboxTheme.spacing32),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    return Padding(
      padding: const EdgeInsets.all(CupertinoDropboxTheme.spacing24),
      child: CupertinoDropboxCard(
        padding: const EdgeInsets.all(CupertinoDropboxTheme.spacing20),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: CupertinoDropboxTheme.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                CupertinoIcons.person_fill,
                size: 32,
                color: CupertinoDropboxTheme.primary,
              ),
            ),

            const SizedBox(width: CupertinoDropboxTheme.spacing16),

            // User info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "FastPDF User",
                    style: CupertinoDropboxTheme.title3Style,
                  ),
                  const SizedBox(height: CupertinoDropboxTheme.spacing4),
                  Text(
                    "Free Account",
                    style: CupertinoDropboxTheme.calloutStyle.copyWith(
                      color: CupertinoDropboxTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // Edit button
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: CupertinoDropboxTheme.gray100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                CupertinoIcons.pencil,
                color: CupertinoDropboxTheme.textSecondary,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: CupertinoDropboxTheme.spacing24,
      ),
      child: CupertinoDropboxCard(
        onTap: () {
          Navigator.push(
            context,
            CupertinoPageRoute(builder: (_) => const PremScreen()),
          );
        },
        padding: const EdgeInsets.all(CupertinoDropboxTheme.spacing20),
        backgroundColor: CupertinoDropboxTheme.primary,
        shadows: CupertinoDropboxTheme.buttonShadow,
        child: Row(
          children: [
            // Premium icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                CupertinoIcons.star_circle_fill,
                color: Colors.white,
                size: 24,
              ),
            ),

            const SizedBox(width: CupertinoDropboxTheme.spacing16),

            // Premium content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Upgrade to Premium",
                    style: CupertinoDropboxTheme.headlineStyle.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: CupertinoDropboxTheme.spacing4),
                  Text(
                    "Unlock unlimited scans & features",
                    style: CupertinoDropboxTheme.calloutStyle.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),

            // Arrow
            const Icon(
              CupertinoIcons.chevron_right,
              color: Colors.white,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: CupertinoDropboxTheme.spacing24,
        vertical: CupertinoDropboxTheme.spacing16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: CupertinoDropboxTheme.spacing16),

          Text(
            "Account",
            style: CupertinoDropboxTheme.title3Style.copyWith(
              color: CupertinoDropboxTheme.textSecondary,
            ),
          ),

          const SizedBox(height: CupertinoDropboxTheme.spacing12),

          CupertinoDropboxCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                CupertinoDropboxListTile(
                  leading: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: CupertinoDropboxTheme.primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      CupertinoIcons.person,
                      color: CupertinoDropboxTheme.primary,
                      size: 18,
                    ),
                  ),
                  title: Text(
                    "Profile Settings",
                    style: CupertinoDropboxTheme.calloutStyle,
                  ),
                  subtitle: Text(
                    "Manage your account details",
                    style: CupertinoDropboxTheme.footnoteStyle,
                  ),
                  showChevron: true,
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegalSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: CupertinoDropboxTheme.spacing24,
        vertical: CupertinoDropboxTheme.spacing16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Legal",
            style: CupertinoDropboxTheme.title3Style.copyWith(
              color: CupertinoDropboxTheme.textSecondary,
            ),
          ),

          const SizedBox(height: CupertinoDropboxTheme.spacing12),

          CupertinoDropboxCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                CupertinoDropboxListTile(
                  leading: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: CupertinoDropboxTheme.warning.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      CupertinoIcons.doc_text,
                      color: CupertinoDropboxTheme.warning,
                      size: 18,
                    ),
                  ),
                  title: Text(
                    "Terms of Service",
                    style: CupertinoDropboxTheme.calloutStyle,
                  ),
                  subtitle: Text(
                    "App terms and conditions",
                    style: CupertinoDropboxTheme.footnoteStyle,
                  ),
                  showChevron: true,
                  onTap: terms,
                ),

                const Divider(height: 1, indent: 48),

                CupertinoDropboxListTile(
                  leading: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: CupertinoDropboxTheme.success.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      CupertinoIcons.lock_shield,
                      color: CupertinoDropboxTheme.success,
                      size: 18,
                    ),
                  ),
                  title: Text(
                    "Privacy Policy",
                    style: CupertinoDropboxTheme.calloutStyle,
                  ),
                  subtitle: Text(
                    "How we protect your privacy",
                    style: CupertinoDropboxTheme.footnoteStyle,
                  ),
                  showChevron: true,
                  onTap: privacy,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGeneralSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: CupertinoDropboxTheme.spacing24,
        vertical: CupertinoDropboxTheme.spacing16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "General",
            style: CupertinoDropboxTheme.title3Style.copyWith(
              color: CupertinoDropboxTheme.textSecondary,
            ),
          ),

          const SizedBox(height: CupertinoDropboxTheme.spacing12),

          CupertinoDropboxCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                CupertinoDropboxListTile(
                  leading: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.purple.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      CupertinoIcons.share,
                      color: Colors.purple,
                      size: 18,
                    ),
                  ),
                  title: Text(
                    "Share App",
                    style: CupertinoDropboxTheme.calloutStyle,
                  ),
                  subtitle: Text(
                    "Tell friends about FastPDF",
                    style: CupertinoDropboxTheme.footnoteStyle,
                  ),
                  showChevron: true,
                  onTap: shareApp,
                ),

                const Divider(height: 1, indent: 48),

                CupertinoDropboxListTile(
                  leading: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: CupertinoDropboxTheme.textSecondary.withOpacity(
                        0.15,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      CupertinoIcons.info_circle,
                      color: CupertinoDropboxTheme.textSecondary,
                      size: 18,
                    ),
                  ),
                  title: Text(
                    "About FastPDF",
                    style: CupertinoDropboxTheme.calloutStyle,
                  ),
                  subtitle: Text(
                    "Version 1.0.0",
                    style: CupertinoDropboxTheme.footnoteStyle,
                  ),
                  showChevron: true,
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
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
        title: 'Check out FastPDF!',
        subject: 'Amazing PDF app for scanning and editing documents',
        uri: Uri.parse(link),
      ),
    );
  }
}
