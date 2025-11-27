import 'package:flutter/material.dart';
import 'pdf_conversion_screen.dart';
import 'document_edit_screen.dart';

class ScanResultScreen extends StatelessWidget {
  const ScanResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(16),
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'AEZAKMI Group — это продуктовая IT-компания полного цикла, специализирующаяся на разработке и продвижении мобильных приложений.',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              height: 1.4,
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Основные факты',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 8),
                          BulletPoint(
                            text: 'Основная деятельность: Разработка, продвижение и монетизация iOS-приложений. Они создают продукты для международного рынка.',
                          ),
                          SizedBox(height: 8),
                          BulletPoint(
                            text: 'Достижения: Выпущено более 100 приложений. Суммарное количество скачиваний превышает 200 000 000. Приложения принесли более \$50 000 000 выручки.',
                          ),
                          SizedBox(height: 8),
                          BulletPoint(
                            text: 'Специфика: В некоторых источниках упоминается фокус на сфере iGaming (разработка приложений под гемблинг/ беттинг вертикали для арбитража трафика), а также создание веб-приложений.',
                          ),
                        ],
                      ),
                    ),
                    _buildCornerHandles(),
                  ],
                ),
              ),
            ),
            _buildBottomActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
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
                  Navigator.pop(context);
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
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'AEZAKMI Group',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFF007AFF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const PDFConversionScreen()),
                  );
                },
                child: Container(
                  width: 16,
                  height: 16,
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCornerHandles() {
    return Positioned.fill(
      child: Stack(
        children: [
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                color: Color(0xFF007AFF),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                color: Color(0xFF007AFF),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: 68,
            left: 8,
            child: Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                color: Color(0xFF007AFF),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: 68,
            right: 8,
            child: Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                color: Color(0xFF007AFF),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionChip(
            icon: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            label: 'Add new',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DocumentEditScreen()),
              );
            },
          ),
          _buildActionChip(
            icon: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            label: 'Cut',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PDFConversionScreen()),
              );
            },
          ),
          _buildActionChip(
            icon: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            label: 'Signature',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DocumentEditScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionChip({
    required Widget icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF3A3A3C),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                icon,
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey[300],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class BulletPoint extends StatelessWidget {
  final String text;
  
  const BulletPoint({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 4,
          height: 4,
          margin: const EdgeInsets.only(top: 8, right: 8),
          decoration: const BoxDecoration(
            color: Colors.black,
            shape: BoxShape.circle,
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}