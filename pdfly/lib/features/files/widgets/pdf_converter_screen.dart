import 'dart:io';
import 'dart:typed_data';
import 'package:archive/archive.dart';
import 'package:fast_pdf/core/theme/cupertino_dropbox_theme.dart';
import 'package:fast_pdf/core/widgets/cupertino_dropbox_widgets.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
    return Material(
      type: MaterialType.transparency,
      child: CupertinoPageScaffold(
        backgroundColor: CupertinoDropboxTheme.background,
        navigationBar: CupertinoNavigationBar(
          backgroundColor: CupertinoDropboxTheme.background,
          border: null,
          leading: CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () {
              context.read<PdfConverterBloc>().add(ResetConverterEvent());
              Navigator.pop(context);
            },
            child: const Icon(
              CupertinoIcons.xmark,
              color: CupertinoDropboxTheme.textSecondary,
            ),
          ),
          middle: Text(
            "File Converter",
            style: CupertinoDropboxTheme.headlineStyle,
          ),
          trailing: BlocBuilder<PdfConverterBloc, PdfConverterState>(
            builder: (context, state) {
              if (state is! FileConverted) return const SizedBox.shrink();

              return CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () async {
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
                child: const Icon(
                  CupertinoIcons.checkmark_alt,
                  color: CupertinoDropboxTheme.primary,
                ),
              );
            },
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(CupertinoDropboxTheme.spacing24),
            child: Column(
              children: [
                const SizedBox(height: CupertinoDropboxTheme.spacing32),

                // Title section
                Text(
                  "Convert Your Files",
                  style: CupertinoDropboxTheme.title1Style,
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: CupertinoDropboxTheme.spacing8),

                Text(
                  "Select files to convert between formats",
                  style: CupertinoDropboxTheme.calloutStyle.copyWith(
                    color: CupertinoDropboxTheme.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: CupertinoDropboxTheme.spacing40),

                // Main conversion area
                BlocBuilder<PdfConverterBloc, PdfConverterState>(
                  builder: (context, state) {
                    if (state is PdfConverterLoading) {
                      return Center(child: _buildLoadingState());
                    }

                    if (state is PdfPdfToImagesDone) {
                      return Center(child: _buildSuccessState());
                    }

                    if (state is FileConverted) {
                      return _buildSuccessState();
                    }

                    return Center(child: _buildInitialState());
                  },
                ),
                Spacer(),

                _buildActionButton(),

                const SizedBox(height: CupertinoDropboxTheme.spacing32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInitialState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Large upload area
        CupertinoDropboxCard(
          padding: const EdgeInsets.all(CupertinoDropboxTheme.spacing48),
          child: Column(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: CupertinoDropboxTheme.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  CupertinoIcons.arrow_2_circlepath,
                  size: 40,
                  color: CupertinoDropboxTheme.primary,
                ),
              ),

              const SizedBox(height: CupertinoDropboxTheme.spacing24),

              Text(
                "Select Files to Convert",
                style: CupertinoDropboxTheme.title3Style,
              ),

              const SizedBox(height: CupertinoDropboxTheme.spacing8),

              Text(
                "Supports PDF, PNG, JPG, JPEG, and TXT files",
                style: CupertinoDropboxTheme.footnoteStyle,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),

        const SizedBox(height: CupertinoDropboxTheme.spacing24),

        // Supported formats
        _buildSupportedFormats(),
      ],
    );
  }

  Widget _buildLoadingState() {
    return CupertinoDropboxCard(
      padding: const EdgeInsets.all(CupertinoDropboxTheme.spacing40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CupertinoActivityIndicator(
            color: CupertinoDropboxTheme.primary,
            radius: 20,
          ),

          const SizedBox(height: CupertinoDropboxTheme.spacing24),

          Text("Converting Files", style: CupertinoDropboxTheme.title3Style),

          const SizedBox(height: CupertinoDropboxTheme.spacing8),

          Text(
            "Please wait while we process your files",
            style: CupertinoDropboxTheme.calloutStyle.copyWith(
              color: CupertinoDropboxTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessState() {
    return CupertinoDropboxCard(
      padding: const EdgeInsets.all(CupertinoDropboxTheme.spacing40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: CupertinoDropboxTheme.success.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              CupertinoIcons.checkmark_alt_circle_fill,
              size: 40,
              color: CupertinoDropboxTheme.success,
            ),
          ),

          const SizedBox(height: CupertinoDropboxTheme.spacing24),

          Text(
            "Conversion Complete!",
            style: CupertinoDropboxTheme.title2Style.copyWith(
              color: CupertinoDropboxTheme.success,
            ),
          ),

          const SizedBox(height: CupertinoDropboxTheme.spacing8),

          Text(
            "Your file has been converted successfully.\nTap the checkmark to save it.",
            style: CupertinoDropboxTheme.calloutStyle.copyWith(
              color: CupertinoDropboxTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview(List<Uint8List> images) {
    return Column(
      children: [
        Text("Converted Images", style: CupertinoDropboxTheme.title2Style),

        const SizedBox(height: CupertinoDropboxTheme.spacing16),

        Expanded(
          child: CupertinoDropboxCard(
            padding: const EdgeInsets.all(CupertinoDropboxTheme.spacing8),
            child: PageView.builder(
              itemCount: images.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.all(CupertinoDropboxTheme.spacing8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.memory(images[index], fit: BoxFit.contain),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSupportedFormats() {
    final formats = [
      {"name": "PDF", "color": CupertinoDropboxTheme.error},
      {"name": "PNG", "color": CupertinoDropboxTheme.primary},
      {"name": "JPG", "color": CupertinoDropboxTheme.success},
      {"name": "TXT", "color": CupertinoDropboxTheme.warning},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: formats.map((format) {
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: CupertinoDropboxTheme.spacing12,
            vertical: CupertinoDropboxTheme.spacing8,
          ),
          decoration: BoxDecoration(
            color: (format["color"] as Color).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            format["name"] as String,
            style: CupertinoDropboxTheme.caption1Style.copyWith(
              color: format["color"] as Color,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildActionButton() {
    return CupertinoDropboxButton(
      onPressed: () => _pickFile(context),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            CupertinoIcons.folder_badge_plus,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(width: CupertinoDropboxTheme.spacing8),
          Text(
            "Select Files",
            style: CupertinoDropboxTheme.headlineStyle.copyWith(
              color: Colors.white,
            ),
          ),
        ],
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
