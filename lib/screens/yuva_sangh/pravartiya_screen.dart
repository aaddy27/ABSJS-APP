import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PravartiyaScreen extends StatefulWidget {
  const PravartiyaScreen({super.key});

  @override
  State<PravartiyaScreen> createState() => _PravartiyaScreenState();
}

class _PravartiyaScreenState extends State<PravartiyaScreen> {
  List<dynamic> pravartiyaList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPravartiya();
  }

  Future<void> fetchPravartiya() async {
    final url = Uri.parse("https://website.sadhumargi.in/api/yuva-pravartiya");
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          pravartiyaList = json.decode(response.body);
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 🔹 Top Heading
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            "प्रवर्तिया",
            style: GoogleFonts.amita(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.brown.shade800,
            ),
          ),
        ),

        // 🔹 List
        Expanded(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : pravartiyaList.isEmpty
                  ? const Center(child: Text("No Pravartiya found"))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: pravartiyaList.length,
                      itemBuilder: (context, index) {
                        final item = pravartiyaList[index];
                        final String heading = item['heading'] ?? "";
                        final String content = item['content'] ?? "";
                        final String? photo = item['photo'];

                        return Card(
                          elevation: 4,
                          margin: const EdgeInsets.only(bottom: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                                color: Colors.brown.shade200, width: 1),
                          ),
                          color: Colors.brown.shade50,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (photo != null) ...[
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      photo,
                                      height: 150,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              const Icon(Icons.broken_image,
                                                  size: 50),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                ],
                                Text(
                                  heading,
                                  style: GoogleFonts.amita(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.brown.shade800,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  content,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    height: 1.5,
                                    color: Colors.black87,
                                  ),
                                  textAlign: TextAlign.justify,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }
}
