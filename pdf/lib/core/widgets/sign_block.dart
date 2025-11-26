import 'dart:typed_data';

import 'package:flutter/material.dart';

class SignatureListWidget extends StatelessWidget {
  final String title;
  final List<Uint8List> signatures;
  final Function(Uint8List) onSignatureTap;

  const SignatureListWidget({
    super.key,
    required this.title,
    required this.signatures,
    required this.onSignatureTap,
  });

  @override
  Widget build(BuildContext context) {
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
            SizedBox(height: 10),
            Text(
              title.toUpperCase(),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.normal,
                color: Color(0xFFB2B2B2),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 110,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: signatures.length,
                itemBuilder: (context, index) {
                  final signature = signatures[index];
                  return InkWell(
                    onTap: () => onSignatureTap(signature),
                    child: Container(
                      width: 120,
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F6FA),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Image.memory(signature, fit: BoxFit.contain),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
