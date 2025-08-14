import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../../base_scaffold.dart';

class SanghSadasyataScreen extends StatefulWidget {
  const SanghSadasyataScreen({super.key});

  @override
  State<SanghSadasyataScreen> createState() => _SanghSadasyataScreenState();
}

class _SanghSadasyataScreenState extends State<SanghSadasyataScreen> {
  List<dynamic> _data = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final response = await http.get(Uri.parse(
          "https://website.sadhumargi.in/api/aavedan-patra/sangh_membership"));
      if (response.statusCode == 200) {
        setState(() {
          _data = json.decode(response.body);
          _loading = false;
        });
      } else {
        throw Exception("Failed to load data");
      }
    } catch (e) {
      setState(() {
        _loading = false;
      });
      debugPrint("Error: $e");
    }
  }

  Future<void> _openLink(String fileType, String fileName) async {
    String url;
    if (fileType == "pdf") {
      url = "https://website.sadhumargi.in/storage/aavedan_patra/$fileName";
    } else {
      // Assuming file contains Google Form link if not PDF
      url = fileName;
    }

    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint("Could not launch $url");
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      selectedIndex: -1,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: _data.length,
              itemBuilder: (context, index) {
                final item = _data[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    title: Text(
                      item['name'],
                      style: const TextStyle(fontSize: 16),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                    onTap: () => _openLink(item['file_type'], item['file']),
                  ),
                );
              },
            ),
    );
  }
}
