part of 'scan_bloc.dart';

@immutable
sealed class ScanEvent {}

class ScanFileReceivedEvent extends ScanEvent {
  final Uint8List pdfBytes;
  final int pages;
  ScanFileReceivedEvent(this.pdfBytes, this.pages);
}

class ExportPdfEvent extends ScanEvent {}

class ScanIdleEvent extends ScanEvent {}
