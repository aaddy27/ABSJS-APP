import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../../base_scaffold.dart';

class ShivirScreen extends StatefulWidget {
  const ShivirScreen({super.key});

  @override
  State<ShivirScreen> createState() => _ShivirScreenState();
}

class _ShivirScreenState extends State<ShivirScreen> {
  bool _loading = true;
  List<dynamic> _forms = [];

  @override
  void initState() {
    super.initState();
    _fetchForms();
  }

  Future<void> _fetchForms() async {
    try {
      final response = await http.get(
        Uri.parse('https://website.sadhumargi.in/api/aavedan-patra/shivir'),
      );
      if (response.statusCode == 200) {
        List<dynamic> result = json.decode(response.body);
        setState(() {
          _forms = result;
          _loading = false;
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      setState(() => _loading = false);
      debugPrint('Error: $e');
    }
  }

  Future<void> _openFile(Map<String, dynamic> form) async {
    String fileType = form['file_type'];
    String fileUrl;

    if (fileType == 'pdf') {
      fileUrl =
          'https://website.sadhumargi.in/storage/aavedan_patra/${form['file']}';
    } else {
      fileUrl = form['file']; // Google Form URL
    }

    if (await canLaunchUrl(Uri.parse(fileUrl))) {
      await launchUrl(Uri.parse(fileUrl), mode: LaunchMode.externalApplication);
    } else {
      debugPrint('Could not launch $fileUrl');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      selectedIndex: -1,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _forms.isEmpty
              ? const Center(child: Text('कोई डेटा उपलब्ध नहीं'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _forms.length,
                  itemBuilder: (context, index) {
                    final form = _forms[index];
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        leading: const Icon(Icons.description,
                            color: Colors.blue, size: 32),
                        title: Text(
                          form['name'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        trailing: const Icon(Icons.open_in_new),
                        onTap: () => _openFile(form),
                      ),
                    );
                  },
                ),
    );
  }
}
