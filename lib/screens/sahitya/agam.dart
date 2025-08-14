import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import '../base_scaffold.dart';

class AgamScreen extends StatefulWidget {
  const AgamScreen({super.key});

  @override
  State<AgamScreen> createState() => _AgamScreenState();
}

class _AgamScreenState extends State<AgamScreen> {
  List books = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchBooks();
  }

  Future<void> fetchBooks() async {
    final response = await http.get(
      Uri.parse('https://website.sadhumargi.in/api/sahitya/category/agam'),
    );

    if (response.statusCode == 200) {
      setState(() {
        books = json.decode(response.body);
        loading = false;
      });
    } else {
      setState(() {
        loading = false;
      });
      // Error handling
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to fetch books')),
      );
    }
  }

  void openFile(String pdfUrl, String? driveLink) async {
    final fullPdfUrl = 'https://website.sadhumargi.in$pdfUrl';
    if (pdfUrl.isNotEmpty) {
      // Open PDF link
      if (await canLaunchUrl(Uri.parse(fullPdfUrl))) {
        await launchUrl(Uri.parse(fullPdfUrl));
      }
    } else if (driveLink != null && driveLink.isNotEmpty) {
      // Open Drive link
      if (await canLaunchUrl(Uri.parse(driveLink))) {
        await launchUrl(Uri.parse(driveLink));
      }
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
              'आगम, अहिंसा-समता एवं प्राकृत संस्थान',
              textAlign: TextAlign.center,
              style: GoogleFonts.amita(
                fontSize: 28,
                color: const Color.fromARGB(255, 102, 87, 3),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: loading
                  ? const Center(child: CircularProgressIndicator())
                  : GridView.builder(
                      padding: const EdgeInsets.all(8),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, // 2 books per row
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 0.7, // cover photo size ratio
                      ),
                      itemCount: books.length,
                      itemBuilder: (context, index) {
                        final book = books[index];
                        final coverUrl =
                            'https://website.sadhumargi.in${book['cover_photo']}';
                        final pdfUrl = book['pdf'] ?? '';
                        final driveLink = book['drive_link'];

                        return GestureDetector(
                          onTap: () => openFile(pdfUrl, driveLink),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.white,
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 4,
                                  offset: Offset(2, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(8),
                                        topRight: Radius.circular(8)),
                                    child: Image.network(
                                      coverUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              const Icon(Icons.book),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    book['name'] ?? 'Agam Book',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
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
