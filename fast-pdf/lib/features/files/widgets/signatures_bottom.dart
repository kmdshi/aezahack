import 'dart:convert';
import 'dart:typed_data';

import 'package:fast_pdf/features/signature/widgets/create_new_sign.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void showSignatureSelector({
  required BuildContext context,
  required Function(Uint8List, int) onSignatureSelected,
}) {
  showModalBottomSheet(
    backgroundColor: Colors.black,
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return FractionallySizedBox(
        heightFactor: 0.25,
        child: FutureBuilder<List<SignatureItem>>(
          future: _loadSavedSignatures(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CupertinoActivityIndicator());
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
                    padding: EdgeInsets.only(bottom: 20),
                    children: [
                      SizedBox(height: 20),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          "Saved signatures",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      SizedBox(height: 12),

                      SizedBox(
                        width: 111,
                        height: 78,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          itemCount: signatures.length + 1,
                          itemBuilder: (context, index) {
                            if (index == signatures.length) {
                              return GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                  Navigator.push(
                                    context,
                                    CupertinoPageRoute(
                                      builder: (_) => NewSignatureScreen(),
                                    ),
                                  );
                                },
                                child: Container(
                                  width: 111,
                                  height: 78,
                                  margin: EdgeInsets.only(right: 12),
                                  decoration: BoxDecoration(
                                    color: Color(0xFF929292),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.add,
                                    size: 32,
                                    color: Colors.black87,
                                  ),
                                ),
                              );
                            }

                            final signature = signatures[index];

                            return GestureDetector(
                              onTap: () {
                                onSignatureSelected(
                                  signature.bytes,
                                  signature.id,
                                );
                                Navigator.pop(context);
                              },
                              child: Container(
                                width: 111,
                                height: 78,
                                margin: EdgeInsets.only(right: 12),
                                decoration: BoxDecoration(
                                  color: Color(0xFF929292),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.memory(
                                    signature.bytes,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
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
