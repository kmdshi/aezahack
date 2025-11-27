import 'package:flutter/material.dart';
import 'scan_result_screen.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  int selectedZoom = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF4A5568),
              Color(0xFF2D3748),
              Color(0xFF1A202C),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: Center(
                  child: Container(
                    width: 280,
                    height: 400,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.4),
                          blurRadius: 25,
                          offset: const Offset(0, 15),
                        ),
                      ],
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'AEZAKMI Group — это продуктовая IT-компания полного цикла, специализирующаяся на разработке и продвижении мобильных приложений.',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 12,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Основные факты',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            '• Основная деятельность: Разработка, продвижение и монетизация iOS-приложений. Они создают продукты для международного рынка.',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 10,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            '• Достижения: Выпущено более 100 приложений. Суммарное количество скачиваний превышает 200 000 000. Приложения принесли более \$50 000 000 выручки.',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 10,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            '• Специфика: В некоторых источниках упоминается фокус на сфере iGaming (разработка приложений под гемблинг/ беттинг вертикали для арбитража трафика), а также создание веб-приложений.',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 10,
                              height: 1.3,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            width: double.infinity,
                            height: 30,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              _buildZoomControls(),
              _buildCameraControls(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
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
          const Expanded(
            child: Center(
              child: Text(
                'Scan to PDF',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 32),
        ],
      ),
    );
  }

  Widget _buildZoomControls() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildZoomButton('.5', 0.5, 0),
          const SizedBox(width: 20),
          _buildZoomButton('1x', 1, 1),
          const SizedBox(width: 20),
          _buildZoomButton('2', 2, 2),
        ],
      ),
    );
  }

  Widget _buildZoomButton(String label, double zoom, int index) {
    final isSelected = selectedZoom == index;
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF007AFF) : Colors.transparent,
        border: Border.all(
          color: isSelected ? const Color(0xFF007AFF) : Colors.white,
          width: 2,
        ),
        shape: BoxShape.circle,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            setState(() {
              selectedZoom = index;
            });
          },
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCameraControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFF3A3A3C),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            width: 24,
            height: 24,
            margin: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ),
        Container(
          width: 80,
          height: 80,
          decoration: const BoxDecoration(
            color: Color(0xFF007AFF),
            shape: BoxShape.circle,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(40),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ScanResultScreen()),
                );
              },
              child: Container(
                width: 32,
                height: 32,
                margin: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ),
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFF3A3A3C),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            width: 24,
            height: 24,
            margin: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ),
      ],
    );
  }
}