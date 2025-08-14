import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../../base_scaffold.dart';

class AnyaSadasyataScreen extends StatefulWidget {
  const AnyaSadasyataScreen({super.key});

  @override
  State<AnyaSadasyataScreen> createState() => _AnyaSadasyataScreenState();
}

class _AnyaSadasyataScreenState extends State<AnyaSadasyataScreen> {
  bool _loading = true;
  List<dynamic> _forms = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    const apiUrl =
        'https://website.sadhumargi.in/api/aavedan-patra/anya_membership';
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final List<dynamic> result = json.decode(response.body);
        setState(() {
          _forms = result;
          _loading = false;
        });
      } else {
        throw Exception(
            'Failed to load data (status: ${response.statusCode})');
      }
    } catch (e) {
      setState(() {
        _loading = false;
      });
      debugPrint('Error fetching anya membership data: $e');
    }
  }

  Future<void> _openFile(Map<String, dynamic> form) async {
    final fileType = form['file_type'] as String;
    final fileRef = form['file'] as String;
    final fileUrl = fileType == 'pdf'
        ? 'https://website.sadhumargi.in/storage/aavedan_patra/$fileRef'
        : fileRef;

    final uri = Uri.parse(fileUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint('Cannot launch URL: $fileUrl');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      selectedIndex: -1,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _forms.isEmpty
              ? const Center(
                  child: Text(
                    'कोई डेटा उपलब्ध नहीं',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _forms.length,
                  itemBuilder: (context, index) {
                    final form = _forms[index];
                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              form['file_type'] == 'pdf'
                                  ? Icons.picture_as_pdf
                                  : Icons.assignment_outlined,
                              color: form['file_type'] == 'pdf'
                                  ? Colors.red
                                  : Colors.blue,
                              size: 60,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              form['name'] ?? 'फ़ाइल खोलें',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              form['file_type'] == 'pdf'
                                  ? 'PDF फाइल उपलब्ध है'
                                  : 'Google Form उपलब्ध है',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 14, horizontal: 16),
                                  backgroundColor: form['file_type'] == 'pdf'
                                      ? Colors.red
                                      : Colors.blue,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: () => _openFile(form),
                                icon: const Icon(Icons.open_in_new,
                                    color: Colors.white),
                                label: const Text(
                                  'खोलें',
                                  style: TextStyle(
                                      fontSize: 18, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
