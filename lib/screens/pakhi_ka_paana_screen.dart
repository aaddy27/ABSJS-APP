import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import 'base_scaffold.dart';

class PakhiKaPaanaScreen extends StatefulWidget {
  const PakhiKaPaanaScreen({super.key});

  @override
  State<PakhiKaPaanaScreen> createState() => _PakhiKaPaanaScreenState();
}

class _PakhiKaPaanaScreenState extends State<PakhiKaPaanaScreen> {
  Future<List<dynamic>> fetchPakhiData() async {
    final response =
        await http.get(Uri.parse("https://website.sadhumargi.in/api/pakhi"));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("डेटा लोड करने में समस्या आई");
    }
  }

  Future<void> _launchPDF(String url) async {
    final Uri fullUrl = Uri.parse("https://website.sadhumargi.in$url");
    if (await canLaunchUrl(fullUrl)) {
      await launchUrl(fullUrl, mode: LaunchMode.externalApplication);
    } else {
      throw Exception("PDF खोलने में समस्या");
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      selectedIndex: -1,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 🔹 Centered Heading with Amita font
            Center(
              child: Text(
                "📄 पक्खी का पाना ",
                style: GoogleFonts.amita(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E3A8A),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),

            // 🔽 FutureBuilder for API Data
            Expanded(
              child: FutureBuilder<List<dynamic>>(
                future: fetchPakhiData(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                        child: Text("⚠️ डेटा लोड करने में त्रुटि: ${snapshot.error}"));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text("कोई रिकॉर्ड उपलब्ध नहीं है"));
                  }

                  final pakhiList = snapshot.data!;

                  return ListView.builder(
                    itemCount: pakhiList.length,
                    itemBuilder: (context, index) {
                      final item = pakhiList[index];
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 3,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          leading: const Icon(Icons.picture_as_pdf,
                              color: Colors.red),
                          title: Text(
                            "वर्ष : ${item['year']}",
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.download, color: Colors.blue),
                            onPressed: () {
                              _launchPDF(item['pdf']);
                            },
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
