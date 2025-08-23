import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'layout.dart';
import 'package:google_fonts/google_fonts.dart';

class YuvaExPresidentScreen extends StatefulWidget {
  const YuvaExPresidentScreen({super.key});

  @override
  State<YuvaExPresidentScreen> createState() => _YuvaExPresidentScreenState();
}

class _YuvaExPresidentScreenState extends State<YuvaExPresidentScreen> {
  late Future<List<dynamic>> _exPresidentsFuture;

  Future<List<dynamic>> fetchExPresidents() async {
    final res = await http.get(
      Uri.parse("https://website.sadhumargi.in/api/yuva-ex-president"),
    );
    if (res.statusCode == 200) {
      final list = json.decode(res.body) as List;
      // NOTE: पुरानी entry ऊपर, नई नीचे चाहिए तो ascending रखें (id आधार)
      list.sort((a, b) => (a['id'] ?? 0).compareTo(b['id'] ?? 0));
      // अगर latest सबसे ऊपर चाहिए तो उल्टा कर दें:
      // list.sort((a, b) => (b['id'] ?? 0).compareTo(a['id'] ?? 0));
      return list;
    } else {
      throw Exception("Failed to load Ex Presidents");
    }
  }

  @override
  void initState() {
    super.initState();
    _exPresidentsFuture = fetchExPresidents();
  }

  @override
  Widget build(BuildContext context) {
    return YuvaSanghLayout(
      // customTitle चाहें तो पास कर सकते हैं
      customChild: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch, // 👉 full width
        children: [
          // 👉 Center aligned heading
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Text(
                "युवा संघ पूर्व अध्यक्षगण",
                textAlign: TextAlign.center,
                style: GoogleFonts.amita(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown.shade900,
                ),
              ),
            ),
          ),

          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: _exPresidentsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }
                final data = snapshot.data ?? [];
                if (data.isEmpty) {
                  return const Center(child: Text("No records found"));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    final item = data[index];
                    final imageUrl =
                        "https://website.sadhumargi.in${item['photo']}";
                    final name = (item['name'] ?? '').toString();
                    final city = (item['city'] ?? '').toString();
                    final karyakal = (item['karyakal'] ?? '').toString();

                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: Colors.brown.shade200,
                          width: 2,
                        ),
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
                              errorBuilder: (_, __, ___) => Container(
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
                                  const EdgeInsets.symmetric(vertical: 12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    style: GoogleFonts.sarala(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.brown.shade900,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Icon(Icons.calendar_month,
                                          size: 16,
                                          color: Colors.brown.shade700),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          karyakal,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.brown.shade700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(Icons.location_on_outlined,
                                          size: 16,
                                          color: Colors.brown.shade700),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          city,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.brown.shade700,
                                          ),
                                        ),
                                      ),
                                    ],
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
