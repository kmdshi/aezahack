import 'package:fast_pdf/features/start/welcome_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fast_pdf/core/widgets/root_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _page = 0;

  final List<Map<String, String>> pages = [
    {
      "title": "Scan Documents",
      "subtitle":
          "Point your camera at a document to capture. The app will automatically detect edges and save it as a PDF",
      "image": "assets/images/start/onb_1.png",
    },
    {
      "title": "Convert Files",
      "subtitle":
          'Select a photo or document from your gallery, choose the output format, and tap "Convert" to change the file type',
      "image": "assets/images/start/onb_2.png",
    },
    {
      "title": "Edit & Annotate",
      "subtitle":
          "Open any PDF file and use the bottom toolbar to highlight text, add notes, or reorder pages",
      "image": "assets/images/start/onb_3.png",
    },
    {
      "title": "Create & Apply Signature",
      "subtitle":
          "Draw your signature on the screen to save it. Drag and drop it onto any document to sign instantly",
      "image": "assets/images/start/onb_4.png",
    },
    {
      "title": "Organize with Folders",
      "subtitle":
          "Create custom folders and drag your documents into them to keep your files sorted and easy to find",
      "image": "assets/images/start/onb_5.png",
    },
  ];

  void nextPage() {
    if (_page < pages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      Navigator.pushReplacement(
        context,
        CupertinoPageRoute(builder: (_) => RootScreen()),
      );
    }
  }

  void prevPage() {
    if (_page == 0) {
      Navigator.pop(context);
      return;
    }
    if (_page > 0) {
      _controller.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final double w = size.width;
    final double h = size.height;

    // адаптивные размеры
    final double titleSize = w * 0.08; // ~30–34
    final double subtitleSize = w * 0.045; // ~16–18
    final double topBtnSize = w * 0.12;
    final double horizontalPadding = w * 0.06;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/welcome.png', fit: BoxFit.cover),
          ),

          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: Row(
                    children: [
                      Container(
                        width: topBtnSize,
                        height: topBtnSize,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: prevPage,
                            child: Center(
                              child: SvgPicture.asset(
                                'assets/images/icons/back.svg',
                                width: w * 0.05,
                              ),
                            ),
                          ),
                        ),
                      ),

                      Expanded(
                        child: Center(
                          child: Text(
                            "${_page + 1}/${pages.length}",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: w * 0.06,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: w * 0.08,
                            vertical: w * 0.03,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            CupertinoPageRoute(builder: (_) => RootScreen()),
                          );
                        },
                        child: Text(
                          "Skip",
                          style: TextStyle(
                            fontSize: w * 0.045,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: h * 0.015),

                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    onPageChanged: (i) => setState(() => _page = i),
                    itemCount: pages.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: EdgeInsets.fromLTRB(
                          horizontalPadding,
                          h * 0.02,
                          horizontalPadding,
                          h * 0.13,
                        ),
                        child: Column(
                          children: [
                            Expanded(
                              child: Center(
                                child: Image.asset(
                                  pages[index]["image"]!,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              pages[index]["title"]!,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: titleSize,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),

                            SizedBox(height: h * 0.015),

                            Text(
                              pages[index]["subtitle"]!,
                              style: TextStyle(
                                fontSize: subtitleSize,
                                color: Colors.white60,
                              ),
                              textAlign: TextAlign.center,
                            ),

                            SizedBox(height: h * 0.03),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            left: horizontalPadding,
            right: horizontalPadding,
            bottom: h * 0.04,
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF55A4FF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  elevation: 0,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: h * 0.02),
                ),
                onPressed: nextPage,
                child: Text(
                  (_page == pages.length - 1) ? "Start" : "Continue",
                  style: TextStyle(
                    fontSize: w * 0.05,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
