import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';
import '../../base_scaffold.dart';

class VivarnikaScreen extends StatefulWidget {
  const VivarnikaScreen({super.key});

  @override
  State<VivarnikaScreen> createState() => _VivarnikaScreenState();
}

class _VivarnikaScreenState extends State<VivarnikaScreen> {
  late final PdfControllerPinch _pdfController;

  @override
  void initState() {
    super.initState();
    // ✅ Directly assets se document khol rahe hain
    _pdfController = PdfControllerPinch(
      document: PdfDocument.openAsset('assets/pdf/vivarnika.pdf'),
    );
  }

  @override
  void dispose() {
    _pdfController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      selectedIndex: -1,
      body: PdfViewPinch(
        controller: _pdfController,
      ),
    );
  }
}
