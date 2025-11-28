import 'dart:typed_data';

enum ConvertedType { pdf, images }

abstract class PdfConverterState {}

class PdfConverterInitial extends PdfConverterState {}

class PdfConverterLoading extends PdfConverterState {}

class PdfPdfToImagesDone extends PdfConverterState {
  final List<Uint8List> images;

  PdfPdfToImagesDone(this.images);
}

class FileConverted extends PdfConverterState {
  final ConvertedType type;
  final Uint8List bytes;        
  final List<Uint8List>? images; 

  FileConverted.pdf(this.bytes)
      : type = ConvertedType.pdf,
        images = null;

  FileConverted.images(this.images)
      : type = ConvertedType.images,
        bytes = Uint8List(0);
}


class ConversionError extends PdfConverterState {
  final String message;
  ConversionError(this.message);
}
