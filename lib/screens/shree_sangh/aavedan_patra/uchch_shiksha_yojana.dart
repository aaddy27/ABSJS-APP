import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../../base_scaffold.dart';

class UchchShikshaYojanaScreen extends StatefulWidget {
  const UchchShikshaYojanaScreen({super.key});

  @override
  State<UchchShikshaYojanaScreen> createState() => _UchchShikshaYojanaScreenState();
}

class _UchchShikshaYojanaScreenState extends State<UchchShikshaYojanaScreen> {
  bool _loading = true;
  List<dynamic> _data = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final response = await http.get(
        Uri.parse('https://website.sadhumargi.in/api/aavedan-patra/acharya_shrilal_yojana'),
      );
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        setState(() {
          _data = jsonData;
          _loading = false;
        });
      } else {
        throw Exception("Failed to load data");
      }
    } catch (e) {
      setState(() {
        _loading = false;
      });
      debugPrint("Error fetching data: $e");
    }
  }

  Future<void> _openFile(String file, String fileType) async {
    String url;
    if (fileType.toLowerCase() == 'pdf') {
      url = "https://website.sadhumargi.in/storage/aavedan_patra/$file";
    } else {
      url = file; // direct link for Google Form
    }

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
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
          : _data.isEmpty
              ? const Center(child: Text("कोई आवेदन पत्र उपलब्ध नहीं है"))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _data.length,
                  itemBuilder: (context, index) {
                    final item = _data[index];
                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        title: Text(
                          item['name'] ?? '',
                          style: const TextStyle(fontSize: 16),
                        ),
                        trailing: const Icon(Icons.open_in_new),
                        onTap: () {
                          _openFile(item['file'], item['file_type']);
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
