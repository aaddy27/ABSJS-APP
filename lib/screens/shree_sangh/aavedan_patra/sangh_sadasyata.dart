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
      url = fileName;
    }

    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint("Could not launch $url");
    }
  }

  Color _colorForType(String? t) {
    final s = (t ?? '').toLowerCase();
    if (s == 'pdf') return Colors.red.shade600;
    if (s.contains('form')) return Colors.teal.shade600;
    if (s.contains('doc') || s.contains('docx')) return Colors.indigo.shade600;
    return Colors.blue.shade700; // default bluish accent
  }

  String _formatFileType(String? t) {
    final s = (t ?? '').toString().toLowerCase();
    if (s == 'pdf') return 'PDF';
    if (s.contains('form')) return 'Form';
    if (s.isEmpty) return 'Link';
    return s.toUpperCase();
  }

  Widget _buildListItem(dynamic item) {
    final name = item['name'] ?? 'Unnamed';
    final fileType = item['file_type'] ?? '';
    final fileName = item['file'] ?? '';
    final color = _colorForType(fileType);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(14),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _openLink(fileType, fileName),
          child: Row(
            children: [
              // Decorative colored strip
              Container(
                width: 8,
                height: 88,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color.withOpacity(0.95), color.withOpacity(0.6)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),

              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Row(
                    children: [
                      // Icon circle
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Icon(
                            fileType.toString().toLowerCase() == 'pdf'
                                ? Icons.picture_as_pdf
                                : Icons.link,
                            color: color,
                            size: 28,
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Texts
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name.toString(),
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                  ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                // File type chip
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: color,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    _formatFileType(fileType),
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                // File name
                                Expanded(
                                  child: Text(
                                    fileName.toString(),
                                    style: TextStyle(
                                        fontSize: 13, color: Colors.grey.shade700),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Open icon
                      Padding(
                        padding: const EdgeInsets.only(left: 8, right: 8),
                        child: IconButton(
                          onPressed: () => _openLink(fileType, fileName),
                          icon: Icon(Icons.open_in_new,
                              color: Colors.grey.shade700),
                          tooltip: 'Open',
                        ),
                      ),
                    ],
                  ),
                ),
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
          Icon(Icons.insert_drive_file_outlined,
              size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text('No forms available',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade700)),
          const SizedBox(height: 6),
          Text('Please try again later.',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
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
            // Blue header
            Container(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.blue.shade700,
                    Colors.blue.shade400,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                      color: Colors.blue.shade700.withOpacity(0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 6)),
                ],
              ),
              child: Row(
                children: [
                  // Small circular logo / avatar
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                        child: Icon(Icons.group,
                            color: Colors.white, size: 30)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sangh Membership',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 18,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Forms & Downloads',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: Colors.white70),
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
            ),

            // Body
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : (_data.isEmpty
                      ? _buildEmpty()
                      : ListView.builder(
                          padding:
                              const EdgeInsets.only(top: 12, bottom: 16),
                          itemCount: _data.length,
                          itemBuilder: (context, index) {
                            final item = _data[index];
                            return _buildListItem(item);
                          },
                        )),
            ),
          ],
        ),
      ),
    );
  }
}
