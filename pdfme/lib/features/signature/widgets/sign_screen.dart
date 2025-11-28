import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pdf_app/core/services/notifier.dart';
import 'package:pdf_app/core/widgets/sign_block.dart';
import 'package:pdf_app/features/files/widgets/signatures_bottom.dart';
import 'package:pdf_app/features/signature/widgets/create_new_sign.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SingScreen extends StatefulWidget {
  const SingScreen({super.key});

  @override
  State<SingScreen> createState() => _SingScreenState();
}

class _SingScreenState extends State<SingScreen> {
  List<SignatureItem> signatures = [];

  @override
  void initState() {
    super.initState();
    _loadSignatures();

    GlobalStreamController.stream.listen((update) {
      if (update) {
        _loadSignatures();
      }
    });
  }

  Future<void> _loadSignatures() async {
    final prefs = await SharedPreferences.getInstance();

    int counter = prefs.getInt("signature_counter") ?? 0;
    List<SignatureItem> list = [];

    for (int i = 1; i <= counter; i++) {
      String? b64 = prefs.getString("signature_$i");
      if (b64 != null) {
        list.add(SignatureItem(i, Uint8List.fromList(base64Decode(b64))));
      }
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

              SignatureListWidget(
                title: "Favourite signatures",
                signatures: signatures.map((e) => e.bytes).toList(),
                onSignatureTap: (sign, index) {
                  final id = signatures[index].id;
                  Navigator.of(context).push(
                    CupertinoPageRoute(
                      builder: (_) => NewSignatureScreen(
                        savedSignature: sign,
                        savedSignatureId: id,
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),

              SignatureListWidget(
                title: "Recent signatures",
                signatures: signatures.map((e) => e.bytes).toList(),
                onSignatureTap: (sign, index) {
                  final id = signatures[index].id;
                  Navigator.of(context).push(
                    CupertinoPageRoute(
                      builder: (_) => NewSignatureScreen(
                        savedSignature: sign,
                        savedSignatureId: id,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
