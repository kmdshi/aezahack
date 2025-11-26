// Full Flutter UI with BLoC + file picker

import 'dart:io';
import 'dart:typed_data';
import 'package:archive/archive.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf_app/features/files/blocs/converter/convert_bloc.dart';
import 'package:pdf_app/features/files/blocs/converter/convert_state.dart';

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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("PDF / TXT можно выбрать только один.")),
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

      context.read<PdfConverterBloc>().add(
        ConvertMultipleImagesEvent(files),
      ); 
      setState(() {});
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Нельзя смешивать типы файлов.")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: SvgPicture.asset(
                'assets/images/bg_line.svg',
                fit: BoxFit.cover,
              ),
            ),

            Positioned(
              top: 16,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    LiquidGlassLayer(
                      settings: LiquidGlassSettings(glassColor: Colors.white),
                      child: LiquidGlass(
                        shape: LiquidRoundedSuperellipse(borderRadius: 100),
                        child: SizedBox(
                          width: 62,
                          height: 62,
                          child: IconButton(
                            icon: const Icon(
                              CupertinoIcons.xmark,
                              size: 24,
                              color: Color(0xFF383838),
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    const Text(
                      'PDF Converter',
                      style: TextStyle(
                        fontSize: 26,
                        color: Color(0xFF383838),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    LiquidGlassLayer(
                      settings: LiquidGlassSettings(glassColor: Colors.white),
                      child: LiquidGlass(
                        shape: LiquidRoundedSuperellipse(borderRadius: 100),
                        child: SizedBox(
                          width: 62,
                          height: 62,
                          child: IconButton(
                            icon: SvgPicture.asset(
                              'assets/images/icons/check.svg',
                              fit: BoxFit.cover,
                              color: Color(0xFF55A4FF),
                            ),
                            onPressed: () async {
                              final state = context
                                  .read<PdfConverterBloc>()
                                  .state;

                              if (state is! FileConverted) return;

                              if (state.type == ConvertedType.pdf) {
                                final dir = await FilePicker.platform
                                    .getDirectoryPath();
                                if (dir == null) return;

                                final savePath =
                                    "$dir/converted_${DateTime.now().millisecondsSinceEpoch}.pdf";

                                await File(savePath).writeAsBytes(state.bytes);

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("PDF saved to $savePath"),
                                  ),
                                );
                              }

                              if (state.type == ConvertedType.images) {
                                final zipPath = await saveImagesAsZip(
                                  state.images!,
                                );

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("ZIP saved to: $zipPath"),
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
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
                      image: const DecorationImage(
                        image: AssetImage(
                          'assets/images/actions/import_conv.png',
                        ),
                        fit: BoxFit.cover,
                      ),
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
                    'assets/images/icons/import.svg',
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

  final downloads = await getDownloadsDirectory();
  final savePath =
      "${downloads!.path}/converted_${DateTime.now().millisecondsSinceEpoch}.zip";

  final file = File(savePath);
  await file.writeAsBytes(zipData);

  return savePath;
}
