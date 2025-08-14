import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

import '../../base_scaffold.dart';

class SheshnikPravartiyaScreen extends StatefulWidget {
  const SheshnikPravartiyaScreen({super.key});

  @override
  State<SheshnikPravartiyaScreen> createState() => _SheshnikPravartiyaScreenState();
}

class _SheshnikPravartiyaScreenState extends State<SheshnikPravartiyaScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  bool _loading = true;
  String? _contentText;
  String? _imageUrl;

  final String baseImageUrl = 'https://website.sadhumargi.in/storage/'; // Base URL for images

  bool _jspExamLoading = true;
  List<dynamic> _jspExamItems = [];

  bool _jspBigExamLoading = true;
List<dynamic> _jspBigExamItems = [];

bool _jspHindiBooksLoading = true;
List<dynamic> _jspHindiBooksItems = [];

bool _jspGujaratiBooksLoading = true;
List<dynamic> _jspGujaratiBooksItems = [];

bool _oldPapersLoading = true;
Map<String, dynamic> _oldPapersData = {};
String? _selectedClass; // the class user selects
List<dynamic> _displayedOldPapers = [];




  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _fetchApiData();      // for Tab 1
    _fetchJspExamData();  // for Tab 2
    _fetchJspBigExamData(); // for Tab 3
    _fetchJspHindiBooksData();  // for Tab 4
    _fetchJspGujaratiBooksData(); // fetch Tab 5 data
    _fetchOldPapers(); // fetch Tab 6 data
  }

  Future<void> _fetchApiData() async {
    try {
      final response = await http.get(Uri.parse('https://website.sadhumargi.in/api/jsp-basic'));
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        if (jsonData.isNotEmpty) {
          final firstItem = jsonData[0];
          setState(() {
            _contentText = firstItem['content'] ?? 'No Content';
            // Replace backslashes with forward slashes for image path
            final dtp = firstItem['dtp']?.replaceAll(r'\', '/');
            _imageUrl = dtp != null ? baseImageUrl + dtp : null;
            _loading = false;
          });
        } else {
          setState(() {
            _contentText = 'No data found';
            _loading = false;
          });
        }
      } else {
        setState(() {
          _contentText = 'Failed to load data';
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _contentText = 'Error: $e';
        _loading = false;
      });
    }
  }

  Future<void> _fetchJspExamData() async {
    try {
      final response = await http.get(Uri.parse('https://website.sadhumargi.in/api/jsp-exam'));
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        setState(() {
          _jspExamItems = jsonData;
          _jspExamLoading = false;
        });
      } else {
        setState(() {
          _jspExamLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _jspExamLoading = false;
      });
    }
  }

Future<void> _fetchJspBigExamData() async {
  try {
    final response = await http.get(Uri.parse('https://website.sadhumargi.in/api/jsp-bigexam'));
    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      setState(() {
        _jspBigExamItems = jsonData;
        _jspBigExamLoading = false;
      });
    } else {
      setState(() {
        _jspBigExamLoading = false;
      });
    }
  } catch (e) {
    setState(() {
      _jspBigExamLoading = false;
    });
  }
}


Future<void> _fetchJspHindiBooksData() async {
  try {
    final response = await http.get(
      Uri.parse('https://website.sadhumargi.in/api/jsp-hindi-books'),
    );
    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      setState(() {
        _jspHindiBooksItems = jsonData;
        _jspHindiBooksLoading = false;
      });
    } else {
      setState(() {
        _jspHindiBooksLoading = false;
      });
    }
  } catch (e) {
    setState(() {
      _jspHindiBooksLoading = false;
    });
  }
}

Future<void> _fetchJspGujaratiBooksData() async {
  try {
    final response = await http.get(
      Uri.parse('https://website.sadhumargi.in/api/jsp-gujrati-books'),
    );
    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      // Sort by preference if available
      jsonData.sort((a, b) => (a['preference'] ?? 0).compareTo(b['preference'] ?? 0));
      setState(() {
        _jspGujaratiBooksItems = jsonData;
        _jspGujaratiBooksLoading = false;
      });
    } else {
      setState(() {
        _jspGujaratiBooksLoading = false;
      });
    }
  } catch (e) {
    setState(() {
      _jspGujaratiBooksLoading = false;
    });
  }
}


