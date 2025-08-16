import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart'; // ✅ Google Fonts
import 'base_scaffold.dart';

class ChaturmasSuchiScreen extends StatefulWidget {
  const ChaturmasSuchiScreen({super.key});

  @override
  State<ChaturmasSuchiScreen> createState() => _ChaturmasSuchiScreenState();
}

class _ChaturmasSuchiScreenState extends State<ChaturmasSuchiScreen> {
  List<dynamic> _data = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    const url = "https://website.sadhumargi.in/api/chaturmas-suchi";
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        setState(() {
          _data = json.decode(response.body);
          _loading = false;
        });
      } else {
        setState(() => _loading = false);
      }
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  Future<void> _openPdf(String pdfPath) async {
    final fullUrl = "https://website.sadhumargi.in$pdfPath";
    if (await canLaunchUrl(Uri.parse(fullUrl))) {
      await launchUrl(Uri.parse(fullUrl), mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("PDF नहीं खुल सका")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      selectedIndex: -1,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "📜 चातुर्मास सूची",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.amita(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E3A8A),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "  यहां चातुर्मास के विभिन्न वर्षों की सूची उपलब्ध है।",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.amita(
                      fontSize: 18,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 20),

                  Expanded(
                    child: ListView.builder(
                      itemCount: _data.length,
                      itemBuilder: (context, index) {
                        final item = _data[index];
                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          child: ListTile(
                            leading: const Icon(Icons.picture_as_pdf,
                                color: Color(0xFF1E3A8A)),
                            title: Text(
                              "वर्ष : ${item['year']}",
                              style: GoogleFonts.amita(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            trailing: ElevatedButton.icon(
                              onPressed: () => _openPdf(item['pdf']),
                              icon: const Icon(Icons.open_in_new, size: 18),
                              label: Text("देखें",
                                  style: GoogleFonts.amita(fontSize: 16)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1E3A8A),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
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
