import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../../base_scaffold.dart';

class AavedanPatraHomeScreen extends StatefulWidget {
  const AavedanPatraHomeScreen({super.key});

  @override
  State<AavedanPatraHomeScreen> createState() => _AavedanPatraHomeScreenState();
}

class _AavedanPatraHomeScreenState extends State<AavedanPatraHomeScreen>
    with TickerProviderStateMixin {
  List offlineForms = [];
  List onlineForms = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchForms();
  }

  Future<void> fetchForms() async {
    try {
      final response = await http
          .get(Uri.parse('https://website.sadhumargi.in/api/aavedan-patra'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          offlineForms = data
              .where((item) =>
                  item['file_type'] == 'pdf' &&
                  !item['file'].toString().contains('docs.google.com'))
              .toList();

          onlineForms = data
              .where((item) =>
                  item['file'].toString().contains('docs.google.com'))
              .toList();

          isLoading = false;
        });
      } else {
        throw Exception('Failed to load forms');
      }
    } catch (e) {
      debugPrint('Error: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      selectedIndex: -1,
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            Container(
              color: Colors.deepPurple.shade100,
              child: const TabBar(
                labelColor: Colors.deepPurple,
                indicatorColor: Colors.deepPurple,
                tabs: [
                  Tab(text: '📄 Offline Forms'),
                  Tab(text: '🌐 Online Forms'),
                ],
              ),
            ),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : TabBarView(
                      children: [
                        _buildFormList(offlineForms, isOnline: false),
                        _buildFormList(onlineForms, isOnline: true),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormList(List forms, {required bool isOnline}) {
    if (forms.isEmpty) {
      return const Center(child: Text('कोई डेटा उपलब्ध नहीं है'));
    }

    return ListView.builder(
      itemCount: forms.length,
      itemBuilder: (context, index) {
        final form = forms[index];
        final title = form['name'];

        // Prepare full URL
        final rawFile = form['file'].toString();
        final cleanedUrl = rawFile.contains('http')
            ? rawFile.replaceAll(r'\/', '/')
            : 'https://website.sadhumargi.in/storage/aavedan_patra/$rawFile';

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
          child: ListTile(
            leading: Icon(
              isOnline ? Icons.link : Icons.picture_as_pdf,
              color: isOnline ? Colors.green : Colors.red,
            ),
            title: Text(title, style: GoogleFonts.hindSiliguri(fontSize: 16)),
            trailing: const Icon(Icons.open_in_new, color: Colors.deepPurple),
            onTap: () => _launchURL(cleanedUrl, context),
          ),
        );
      },
    );
  }

Future<void> _launchURL(String url, BuildContext context) async {
  final Uri uri = Uri.parse(url);

  if (await canLaunchUrl(uri)) {
    final launched = await launchUrl(
      uri,
      mode: LaunchMode.inAppWebView, // 👈 try this instead of external
    );

    if (!launched) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('URL नहीं खोल सका')),
      );
    }
  } else {
    debugPrint('❌ Cannot launch: $url');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('URL नहीं खोल सका')),
    );
  }
}

}