Future<void> _fetchOldPapers() async {
  try {
    final response = await http.get(
      Uri.parse('https://website.sadhumargi.in/api/jsp-old-papers'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      setState(() {
        _oldPapersData = jsonData;
        _oldPapersLoading = false;
        if (jsonData.isNotEmpty) {
          _selectedClass = jsonData.keys.first; // default to first class
          _displayedOldPapers = jsonData[_selectedClass] ?? [];
        }
      });
    } else {
      setState(() {
        _oldPapersLoading = false;
      });
    }
  } catch (e) {
    setState(() {
      _oldPapersLoading = false;
    });
    debugPrint('Error fetching old papers: $e');
  }
}

void _onClassChanged(String? selected) {
  setState(() {
    _selectedClass = selected;
    _displayedOldPapers = _oldPapersData[selected] ?? [];
  });
}


void _openUrl(String url) async {
  final uri = Uri.parse(url);
  bool canLaunch = await canLaunchUrl(uri);
  print('canLaunchUrl: $canLaunch');
  if (canLaunch) {
    await launchUrl(uri, mode: LaunchMode.platformDefault);

  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cannot open the link')),
    );
  }
}


void _downloadFile(String url) async {
  print("Trying to download URL: $url");  // debug print
  final uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cannot download the file')),
    );
  }
}


Widget _buildTabContent(int index) {
  if (index == 0) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    } else {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              _contentText ?? 'No Content',
              style: GoogleFonts.hindSiliguri(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            if (_imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  _imageUrl!,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return const Center(child: CircularProgressIndicator());
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return const Text('Image load failed');
                  },
                ),
              )
            else
              const Text('No Image Available'),
          ],
        ),
      );
    }
  } else if (index == 1) {
    // Tab 2: jsp exam
    if (_jspExamLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_jspExamItems.isEmpty) {
      return Center(
        child: Text(
          'कोई डेटा उपलब्ध नहीं है',
          style: GoogleFonts.hindSiliguri(fontSize: 18),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _jspExamItems.length,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (context, i) {
        final item = _jspExamItems[i];
        final name = item['name'] ?? 'No Name';
        final pdf = item['pdf'];
        final googleFormLink = item['google_form_link'];
        final pdfUrl = pdf != null ? 'https://website.sadhumargi.in/storage/$pdf' : null;

        return ListTile(
          title: Text(name, style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.w600)),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (pdfUrl != null) ...[
                IconButton(
                  icon: const Icon(Icons.picture_as_pdf, color: Colors.redAccent),
                  tooltip: 'PDF देखें',
                  onPressed: () => _openUrl(pdfUrl),  // View PDF
                ),
                IconButton(
                  icon: const Icon(Icons.download, color: Colors.green),
                  tooltip: 'PDF डाउनलोड करें',
                  onPressed: () => _downloadFile(pdfUrl),  // Download PDF
                ),
              ] else if (googleFormLink != null && googleFormLink.isNotEmpty) ...[
                IconButton(
                  icon: const Icon(Icons.open_in_new, color: Colors.blueAccent),
                  tooltip: 'Google Form खोलें',
                  onPressed: () => _openUrl(googleFormLink),
                ),
              ]
            ],
          ),
        );
      },
    );
  } 
  
  else if (index == 2) {
    // Tab 3: JSP Big Exam
    if (_jspBigExamLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_jspBigExamItems.isEmpty) {
      return Center(
        child: Text(
          'कोई डेटा उपलब्ध नहीं है',
          style: GoogleFonts.hindSiliguri(fontSize: 18),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _jspBigExamItems.length,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (context, i) {
        final item = _jspBigExamItems[i];
        final name = item['name'] ?? 'No Name';
        final pdf = item['pdf'];
        final pdfUrl = pdf != null
            ? 'https://website.sadhumargi.in/storage/${pdf.replaceAll(r'\', '/')}' 
            : null;

        return ListTile(
          title: Text(name, style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.w600)),
          trailing: pdfUrl != null
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.picture_as_pdf, color: Colors.redAccent),
                      tooltip: 'PDF देखें',
                      onPressed: () => _openUrl(pdfUrl),
                    ),
                    IconButton(
                      icon: const Icon(Icons.download, color: Colors.green),
                      tooltip: 'PDF डाउनलोड करें',
                      onPressed: () => _downloadFile(pdfUrl),
                    ),
                  ],
                )
              : null,
        );
      },
    );
  }

  else if (index == 3) {
  // Tab 4: JSP Hindi Books
  if (_jspHindiBooksLoading) {
    return const Center(child: CircularProgressIndicator());
  }
  if (_jspHindiBooksItems.isEmpty) {
    return Center(
      child: Text(
        'कोई डेटा उपलब्ध नहीं है',
        style: GoogleFonts.hindSiliguri(fontSize: 18),
      ),
    );
  }

  return ListView.separated(
    padding: const EdgeInsets.all(16),
    itemCount: _jspHindiBooksItems.length,
    separatorBuilder: (_, __) => const Divider(),
    itemBuilder: (context, i) {
      final item = _jspHindiBooksItems[i];
      final name = item['name'] ?? 'No Name';
      final pdf = item['pdf'];
      final pdfUrl = pdf != null
          ? 'https://website.sadhumargi.in/storage/${pdf.replaceAll(r'\', '/')}' 
          : null;

      return ListTile(
        title: Text(name, style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.w600)),
        trailing: pdfUrl != null
            ? IconButton(
                icon: const Icon(Icons.picture_as_pdf, color: Colors.redAccent),
                tooltip: 'PDF देखें',
                onPressed: () => _openUrl(pdfUrl),
              )
            : null,
      );
    },
  );
}


