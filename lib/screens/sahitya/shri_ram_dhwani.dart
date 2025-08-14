import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../base_scaffold.dart';

class ShriRamDhwaniScreen extends StatefulWidget {
  const ShriRamDhwaniScreen({super.key});

  @override
  State<ShriRamDhwaniScreen> createState() => _ShriRamDhwaniScreenState();
}

class _ShriRamDhwaniScreenState extends State<ShriRamDhwaniScreen> {
  List<dynamic> books = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchBooks();
  }

  Future<void> fetchBooks() async {
    const String apiUrl =
        "https://website.sadhumargi.in/api/sahitya/category/shri_ram_dhwani";
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          books = data;
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        debugPrint("Error fetching books: ${response.statusCode}");
      }
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint("Exception fetching books: $e");
    }
  }

  Future<void> openLink(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      selectedIndex: -1,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Heading
              Text(
                'राम ध्वनि',
                textAlign: TextAlign.center,
                style: GoogleFonts.amita(
                  fontSize: 38,
                  fontWeight: FontWeight.bold,
                  color: const Color.fromARGB(255, 102, 87, 3),
                ),
              ),
              const SizedBox(height: 20),
              // Books Grid
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Expanded(
                      child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2, // 2 books per row
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 0.65, // book cover ratio
                        ),
                        itemCount: books.length,
                        itemBuilder: (context, index) {
                          final book = books[index];
                          final coverPhoto =
                              "https://website.sadhumargi.in${book['cover_photo']}";
                          final pdf = book['pdf'] != null
                              ? "https://website.sadhumargi.in${book['pdf']}"
                              : null;
                          final driveLink = book['drive_link'];

                          return GestureDetector(
                            onTap: () {
                              if (pdf != null) {
                                openLink(pdf);
                              } else if (driveLink != null) {
                                openLink(driveLink);
                              }
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.3),
                                    blurRadius: 5,
                                    offset: const Offset(0, 5),
                                  )
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Cover Photo
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(12),
                                        topRight: Radius.circular(12),
                                      ),
                                      child: AspectRatio(
                                        aspectRatio: 0.65,
                                        child: Image.network(
                                          coverPhoto,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  Container(
                                            color: Colors.grey[200],
                                            child: const Icon(
                                              Icons.image,
                                              size: 50,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  // Book Name
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      book['name'] ?? '  ',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
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
      ),
    );
  }
}
