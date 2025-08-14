import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
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
  late Future<Map<String, dynamic>?> latestData;
  List<dynamic> filteredYearData = [];

  @override
  void initState() {
    super.initState();
    latestData = fetchLatest();
    fetchAllData();
  }

  Future<Map<String, dynamic>?> fetchLatest() async {
    final url = 'https://website.sadhumargi.in/api/shramnopasak/latest';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded is Map && decoded.containsKey('data')) {
        return decoded['data'];
      }
    }
    return null;
  }

  Future<void> fetchAllData() async {
    final url = 'https://website.sadhumargi.in/api/shramnopasak';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List decoded = jsonDecode(response.body);
      Set<String> yearSet = {};
      for (var item in decoded) {
        if (item['year'] != null) {
          yearSet.add(item['year'].toString());
        }
      }
      setState(() {
        allData = decoded;
        years = yearSet.toList()..sort((a, b) => b.compareTo(a));
      });
    }
  }

  void filterByYear(String year) {
    setState(() {
      selectedYear = year;
      filteredYearData = allData.where((e) => e['year'] == year).toList();
    });
  }

  Future<void> openFile(Map<String, dynamic> item) async {
    String? urlToOpen;

    if (item['file_type'] == 'pdf' && item['pdf'] != null && item['pdf'].toString().isNotEmpty) {
      urlToOpen = "https://website.sadhumargi.in/storage/${item['pdf']}";
    } else if (item['file_type'] == 'drive' &&
        item['drive_link'] != null &&
        item['drive_link'].toString().isNotEmpty) {
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

Widget buildGrid(List<dynamic> data) {
  return GridView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    itemCount: data.length,
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      crossAxisSpacing: 14,
      mainAxisSpacing: 14,
      childAspectRatio: 0.65,
    ),
    itemBuilder: (context, index) {
      final item = data[index];
      final coverUrl = (item['cover_photo'] != null &&
              item['cover_photo'].toString().isNotEmpty)
          ? "https://website.sadhumargi.in/storage/${item['cover_photo']}"
          : "https://via.placeholder.com/936x1254?text=No+Image";

      return InkWell(
        onTap: () => openFile(item),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 936 / 1254,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  coverUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.image_not_supported,
                    size: 50,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "${item['month'] ?? ''} ${item['year'] ?? ''}",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Colors.black87,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      );
    },
  );
}


  Widget buildLatestCard(Map<String, dynamic> latest) {
    final coverUrl = (latest['cover_photo'] != null && latest['cover_photo'].toString().isNotEmpty)
        ? "https://website.sadhumargi.in/storage/${latest['cover_photo']}"
        : "https://via.placeholder.com/300x400?text=No+Image";

    return Column(
      children: [
        Text(
          "",
          style: GoogleFonts.playfairDisplay(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF90963E),
          ),
        ),
        const SizedBox(height: 20),
        Card(
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => openFile(latest),
            child: Column(
              children: [
           ClipRRect(
  borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
  child: AspectRatio(
    aspectRatio: 936 / 1254,
    child: Image.network(
      coverUrl,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => const Icon(
        Icons.image_not_supported,
        size: 50,
        color: Colors.grey,
      ),
    ),
  ),
),

                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Text(
                        "${latest['month'] ?? ''} ${latest['year'] ?? ''}",
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Icon(
                        Icons.picture_as_pdf,
                        color: latest['file_type'] == 'pdf' ? Colors.redAccent : Colors.green,
                        size: 30,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFF8F9FA), Color(0xFFE9ECEF)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      padding: const EdgeInsets.all(14),
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 10),
            Text(
              "श्रमणोपासक",
              textAlign: TextAlign.center,
              style: GoogleFonts.amita(
                fontSize: 44,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: const Color(0xFF90963E),
              ),
            ),
            const SizedBox(height: 20),

            FutureBuilder<Map<String, dynamic>?>(
              future: latestData,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data == null) {
                  return const Text("Latest Shramnopasak not available");
                }
                return buildLatestCard(snapshot.data!);
              },
            ),

            const SizedBox(height: 30),

            if (years.isNotEmpty)
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

          if (selectedYear != null && filteredYearData.isNotEmpty)
  Padding(
    padding: const EdgeInsets.only(bottom: 20),
    child: buildGrid(filteredYearData),
  ),

          ],
        ),
      ),
    );
  }
}
