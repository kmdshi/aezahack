part of 'pdf_editor_bloc.dart';

@immutable
sealed class PdfEditorEvent {}

final class LoadPdfIdleEvent extends PdfEditorEvent {}

final class LoadPdfEvent extends PdfEditorEvent {
  final Uint8List pdfBytes;
  final String fileName;

  LoadPdfEvent({required this.pdfBytes, required this.fileName});
}

final class ReorderPagesEvent extends PdfEditorEvent {
  final int oldIndex;
  final int newIndex;

  ReorderPagesEvent(this.oldIndex, this.newIndex);
}

final class DeletePageEvent extends PdfEditorEvent {
  final int index;

  DeletePageEvent(this.index);
}

final class RenamePdfEvent extends PdfEditorEvent {
  final String newName;

  RenamePdfEvent(this.newName);
}

final class ExportPdfEvent extends PdfEditorEvent {}

final class CropPageEvent extends PdfEditorEvent {
  final int index;
  final Rect cropRect;
  final Uint8List original;

  CropPageEvent({
    required this.index,
    required this.cropRect,
    required this.original,
  });
}

final class AddPageEvent extends PdfEditorEvent {
  final Uint8List imageBytes;

  AddPageEvent(this.imageBytes);
}
