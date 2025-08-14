import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

import '../base_scaffold.dart';

class SamtaKathaMalaScreen extends StatefulWidget {
  const SamtaKathaMalaScreen({super.key});

  @override
  State<SamtaKathaMalaScreen> createState() => _SamtaKathaMalaScreenState();
}

class _SamtaKathaMalaScreenState extends State<SamtaKathaMalaScreen> {
  List<dynamic> books = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchBooks();
  }

  Future<void> fetchBooks() async {
    const String apiUrl = 'https://website.sadhumargi.in/api/sahitya/category/samta_katha_mala';
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        setState(() {
          books = json.decode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        throw Exception('Failed to load books');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      debugPrint(e.toString());
    }
  }

  void _openFile(String? pdf, String? driveLink) async {
    String url = '';
    if (pdf != null && pdf.isNotEmpty) {
      url = 'https://website.sadhumargi.in$pdf';
    } else if (driveLink != null && driveLink.isNotEmpty) {
      url = driveLink;
    }

    if (url.isNotEmpty && await canLaunch(url)) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('File not available')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      selectedIndex: -1,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            Text(
              'समता कथा माला',
              textAlign: TextAlign.center,
              style: GoogleFonts.amita(
                fontSize: 38,
                color: const Color.fromARGB(255, 102, 87, 3),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, // 2 books per row
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.65, // Adjust as needed
                      ),
                      itemCount: books.length,
                      itemBuilder: (context, index) {
                        final book = books[index];
                        final cover = book['cover_photo'] ?? '';
                        final pdf = book['pdf'];
                        final driveLink = book['drive_link'];

                        return GestureDetector(
                          onTap: () => _openFile(pdf, driveLink),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    'https://website.sadhumargi.in$cover',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                book['name'] ?? 'अनाम प्रकाशन',
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
