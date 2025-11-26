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
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    LiquidGlassLayer(
                      settings: LiquidGlassSettings(glassColor: Colors.white),
                      child: LiquidGlass(
                        shape: LiquidRoundedSuperellipse(borderRadius: 100),
                        child: SizedBox(
                          width: 62,
                          height: 62,
                          child: IconButton(
                            icon: const Icon(
                              CupertinoIcons.xmark,
                              size: 24,
                              color: Color(0xFF383838),
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                      ),
                    ),
                    Spacer(),
                    Text(
                      'Reorder',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Spacer(),
                    LiquidGlassLayer(
                      settings: LiquidGlassSettings(glassColor: Colors.white),
                      child: LiquidGlass(
                        shape: LiquidRoundedSuperellipse(borderRadius: 100),
                        child: SizedBox(
                          width: 62,
                          height: 62,
                          child: IconButton(
                            icon: SvgPicture.asset(
                              'assets/images/icons/check.svg',
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
            Positioned(
              top: 80,
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

                  return Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: ReorderableGridView.builder(
                      itemCount: _localPages.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 0,
                            crossAxisSpacing: 15,
                            childAspectRatio: 0.7,
                          ),
                      onReorder: (oldIndex, newIndex) {
                        setState(() {
                          final movedPage = _localPages.removeAt(oldIndex);
                          _localPages.insert(newIndex, movedPage);
                        });
                      },
                      itemBuilder: (_, index) {
                        return Stack(
                          key: ValueKey(index),
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Image.memory(
                                  _localPages[index],
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: -10,
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.black),
                                ),
                                child: Center(
                                  child: Text(
                                    (index + 1).toString(),
                                    style: TextStyle(
                                      color: Color(0xFF55A4FF),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
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
