import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../../base_scaffold.dart';

class GaneshJainChhatravasScreen extends StatefulWidget {
  const GaneshJainChhatravasScreen({super.key});

  @override
  State<GaneshJainChhatravasScreen> createState() =>
      _GaneshJainChhatravasScreenState();
}

class _GaneshJainChhatravasScreenState
    extends State<GaneshJainChhatravasScreen> {
  bool isLoading = true;
  List<dynamic> forms = [];

  @override
  void initState() {
    super.initState();
    fetchForms();
  }

  Future<void> fetchForms() async {
    const url =
        'https://website.sadhumargi.in/api/aavedan-patra/ganesh_jain_hostel';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          forms = data;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      debugPrint('Error fetching data: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> _openUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $url');
    }
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade800, Colors.blue.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
              color: Colors.blue.shade700.withOpacity(0.22),
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
              color: Colors.white.withOpacity(0.20),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.home, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ganesh Jain Chhatravas',
                  style: GoogleFonts.hindSiliguri(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Forms & Applications',
                  style: GoogleFonts.hindSiliguri(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: fetchForms,
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: 'Refresh',
          )
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext context, Map<String, dynamic> form) {
    final title = form['name'] ?? 'नाम उपलब्ध नहीं';
    final rawFile = form['file']?.toString() ?? '';
    final cleanedUrl = rawFile.contains('http')
        ? rawFile.replaceAll(r'\/', '/')
        : 'https://website.sadhumargi.in/storage/aavedan_patra/$rawFile';
    final isOnline = cleanedUrl.contains('docs.google.com');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Material(
        color: Colors.white,
        elevation: 4,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _openUrl(cleanedUrl),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: isOnline
                        ? Colors.blue.shade50
                        : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Icon(
                      isOnline ? Icons.link : Icons.picture_as_pdf,
                      color: isOnline ? Colors.blue.shade700 : Colors.red.shade700,
                      size: 26,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.hindSiliguri(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey.shade900,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        cleanedUrl,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.open_in_new, color: Colors.blue),
                ),
              ],
            ),
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
          Icon(Icons.folder_open, size: 64, color: Colors.blue.shade200),
          const SizedBox(height: 12),
          Text(
            'कोई डेटा उपलब्ध नहीं है',
            style: GoogleFonts.hindSiliguri(
              fontSize: 16,
              color: Colors.blue.shade700,
            ),
          ),
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
            _buildHeader(context),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : forms.isEmpty
                      ? _buildEmpty()
                      : RefreshIndicator(
                          onRefresh: fetchForms,
                          child: ListView.builder(
                            padding: const EdgeInsets.only(top: 12, bottom: 18),
                            itemCount: forms.length,
                            itemBuilder: (context, index) {
                              final form = forms[index] as Map<String, dynamic>;
                              return _buildCard(context, form);
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
