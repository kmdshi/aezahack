part of 'scantopdf_bloc.dart';

@immutable
abstract class ScantopdfState {}

class ScantopdfInitial extends ScantopdfState {}

class CameraReadyState extends ScantopdfState {}

class PhotoTakenState extends ScantopdfState {
  final Uint8List bytes;
  PhotoTakenState(this.bytes);
}

class PhotoCroppedState extends ScantopdfState {
  final Uint8List bytes;
  PhotoCroppedState(this.bytes);
}

class PdfCreatedState extends ScantopdfState {
  final Uint8List pdfBytes;
  PdfCreatedState(this.pdfBytes);
}
