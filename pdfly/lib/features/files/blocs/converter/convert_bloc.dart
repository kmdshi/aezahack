import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:fast_pdf/features/files/blocs/converter/convert_state.dart';
import 'package:pdfx/pdfx.dart';

part 'convert_event.dart';

class PdfConverterBloc extends Bloc<PdfConverterEvent, PdfConverterState> {
  PdfConverterBloc() : super(PdfConverterInitial()) {
    on<ConvertFileEvent>(_onConvertFile);
    on<ConvertMultipleImagesEvent>(_onConvertMultipleImages);
    on<ResetConverterEvent>(_idle);
  }

  Future<void> _idle(
    ResetConverterEvent event,
    Emitter<PdfConverterState> emit,
  ) async {
    emit(PdfConverterInitial());
  }

  Future<void> _onConvertMultipleImages(
    ConvertMultipleImagesEvent event,
    Emitter<PdfConverterState> emit,
  ) async {
    final pdf = pw.Document();

    for (final f in event.files) {
      final bytes = await f.readAsBytes();
      final img = pw.MemoryImage(bytes);

      pdf.addPage(
        pw.Page(
          build: (_) => pw.Center(child: pw.Image(img, fit: pw.BoxFit.contain)),
        ),
      );
    }

    final result = await pdf.save();
    emit(FileConverted.pdf(result));
  }

  Future<void> _onConvertFile(
    ConvertFileEvent event,
    Emitter<PdfConverterState> emit,
  ) async {
    emit(PdfConverterLoading());

    final ext = event.file.path.split('.').last.toLowerCase();

    try {
      if (ext == 'pdf') {
        final pdfDoc = await PdfDocument.openFile(event.file.path);
        List<Uint8List> pages = [];

        for (int i = 1; i <= pdfDoc.pagesCount; i++) {
          final page = await pdfDoc.getPage(i);
          final img = await page.render(width: page.width, height: page.height);
          pages.add(img!.bytes);
          await page.close();
        }

        emit(FileConverted.images(pages));
        return;
      }

      final pdf = pw.Document();

      if (ext == 'txt') {
        final text = await event.file.readAsString();
        pdf.addPage(pw.Page(build: (_) => pw.Center(child: pw.Text(text))));
      } else {
        final bytes = await event.file.readAsBytes();
        final img = pw.MemoryImage(bytes);

        pdf.addPage(
          pw.Page(
            build: (_) =>
                pw.Center(child: pw.Image(img, fit: pw.BoxFit.contain)),
          ),
        );
      }

      final result = await pdf.save();

      emit(FileConverted.pdf(result));
    } catch (e) {
      emit(ConversionError(e.toString()));
    }
  }
}
