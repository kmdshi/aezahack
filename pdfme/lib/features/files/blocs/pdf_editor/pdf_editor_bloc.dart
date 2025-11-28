import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:image/image.dart' as img;
import 'package:pdf_app/core/services/files_history.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart' as spdf;
import 'package:pdfx/pdfx.dart' as pdfx;
import 'dart:ui' as ui;

part 'pdf_editor_event.dart';
part 'pdf_editor_state.dart';

class PdfEditorBloc extends Bloc<PdfEditorEvent, PdfEditorState> {
  PdfEditorBloc() : super(PdfEditorInitial()) {
    on<LoadPdfIdleEvent>(_idlePdf);
    on<LoadPdfEvent>(_onLoadPdf);
    on<ReorderPagesEvent>(_onReorder);
    on<DeletePageEvent>(_onDelete);
    on<RenamePdfEvent>(_onRename);
    on<ExportPdfEvent>(_onExport);
    on<CropPageEvent>(_onCropPage);
    on<CopyPageEvent>(_onCopyPage);
    on<AddSignatureEvent>(_onAddSignature);
    on<LoadPdfFromPathEvent>(_onLoadPdfFromPath);
  }

  Future<void> _onLoadPdfFromPath(
    LoadPdfFromPathEvent event,
    Emitter<PdfEditorState> emit,
  ) async {
    emit(PdfEditorLoading());

    try {
      final doc = await pdfx.PdfDocument.openFile(event.path);

      final pages = <Uint8List>[];

      for (int i = 1; i <= doc.pagesCount; i++) {
        final page = await doc.getPage(i);

        final rendered = await page.render(
          width: page.width,
          height: page.height,
          format: pdfx.PdfPageImageFormat.png,
        );

        pages.add(rendered!.bytes);
      }

      await RecentFilesService.add(event.path);

      emit(
        PdfEditorLoaded(
          pdfBytes: await File(event.path).readAsBytes(),
          pages: pages,
          fileName: event.path.split('/').last.replaceAll('.pdf', ''),
        ),
      );
    } catch (e) {
      emit(PdfEditorError("Не удалось открыть PDF: $e"));
    }
  }

  void _onAddSignature(
    AddSignatureEvent event,
    Emitter<PdfEditorState> emit,
  ) async {
    final currentState = state;
    if (currentState is! PdfEditorLoaded) return;

    try {
      emit(PdfEditorLoading());

      final document = spdf.PdfDocument(inputBytes: currentState.pdfBytes);

      final page = document.pages[document.pages.count - 1];
      final image = spdf.PdfBitmap(event.signature);

      final pageSize = page.getClientSize();

      const signatureWidth = 200.0;
      const signatureHeight = 100.0;

      const margin = 20.0;

      final dx = pageSize.width - signatureWidth - margin;
      final dy = pageSize.height - signatureHeight - margin;

      page.graphics.drawImage(
        image,
        Rect.fromLTWH(dx, dy, signatureWidth, signatureHeight),
      );

      final updatedPdfBytes = Uint8List.fromList(await document.save());
      document.dispose();

      final doc = await pdfx.PdfDocument.openData(updatedPdfBytes);
      final newPages = <Uint8List>[];

      for (int i = 1; i <= doc.pagesCount; i++) {
        final pdfPage = await doc.getPage(i);

        final rendered = await pdfPage.render(
          width: pdfPage.width,
          height: pdfPage.height,
          format: pdfx.PdfPageImageFormat.png,
        );

        newPages.add(rendered!.bytes);
      }

      emit(
        PdfEditorLoaded(
          pages: newPages,
          pdfBytes: updatedPdfBytes,
          fileName: currentState.fileName,
        ),
      );
    } catch (e) {
      emit(PdfEditorError("Ошибка при добавлении подписи: $e"));
    }
  }

  Future<void> _onCopyPage(
    CopyPageEvent event,
    Emitter<PdfEditorState> emit,
  ) async {
    final currentState = state;
    if (currentState is! PdfEditorLoaded) return;

    try {
      final page = currentState.pages[event.index];
      final copiedPage = Uint8List.fromList(page);

      final updatedPages = List<Uint8List>.from(currentState.pages);
      updatedPages.add(copiedPage);
      final updatedPdf = await _rebuildPdfFromPages(updatedPages);

      emit(
        PdfEditorLoaded(
          pdfBytes: updatedPdf,
          pages: updatedPages,
          fileName: currentState.fileName,
        ),
      );
    } catch (e) {
      emit(PdfEditorError("Ошибка при копировании страницы: $e"));
    }
  }

  Future<void> _idlePdf(
    LoadPdfIdleEvent event,
    Emitter<PdfEditorState> emit,
  ) async {
    emit(PdfEditorInitial());
  }

