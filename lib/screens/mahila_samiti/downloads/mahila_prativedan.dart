import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../layout_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class MahilaPrativedanScreen extends StatefulWidget {
  const MahilaPrativedanScreen({super.key});

  @override
  State<MahilaPrativedanScreen> createState() => _MahilaPrativedanScreenState();
}

class _MahilaPrativedanScreenState extends State<MahilaPrativedanScreen> {
  List<dynamic> prativedanList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPrativedan();
  }

  Future<void> fetchPrativedan() async {
    final response = await http
        .get(Uri.parse("https://website.sadhumargi.in/api/mahila_prativedan"));
    if (response.statusCode == 200) {
      setState(() {
        prativedanList = json.decode(response.body);
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  void _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ लिंक नहीं खुल सका")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutScreen(
      title: "प्रतिवेदन",
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : prativedanList.isEmpty
              ? const Center(child: Text("⚠ कोई प्रतिवेदन उपलब्ध नहीं है"))
              : RefreshIndicator(
                  onRefresh: fetchPrativedan,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: prativedanList.length,
                    itemBuilder: (context, index) {
                      final item = prativedanList[index];
                      return Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 4,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          title: Text(
                            item["name"] ?? "Untitled",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          trailing: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.amber[800],
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: () {
                              if (item["google_drive_link"] != null) {
                                _openUrl(item["google_drive_link"]);
                              }
                            },
                            child: const Text("Open Link"),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
