import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../base_scaffold.dart';

class PadhadhikariParikshanKaryashalaScreen extends StatefulWidget {
  const PadhadhikariParikshanKaryashalaScreen({super.key});

  @override
  State<PadhadhikariParikshanKaryashalaScreen> createState() =>
      _PadhadhikariParikshanKaryashalaScreenState();
}

class _PadhadhikariParikshanKaryashalaScreenState
    extends State<PadhadhikariParikshanKaryashalaScreen> {
  bool isLoading = true;
  List<dynamic> data = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    const String apiUrl =
        'https://website.sadhumargi.in/api/padhadhikari-prashashan-karyashala';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        setState(() {
          data = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      debugPrint('Error fetching data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _openUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      selectedIndex: -1,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : data.isEmpty
                ? const Center(child: Text('कोई डेटा उपलब्ध नहीं है'))
                : ListView.builder(
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      final item = data[index];
                      final title = item['name'] ?? 'नाम नहीं मिला';
                      final rawFile = item['pdf']?.toString() ?? '';
                      final cleanedUrl = rawFile.contains('http')
                          ? rawFile.replaceAll(r'\/', '/')
                          : 'https://website.sadhumargi.in/storage/$rawFile';
                      final isOnline = cleanedUrl.contains('docs.google.com');

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 2,
                        child: ListTile(
                          leading: Icon(
                            isOnline ? Icons.link : Icons.picture_as_pdf,
                            color: isOnline ? Colors.green : Colors.red,
                          ),
                          title: Text(
                            title,
                            style: GoogleFonts.hindSiliguri(fontSize: 16),
                          ),
                          trailing: const Icon(Icons.open_in_new,
                              color: Colors.deepPurple),
                          onTap: () => _openUrl(cleanedUrl),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
