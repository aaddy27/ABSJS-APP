import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'layout.dart';
import 'package:google_fonts/google_fonts.dart';

class YuvaVpSecScreen extends StatefulWidget {
  const YuvaVpSecScreen({super.key});

  @override
  State<YuvaVpSecScreen> createState() => _YuvaVpSecScreenState();
}

class _YuvaVpSecScreenState extends State<YuvaVpSecScreen> {
  late Future<List<dynamic>> _vpSecFuture;

  Future<List<dynamic>> fetchVpSec() async {
    final res = await http.get(
      Uri.parse("https://website.sadhumargi.in/api/yuva-vp-sec"),
    );
    if (res.statusCode == 200) {
      final list = json.decode(res.body) as List;
      // oldest first (id asc). Latest first चाहिए तो नीचे वाली लाइन use करें।
      list.sort((a, b) => (a['id'] ?? 0).compareTo(b['id'] ?? 0));
      // list.sort((a, b) => (b['id'] ?? 0).compareTo(a['id'] ?? 0)); // latest first
      return list;
    } else {
      throw Exception("Failed to load VP/Secretary data");
    }
  }

  @override
  void initState() {
    super.initState();
    _vpSecFuture = fetchVpSec();
  }

  @override
  Widget build(BuildContext context) {
    return YuvaSanghLayout(
      customChild: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Center aligned heading
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Text(
                "उपाध्यक्ष /  मंत्री ",
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
              future: _vpSecFuture,
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
                    final post = (item['post'] ?? '').toString();
                    final city = (item['city'] ?? '').toString();
                    final aanchal = (item['aanchal'] ?? '').toString();
                    final mobile = (item['mobile'] ?? '').toString();

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
                                  _InfoRow(
                                    icon: Icons.badge_outlined,
                                    text: post,
                                  ),
                                  const SizedBox(height: 4),
                                  _InfoRow(
                                    icon: Icons.location_on_outlined,
                                    text: city,
                                  ),
                                  const SizedBox(height: 4),
                                  _InfoRow(
                                    icon: Icons.map_outlined,
                                    text: aanchal,
                                  ),
                                  const SizedBox(height: 4),
                                  _InfoRow(
                                    icon: Icons.phone_outlined,
                                    text: mobile,
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

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.brown.shade700),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 14, color: Colors.brown.shade700),
          ),
        ),
      ],
    );
    }
}
