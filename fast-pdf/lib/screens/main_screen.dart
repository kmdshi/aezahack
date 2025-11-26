import 'package:flutter/material.dart';
import 'document_edit_screen.dart';
import 'settings_screen.dart';
import 'scan_screen.dart';
import '../widgets/file_item.dart';
import '../widgets/delete_dialog.dart';
import '../widgets/file_actions_menu.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  bool showDeleteDialog = false;
  bool showFileActions = false;
  TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            _buildSearchBar(),
            const SizedBox(height: 20),
            _buildFilesList(),
          ],
        ),
      ),
      floatingActionButton: Container(
        width: 60,
        height: 60,
        margin: const EdgeInsets.only(bottom: 20),
        decoration: const BoxDecoration(
          color: Color(0xFF007AFF),
          shape: BoxShape.circle,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(30),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ScanScreen()),
              );
            },
            child: Container(
              width: 24,
              height: 24,
              margin: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildAppBar() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFF3A3A3C),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SettingsScreen()),
                  );
                },
                child: Container(
                  width: 16,
                  height: 16,
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ),
          const Expanded(
            child: Center(
              child: Text(
                'Main',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFF3A3A3C),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Container(
              width: 16,
              height: 16,
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF3A3A3C),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    margin: const EdgeInsets.only(left: 12, right: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[500],
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: searchController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: 'Search',
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 16),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 50,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF3A3A3C),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.grey[500],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 4),
                const Text(
                  'Date',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilesList() {
    return Expanded(
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Example',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(right: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Today',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              FileItem(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const DocumentEditScreen()),
                  );
                },
                onLongPress: () {
                  setState(() {
                    showFileActions = true;
                  });
                },
              ),
              if (!showDeleteDialog && !showFileActions)
                const Expanded(
                  child: Center(
                    child: Text(
                      'Press the button to scan',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          if (showDeleteDialog)
            DeleteDialog(
              onCancel: () {
                setState(() {
                  showDeleteDialog = false;
                });
              },
              onDelete: () {
                setState(() {
                  showDeleteDialog = false;
                });
              },
            ),
          if (showFileActions)
            FileActionsMenu(
              onSave: () {
                setState(() {
                  showFileActions = false;
                });
              },
              onShare: () {
                setState(() {
                  showFileActions = false;
                });
              },
              onEdit: () {
                setState(() {
                  showFileActions = false;
                });
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const DocumentEditScreen()),
                );
              },
              onDelete: () {
                setState(() {
                  showFileActions = false;
                  showDeleteDialog = true;
                });
              },
              onClose: () {
                setState(() {
                  showFileActions = false;
                });
              },
            ),
        ],
      ),
    );
  }
}