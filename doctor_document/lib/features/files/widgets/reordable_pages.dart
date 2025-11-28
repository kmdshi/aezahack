import 'dart:typed_data';

import 'package:fast_pdf/core/theme/cupertino_dropbox_theme.dart';
import 'package:fast_pdf/core/widgets/appbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';
import 'package:fast_pdf/features/files/blocs/pdf_editor/pdf_editor_bloc.dart';

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
      backgroundColor: CupertinoDropboxTheme.background,
      appBar: CustomAppBar.dropboxAppBar(
        title: "Reorder Pages",
        onBack: () => Navigator.pop(context),
        actions: [
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () {
              context.read<PdfEditorBloc>().add(
                ReorderPagesEvent(_localPages),
              );
              Navigator.pop(context);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: CupertinoDropboxTheme.spacing12,
                vertical: CupertinoDropboxTheme.spacing6,
              ),
              decoration: BoxDecoration(
                color: CupertinoDropboxTheme.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "Done",
                style: CupertinoDropboxTheme.footnoteStyle.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: CupertinoDropboxTheme.spacing16),
        ],
      ),
      body: BlocBuilder<PdfEditorBloc, PdfEditorState>(
        builder: (context, state) {
          if (state is! PdfEditorLoaded) {
            return const Center(
              child: CupertinoActivityIndicator(
                color: CupertinoDropboxTheme.primary,
              ),
            );
          }

          if (_localPages.isEmpty) {
            _localPages = List.from(state.pages);
          }

          return Column(
            children: [
              // Instructions
              Container(
                padding: const EdgeInsets.all(CupertinoDropboxTheme.spacing16),
                child: Column(
                  children: [
                    Text(
                      "Drag to Reorder",
                      style: CupertinoDropboxTheme.title3Style,
                    ),
                    const SizedBox(height: CupertinoDropboxTheme.spacing4),
                    Text(
                      "Hold and drag pages to change their order",
                      style: CupertinoDropboxTheme.calloutStyle.copyWith(
                        color: CupertinoDropboxTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Grid
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: CupertinoDropboxTheme.spacing16,
                  ),
                  child: ReorderableGridView.builder(
                    itemCount: _localPages.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.7,
                    ),
                    onReorder: (oldIndex, newIndex) {
                      setState(() {
                        final movedPage = _localPages.removeAt(oldIndex);
                        _localPages.insert(newIndex, movedPage);
                      });
                    },
                    itemBuilder: (_, index) {
                      return Container(
                        key: ValueKey(index),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: CupertinoDropboxTheme.cardShadow,
                        ),
                        child: Stack(
                          children: [
                            // Page image
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.all(
                                  CupertinoDropboxTheme.spacing8,
                                ),
                                child: Image.memory(
                                  _localPages[index],
                                  fit: BoxFit.contain,
                                  width: double.infinity,
                                  height: double.infinity,
                                ),
                              ),
                            ),
                            
                            // Page number badge
                            Positioned(
                              top: CupertinoDropboxTheme.spacing8,
                              right: CupertinoDropboxTheme.spacing8,
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: CupertinoDropboxTheme.primary,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    (index + 1).toString(),
                                    style: CupertinoDropboxTheme.footnoteStyle.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            
                            // Drag handle indicator
                            Positioned(
                              bottom: CupertinoDropboxTheme.spacing8,
                              right: CupertinoDropboxTheme.spacing8,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: CupertinoDropboxTheme.gray100,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Icon(
                                  CupertinoIcons.move,
                                  size: 16,
                                  color: CupertinoDropboxTheme.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
              
              const SizedBox(height: CupertinoDropboxTheme.spacing16),
            ],
          );
        },
      ),
    );
  }
}