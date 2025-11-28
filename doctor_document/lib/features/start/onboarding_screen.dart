import 'package:fast_pdf/core/theme/cupertino_dropbox_theme.dart';
import 'package:fast_pdf/core/widgets/cupertino_dropbox_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fast_pdf/core/widgets/root_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _controller = PageController();
  int _page = 0;

  late AnimationController _cardAnimController;
  late Animation<double> _cardAnimation;

  late double _scale;
  late double _textScale;

  final List<Map<String, dynamic>> pages = [
    {
      "title": "Scan Documents",
      "subtitle":
          "Point your camera at any document to capture it. The app automatically detects edges and saves it as a high-quality PDF.",
      "image": "assets/images/start/onb_1.png",
      "icon": CupertinoIcons.doc_text_viewfinder,
      "color": CupertinoDropboxTheme.primary,
    },
    {
      "title": "Convert Files",
      "subtitle":
          "Select photos or documents from your gallery, choose the output format, and instantly convert to PDF or other formats.",
      "image": "assets/images/start/onb_2.png",
      "icon": CupertinoIcons.arrow_2_circlepath,
      "color": CupertinoDropboxTheme.success,
    },
    {
      "title": "Edit & Annotate",
      "subtitle":
          "Open any PDF file to highlight text, add notes, insert images, or reorder pages with intuitive editing tools.",
      "image": "assets/images/start/onb_3.png",
      "icon": CupertinoIcons.pencil,
      "color": CupertinoDropboxTheme.warning,
    },
    {
      "title": "Digital Signatures",
      "subtitle":
          "Create your digital signature once and apply it to any document. Sign contracts and forms securely.",
      "image": "assets/images/start/onb_4.png",
      "icon": CupertinoIcons.signature,
      "color": Colors.purple,
    },
    {
      "title": "Organize Files",
      "subtitle":
          "Create folders and organize your documents. All files are stored securely on your device.",
      "image": "assets/images/start/onb_5.png",
      "icon": CupertinoIcons.folder,
      "color": CupertinoDropboxTheme.primary,
    },
  ];

  @override
  void initState() {
    super.initState();

    _cardAnimController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _cardAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _cardAnimController, curve: Curves.easeOut),
    );

    _cardAnimController.forward();
  }

  @override
  void dispose() {
    _cardAnimController.dispose();
    super.dispose();
  }

  void nextPage() {
    if (_page < pages.length - 1) {
      _cardAnimController.reset();
      _cardAnimController.forward();

      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      Navigator.pushReplacement(
        context,
        CupertinoPageRoute(builder: (_) => const RootScreen()),
      );
    }
  }

  void prevPage() {
    if (_page == 0) {
      Navigator.pop(context);
      return;
    }
    if (_page > 0) {
      _cardAnimController.reset();
      _cardAnimController.forward();

      _controller.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    /// BASE FOR ADAPTIVE
    const baseWidth = 390.0; // iPhone 14 width
    _scale = size.width / baseWidth;
    _textScale = MediaQuery.textScaleFactorOf(context).clamp(1.0, 1.3);

    return Scaffold(
      backgroundColor: CupertinoDropboxTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),

            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (page) {
                  setState(() => _page = page);
                  _cardAnimController.reset();
                  _cardAnimController.forward();
                },
                itemCount: pages.length,
                itemBuilder: (context, index) =>
                    _buildPageContent(pages[index]),
              ),
            ),

            _buildBottomNavigation(),
            SizedBox(height: 32 * _scale),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // HEADER
  // -------------------------------------------------------------

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.all(16 * _scale),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: prevPage,
            child: Icon(
              CupertinoIcons.back,
              color: CupertinoDropboxTheme.textSecondary,
              size: 28 * _scale,
            ),
          ),
          Text(
            "${_page + 1} of ${pages.length}",
            style: CupertinoDropboxTheme.calloutStyle.copyWith(
              fontSize:
                  CupertinoDropboxTheme.calloutStyle.fontSize! * _textScale,
              color: CupertinoDropboxTheme.textSecondary,
            ),
          ),
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () => Navigator.pushReplacement(
              context,
              CupertinoPageRoute(builder: (_) => const RootScreen()),
            ),
            child: Text(
              "Skip",
              style: CupertinoDropboxTheme.calloutStyle.copyWith(
                fontSize:
                    CupertinoDropboxTheme.calloutStyle.fontSize! * _textScale,
                color: CupertinoDropboxTheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // PAGE CONTENT
  // -------------------------------------------------------------

  Widget _buildPageContent(Map<String, dynamic> p) {
    return ScaleTransition(
      scale: _cardAnimation,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24 * _scale),
        child: Column(
          children: [
            SizedBox(height: 50 * _scale),

            /// ✦ Feature card
            CupertinoDropboxCard(
              padding: EdgeInsets.all(32 * _scale),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: 300 * _scale),

                child: Column(
                  children: [
                    Container(
                      width: 80 * _scale,
                      height: 80 * _scale,
                      decoration: BoxDecoration(
                        color: p['color'].withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20 * _scale),
                      ),
                      child: Icon(
                        p['icon'],
                        color: p['color'],
                        size: 40 * _scale,
                      ),
                    ),

                    SizedBox(height: 24 * _scale),

                    Text(
                      p['title'],
                      style: CupertinoDropboxTheme.title2Style.copyWith(
                        fontSize:
                            CupertinoDropboxTheme.title2Style.fontSize! *
                            _textScale,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: 16 * _scale),

                    Text(
                      p['subtitle'],
                      style: CupertinoDropboxTheme.calloutStyle.copyWith(
                        fontSize:
                            CupertinoDropboxTheme.calloutStyle.fontSize! *
                            _textScale,
                        color: CupertinoDropboxTheme.textSecondary,
                        height: 1.35,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 48 * _scale),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // BOTTOM NAVIGATION (DOTS + BUTTON)
  // -------------------------------------------------------------

  Widget _buildBottomNavigation() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24 * _scale),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              pages.length,
              (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: i == _page ? 24 * _scale : 8 * _scale,
                height: 8 * _scale,
                margin: EdgeInsets.symmetric(horizontal: 4 * _scale),
                decoration: BoxDecoration(
                  color: i == _page
                      ? CupertinoDropboxTheme.primary
                      : CupertinoDropboxTheme.gray300,
                  borderRadius: BorderRadius.circular(4 * _scale),
                ),
              ),
            ),
          ),

          SizedBox(height: 32 * _scale),

          CupertinoDropboxButton(
            onPressed: nextPage,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _page == pages.length - 1 ? "Get Started" : "Continue",
                  style: CupertinoDropboxTheme.headlineStyle.copyWith(
                    fontSize:
                        CupertinoDropboxTheme.headlineStyle.fontSize! *
                        _textScale,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 8 * _scale),
                Icon(
                  CupertinoIcons.arrow_right,
                  color: Colors.white,
                  size: 18 * _scale,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
