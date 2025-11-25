import 'package:flutter/material.dart';

class PdfConverterScreen extends StatefulWidget {
  const PdfConverterScreen({super.key});

  @override
  State<PdfConverterScreen> createState() => _PdfConverterScreenState();
}

class _PdfConverterScreenState extends State<PdfConverterScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(child: Text('data')),
    );
  }
}
