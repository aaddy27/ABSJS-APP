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
            _data = result.first as Map<String, dynamic>;
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
    final fileType = (_data!['file_type'] ?? '').toString().toLowerCase();
    final fileRef = (_data!['file'] ?? '').toString();
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
                  'विशिष्ट सदस्यता',
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
            tooltip: 'Refresh',
          )
        ],
      ),
    );
  }

  Widget _buildCard() {
    if (_data == null) return const SizedBox.shrink();

    final fileType = (_data!['file_type'] ?? '').toString().toLowerCase();
    final isPdf = fileType == 'pdf';
    final icon = isPdf ? Icons.picture_as_pdf : Icons.assignment_outlined;
    final iconColor = isPdf ? Colors.red : Colors.blue;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 44),
              ),
              const SizedBox(height: 14),
              // Title
              Text(
                _data!['name'] ?? 'फ़ाइल खोलें',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              // Subtitle
              Text(
                isPdf ? 'PDF फाइल उपलब्ध है' : 'Google Form उपलब्ध है',
                style: TextStyle(fontSize: 15, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 14),
              // File reference (single line, ellipsis)
              if ((_data!['file'] ?? '').toString().isNotEmpty) ...[
                Text(
                  (_data!['file'] ?? '').toString(),
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
              ],
              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _openFile,
                      icon: const Icon(Icons.open_in_new, color: Colors.white),
                      label: const Text('खोलें', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isPdf ? Colors.red : Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
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
          Text('कोई डेटा उपलब्ध नहीं', style: TextStyle(fontSize: 16, color: Colors.blue.shade600)),
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
                  : _data == null
                      ? _buildEmpty()
                      : RefreshIndicator(
                          onRefresh: _fetchData,
                          child: ListView(
                            padding: const EdgeInsets.only(top: 12, bottom: 18),
                            children: [
                              _buildCard(),
                            ],
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
