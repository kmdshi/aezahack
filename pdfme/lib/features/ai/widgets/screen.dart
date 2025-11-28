import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/services.dart';
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
  List<Map<String, dynamic>> messages = [];

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
          child: Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(msg["text"]),
          ),
        );

      case "file":
        return Align(
          alignment: Alignment.centerLeft,
          child: Card(
            margin: const EdgeInsets.all(8),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    msg["filename"],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () => OpenFilex.open(msg["internalPath"]),
                        child: const Text("Открыть"),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton(
                        onPressed: () async {
                          final path = await saveToUserFolder(
                            msg["filename"],
                            msg["bytes"],
                          );
                          if (path != null) OpenFilex.open(path);
                        },
                        child: const Text("Скачать"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );

      default:
        return Align(
          alignment: Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(msg["text"]),
          ),
        );
    }
  }

  /// Отправка сообщения модели и генерация PDF
  Future<void> sendMessage(String text) async {
    setState(() => messages.add({"role": "user", "text": text}));

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
  - Тема документа — это только подсказка, сам текст должен быть полностью уникальным.
  - Структура документа должна быть Markdown-подобной:
    - Заголовки: # Главный заголовок, ## Подзаголовок
    - Списки: начинаем строку с "- "
    - Таблицы: строки начинаются с "|" и разделяются "|"
    - Параграфы: обычный текст
  - Не добавляй какие-либо объяснения, JSON или код.
  - Не включай тему документа в текст, только создавай полноценный контент.
  - Максимально структурируй: разбей на главы, подпункты, при необходимости вставляй таблицы или списки.

'''),
          ],
        ),
      ],
    );

    final rawText = response.choices.first.message.content?.first.text ?? "";

    // Генерация PDF
    final filename = "document_${DateTime.now().millisecondsSinceEpoch}.pdf";
    final internalPath = await generateStyledPdf(filename, rawText);
    final bytes = await File(internalPath).readAsBytes();

    setState(() {
      messages.add({
        "role": "file",
        "filename": filename,
        "internalPath": internalPath,
        "bytes": bytes,
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("AI Styled PDF Chat")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (_, i) => buildMessage(messages[i]),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    hintText: "Введите сообщение...",
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: () {
                  final text = _controller.text.trim();
                  if (text.isNotEmpty) {
                    _controller.clear();
                    sendMessage(text);
                  }
                },
              ),
            ],
          ),
        ],
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
