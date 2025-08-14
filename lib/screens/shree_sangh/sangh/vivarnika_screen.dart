import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';
import 'package:http/http.dart' as http;
import '../../base_scaffold.dart';

class VivarnikaScreen extends StatefulWidget {
  const VivarnikaScreen({super.key});

  @override
  State<VivarnikaScreen> createState() => _VivarnikaScreenState();
}

class _VivarnikaScreenState extends State<VivarnikaScreen> {
  late PdfControllerPinch _pdfController;
  bool _isLoading = true;

  final String pdfUrl =
      'https://web.sadhumargi.in/uploads/Prospectus-2021-23.pdf';

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  Future<void> _loadPdf() async {
    try {
      final response = await http.get(Uri.parse(pdfUrl));
      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        _pdfController = PdfControllerPinch(
          document: PdfDocument.openData(bytes),
        );
        setState(() {
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load PDF');
      }
    } catch (e) {
      print('Error loading PDF: $e');
    }
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : PdfViewPinch(
              controller: _pdfController,
            ),
    );
  }
}
