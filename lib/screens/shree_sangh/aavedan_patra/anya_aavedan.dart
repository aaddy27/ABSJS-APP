import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../../base_scaffold.dart';

class AnyaAavedanScreen extends StatefulWidget {
  const AnyaAavedanScreen({super.key});

  @override
  State<AnyaAavedanScreen> createState() => _AnyaAavedanScreenState();
}

class _AnyaAavedanScreenState extends State<AnyaAavedanScreen> {
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
        Uri.parse('https://website.sadhumargi.in/api/aavedan-patra/other'),
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
      url = file; // direct Google Form link
    }

    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint("Could not launch $url");
    }
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue.shade800,
            Colors.blue.shade500,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade700.withOpacity(0.28),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.22),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.receipt_long, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'अन्य आवेदन पत्र',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Forms & Applications',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: fetchData,
            icon: const Icon(Icons.refresh, color: Colors.white),
          )
        ],
      ),
    );
  }

  Widget _buildCard(Map<String, dynamic> item) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 3,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.insert_drive_file, color: Colors.blue, size: 26),
        ),
        title: Text(
          item['name'] ?? '',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: const Icon(Icons.open_in_new, color: Colors.grey),
        onTap: () => _openFile(item['file'] ?? '', item['file_type'] ?? ''),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.insert_drive_file_outlined, size: 64, color: Colors.blue.shade300),
          const SizedBox(height: 12),
          Text('कोई आवेदन पत्र उपलब्ध नहीं है',
              style: TextStyle(fontSize: 16, color: Colors.blue.shade600)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      selectedIndex: -1,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _data.isEmpty
                      ? _buildEmpty()
                      : RefreshIndicator(
                          onRefresh: fetchData,
                          child: ListView.builder(
                            padding: const EdgeInsets.only(top: 12, bottom: 18),
                            itemCount: _data.length,
                            itemBuilder: (context, index) {
                              final item = _data[index] as Map<String, dynamic>;
                              return _buildCard(item);
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
