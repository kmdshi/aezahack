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
import 'package:pdf_app/core/widgets/pop_up.dart';
import 'package:pdf_app/features/files/blocs/converter/convert_bloc.dart';
import 'package:pdf_app/features/files/blocs/converter/convert_state.dart';
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
          title: Text("PDF / TXT можно выбрать только один."),
          autoCloseDuration: Duration(seconds: 3),
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
      title: Text("Нельзя смешивать типы файлов."),
      autoCloseDuration: Duration(seconds: 3),
    );
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    final double btnSize = w * 0.16;
    final double topBtnSize = w * 0.15;
    final double previewW = w * 0.8;
    final double previewH = h * 0.5;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            /// BACKGROUND
            Positioned.fill(
              child: SvgPicture.asset(
                'assets/images/bg_line.svg',
                fit: BoxFit.cover,
              ),
            ),

            /// TOP BAR
            Positioned(
              top: h * 0.02,
              left: 0,
              right: 0,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: w * 0.04),
                child: Row(
                  children: [
                    LiquidGlassLayer(
                      settings: LiquidGlassSettings(glassColor: Colors.white),
                      child: LiquidGlass(
                        shape: LiquidRoundedSuperellipse(borderRadius: 100),
                        child: SizedBox(
                          width: topBtnSize,
                          height: topBtnSize,
                          child: IconButton(
                            icon: Icon(
                              CupertinoIcons.xmark,
                              size: w * 0.06,
                              color: const Color(0xFF383838),
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                      ),
                    ),

                    const Spacer(),

                    Text(
                      'Converter',
                      style: TextStyle(
                        fontSize: w * 0.065,
                        color: const Color(0xFF383838),
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const Spacer(),

                    LiquidGlassLayer(
                      settings: LiquidGlassSettings(glassColor: Colors.white),
                      child: LiquidGlass(
                        shape: LiquidRoundedSuperellipse(borderRadius: 100),
                        child: SizedBox(
                          width: topBtnSize,
                          height: topBtnSize,
                          child: IconButton(
                            icon: SvgPicture.asset(
                              'assets/images/icons/check.svg',
                              fit: BoxFit.cover,
                              color: const Color(0xFF55A4FF),
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

                                toastification.show(
                                  title: Text(
                                    'PDF saved to files successfully!',
                                  ),
                                );
                              }

                              if (state.type == ConvertedType.images) {
                                await saveImagesAsZip(state.images!);

                                toastification.show(
                                  type: ToastificationType.success,
                                  title: Text(
                                    'ZIP saved to files successfully!',
                                  ),
                                  autoCloseDuration: Duration(seconds: 3),
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

            /// CONTENT (CENTER)
            Center(
              child: BlocBuilder<PdfConverterBloc, PdfConverterState>(
                builder: (context, state) {
                  if (state is PdfConverterLoading) {
                    return const CircularProgressIndicator();
                  }

                  if (state is PdfPdfToImagesDone) {
                    return Container(
                      height: previewH,
                      width: previewW,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(w * 0.03),
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
                      height: previewH,
                      width: previewW,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(w * 0.04),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 12,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: EdgeInsets.symmetric(horizontal: w * 0.06),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check_circle_rounded,
                            size: w * 0.18,
                            color: Colors.blueAccent,
                          ),
                          SizedBox(height: w * 0.04),
                          Text(
                            "Conversion Complete",
                            style: TextStyle(
                              fontSize: w * 0.06,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: w * 0.015),
                          Text(
                            "Tap the check button below to save your file.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: w * 0.04,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return Container(
                    height: previewH,
                    width: previewW,
                    decoration: BoxDecoration(
                      image: const DecorationImage(
                        image: AssetImage(
                          'assets/images/actions/import_conv.png',
                        ),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.circular(w * 0.03),
                    ),
                  );
                },
              ),
            ),

            /// IMPORT BUTTON
            Positioned(
              bottom: h * 0.03,
              left: w / 2 - btnSize / 2,
              child: InkWell(
                onTap: () => _pickFile(context),
                child: Container(
                  width: btnSize,
                  height: btnSize,
                  decoration: const BoxDecoration(
                    color: Color(0xFF55A4FF),
                    shape: BoxShape.circle,
                  ),
                  child: SvgPicture.asset(
                    'assets/images/icons/import.svg',
                    fit: BoxFit.scaleDown,
                    width: btnSize * 0.4,
                    height: btnSize * 0.4,
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
