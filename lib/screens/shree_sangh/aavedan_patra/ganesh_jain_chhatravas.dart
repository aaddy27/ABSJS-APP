import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart'; // ✅ Added
import '../../base_scaffold.dart';

class GaneshJainChhatravasScreen extends StatefulWidget {
  const GaneshJainChhatravasScreen({super.key});

  @override
  State<GaneshJainChhatravasScreen> createState() =>
      _GaneshJainChhatravasScreenState();
}

class _GaneshJainChhatravasScreenState
    extends State<GaneshJainChhatravasScreen> {
  bool isLoading = true;
  List<dynamic> forms = [];

  @override
  void initState() {
    super.initState();
    fetchForms();
  }

  Future<void> fetchForms() async {
    const url =
        'https://website.sadhumargi.in/api/aavedan-patra/ganesh_jain_hostel';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          forms = data;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      debugPrint('Error fetching data: $e');
      setState(() => isLoading = false);
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
        padding: const EdgeInsets.all(16),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : forms.isEmpty
                ? const Center(child: Text('कोई डेटा उपलब्ध नहीं है'))
                : ListView.builder(
                    itemCount: forms.length,
                    itemBuilder: (context, index) {
                      final form = forms[index];
                      final title = form['name'] ?? 'नाम नहीं मिला';
                      final rawFile = form['file']?.toString() ?? '';
                      final cleanedUrl = rawFile.contains('http')
                          ? rawFile.replaceAll(r'\/', '/')
                          : 'https://website.sadhumargi.in/storage/aavedan_patra/$rawFile';
                      final isOnline =
                          cleanedUrl.contains('docs.google.com');

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
                          onTap: () => _openUrl(cleanedUrl), // ✅ Open on tap
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
