part of 'scantopdf_bloc.dart';

@immutable
sealed class ScantopdfEvent {}

class InitCameraEvent extends ScantopdfEvent {}

class TakePhotoEvent extends ScantopdfEvent {
  final Uint8List bytes;
  TakePhotoEvent(this.bytes);
}

class CropPhotoEvent extends ScantopdfEvent {
  final Uint8List bytes;
  CropPhotoEvent(this.bytes);
}

class MultiplePhotosPickedEvent extends ScantopdfEvent {
  final List<Uint8List> bytesList;
  MultiplePhotosPickedEvent(this.bytesList);
}

class CreatePdfEvent extends ScantopdfEvent {
  final Uint8List pdfBytes;
  CreatePdfEvent(this.pdfBytes);
}
