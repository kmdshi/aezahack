import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';
import 'package:pdf_app/features/files/blocs/pdf_editor/pdf_editor_bloc.dart';

class ReorderPagesScreen extends StatelessWidget {
  const ReorderPagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Порядок страниц")),

      body: BlocBuilder<PdfEditorBloc, PdfEditorState>(
        builder: (context, state) {
          if (state is! PdfEditorLoaded) {
            return const Center(child: CircularProgressIndicator());
          }

          final pages = state.pages;

          return Padding(
            padding: const EdgeInsets.all(12.0),

            child: ReorderableGridView.builder(
              itemCount: pages.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, 
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.7,
              ),

              onReorder: (oldIndex, newIndex) {
                context.read<PdfEditorBloc>().add(
                  ReorderPagesEvent(oldIndex, newIndex),
                );
              },

              itemBuilder: (_, index) {
                return Card(
                  key: ValueKey(index),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Image.memory(pages[index], fit: BoxFit.contain),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
