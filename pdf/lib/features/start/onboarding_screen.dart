import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pdf_app/core/widgets/root_screen.dart';

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
    if (_page < 4) {
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
    if (_page > 0) {
      _controller.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: Stack(
        children: [
          Positioned.fill(
            child: SvgPicture.asset(
              "assets/images/bg_line.svg",
              fit: BoxFit.cover,
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Material(
                        color: Colors.white,
                        shape: const CircleBorder(),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: prevPage,
                          child: SizedBox(
                            width: w * 0.15,
                            height: w * 0.15,
                            child: const Icon(
                              CupertinoIcons.back,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),

                      Expanded(
                        child: Center(
                          child: Text(
                            "${_page + 1}/5",
                            style: const TextStyle(
                              color: Color(0xFF383838),
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      Material(
                        color: Colors.white,
                        shape: const CircleBorder(),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () => Navigator.pushReplacement(
                            context,
                            CupertinoPageRoute(builder: (_) => RootScreen()),
                          ),
                          child: Container(
                            width: w * 0.27,
                            height: w * 0.15,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: const Center(
                              child: Text(
                                "Skip",
                                style: TextStyle(
                                  color: Colors.blueAccent,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    onPageChanged: (i) => setState(() => _page = i),
                    itemCount: pages.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(24, 10, 24, 25),
                        child: Column(
                          children: [
                            Text(
                              pages[index]["title"]!,
                              style: const TextStyle(
                                color: Color(0xFF383838),
                                fontSize: 32,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),

                            const SizedBox(height: 12),

                            Text(
                              pages[index]["subtitle"]!,
                              style: const TextStyle(
                                fontSize: 18,
                                color: Color(0xFFB2B2B2),
                              ),
                              textAlign: TextAlign.center,
                            ),

                            const SizedBox(height: 20),

                            Expanded(
                              child: Center(
                                child: Image.asset(
                                  pages[index]["image"]!,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
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
            left: 24,
            right: 24,
            bottom: 24,
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
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: nextPage,
                child: Text(
                  (_page >= 3) ? "Start" : "Continue",
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
