import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:meta/meta.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;

part 'scantopdf_event.dart';
part 'scantopdf_state.dart';

class ScantopdfBloc extends Bloc<ScantopdfEvent, ScantopdfState> {
  ScantopdfBloc() : super(ScantopdfInitial()) {
    on<InitCameraEvent>(_onInitCamera);
    on<TakePhotoEvent>(_onTakePhoto);
    on<CropPhotoEvent>(_onCropPhoto);
    on<CreatePdfEvent>(_onCreatePdf);
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
    final text = await _extractTextFromBytes(event.bytes);

    final pdfBytes = await _generatePdfFromText(text);

    emit(PdfCreatedState(pdfBytes));
  }

  Future<void> _onCreatePdf(
    CreatePdfEvent event,
    Emitter<ScantopdfState> emit,
  ) async {
    emit(PdfCreatedState(event.pdfBytes));
  }

  Future<Uint8List> _generatePdfFromText(String text) async {
    final pdf = pw.Document();

    final font = pw.Font.ttf(
      await rootBundle.load("assets/fonts/Roboto/Roboto-Black.ttf"),
    );

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(16),
            child: pw.Text(text, style: pw.TextStyle(font: font, fontSize: 20)),
          );
        },
      ),
    );

    return pdf.save();
  }

  Future<String> _extractTextFromBytes(Uint8List bytes) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/scan_ocr.jpg')
        ..writeAsBytesSync(bytes);

      final inputImage = InputImage.fromFilePath(tempFile.path);

      final textRecognizer = TextRecognizer(
        script: TextRecognitionScript.latin,
      );

      final recognizedText = await textRecognizer.processImage(inputImage);

      await textRecognizer.close();

      return recognizedText.text;
    } catch (e, st) {
      debugPrint("OCR ERROR: $e\n$st");
      return "";
    }
  }
}