  Future<void> _onCropPage(
    CropPageEvent event,
    Emitter<PdfEditorState> emit,
  ) async {
    final currentState = state;

    if (currentState is! PdfEditorLoaded) return;

    try {
      final original = img.decodeImage(event.original);
      if (original == null) {
        emit(PdfEditorError("Не удалось декодировать страницу"));
        return;
      }

      final x = event.cropRect.left.toInt();
      final y = event.cropRect.top.toInt();
      final w = event.cropRect.width.toInt();
      final h = event.cropRect.height.toInt();

      final safeX = x.clamp(0, original.width - 1);
      final safeY = y.clamp(0, original.height - 1);
      final safeW = w.clamp(1, original.width - safeX);
      final safeH = h.clamp(1, original.height - safeY);

      final cropped = img.copyCrop(
        original,
        x: safeX,
        y: safeY,
        width: safeW,
        height: safeH,
      );

      final croppedBytes = Uint8List.fromList(img.encodePng(cropped));

      final updatedPages = List<Uint8List>.from(currentState.pages);
      updatedPages[event.index] = croppedBytes;
      final updatedPdf = await _rebuildPdfFromPages(updatedPages);

      emit(
        PdfEditorLoaded(
          pdfBytes: updatedPdf,
          pages: updatedPages,
          fileName: currentState.fileName,
        ),
      );
    } catch (e) {
      emit(PdfEditorError("Ошибка при обрезке страницы: $e"));
    }
  }

  Future<void> _onLoadPdf(
    LoadPdfEvent event,
    Emitter<PdfEditorState> emit,
  ) async {
    emit(PdfEditorLoading());

    try {
      final doc = await pdfx.PdfDocument.openData(event.pdfBytes);

      final pages = <Uint8List>[];

      for (int i = 1; i <= doc.pagesCount; i++) {
        final page = await doc.getPage(i);

        final rendered = await page.render(
          width: page.width,
          height: page.height,
          format: pdfx.PdfPageImageFormat.png,
        );

        pages.add(rendered!.bytes);
      }
      emit(
        PdfEditorLoaded(
          pdfBytes: event.pdfBytes,
          pages: pages,
          fileName: event.fileName,
        ),
      );
    } catch (e) {
      emit(PdfEditorError("Не удалось загрузить PDF: $e"));
    }
  }

  Future<void> _onReorder(
    ReorderPagesEvent event,
    Emitter<PdfEditorState> emit,
  ) async {
    if (state is! PdfEditorLoaded) return;

    final s = state as PdfEditorLoaded;
    final pages = List<Uint8List>.from(event.pages);

    final updatedPdf = await _rebuildPdfFromPages(pages);

    emit(s.copyWith(pdfBytes: updatedPdf, pages: pages));
  }

  Future<void> _onDelete(
    DeletePageEvent event,
    Emitter<PdfEditorState> emit,
  ) async {
    if (state is! PdfEditorLoaded) return;

    final s = state as PdfEditorLoaded;

    if (event.index < 0 || event.index >= s.pages.length) {
      emit(PdfEditorError("Неправильный индекс страницы"));
      return;
    }

    final pages = List<Uint8List>.from(s.pages)..removeAt(event.index);

    if (pages.isEmpty) {
      emit(PdfEditorInitial());
      return;
    }

    final updatedPdf = await _rebuildPdfFromPages(pages);
    emit(s.copyWith(pdfBytes: updatedPdf, pages: pages));
  }

  Future<void> _onRename(
    RenamePdfEvent event,
    Emitter<PdfEditorState> emit,
  ) async {
    if (state is! PdfEditorLoaded) return;

    final s = state as PdfEditorLoaded;

    emit(s.copyWith(fileName: event.newName));
  }

  Future<void> _onExport(
    ExportPdfEvent event,
    Emitter<PdfEditorState> emit,
  ) async {
    if (state is! PdfEditorLoaded) return;

    try {
      final s = state as PdfEditorLoaded;
      final pdf = pw.Document();
      for (final pageImg in s.pages) {
        final decoded = await _decodeImage(pageImg);

        final w = decoded.width.toDouble();
        final h = decoded.height.toDouble();

        final img = pw.MemoryImage(pageImg);

        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat(w, h),
            margin: pw.EdgeInsets.zero,
            build: (_) => pw.Image(img, fit: pw.BoxFit.fill),
          ),
        );
      }

      final bytes = await pdf.save();
      emit(PdfExported(bytes, s.fileName));
    } catch (e) {
      emit(PdfEditorError("Ошибка экспорта PDF: $e"));
    }
  }

  Future<ui.Image> _decodeImage(Uint8List bytes) async {
    try {
      if (bytes.isEmpty) {
        throw Exception("Полученные данные изображения пусты.");
      }

      final buffer = await ui.ImmutableBuffer.fromUint8List(bytes);
      final descriptor = await ui.ImageDescriptor.encoded(buffer);
      final codec = await descriptor.instantiateCodec();
      final frame = await codec.getNextFrame();

      return frame.image;
    } catch (e) {
      throw Exception("Ошибка при декодировании изображения: $e");
    }
  }

  Future<Uint8List> _rebuildPdfFromPages(List<Uint8List> pngPages) async {
    final pdf = pw.Document();

    for (final pageImg in pngPages) {
      final decoded = await _decodeImage(pageImg);

      final w = decoded.width.toDouble();
      final h = decoded.height.toDouble();

      final imgProvider = pw.MemoryImage(pageImg);

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat(w, h),
          margin: pw.EdgeInsets.zero,
          build: (_) => pw.Image(imgProvider, fit: pw.BoxFit.fill),
        ),
      );
    }

    return Uint8List.fromList(await pdf.save());
  }
}
