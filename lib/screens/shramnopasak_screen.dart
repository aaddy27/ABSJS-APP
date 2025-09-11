import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class ShramnopasakScreen extends StatefulWidget {
  const ShramnopasakScreen({super.key});

  @override
  State<ShramnopasakScreen> createState() => _ShramnopasakScreenState();
}

class _ShramnopasakScreenState extends State<ShramnopasakScreen> {
  String? selectedYear;
  List<String> years = [];
  List<dynamic> allData = [];
  Map<String, dynamic>? latestData;
  List<dynamic> filteredYearData = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // 1. Load data from cache
    await _fetchDataFromCache();
    // 2. Fetch latest data from API and update
    await _fetchDataFromApi();
  }

  Future<void> _fetchDataFromCache() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedLatest = prefs.getString('latestShramnopasak');
    final cachedAll = prefs.getString('allShramnopasak');

    if (cachedLatest != null) {
      latestData = jsonDecode(cachedLatest);
    }
    if (cachedAll != null) {
      allData = jsonDecode(cachedAll);
      _processData();
    }
  }

  Future<void> _fetchDataFromApi() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Fetch latest issue
    final latestResponse = await http.get(Uri.parse('https://website.sadhumargi.in/api/shramnopasak/latest'));
    if (latestResponse.statusCode == 200) {
      final latestDecoded = jsonDecode(latestResponse.body);
      if (latestDecoded is Map && latestDecoded.containsKey('data')) {
        setState(() {
          latestData = latestDecoded['data'];
        });
        prefs.setString('latestShramnopasak', jsonEncode(latestData));
      }
    }

    // Fetch all issues
    final allResponse = await http.get(Uri.parse('https://website.sadhumargi.in/api/shramnopasak'));
    if (allResponse.statusCode == 200) {
      final List allDecoded = jsonDecode(allResponse.body);
      setState(() {
        allData = allDecoded;
      });
      prefs.setString('allShramnopasak', jsonEncode(allData));
      _processData();
    }
  }

  void _processData() {
    Set<String> yearSet = {};
    for (var item in allData) {
      if (item['year'] != null) {
        yearSet.add(item['year'].toString());
      }
    }
    setState(() {
      years = yearSet.toList()..sort((a, b) => b.compareTo(a));
      if (selectedYear == null && years.isNotEmpty) {
        selectedYear = years.first;
        filterByYear(selectedYear!);
      } else if (selectedYear != null) {
        filterByYear(selectedYear!);
      }
    });
  }

  void filterByYear(String year) {
    setState(() {
      selectedYear = year;
      filteredYearData = allData.where((e) => e['year'].toString() == year).toList();
    });
  }

  Future<void> openFile(Map<String, dynamic> item) async {
    String? urlToOpen;
    if (item['file_type'] == 'pdf' && item['pdf'] != null && item['pdf'].toString().isNotEmpty) {
      urlToOpen = "https://website.sadhumargi.in/storage/${item['pdf']}";
    } else if (item['file_type'] == 'drive' && item['drive_link'] != null && item['drive_link'].toString().isNotEmpty) {
      urlToOpen = item['drive_link'];
    }

    if (urlToOpen != null && urlToOpen.isNotEmpty) {
      if (await canLaunchUrl(Uri.parse(urlToOpen))) {
        await launchUrl(Uri.parse(urlToOpen), mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open the file')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No file available to open')),
      );
    }
  }

  @override
@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color(0xFFF8F9FA),
    appBar: AppBar(
      title: Text(
        "श्रमणोपासक",
        style: GoogleFonts.amita(
          fontSize: 38,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF90963E),
        ),
      ),
      centerTitle: true,
      backgroundColor: Colors.white,
      elevation: 0,
    ),
    body: RefreshIndicator(
      onRefresh: _fetchDataFromApi,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (latestData != null) ...[
              _buildLatestCard(latestData!),
            ] else ...[
              const Center(child: CircularProgressIndicator()),
              const SizedBox(height: 30),
            ],
            
            if (years.isNotEmpty) ...[
              const SizedBox(height: 20),
              Text(
                "संग्रह (वर्षानुसार)",
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF333333),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: "Select Year",
                  labelStyle: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.white,
                ),
                value: selectedYear,
                items: years.map((year) {
                  return DropdownMenuItem(
                    value: year,
                    child: Text(year, style: GoogleFonts.poppins(fontSize: 16)),
                  );
                }).toList(),
                onChanged: (value) => filterByYear(value!),
              ),
              const SizedBox(height: 20),
              if (filteredYearData.isNotEmpty)
                _buildGrid(filteredYearData),
            ] else if (latestData != null) ...[
              const SizedBox(height: 20),
              const Center(child: Text("No other issues available.")),
            ],
          ],
        ),
      ),
    ),
  );
}

Widget _buildLatestCard(Map<String, dynamic> latest) {
  final coverUrl = (latest['cover_photo'] != null && latest['cover_photo'].toString().isNotEmpty)
      ? "https://website.sadhumargi.in/storage/${latest['cover_photo']}"
      : "https://via.placeholder.com/936x1254?text=No+Image";

  return Container(
    margin: const EdgeInsets.only(bottom: 20),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      color: Colors.white,
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.3),
          spreadRadius: 2,
          blurRadius: 10,
          offset: const Offset(0, 5),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: AspectRatio(
            aspectRatio: 936 / 1254,
            child: Image.network(
              coverUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const Center(
                child: Icon(
                  Icons.image_not_supported,
                  size: 80,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "नवीनतम अंक",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF90963E),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "${latest['month'] ?? ''} ${latest['year'] ?? ''}",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF333333),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => openFile(latest),
                  icon: Icon(
                    latest['file_type'] == 'pdf' ? Icons.picture_as_pdf : Icons.cloud_download,
                    color: Colors.white,
                  ),
                  label: Text(
                    "Read Now",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF90963E),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

  Widget _buildGrid(List<dynamic> data) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: data.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.6,
      ),
      itemBuilder: (context, index) {
        final item = data[index];
        final coverUrl = (item['cover_photo'] != null && item['cover_photo'].toString().isNotEmpty)
            ? "https://website.sadhumargi.in/storage/${item['cover_photo']}"
            : "https://via.placeholder.com/936x1254?text=No+Image";

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: InkWell(
            onTap: () => openFile(item),
            borderRadius: BorderRadius.circular(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: AspectRatio(
                    aspectRatio: 936 / 1254,
                    child: Image.network(
                      coverUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Center(
                        child: Icon(
                          Icons.image_not_supported,
                          size: 50,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                  child: Text(
                    "${item['month'] ?? ''} ${item['year'] ?? ''}",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: const Color(0xFF333333),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}