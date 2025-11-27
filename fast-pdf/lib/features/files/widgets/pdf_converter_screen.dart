// Full Flutter UI with BLoC + file picker

import 'dart:io';
import 'dart:typed_data';
import 'package:archive/archive.dart';
import 'package:fast_pdf/core/widgets/appbar.dart';
import 'package:fast_pdf/core/widgets/button_widget.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import 'package:path_provider/path_provider.dart';
import 'package:fast_pdf/features/files/blocs/converter/convert_bloc.dart';
import 'package:fast_pdf/features/files/blocs/converter/convert_state.dart';
import 'package:toastification/toastification.dart';

class PdfConverterScreen extends StatefulWidget {
  const PdfConverterScreen({super.key});

  @override
  State<PdfConverterScreen> createState() => _PdfConverterScreenState();
}

class _PdfConverterScreenState extends State<PdfConverterScreen> {
  File? pickedFile;

  Future<void> _pickFile(BuildContext context) async {
    final res = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg', 'txt'],
    );

    if (res == null) return;

    final paths = res.files.map((f) => f.path).whereType<String>().toList();

    if (paths.isEmpty) return;

    final exts = paths.map((p) => p.split('.').last.toLowerCase()).toSet();

    if (exts.contains('pdf') || exts.contains('txt')) {
      if (paths.length > 1) {
        toastification.show(
          type: ToastificationType.error,
          context: context,
          title: Text('PDF / TXT можно выбрать только один.'),
          autoCloseDuration: const Duration(seconds: 5),
        );

        return;
      }

      pickedFile = File(paths.first);
      context.read<PdfConverterBloc>().add(ConvertFileEvent(pickedFile!));
      setState(() {});
      return;
    }

    final allowedImageExts = {'png', 'jpg', 'jpeg'};
    final isAllImages = exts.every((e) => allowedImageExts.contains(e));

    if (isAllImages) {
      final files = paths.map((p) => File(p)).toList();

      context.read<PdfConverterBloc>().add(ConvertMultipleImagesEvent(files));
      setState(() {});
      return;
    }

    toastification.show(
      type: ToastificationType.error,
      context: context,
      title: Text('Нельзя смешивать типы файлов.'),
      autoCloseDuration: const Duration(seconds: 5),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 16,
              left: 0,
              right: 0,
              child: CustomAppBar(
                titleWidget: Text(
                  "FILES CONVERTER",
                  style: TextStyle(color: Colors.white),
                ),
                left: ButtonWidget(
                  asset: 'assets/images/icons/cross.svg',
                  onTap: () {
                    context.read<PdfConverterBloc>().add(ResetConverterEvent());
                    Navigator.pop(context);
                  },
                ),
                right: ButtonWidget(
                  asset: 'assets/images/icons/done.svg',
                  iconSize: 10,
                  onTap: () async {
                    final state = context.read<PdfConverterBloc>().state;

                    if (state is! FileConverted) return;

                    if (state.type == ConvertedType.pdf) {
                      final dir = await FilePicker.platform.getDirectoryPath();
                      if (dir == null) return;

                      final savePath =
                          "$dir/converted_${DateTime.now().millisecondsSinceEpoch}.pdf";

                      await File(savePath).writeAsBytes(state.bytes);

                      toastification.show(
                        type: ToastificationType.success,
                        context: context,
                        title: Text('PDF Saved successfully!'),
                        autoCloseDuration: const Duration(seconds: 5),
                      );
                    }

                    if (state.type == ConvertedType.images) {
                      await saveImagesAsZip(state.images!);
                      toastification.show(
                        type: ToastificationType.success,
                        context: context,
                        title: Text('ZIP Saved successfully!'),
                        autoCloseDuration: const Duration(seconds: 5),
                      );
                    }
                  },
                ),
              ),
            ),

            Center(
              child: BlocBuilder<PdfConverterBloc, PdfConverterState>(
                builder: (context, state) {
                  if (state is PdfConverterLoading) {
                    return const CircularProgressIndicator();
                  }

                  if (state is PdfPdfToImagesDone) {
                    return Container(
                      height: 435,
                      width: 322,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: PageView(
                        children: state.images
                            .map(
                              (img) => Image.memory(img, fit: BoxFit.contain),
                            )
                            .toList(),
                      ),
                    );
                  }

                  if (state is FileConverted) {
                    return Container(
                      height: 435,
                      width: 322,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white,
                      ),
                      child: const Text(
                        "File converted! Tap to the check to save it.",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }

                  return Container(
                    alignment: Alignment.center,
                    height: 435,
                    width: 322,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  );
                },
              ),
            ),

            Positioned(
              bottom: 20,
              left: MediaQuery.of(context).size.width / 2 - 45,
              child: InkWell(
                onTap: () => _pickFile(context),
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: const BoxDecoration(
                    color: Color(0xFF55A4FF),
                    shape: BoxShape.circle,
                  ),
                  child: SvgPicture.asset(
                    'assets/images/icons/save.svg',
                    fit: BoxFit.scaleDown,
                    width: 32,
                    height: 32,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<String> saveImagesAsZip(List<Uint8List> images) async {
  final archive = Archive();

  for (int i = 0; i < images.length; i++) {
    archive.addFile(ArchiveFile('page_$i.png', images[i].length, images[i]));
  }

  final zipData = ZipEncoder().encode(archive);

  Directory dir;

  if (Platform.isIOS) {
    dir = await getApplicationDocumentsDirectory();
  } else {
    dir =
        (await getDownloadsDirectory()) ??
        await getApplicationDocumentsDirectory();
  }
  final savePath =
      "${dir.path}/converted_${DateTime.now().millisecondsSinceEpoch}.zip";

  final file = File(savePath);
  await file.writeAsBytes(zipData);

  return savePath;
}
