import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../../base_scaffold.dart';

class SwadhyayiScreen extends StatefulWidget {
  const SwadhyayiScreen({super.key});

  @override
  State<SwadhyayiScreen> createState() => _SwadhyayiScreenState();
}

class _SwadhyayiScreenState extends State<SwadhyayiScreen> {
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
        Uri.parse(
            'https://website.sadhumargi.in/api/aavedan-patra/swadhyayee_registration'),
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

    final uri = Uri.parse(fileUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint('Could not launch $fileUrl');
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
              color: Colors.blue.shade700.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.menu_book, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Swadhyayi Registration',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Registration forms & details',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _fetchForms,
            icon: const Icon(Icons.refresh, color: Colors.white),
          )
        ],
      ),
    );
  }

  Widget _buildCard(Map<String, dynamic> form) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 4,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.description, color: Colors.blue, size: 26),
        ),
        title: Text(
          form['name'] ?? '',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: const Icon(Icons.open_in_new, color: Colors.grey),
        onTap: () => _openFile(form),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.insert_drive_file_outlined,
              size: 64, color: Colors.blue.shade300),
          const SizedBox(height: 12),
          Text('कोई डेटा उपलब्ध नहीं',
              style: TextStyle(fontSize: 16, color: Colors.blue.shade600)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      selectedIndex: -1,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _forms.isEmpty
                    ? _buildEmpty()
                    : ListView.builder(
                        padding: const EdgeInsets.only(top: 12, bottom: 16),
                        itemCount: _forms.length,
                        itemBuilder: (context, index) =>
                            _buildCard(_forms[index]),
                      ),
          ),
        ],
      ),
    );
  }
}
