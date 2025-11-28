import 'dart:convert';
import 'dart:typed_data';

import 'package:fast_pdf/features/signature/widgets/create_new_sign.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void showSignatureSelector({
  required BuildContext context,
  required Function(Uint8List, int) onSignatureSelected,
  required Function(int) onDeleteSignature,
}) {
  showModalBottomSheet(
    backgroundColor: Colors.white,
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
                    color: Colors.grey.withOpacity(.1),
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
                            color: Colors.black,
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
                              onLongPress: () async {
                                final should = await showCupertinoDialog<bool>(
                                  context: context,
                                  builder: (c) => CupertinoTheme(
                                    data: const CupertinoThemeData(
                                      brightness: Brightness.dark,
                                    ),
                                    child: CupertinoAlertDialog(
                                      title: const Text('Delete signature?'),
                                      content: const Text(
                                        'Are you sure you want to delete this signature?',
                                      ),
                                      actions: [
                                        CupertinoDialogAction(
                                          onPressed: () =>
                                              Navigator.pop(c, false),
                                          child: const Text('Cancel'),
                                        ),
                                        CupertinoDialogAction(
                                          isDestructiveAction: true,
                                          onPressed: () =>
                                              Navigator.pop(c, true),
                                          child: const Text('Delete'),
                                        ),
                                      ],
                                    ),
                                  ),
                                );

                                if (should == true) {
                                  onDeleteSignature(signature.id);
                                  Navigator.pop(context);
                                }
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

  final signatureStrings = prefs.getStringList('signatures') ?? [];

  final List<SignatureItem> list = [];

  for (int i = 0; i < signatureStrings.length; i++) {
    final base64Str = signatureStrings[i];
    list.add(SignatureItem(i, base64Decode(base64Str)));
  }

  return list;
}

class SignatureItem {
  final int id;
  final Uint8List bytes;

  SignatureItem(this.id, this.bytes);
}