else if (index == 4) {
  // Tab 5: JSP Gujarati Books
  if (_jspGujaratiBooksLoading) {
    return const Center(child: CircularProgressIndicator());
  }
  if (_jspGujaratiBooksItems.isEmpty) {
    return Center(
      child: Text(
        'कोई डेटा उपलब्ध नहीं है',
        style: GoogleFonts.hindSiliguri(fontSize: 18),
      ),
    );
  }

  return ListView.separated(
    padding: const EdgeInsets.all(16),
    itemCount: _jspGujaratiBooksItems.length,
    separatorBuilder: (_, __) => const Divider(),
    itemBuilder: (context, i) {
      final item = _jspGujaratiBooksItems[i];
      final name = item['name'] ?? 'No Name';
      final pdf = item['pdf'];
      final pdfUrl = pdf != null
          ? 'https://website.sadhumargi.in/storage/${pdf.replaceAll(r'\', '/')}' 
          : null;

      return ListTile(
        title: Text(name, style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.w600)),
        trailing: pdfUrl != null
            ? IconButton(
                icon: const Icon(Icons.picture_as_pdf, color: Colors.redAccent),
                tooltip: 'PDF देखें',
                onPressed: () => _openUrl(pdfUrl),
              )
            : null,
      );
    },
  );
}

else if (index == 5) {
  // Tab 6: Old Papers
  if (_oldPapersLoading) {
    return const Center(child: CircularProgressIndicator());
  }

  if (_oldPapersData.isEmpty) {
    return Center(
      child: Text(
        'कोई डेटा उपलब्ध नहीं है',
        style: GoogleFonts.hindSiliguri(fontSize: 18),
      ),
    );
  }

  return Column(
    children: [
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: DropdownButton<String>(
          value: _selectedClass,
          isExpanded: true,
          hint: const Text("कक्षा चुनें"),
          items: _oldPapersData.keys
              .map((cls) => DropdownMenuItem(
                    value: cls,
                    child: Text('Class $cls'),
                  ))
              .toList(),
          onChanged: _onClassChanged,
        ),
      ),
      Expanded(
        child: _displayedOldPapers.isEmpty
            ? Center(
                child: Text(
                  'कोई डेटा उपलब्ध नहीं है',
                  style: GoogleFonts.hindSiliguri(fontSize: 18),
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: _displayedOldPapers.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, i) {
                  final paper = _displayedOldPapers[i];
                  final year = paper['year'] ?? 'Unknown';
                  final pdf = paper['pdf'];
                  final pdfUrl = pdf != null
                      ? 'https://website.sadhumargi.in/storage/${pdf.replaceAll(r'\', '/')}' 
                      : null;

                  return ListTile(
                    title: Text('Year: $year',
                        style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.w600)),
                    trailing: pdfUrl != null
                        ? IconButton(
                            icon: const Icon(Icons.picture_as_pdf, color: Colors.redAccent),
                            tooltip: 'PDF देखें',
                            onPressed: () => _openUrl(pdfUrl),
                          )
                        : null,
                  );
                },
              ),
      ),
    ],
  );
}

  // Placeholder content for other tabs
  List<String> tabTitles = [
    'JSP',
    'JSP Exam',
    'JSP Big Exam',
    'JSP Hindi Books',
    'JSP Gujarati Books',
    'JSP Old Papers',
  ];

  return Center(
    child: Text(
      '${tabTitles[index]} कंटेंट यहाँ होगा',
      style: GoogleFonts.hindSiliguri(fontSize: 18),
    ),
  );
}


  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      selectedIndex: -1,
      body: Column(
        children: [
          Container(
            color: Colors.blue.shade50,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: Colors.blue.shade900,
              unselectedLabelColor: Colors.grey.shade600,
              indicatorColor: Colors.blue.shade900,
              labelStyle: GoogleFonts.hindSiliguri(fontWeight: FontWeight.w600),
              tabs: const [
                Tab(text: 'JSP'),
                Tab(text: 'JSP Exam'),
                Tab(text: 'JSP Big Exam'),
                Tab(text: 'JSP Hindi Books'),
                Tab(text: 'JSP Gujarati Books'),
                Tab(text: 'JSP Old Papers'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: List.generate(6, (index) => _buildTabContent(index)),
            ),
          ),
        ],
      ),
    );
  }
}
