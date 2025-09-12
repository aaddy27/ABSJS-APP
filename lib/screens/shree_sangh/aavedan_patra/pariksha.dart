import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../base_scaffold.dart';

class ParikshaScreen extends StatefulWidget {
  const ParikshaScreen({super.key});

  @override
  State<ParikshaScreen> createState() => _ParikshaScreenState();
}

class _ParikshaScreenState extends State<ParikshaScreen> {
  bool _loading = true;
  bool _error = false;
  List<dynamic> _data = [];
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> fetchData() async {
    try {
      final response = await http.get(
        Uri.parse('https://website.sadhumargi.in/api/aavedan-patra/exam'),
      );
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        setState(() {
          _data = jsonData;
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
      debugPrint('Error fetching data: $e');
    }
  }

  Future<void> _openFile(String file, String fileType) async {
    String url;
    if (fileType.toLowerCase() == 'pdf') {
      url = "https://website.sadhumargi.in/storage/aavedan_patra/$file";
    } else {
      url = file; // treat as Google Form link
    }

    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint('Could not launch $url');
      // optionally show a snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('लिंक खोलने में त्रुटि')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _data.where((item) {
      final name = (item['name'] ?? '').toString().toLowerCase();
      final fileType = (item['file_type'] ?? '').toString().toLowerCase();
      final q = _query.toLowerCase().trim();
      return name.contains(q) || fileType.contains(q);
    }).toList();

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
                    colors: [Color(0xFF0EA5E9), Color(0xFF2563EB)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(18)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('परीक्षा आवेदन-पत्र',
                        style: GoogleFonts.amita(
                            fontSize: 26, fontWeight: FontWeight.w700, color: Colors.white)),
                    const SizedBox(height: 6),
                    Text('नीचे से अपना आवेदन-पत्र खोलें या डाउनलोड करें',
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

            // Loading, error or empty states
            if (_loading)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CircularProgressIndicator()),
              ),

            if (!_loading && _error)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.cloud_off, size: 56, color: Colors.grey),
                      const SizedBox(height: 8),
                      const Text('डेटा लोड नहीं हो पाया'),
                      const SizedBox(height: 10),
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _loading = true;
                            _error = false;
                          });
                          fetchData();
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('दोबारा कोशिश करें'),
                      ),
                    ],
                  ),
                ),
              ),

            if (!_loading && !_error && filtered.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: Text('कोई आवेदन पत्र उपलब्ध नहीं है')), 
              ),

            if (!_loading && !_error && filtered.isNotEmpty)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                sliver: SliverLayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.crossAxisExtent;
                    int crossAxisCount = 1;
                    if (width > 1200) crossAxisCount = 3;
                    else if (width > 800) crossAxisCount = 2;

                    return SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        mainAxisSpacing: 14,
                        crossAxisSpacing: 14,
                        childAspectRatio: 3.2,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final item = filtered[index];
                          return _ExamCard(
                            title: item['name'] ?? '',
                            subtitle: item['description'] ?? '',
                            file: item['file'] ?? '',
                            fileType: (item['file_type'] ?? 'pdf').toString(),
                            color: const Color(0xFF0EA5E9),
                            onOpen: () => _openFile(item['file'] ?? '', item['file_type'] ?? 'pdf'),
                          );
                        },
                        childCount: filtered.length,
                      ),
                    );
                  },
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

class _ExamCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String file;
  final String fileType;
  final Color color;
  final VoidCallback onOpen;

  const _ExamCard({
    required this.title,
    required this.subtitle,
    required this.file,
    required this.fileType,
    required this.color,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final bg = color.withOpacity(0.06);
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.12)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
                child: Icon(
                  fileType.toLowerCase() == 'pdf' ? Icons.picture_as_pdf : Icons.link,
                  color: color,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.hindSiliguri(fontSize: 15, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    if (subtitle.isNotEmpty)
                      Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.grey[700], fontSize: 13)),
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
        ),
      ),
    );
  }
}
