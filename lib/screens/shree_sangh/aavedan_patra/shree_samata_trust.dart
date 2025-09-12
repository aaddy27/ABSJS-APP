import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../base_scaffold.dart';

class ShreeSamataTrustScreen extends StatefulWidget {
  const ShreeSamataTrustScreen({super.key});

  @override
  State<ShreeSamataTrustScreen> createState() => _ShreeSamataTrustScreenState();
}

class _ShreeSamataTrustScreenState extends State<ShreeSamataTrustScreen> {
  bool _loading = true;
  bool _error = false;
  List<dynamic> _forms = [];
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _fetchForms();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchForms() async {
    try {
      final response = await http.get(
        Uri.parse('https://website.sadhumargi.in/api/aavedan-patra/samata_trust'),
      );
      if (response.statusCode == 200) {
        setState(() {
          _forms = json.decode(response.body);
          _loading = false;
          _error = false;
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      setState(() {
        _loading = false;
        _error = true;
      });
      debugPrint('Error: $e');
    }
  }

  Future<void> _openFile(Map<String, dynamic> form) async {
    String fileType = form['file_type'] ?? 'pdf';
    String fileUrl;

    if (fileType.toLowerCase() == 'pdf') {
      fileUrl = 'https://website.sadhumargi.in/storage/aavedan_patra/${form['file']}';
    } else {
      fileUrl = form['file']; // Google Form URL
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
    final filtered = _forms.where((item) {
      final name = (item['name'] ?? '').toString().toLowerCase();
      final fileType = (item['file_type'] ?? '').toString().toLowerCase();
      final q = _query.toLowerCase().trim();
      return name.contains(q) || fileType.contains(q);
    }).toList();

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
                    Text('श्री समता ट्रस्ट आवेदन-पत्र',
                        style: GoogleFonts.amita(
                            fontSize: 26, fontWeight: FontWeight.w700, color: Colors.white)),
                    const SizedBox(height: 6),
                    Text('यहाँ से आवेदन-पत्र खोलें या डाउनलोड करें',
                        style: GoogleFonts.hindSiliguri(fontSize: 13, color: Colors.white70)),
                    const SizedBox(height: 14),
                    _SearchField(
                      controller: _searchCtrl,
                      hint: 'खोजें (नाम या प्रकार...)',
                      onChanged: (v) => setState(() => _query = v),
                      onClear: () {
                        _searchCtrl.clear();
                        setState(() => _query = '');
                      },
                    ),
                  ],
                ),
              ),
            ),

            if (_loading)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CircularProgressIndicator()),
              ),

            if (!_loading && _error)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: Text('डेटा लोड नहीं हो पाया')), 
              ),

            if (!_loading && !_error && filtered.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: Text('कोई डेटा उपलब्ध नहीं')), 
              ),

            if (!_loading && !_error && filtered.isNotEmpty)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final form = filtered[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _TrustCard(
                          title: form['name'] ?? '',
                          subtitle: form['description'] ?? '',
                          fileType: (form['file_type'] ?? 'pdf').toString(),
                          color: color,
                          onOpen: () => _openFile(form),
                        ),
                      );
                    },
                    childCount: filtered.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _SearchField({
    required this.controller,
    required this.hint,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: GoogleFonts.hindSiliguri(fontSize: 15, color: Colors.white),
      cursorColor: Colors.white,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white.withOpacity(0.12),
        hintText: hint,
        hintStyle: GoogleFonts.hindSiliguri(color: Colors.white70, fontSize: 14),
        prefixIcon: const Icon(Icons.search, color: Colors.white),
        suffixIcon: controller.text.isNotEmpty
            ? IconButton(onPressed: onClear, icon: const Icon(Icons.close, color: Colors.white))
            : null,
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.25)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white),
        ),
      ),
    );
  }
}

class _TrustCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String fileType;
  final Color color;
  final VoidCallback onOpen;

  const _TrustCard({
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