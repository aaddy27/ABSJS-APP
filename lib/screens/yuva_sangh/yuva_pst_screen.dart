import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'layout.dart';
import 'package:google_fonts/google_fonts.dart';

class YuvaPstScreen extends StatefulWidget {
  const YuvaPstScreen({super.key});

  @override
  State<YuvaPstScreen> createState() => _YuvaPstScreenState();
}

class _YuvaPstScreenState extends State<YuvaPstScreen> {
  late Future<List<dynamic>> _pstFuture;

  Future<List<dynamic>> fetchPst() async {
    final response = await http.get(
      Uri.parse("https://website.sadhumargi.in/api/yuva-pst"),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body) as List;
    } else {
      throw Exception("Failed to load Yuva PST data");
    }
  }

  @override
  void initState() {
    super.initState();
    _pstFuture = fetchPst();
  }

  @override
  Widget build(BuildContext context) {
    return YuvaSanghLayout(
      customChild: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 👇 AppBar के नीचे Heading
       // 👇 AppBar के नीचे Heading
Padding(
  padding: const EdgeInsets.all(16.0),
  child: Center(   // ✅ Center widget use किया
    child: Text(
      "युवा संघ पदाधिकारीगण",
      textAlign: TextAlign.center,   // ✅ Text भी center align
      style: GoogleFonts.amita(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Colors.brown.shade900,
      ),
    ),
  ),
),


          // 👇 बाकी FutureBuilder
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: _pstFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }
                final data = snapshot.data ?? [];
                if (data.isEmpty) {
                  return const Center(child: Text("No PST members found"));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    final item = data[index];
                    final imageUrl =
                        "https://website.sadhumargi.in${item['photo']}";

                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                            color: Colors.brown.shade200, width: 2),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.horizontal(
                              left: Radius.circular(12),
                            ),
                            child: Image.network(
                              imageUrl,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stack) => Container(
                                width: 100,
                                height: 100,
                                color: Colors.grey.shade300,
                                child: const Icon(Icons.person, size: 40),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['name'] ?? "",
                                    style: GoogleFonts.sarala(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.brown.shade900,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    item['post'] ?? "",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.brown.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
