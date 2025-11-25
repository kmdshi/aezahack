import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pdf_app/features/signature/widgets/create_new_sign.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SingScreen extends StatefulWidget {
  const SingScreen({super.key});

  @override
  State<SingScreen> createState() => _SingScreenState();
}

class _SingScreenState extends State<SingScreen> {
  @override
  void initState() {
    super.initState();
    _loadSignatures();
  }

  List<Uint8List> signatures = [];

  Future<void> _loadSignatures() async {
    final prefs = await SharedPreferences.getInstance();

    int counter = prefs.getInt("signature_counter") ?? 0;
    List<Uint8List> list = [];

    for (int i = 1; i <= counter; i++) {
      String? b64 = prefs.getString("signature_$i");
      if (b64 != null) list.add(base64Decode(b64));
    }

    setState(() => signatures = list);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: SvgPicture.asset(
              'assets/images/bg_line.svg',
              fit: BoxFit.cover,
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),

              const Padding(
                padding: EdgeInsets.only(left: 18.0),
                child: Text(
                  "Signature",
                  style: TextStyle(
                    fontSize: 32,
                    color: Color(0xFF383838),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              _signatureBlock("Favourite signatures"),

              const SizedBox(height: 24),

              _signatureBlock("Recent signatures"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _signatureBlock(String title) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            offset: const Offset(0, 6),
            blurRadius: 14,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF383838),
              ),
            ),
            const SizedBox(height: 12),

            SizedBox(
              height: 110,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: signatures.length,
                itemBuilder: (context, index) {
                  final sing = signatures[index];
                  return InkWell(
                    onTap: () => Navigator.of(context).push(
                      CupertinoPageRoute(
                        builder: (_) =>
                            NewSignatureScreen(savedSignature: sing),
                      ),
                    ),
                    child: Container(
                      width: 120,
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Color(0xFFF5F6FA),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Image.memory(sing, fit: BoxFit.contain),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
