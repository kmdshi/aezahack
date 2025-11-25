part of 'pdf_editor_bloc.dart';

@immutable
sealed class PdfEditorState {}

final class PdfEditorInitial extends PdfEditorState {}

final class PdfEditorLoading extends PdfEditorState {}

final class PdfEditorLoaded extends PdfEditorState {
  final List<Uint8List> pages; 
  final String fileName;

  PdfEditorLoaded({
    required this.pages,
    required this.fileName,
  });

  PdfEditorLoaded copyWith({
    List<Uint8List>? pages,
    String? fileName,
  }) {
    return PdfEditorLoaded(
      pages: pages ?? this.pages,
      fileName: fileName ?? this.fileName,
    );
  }
}

final class PdfExported extends PdfEditorState {
  final Uint8List pdfBytes;

  PdfExported(this.pdfBytes);
}

final class PdfEditorError extends PdfEditorState {
  final String message;

  PdfEditorError(this.message);
}
