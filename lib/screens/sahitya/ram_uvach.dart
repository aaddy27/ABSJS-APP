import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import '../base_scaffold.dart';
import 'package:url_launcher/url_launcher.dart';

class RamUvachScreen extends StatefulWidget {
  const RamUvachScreen({super.key});

  @override
  State<RamUvachScreen> createState() => _RamUvachScreenState();
}

class _RamUvachScreenState extends State<RamUvachScreen> {
  List<dynamic> books = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchBooks();
  }

  Future<void> fetchBooks() async {
    try {
      final response = await http.get(
        Uri.parse('https://website.sadhumargi.in/api/sahitya/category/ram_uvach'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          books = data;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        debugPrint('Failed to fetch data');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      debugPrint('Error: $e');
    }
  }

  Future<void> _launchURL(String url) async {
    final fullUrl = url.startsWith('http') ? url : 'https://website.sadhumargi.in$url';
    if (!await launchUrl(Uri.parse(fullUrl))) {
      debugPrint('Could not launch $fullUrl');
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
              child: Center(
                child: Text(
                  'आचार्य श्री रामलाल जी म.सा. का प्रवचन साहित्य',
                  style: GoogleFonts.amita(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: const Color.fromARGB(255, 102, 87, 3),
                  ),
                ),
              ),
            ),

            // Books Grid
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : books.isEmpty
                      ? const Center(child: Text('No books found'))
                      : Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: GridView.builder(
                            itemCount: books.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2, // 2 cards per row
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 0.6,
                            ),
                            itemBuilder: (context, index) {
                              final book = books[index];
                              final coverPhoto = book['cover_photo'];
                              final pdf = book['pdf'];
                              final driveLink = book['drive_link'];

                              return Card(
                                elevation: 3,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    // Cover photo with flexible height
                                    Expanded(
                                      child: coverPhoto != null
                                          ? ClipRRect(
                                              borderRadius: const BorderRadius.only(
                                                  topLeft: Radius.circular(12),
                                                  topRight: Radius.circular(12)),
                                              child: Image.network(
                                                'https://website.sadhumargi.in$coverPhoto',
                                                width: double.infinity,
                                                fit: BoxFit.cover, // auto resize
                                              ),
                                            )
                                          : Container(
                                              width: double.infinity,
                                              color: Colors.grey[300],
                                              child: const Icon(Icons.book, size: 50),
                                            ),
                                    ),

                                    const SizedBox(height: 8),

                                    // Book name
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 4),
                                      child: Text(
                                        book['name'] ?? 'राम उवाच',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),

                                    const SizedBox(height: 8),

                                    // Buttons (PDF / Drive)
                                    if (pdf != null || driveLink != null)
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 8.0),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            if (pdf != null)
                                              ElevatedButton.icon(
                                                onPressed: () => _launchURL(pdf),
                                                icon: const Icon(Icons.picture_as_pdf),
                                                label: const Text('PDF'),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: const Color.fromARGB(255, 253, 253, 253),
                                                ),
                                              ),
                                            if (pdf != null && driveLink != null)
                                              const SizedBox(width: 8),
                                            if (driveLink != null)
                                              ElevatedButton.icon(
                                                onPressed: () => _launchURL(driveLink),
                                                icon: const Icon(Icons.drive_file_move),
                                                label: const Text('Drive'),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: const Color.fromARGB(255, 248, 248, 247),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
