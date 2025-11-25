import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FilesScreen extends StatefulWidget {
  const FilesScreen({super.key});

  @override
  State<FilesScreen> createState() => _FilesScreenState();
}

class _FilesScreenState extends State<FilesScreen> {
  final TextEditingController _folderController = TextEditingController();
  List<String> _folders = [];

  @override
  void initState() {
    super.initState();
    _loadFolders();
  }

  // Загрузка списка папок из SharedPreferences
  _loadFolders() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _folders = prefs.getStringList('folders') ?? [];
    });
  }

  // Добавление новой папки
  _addFolder() async {
    if (_folderController.text.isEmpty) return;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _folders.add(_folderController.text);
      prefs.setStringList('folders', _folders);
    });
    _folderController.clear();
  }

  // Поиск папки по имени
  _searchFolder(String query) {
    return _folders
        .where((folder) => folder.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(title: const Text('Files'), backgroundColor: Colors.blue),
      body: Stack(
        children: [
          Positioned.fill(
            child: SvgPicture.asset(
              'assets/images/bg_line.svg',
              fit: BoxFit.cover,
            ),
          ),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _folderController,
                  decoration: InputDecoration(
                    labelText: 'New Folder',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: _addFolder,
                child: const Text('Create Folder'),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  onChanged: (query) {
                    setState(() {});
                  },
                  decoration: InputDecoration(
                    labelText: 'Search Folder',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _searchFolder('').length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(_searchFolder('')?[index] ?? ''),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
