import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pdf/widgets.dart' as pw;

class AIScreen extends StatefulWidget {
  const AIScreen({super.key});

  @override
  State<AIScreen> createState() => _AIScreenState();
}

class _AIScreenState extends State<AIScreen> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> messages = [
    {"role": "ai", "text": "Hey! How can I help you today?"},
  ];
  bool isLoading = false;

  Future<String> generateStyledPdf(String filename, String rawText) async {
    final pdf = pw.Document();

    final fontData = await rootBundle.load(
      "assets/fonts/Roboto/Roboto-Black.ttf",
    );
    final ttf = pw.Font.ttf(fontData);

    final lines = rawText.split('\n');

    pdf.addPage(
      pw.MultiPage(
        margin: const pw.EdgeInsets.all(20),
        build: (context) => parseMarkdownLines(lines, ttf),
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final file = File("${dir.path}/$filename");
    await file.writeAsBytes(await pdf.save());
    return file.path;
  }

  Future<String?> saveToUserFolder(String filename, List<int> bytes) async {
    final folder = await FilePicker.platform.getDirectoryPath();
    if (folder == null) return null;
    final file = File("$folder/$filename");
    await file.writeAsBytes(bytes);
    return file.path;
  }

  Widget buildMessage(Map<String, dynamic> msg) {
    switch (msg["role"]) {
      case "user":
        return Align(
          alignment: Alignment.centerRight,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7,
            ),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.black.withOpacity(.2)),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(msg["text"]),
            ),
          ),
        );

      case "ai":
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset('assets/images/ai_logo.png', width: 40, height: 40),
              const SizedBox(width: 8),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.7,
                ),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFF1E0FF), Color(0xFFE4DDFF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        child: Text(
                          msg["text"],
                          style: const TextStyle(color: Color(0xFF383838)),
                        ),
                      ),
                      if (msg["isLoading"] ?? false)
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: SvgPicture.asset('assets/images/loading.svg'),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );

      case "file":
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset('assets/images/ai_logo.png', width: 40, height: 40),
              const SizedBox(width: 8),

              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.7,
                ),
                child: InkWell(
                  onTap: () async {
                    final folder = await FilePicker.platform.getDirectoryPath();
                    if (folder == null) return;

                    final file = File("$folder/${msg['filename']}");
                    await file.writeAsBytes(msg['bytes']);

                    await OpenFilex.open(file.path);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFFF1E0FF), Color(0xFFE4DDFF)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      msg["filename"],
                      style: const TextStyle(
                        color: Color(0xFF55A4FF), // голубой цвет
                        decoration: TextDecoration
                            .underline, // подчеркивание только тут
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );

      default:
        return const SizedBox.shrink();
    }
  }

  Future<void> sendMessage(String text) async {
    setState(() {
      messages.add({"role": "user", "text": text});
      messages.add({"role": "ai", "text": "Thinking...", "isLoading": true});
      isLoading = true;
    });

    final response = await OpenAI.instance.chat.create(
      model: "gpt-4.1-mini",
      messages: [
        OpenAIChatCompletionChoiceMessageModel(
          role: OpenAIChatMessageRole.user,
          content: [
            OpenAIChatCompletionChoiceMessageContentItemModel.text('''
Создай уникальный документ по теме:

"$text"

Требования:
- Тема документа — только подсказка, текст уникальный.
- Структура Markdown: заголовки #, списки -, таблицы |, параграфы.
- Не включать JSON, код или объяснения.
- Разбей на главы, подпункты, таблицы или списки.
'''),
          ],
        ),
      ],
    );

    final rawText = response.choices.first.message.content?.first.text ?? "";

    final filename = "document_${DateTime.now().millisecondsSinceEpoch}.pdf";
    final internalPath = await generateStyledPdf(filename, rawText);
    final bytes = await File(internalPath).readAsBytes();

    setState(() {
      final loadingIndex = messages.indexWhere(
        (m) => m["text"] == "Thinking..." && m["role"] == "ai",
      );

      if (loadingIndex != -1) {
        messages[loadingIndex] = {
          "role": "file",
          "filename": filename,
          "internalPath": internalPath,
          "bytes": bytes,
        };
      }

      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    final double topBtnSize = w * 0.15;
    final double bottomInputHeight = 70;
    final double bottomOffset = bottomInputHeight + 16;

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
              top: h * 0.02 + topBtnSize + 16,
              left: 0,
              right: 0,
              bottom: bottomOffset,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (_, i) => buildMessage(messages[i]),
                ),
              ),
            ),

            // Верхний блок (AppBar)
            Positioned(
              top: h * 0.02,
              left: 0,
              right: 0,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: w * 0.04),
                child: Row(
                  children: [
                    SizedBox(width: topBtnSize), // пустое место слева
                    Expanded(
                      child: Center(
                        child: Text(
                          'PDF Me',
                          style: TextStyle(
                            fontSize: w * 0.065,
                            color: const Color(0xFF383838),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    LiquidGlassLayer(
                      settings: LiquidGlassSettings(glassColor: Colors.white),
                      child: LiquidGlass(
                        shape: LiquidRoundedSuperellipse(borderRadius: 100),
                        child: SizedBox(
                          width: topBtnSize,
                          height: topBtnSize,
                          child: IconButton(
                            icon: SvgPicture.asset(
                              'assets/images/icons/refresh.svg',
                              fit: BoxFit.cover,
                            ),
                            onPressed: () async {
                              setState(() {
                                messages = [];
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Positioned(
              bottom: 106,
              left: 8,
              right: 8,
              child: LiquidGlassLayer(
                child: LiquidGlass(
                  shape: LiquidRoundedSuperellipse(borderRadius: 30),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            onEditingComplete: () {
                              final text = _controller.text.trim();
                              if (text.isNotEmpty) {
                                _controller.clear();
                                sendMessage(text);
                              }
                            },
                            decoration: const InputDecoration(
                              hintText: "Write to PDF Me",
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<pw.Widget> parseMarkdownLines(List<String> lines, pw.Font ttf) {
    List<pw.Widget> widgets = [];
    List<List<String>> tableBuffer = [];

    void flushTable() {
      if (tableBuffer.isEmpty) return;
      widgets.add(
        pw.Table.fromTextArray(
          headers: tableBuffer.first,
          data: tableBuffer.sublist(1),
          border: pw.TableBorder.all(),
          headerStyle: pw.TextStyle(font: ttf, fontWeight: pw.FontWeight.bold),
          cellStyle: pw.TextStyle(font: ttf),
          cellAlignment: pw.Alignment.centerLeft,
        ),
      );
      tableBuffer.clear();
      widgets.add(pw.SizedBox(height: 10));
    }

    for (var line in lines) {
      if (line.startsWith('#')) {
        flushTable();
        int level = 0;
        while (level < line.length && line[level] == '#') {
          level++;
        }
        final text = line.substring(level).trim();
        widgets.add(
          pw.Header(
            level: level > 2 ? 2 : level,
            text: text,
            textStyle: pw.TextStyle(font: ttf),
          ),
        );
      } else if (line.startsWith('- ')) {
        flushTable();
        widgets.add(
          pw.Bullet(
            text: line.substring(2).trim(),
            style: pw.TextStyle(font: ttf),
          ),
        );
      } else if (line.startsWith('|')) {
        tableBuffer.add(
          line
              .split('|')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList(),
        );
      } else {
        flushTable();
        widgets.add(
          pw.Paragraph(
            text: line.trim(),
            style: pw.TextStyle(font: ttf),
          ),
        );
      }
    }

    flushTable();
    return widgets;
  }
}
