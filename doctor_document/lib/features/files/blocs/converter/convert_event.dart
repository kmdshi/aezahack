part of 'convert_bloc.dart';

@immutable
abstract class PdfConverterEvent {}

class ConvertFileEvent extends PdfConverterEvent {
  final File file;
  ConvertFileEvent(this.file);
}

class ConvertMultipleImagesEvent extends PdfConverterEvent {
  final List<File> files;
  ConvertMultipleImagesEvent(this.files);
}

class ResetConverterEvent extends PdfConverterEvent {}
