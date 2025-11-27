import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';

part 'scan_event.dart';
part 'scan_state.dart';

class ScanBloc extends Bloc<ScanEvent, ScanState> {
  ScanBloc() : super(ScanInitial()) {
    on<ScanFileReceivedEvent>(_onScanFileReceived);
    on<ExportPdfEvent>(_onExport);
  }

  Future<void> _onScanFileReceived(
    ScanFileReceivedEvent event,
    Emitter<ScanState> emit,
  ) async {
    emit(PdfCreatedState(event.pdfBytes, event.pages));
  }

  Future<void> _onExport(ExportPdfEvent event, Emitter<ScanState> emit) async {
    final current = state;
    if (current is! PdfCreatedState) return;

    emit(PdfExportingState());
    try {
      emit(PdfExportSuccessState(current.pdfBytes, ''));
    } catch (e) {
      emit(ScanErrorState("Ошибка экспорта PDF: $e"));
    }
  }
}
