import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../../base_scaffold.dart';

class AnyaVishishtSadasyataScreen extends StatefulWidget {
  const AnyaVishishtSadasyataScreen({super.key});

  @override
  State<AnyaVishishtSadasyataScreen> createState() =>
      _AnyaVishishtSadasyataScreenState();
}

class _AnyaVishishtSadasyataScreenState
    extends State<AnyaVishishtSadasyataScreen> {
  bool _loading = true;
  Map<String, dynamic>? _data;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final response = await http.get(Uri.parse(
          'https://website.sadhumargi.in/api/aavedan-patra/vishisht_membership'));
      if (response.statusCode == 200) {
        List<dynamic> result = json.decode(response.body);
        if (result.isNotEmpty) {
          setState(() {
            _data = result.first;
            _loading = false;
          });
        } else {
          setState(() => _loading = false);
        }
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      setState(() => _loading = false);
      debugPrint('Error fetching membership data: $e');
    }
  }

  Future<void> _openFile() async {
    if (_data == null) return;
    final fileType = _data!['file_type'] as String;
    final fileRef = _data!['file'] as String;
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
          : _data == null
              ? const Center(
                  child: Text(
                    'कोई डेटा उपलब्ध नहीं',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _data!['file_type'] == 'pdf'
                                ? Icons.picture_as_pdf
                                : Icons.assignment_outlined,
                            color: _data!['file_type'] == 'pdf'
                                ? Colors.red
                                : Colors.blue,
                            size: 60,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _data!['name'] ?? 'फ़ाइल खोलें',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _data!['file_type'] == 'pdf'
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
                                backgroundColor:
                                    _data!['file_type'] == 'pdf'
                                        ? Colors.red
                                        : Colors.blue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: _openFile,
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
                  ),
                ),
    );
  }
}
