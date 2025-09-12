import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../base_scaffold.dart';

class SamtaChatravrittiScreen extends StatefulWidget {
  const SamtaChatravrittiScreen({super.key});

  @override
  State<SamtaChatravrittiScreen> createState() => _SamtaChatravrittiScreenState();
}

class _SamtaChatravrittiScreenState extends State<SamtaChatravrittiScreen> {
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
          'https://website.sadhumargi.in/api/aavedan-patra/samata_scholarship'));
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
      debugPrint('Error: $e');
    }
  }

  Future<void> _openFile() async {
    if (_data == null) return;
    String fileType = (_data!['file_type'] ?? 'pdf').toString();
    String fileUrl;

    if (fileType == 'pdf') {
      fileUrl =
          'https://website.sadhumargi.in/storage/aavedan_patra/${_data!['file']}';
    } else {
      fileUrl = _data!['file']; // Google Form URL
    }

    final uri = Uri.parse(fileUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint('Could not launch $fileUrl');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('लिंक खोलने में त्रुटि')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = const Color(0xFF2563EB);
    return BaseScaffold(
      selectedIndex: -1,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(18)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('समता छात्रवृत्ति आवेदन-पत्र',
                        style: GoogleFonts.amita(
                            fontSize: 26, fontWeight: FontWeight.w700, color: Colors.white)),
                    const SizedBox(height: 6),
                    Text('यहाँ से आवेदन-पत्र खोलें या डाउनलोड करें',
                        style: GoogleFonts.hindSiliguri(fontSize: 13, color: Colors.white70)),
                  ],
                ),
              ),
            ),

            if (_loading)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CircularProgressIndicator()),
              ),

            if (!_loading && _data == null)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: Text('कोई डेटा उपलब्ध नहीं')), 
              ),

            if (!_loading && _data != null)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                sliver: SliverToBoxAdapter(
                  child: _ScholarshipCard(
                    title: _data!['name'] ?? '',
                    subtitle: _data!['description'] ?? '',
                    fileType: (_data!['file_type'] ?? 'pdf').toString(),
                    color: color,
                    onOpen: _openFile,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ScholarshipCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String fileType;
  final Color color;
  final VoidCallback onOpen;

  const _ScholarshipCard({
    required this.title,
    required this.subtitle,
    required this.fileType,
    required this.color,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final bg = color.withOpacity(0.06);
    final isPdf = fileType.toLowerCase() == 'pdf';

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isPdf ? color : color.withOpacity(0.12), width: isPdf ? 2 : 1),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 4)),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
                    child: Icon(isPdf ? Icons.picture_as_pdf : Icons.link, color: color, size: 28),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.hindSiliguri(fontSize: 16, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 6),
                        if (subtitle.isNotEmpty)
                          Text(subtitle, maxLines: 3, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.grey[700], fontSize: 14)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(fileType.toUpperCase(), style: TextStyle(color: color, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      IconButton(onPressed: onOpen, icon: Icon(Icons.open_in_new, color: color)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onOpen,
                  icon: const Icon(Icons.open_in_new, color: Colors.white),
                  label: const Text(
                    'खोलें',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: color,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}