import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pdf_app/features/files/widgets/edit_pdf_screen.dart';
import 'package:pdf_app/features/files/widgets/scan_to_pdf_screen.dart';

class ActionsGroupWidget extends StatefulWidget {
  const ActionsGroupWidget({super.key});

  @override
  State<ActionsGroupWidget> createState() => _ActionsGroupWidgetState();
}

class _ActionsGroupWidgetState extends State<ActionsGroupWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => Navigator.of(
            context,
          ).push(CupertinoPageRoute(builder: (_) => ScanToPdfScreen())),
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withOpacity(0.15)),
              image: const DecorationImage(
                image: AssetImage("assets/images/actions/scan.png"),
                fit: BoxFit.cover,
              ),
            ),
            child: SizedBox.expand(),
          ),
        ),

        const SizedBox(height: 24),

        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => Navigator.of(
                  context,
                ).push(CupertinoPageRoute(builder: (_) => EditPdfScreen())),
                child: Container(
                  height: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.white.withOpacity(0.15)),
                    image: const DecorationImage(
                      image: AssetImage("assets/images/actions/edit.png"),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: SizedBox.expand(),
                ),
              ),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: GestureDetector(
                onTap: () => Navigator.of(
                  context,
                ).push(CupertinoPageRoute(builder: (_) => EditPdfScreen())),
                child: Container(
                  height: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.white.withOpacity(0.15)),
                    image: const DecorationImage(
                      image: AssetImage("assets/images/actions/convert.png"),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: const Center(child: SizedBox.expand()),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
