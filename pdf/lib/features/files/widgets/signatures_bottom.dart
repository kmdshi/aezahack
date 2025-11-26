import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pdf_app/core/widgets/sign_block.dart';
import 'package:shared_preferences/shared_preferences.dart';

void showSignatureSelector({
  required BuildContext context,
  required Function(Uint8List, int) onSignatureSelected,
}) {
  showModalBottomSheet(
    backgroundColor: Colors.white,
    context: context,
    builder: (context) {
      return FutureBuilder<List<SignatureItem>>(
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
                      signatures: signatures.map((e) => e.bytes).toList(),
                      onSignatureTap: (sign, index) {
                        final realId = signatures[index].id;

                        onSignatureSelected(sign, realId);
                        Navigator.pop(context);
                      },
                    ),
                    SizedBox(height: 10),
                    SignatureListWidget(
                      title: "Recent signatures",
                      signatures: signatures.map((e) => e.bytes).toList(),
                      onSignatureTap: (sign, index) {
                        final realId = signatures[index].id;

                        onSignatureSelected(sign, realId);
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

Future<List<SignatureItem>> _loadSavedSignatures() async {
  final prefs = await SharedPreferences.getInstance();
  final signatureCount = prefs.getInt('signature_counter') ?? 0;

  final List<SignatureItem> signatures = [];

  for (int i = 1; i <= signatureCount; i++) {
    final base64Str = prefs.getString('signature_$i');
    if (base64Str != null) {
      signatures.add(
        SignatureItem(i, Uint8List.fromList(base64Decode(base64Str))),
      );
    }
  }

  return signatures;
}

class SignatureItem {
  final int id;
  final Uint8List bytes;

  SignatureItem(this.id, this.bytes);
}
