part of 'pdf_editor_bloc.dart';

@immutable
sealed class PdfEditorState {}

final class PdfEditorInitial extends PdfEditorState {}

final class PdfEditorLoading extends PdfEditorState {}

final class PdfEditorLoaded extends PdfEditorState {
  final Uint8List? pdfBytes;
  final List<Uint8List> pages;
  final String fileName;
  final int currentPageIndex;

  PdfEditorLoaded({
    this.pdfBytes,
    required this.pages,
    required this.fileName,
    required this.currentPageIndex,
  });

  PdfEditorLoaded copyWith({
    Uint8List? pdfBytes,
    List<Uint8List>? pages,
    String? fileName,
    int? currentPageIndex,
  }) {
    return PdfEditorLoaded(
      pdfBytes: pdfBytes ?? this.pdfBytes,
      currentPageIndex: currentPageIndex ?? this.currentPageIndex,
      pages: pages ?? this.pages,
      fileName: fileName ?? this.fileName,
    );
  }
}

final class PdfExported extends PdfEditorState {
  final Uint8List pdfBytes;
  final String? filename;

  PdfExported(this.pdfBytes, this.filename);
}

final class PdfEditorError extends PdfEditorState {
  final String message;

  PdfEditorError(this.message);
}
