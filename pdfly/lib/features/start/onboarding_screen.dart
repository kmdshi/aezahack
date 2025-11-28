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

  final List<Map<String, dynamic>> pages = [
    {
      "title": "Scan Documents",
      "subtitle": "Point your camera at any document to capture it. The app automatically detects edges and saves it as a high-quality PDF.",
      "image": "assets/images/start/onb_1.png",
      "icon": CupertinoIcons.doc_text_viewfinder,
      "color": CupertinoDropboxTheme.primary,
    },
    {
      "title": "Convert Files", 
      "subtitle": "Select photos or documents from your gallery, choose the output format, and instantly convert to PDF or other formats.",
      "image": "assets/images/start/onb_2.png",
      "icon": CupertinoIcons.arrow_2_circlepath,
      "color": CupertinoDropboxTheme.success,
    },
    {
      "title": "Edit & Annotate",
      "subtitle": "Open any PDF file to highlight text, add notes, insert images, or reorder pages with intuitive editing tools.",
      "image": "assets/images/start/onb_3.png",
      "icon": CupertinoIcons.pencil,
      "color": CupertinoDropboxTheme.warning,
    },
    {
      "title": "Digital Signatures",
      "subtitle": "Create your digital signature once and apply it to any document. Sign contracts and forms securely.",
      "image": "assets/images/start/onb_4.png",
      "icon": CupertinoIcons.signature,
      "color": Colors.purple,
    },
    {
      "title": "Organize Files",
      "subtitle": "Create folders and organize your documents. All files are stored securely on your device.",
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

    return Scaffold(
      backgroundColor: CupertinoDropboxTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // Clean navigation header
            _buildHeader(),

            // Main content
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (page) {
                  setState(() => _page = page);
                  _cardAnimController.reset();
                  _cardAnimController.forward();
                },
                itemCount: pages.length,
                itemBuilder: (context, index) => _buildPageContent(pages[index]),
              ),
            ),

            // Bottom navigation
            _buildBottomNavigation(),
            
            const SizedBox(height: CupertinoDropboxTheme.spacing32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(CupertinoDropboxTheme.spacing16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: prevPage,
            child: const Icon(
              CupertinoIcons.back,
              color: CupertinoDropboxTheme.textSecondary,
              size: 28,
            ),
          ),
          
          // Page indicator
          Text(
            "${_page + 1} of ${pages.length}",
            style: CupertinoDropboxTheme.calloutStyle.copyWith(
              color: CupertinoDropboxTheme.textSecondary,
            ),
          ),
          
          // Skip button
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () => Navigator.pushReplacement(
              context,
              CupertinoPageRoute(builder: (_) => const RootScreen()),
            ),
            child: Text(
              "Skip",
              style: CupertinoDropboxTheme.calloutStyle.copyWith(
                color: CupertinoDropboxTheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageContent(Map<String, dynamic> pageData) {
    return ScaleTransition(
      scale: _cardAnimation,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: CupertinoDropboxTheme.spacing24,
        ),
        child: Column(
          children: [
            const SizedBox(height: CupertinoDropboxTheme.spacing40),
            
            // Feature card
            CupertinoDropboxCard(
              padding: const EdgeInsets.all(CupertinoDropboxTheme.spacing32),
              child: Column(
                children: [
                  // Icon
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: pageData['color'].withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      pageData['icon'],
                      color: pageData['color'],
                      size: 40,
                    ),
                  ),
                  
                  const SizedBox(height: CupertinoDropboxTheme.spacing24),
                  
                  // Title
                  Text(
                    pageData['title'],
                    style: CupertinoDropboxTheme.title2Style,
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: CupertinoDropboxTheme.spacing16),
                  
                  // Description
                  Text(
                    pageData['subtitle'],
                    style: CupertinoDropboxTheme.calloutStyle.copyWith(
                      color: CupertinoDropboxTheme.textSecondary,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: CupertinoDropboxTheme.spacing48),
            
            // Image placeholder (since actual images might not be available)
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: CupertinoDropboxTheme.gray100,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: CupertinoDropboxTheme.cardBorder,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    pageData['icon'],
                    color: CupertinoDropboxTheme.gray400,
                    size: 48,
                  ),
                  const SizedBox(height: CupertinoDropboxTheme.spacing8),
                  Text(
                    "Feature Preview",
                    style: CupertinoDropboxTheme.footnoteStyle.copyWith(
                      color: CupertinoDropboxTheme.gray500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: CupertinoDropboxTheme.spacing24,
      ),
      child: Column(
        children: [
          // Page dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              pages.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: index == _page ? 24 : 8,
                height: 8,
                margin: const EdgeInsets.symmetric(
                  horizontal: CupertinoDropboxTheme.spacing4,
                ),
                decoration: BoxDecoration(
                  color: index == _page 
                    ? CupertinoDropboxTheme.primary
                    : CupertinoDropboxTheme.gray300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: CupertinoDropboxTheme.spacing32),
          
          // Continue button
          CupertinoDropboxButton(
            onPressed: nextPage,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _page == pages.length - 1 ? "Get Started" : "Continue",
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
      ),
    );
  }
}