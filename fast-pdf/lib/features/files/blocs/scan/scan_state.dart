part of 'scan_bloc.dart';

@immutable
sealed class ScanState {}

final class ScanInitial extends ScanState {}

final class PdfCreatingState extends ScanState {}

final class PdfCreatedState extends ScanState {
  final Uint8List pdfBytes;
  final int pages;
  PdfCreatedState(this.pdfBytes, this.pages);
}

final class PdfExportingState extends ScanState {}

final class PdfExportSuccessState extends ScanState {
  final Uint8List pdfBytes;
  final String? filename;

  PdfExportSuccessState(this.pdfBytes, this.filename);
}

final class ScanErrorState extends ScanState {
  final String message;
  ScanErrorState(this.message);
}
