import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';
import 'package:pdf_app/features/files/blocs/pdf_editor/pdf_editor_bloc.dart';

class ReorderPagesScreen extends StatefulWidget {
  const ReorderPagesScreen({super.key});

  @override
  _ReorderPagesScreenState createState() => _ReorderPagesScreenState();
}

class _ReorderPagesScreenState extends State<ReorderPagesScreen> {
  late List<Uint8List> _localPages = [];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final w = size.width;
    final h = size.height;

    final double topBtn = w * 0.15; // 62 → адапт.
    final double topPadding = h * 0.015;
    final double pagePadding = w * 0.03;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: SvgPicture.asset(
                'assets/images/bg_line.svg',
                fit: BoxFit.cover,
              ),
            ),

            /// ---- TOP BAR ----
            Positioned(
              top: topPadding,
              left: 0,
              right: 0,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: w * 0.04),
                child: Row(
                  children: [
                    // CLOSE BUTTON
                    LiquidGlassLayer(
                      settings: LiquidGlassSettings(glassColor: Colors.white),
                      child: LiquidGlass(
                        shape: LiquidRoundedSuperellipse(borderRadius: 200),
                        child: SizedBox(
                          width: topBtn,
                          height: topBtn,
                          child: IconButton(
                            icon: Icon(
                              CupertinoIcons.xmark,
                              size: w * 0.07,
                              color: const Color(0xFF383838),
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                      ),
                    ),

                    const Spacer(),

                    // TITLE
                    Text(
                      'Reorder',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: w * 0.065,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const Spacer(),

                    // CHECK BUTTON
                    LiquidGlassLayer(
                      settings: LiquidGlassSettings(glassColor: Colors.white),
                      child: LiquidGlass(
                        shape: LiquidRoundedSuperellipse(borderRadius: 200),
                        child: SizedBox(
                          width: topBtn,
                          height: topBtn,
                          child: IconButton(
                            icon: SvgPicture.asset(
                              'assets/images/icons/check.svg',
                              width: w * 0.06,
                              height: w * 0.06,
                            ),
                            onPressed: () {
                              context.read<PdfEditorBloc>().add(
                                ReorderPagesEvent(_localPages),
                              );
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            /// ---- GRID ----
            Positioned(
              top: topBtn + h * 0.04,
              left: 0,
              right: 0,
              bottom: 0,
              child: BlocBuilder<PdfEditorBloc, PdfEditorState>(
                builder: (context, state) {
                  if (state is! PdfEditorLoaded) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (_localPages.isEmpty) {
                    _localPages = List.from(state.pages);
                  }

                  /// Количество колонок адаптивное:
                  int crossAxis = w < 380 ? 2 : (w < 700 ? 3 : 4);

                  return Padding(
                    padding: EdgeInsets.all(pagePadding),
                    child: ReorderableGridView.builder(
                      itemCount: _localPages.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxis,
                        mainAxisSpacing: w * 0.04,
                        crossAxisSpacing: w * 0.04,
                        childAspectRatio: 0.68,
                      ),
                      onReorder: (oldIndex, newIndex) {
                        setState(() {
                          final movedPage = _localPages.removeAt(oldIndex);
                          _localPages.insert(newIndex, movedPage);
                        });
                      },
                      itemBuilder: (_, index) {
                        final numberSize = w * 0.09;

                        return Stack(
                          key: ValueKey(index),
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(w * 0.02),
                                child: Image.memory(
                                  _localPages[index],
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),

                            /// NUMBER CIRCLE
                            Positioned(
                              top: w * 0.02,
                              right: -w * 0.03,
                              child: Container(
                                width: numberSize,
                                height: numberSize,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.black,
                                    width: 1,
                                  ),
                                  color: Colors.white,
                                ),
                                child: Center(
                                  child: Text(
                                    "${index + 1}",
                                    style: TextStyle(
                                      fontSize: w * 0.045,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF55A4FF),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
