import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pdf_app/core/services/files_history.dart';
import 'package:pdf_app/features/actions/widgets/actions_group_widget.dart';
import 'package:pdf_app/features/files/blocs/pdf_editor/pdf_editor_bloc.dart';
import 'package:pdf_app/features/files/widgets/edit_pdf_screen.dart';

class ActionsScreen extends StatefulWidget {
  const ActionsScreen({super.key});

  @override
  State<ActionsScreen> createState() => _ActionsScreenState();
}

class _ActionsScreenState extends State<ActionsScreen> {
  List<String> recentFiles = [];

  @override
  void initState() {
    super.initState();
    _loadRecentFiles();
  }

  Future<void> _loadRecentFiles() async {
    final files = await RecentFilesService.getRecent();
    setState(() {
      recentFiles = files;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: SvgPicture.asset(
                'assets/images/bg_line.svg',
                fit: BoxFit.cover,
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Actions",
                        style: TextStyle(
                          fontSize: 32,
                          color: Color(0xFF383838),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.search),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),
                  const Expanded(child: ActionsGroupWidget()),
                ],
              ),
            ),

            DraggableScrollableSheet(
              initialChildSize: 0.3,
              minChildSize: 0.3,
              maxChildSize: 1.0,
              expand: true,
              builder: (context, controller) {
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(24),
                        ),
                      ),
                      child: ListView(
                        controller: controller,
                        padding: const EdgeInsets.all(20),
                        children: [
                          const SizedBox(height: 12),
                          const Text(
                            "RECENT  FILES",
                            style: TextStyle(
                              fontSize: 22,
                              color: Color(0xFFB2B2B2),
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                          const SizedBox(height: 16),

                          if (recentFiles.isEmpty)
                            const Text(
                              "История пуста",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            )
                          else
                            ...recentFiles.map(
                              (path) => GestureDetector(
                                onTap: () {
                                  context.read<PdfEditorBloc>().add(
                                    LoadPdfFromPathEvent(path),
                                  );
                                  Navigator.of(context).push(
                                    CupertinoPageRoute(
                                      builder: (_) => EditPdfScreen(),
                                    ),
                                  );
                                },
                                child: pdfCard(path),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget pdfCard(String path) {
    final fileName = path.split('/').last;

    return DottedBorder(
      options: CustomPathDottedBorderOptions(
        padding: const EdgeInsets.all(8),
        color: Colors.grey,
        strokeWidth: 2,
        dashPattern: [10, 5],
        customPath: (size) {
          const radius = 16.0;

          final path = Path()
            ..moveTo(radius, 0)
            ..lineTo(size.width - radius, 0)
            ..quadraticBezierTo(size.width, 0, size.width, radius)
            ..lineTo(size.width, size.height - radius)
            ..quadraticBezierTo(
              size.width,
              size.height,
              size.width - radius,
              size.height,
            )
            ..lineTo(radius, size.height)
            ..quadraticBezierTo(0, size.height, 0, size.height - radius)
            ..lineTo(0, radius)
            ..quadraticBezierTo(0, 0, radius, 0);

          return path;
        },
      ),

      child: Container(
        height: 140,
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 110,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey.shade200,
              ),
              child: const Icon(
                Icons.picture_as_pdf,
                size: 40,
                color: Colors.red,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fileName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    path,
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
