import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../base_scaffold.dart';

class NaneshvaniScreen extends StatefulWidget {
  const NaneshvaniScreen({super.key});

  @override
  State<NaneshvaniScreen> createState() => _NaneshvaniScreenState();
}

class _NaneshvaniScreenState extends State<NaneshvaniScreen> {
  late Future<List<dynamic>> _booksFuture;

  @override
  void initState() {
    super.initState();
    _booksFuture = fetchBooks();
  }

  Future<List<dynamic>> fetchBooks() async {
    final response = await http.get(
      Uri.parse('https://website.sadhumargi.in/api/sahitya/category/naneshvani'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load books');
    }
  }

  void _openPdf(String pdfPath, String? driveLink) async {
    final url = driveLink != null ? driveLink : 'https://website.sadhumargi.in$pdfPath';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open PDF')),
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
            // Heading
           Padding(
  padding: const EdgeInsets.all(16.0),
  child: Text(
    'आचार्य श्री नानालाल जी म.सा. का प्रवचन साहित्य',
    textAlign: TextAlign.center, // Center align
    style: GoogleFonts.amita(
      fontSize: 28,
      fontWeight: FontWeight.bold,
      color: const Color.fromARGB(255, 102, 87, 3), // Golden color
    ),
  ),
),

            // Books Grid
            Expanded(
              child: FutureBuilder<List<dynamic>>(
                future: _booksFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No books found.'));
                  }

                  final books = snapshot.data!;

                  return GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // 2 cards per row
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.65, // height/width ratio
                    ),
                    itemCount: books.length,
                    itemBuilder: (context, index) {
                      final book = books[index];
                      final coverPhoto = 'https://website.sadhumargi.in${book['cover_photo']}';
                      final pdf = book['pdf'];
                      final driveLink = book['drive_link'];

                      return GestureDetector(
                        onTap: () => _openPdf(pdf, driveLink),
                        child: Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                  child: Image.network(
                                    coverPhoto,
                                    fit: BoxFit.cover,
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return const Center(child: CircularProgressIndicator());
                                    },
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Center(child: Icon(Icons.broken_image, size: 50));
                                    },
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  book['name'] ?? ' ',
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
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
