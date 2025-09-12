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
    final fileType = (form['file_type'] ?? '').toString();
    final fileRef = (form['file'] ?? '').toString();
    final fileUrl = fileType.toLowerCase() == 'pdf'
        ? 'https://website.sadhumargi.in/storage/aavedan_patra/$fileRef'
        : fileRef;

    final uri = Uri.parse(fileUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint('Cannot launch URL: $fileUrl');
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
            child:
                const Icon(Icons.receipt_long, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'अन्य सदस्यता / आवेदन',
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
            onPressed: _fetchData,
            icon: const Icon(Icons.refresh, color: Colors.white),
          )
        ],
      ),
    );
  }

  Widget _buildCard(Map<String, dynamic> form) {
    final fileType = (form['file_type'] ?? '').toString().toLowerCase();
    final icon = fileType == 'pdf' ? Icons.picture_as_pdf : Icons.insert_drive_file;
    final iconColor = fileType == 'pdf' ? Colors.red : Colors.blue;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 3,
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 26),
        ),
        title: Text(
          form['name'] ?? '',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: (form['file'] != null)
            ? Text(
                form['file'].toString(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              )
            : null,
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
                  : _forms.isEmpty
                      ? _buildEmpty()
                      : RefreshIndicator(
                          onRefresh: _fetchData,
                          child: ListView.builder(
                            padding:
                                const EdgeInsets.only(top: 12, bottom: 16),
                            itemCount: _forms.length,
                            itemBuilder: (context, index) =>
                                _buildCard(_forms[index]),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
