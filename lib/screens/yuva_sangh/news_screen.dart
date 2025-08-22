import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  List<dynamic> _newsList = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    fetchNews();
  }

  Future<void> fetchNews() async {
    try {
      final response =
          await http.get(Uri.parse("https://website.sadhumargi.in/api/yuva-news"));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _newsList = data;
          _loading = false;
        });
      } else {
        setState(() => _loading = false);
      }
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  void _showFullDescription(String title, String description, String imageUrl) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        builder: (_, controller) => SingleChildScrollView(
          controller: controller,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.amita(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown.shade800,
                ),
              ),
              const SizedBox(height: 12),
              Image.network(imageUrl, fit: BoxFit.contain),
              const SizedBox(height: 12),
              Text(
                description,
                style: const TextStyle(fontSize: 14, height: 1.6),
                textAlign: TextAlign.justify,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFullImage(String imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              Center(
                child: InteractiveViewer(
                  child: Image.network(imageUrl, fit: BoxFit.contain),
                ),
              ),
              Positioned(
                top: 40,
                right: 20,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_newsList.isEmpty) {
      return const Center(child: Text("No news available"));
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 🔹 Heading
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Center(
            child: Text(
              "समाचार ",
              style: GoogleFonts.amita(
                fontSize: 38,
                fontWeight: FontWeight.bold,
                color: Colors.brown.shade800,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // 🔹 News List
        ..._newsList.map((news) {
          final imageUrl = "https://website.sadhumargi.in${news['photo']}";
          final description = news['description'] ?? "";

          return Card(
            elevation: 4,
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.brown.shade200, width: 1),
            ),
            color: Colors.brown.shade50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image with tap for full screen
            // Image with tap for full screen
GestureDetector(
  onTap: () => _showFullImage(imageUrl),
  child: ClipRRect(
    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
    child: ConstrainedBox(
      constraints: const BoxConstraints(
        minHeight: 180,
        maxHeight: 400, // portrait images को ज्यादा जगह मिल सके
      ),
      child: Image.network(
        imageUrl,
        width: double.infinity,
        fit: BoxFit.contain, // 👈 अब crop नहीं होगा
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return const Center(child: CircularProgressIndicator());
        },
        errorBuilder: (context, error, stack) => Container(
          color: Colors.grey.shade300,
          child: const Icon(Icons.broken_image, size: 50),
        ),
      ),
    ),
  ),
),


                // Content
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        news['title'] ?? "",
                        style: GoogleFonts.amita(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.brown.shade800,
                        ),
                      ),
                      const SizedBox(height: 6),

                      Text(
                        description.length > 100
                            ? "${description.substring(0, 100)}..."
                            : description,
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.justify,
                      ),

                      if (description.length > 100)
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => _showFullDescription(
                                news['title'] ?? "", description, imageUrl),
                            child: const Text(
                              "See More",
                              style: TextStyle(color: Colors.brown),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
