part of 'pdf_editor_bloc.dart';

@immutable
sealed class PdfEditorEvent {}

final class LoadPdfIdleEvent extends PdfEditorEvent {}

final class LoadPdfEvent extends PdfEditorEvent {
  final Uint8List pdfBytes;
  final String fileName;
  final String savedPath;
  LoadPdfEvent({
    required this.pdfBytes,
    required this.fileName,
    required this.savedPath,
  });
}

class LoadPdfFromPathEvent extends PdfEditorEvent {
  final String path;
  LoadPdfFromPathEvent(this.path);
}

final class ReorderPagesEvent extends PdfEditorEvent {
  final List<Uint8List> pages;

  ReorderPagesEvent(this.pages);
}

final class DeletePageEvent extends PdfEditorEvent {}

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

class CopyPageEvent extends PdfEditorEvent {}

final class UpdatePageIndex extends PdfEditorEvent {
  final int index;
  UpdatePageIndex({required this.index});
}

class AddSignatureEvent extends PdfEditorEvent {
  final Uint8List signature;

  AddSignatureEvent({required this.signature});
}
