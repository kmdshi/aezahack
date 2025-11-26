import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pdf_app/core/widgets/sign_block.dart';
import 'package:shared_preferences/shared_preferences.dart';

void showSignatureSelector({
  required BuildContext context,
  required Function(Uint8List) onSignatureSelected,
}) {
  showModalBottomSheet(
    backgroundColor: Colors.white,
    context: context,
    builder: (context) {
      return FutureBuilder<List<Uint8List>>(
        future: _loadSavedSignatures(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("Нет сохранённых подписей"));
          }

          final signatures = snapshot.data!;

          return Column(
            children: [
              SizedBox(height: 10),
              Container(
                height: 4,
                width: 50,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Expanded(
                child: ListView(
                  children: [
                    SignatureListWidget(
                      title: "Favourite signatures",
                      signatures: signatures,
                      onSignatureTap: (sign) {
                        onSignatureSelected(sign);
                        Navigator.pop(context);
                      },
                    ),
                    SizedBox(height: 10),
                    SignatureListWidget(
                      title: "Recent signatures",
                      signatures: signatures,
                      onSignatureTap: (sign) {
                        onSignatureSelected(sign);
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      );
    },
  );
}

Future<List<Uint8List>> _loadSavedSignatures() async {
  final prefs = await SharedPreferences.getInstance();
  final signatureCount = prefs.getInt('signature_counter') ?? 0;
  final List<Uint8List> signatures = [];

  for (int i = 0; i <= signatureCount; i++) {
    String? signatureBase64 = prefs.getString('signature_$i');
    if (signatureBase64 != null) {
      signatures.add(Uint8List.fromList(base64Decode(signatureBase64)));
    }
  }

  return signatures;
}
