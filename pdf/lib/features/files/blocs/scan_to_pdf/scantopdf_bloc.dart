import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pdf/widgets.dart' as pw;

part 'scantopdf_event.dart';
part 'scantopdf_state.dart';

class ScantopdfBloc extends Bloc<ScantopdfEvent, ScantopdfState> {
  ScantopdfBloc() : super(ScantopdfInitial()) {
    on<InitCameraEvent>(_onInitCamera);
    on<TakePhotoEvent>(_onTakePhoto);
    on<CropPhotoEvent>(_onCropPhoto);
    on<MultiplePhotosPickedEvent>(_onMultiplePhotosPicked);
    on<CreatePdfEvent>(_onCreatePdf);
    on<ScanFileReceivedEvent>(_onScanFileReceived);
  }

  Future<void> _onScanFileReceived(
    ScanFileReceivedEvent event,
    Emitter<ScantopdfState> emit,
  ) async {
    emit(PdfCreatedState(event.pdfBytes, 1));
  }

  Future<void> _onMultiplePhotosPicked(
    MultiplePhotosPickedEvent event,
    Emitter<ScantopdfState> emit,
  ) async {
    final pdfBytes = await _generatePdfFromImages(event.bytesList);

    emit(PdfCreatedState(pdfBytes, event.bytesList.length));
  }

  Future<void> _onInitCamera(
    InitCameraEvent event,
    Emitter<ScantopdfState> emit,
  ) async {
    emit(CameraReadyState());
  }

  Future<void> _onTakePhoto(
    TakePhotoEvent event,
    Emitter<ScantopdfState> emit,
  ) async {
    emit(PhotoTakenState(event.bytes));
  }

  Future<void> _onCropPhoto(
    CropPhotoEvent event,
    Emitter<ScantopdfState> emit,
  ) async {
    emit(PhotoCroppedState(event.bytes));

    final pdfBytes = await _generatePdfFromImages([event.bytes]);

    emit(PdfCreatedState(pdfBytes, 1));
  }

  Future<void> _onCreatePdf(
    CreatePdfEvent event,
    Emitter<ScantopdfState> emit,
  ) async {
    emit(PdfCreatedState(event.pdfBytes, 0));
  }

  Future<Uint8List> _generatePdfFromImages(
    List<Uint8List> imageBytesList,
  ) async {
    final pdf = pw.Document();

    for (var imageBytes in imageBytesList) {
      final image = pw.MemoryImage(imageBytes);

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Center(child: pw.Image(image));
          },
        ),
      );
    }

    return pdf.save();
  }
}
