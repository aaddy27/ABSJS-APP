import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:printing/printing.dart';
import '../../base_scaffold.dart';

class PadhadhikariParikshanKaryashalaScreen extends StatefulWidget {
  const PadhadhikariParikshanKaryashalaScreen({super.key});

  @override
  State<PadhadhikariParikshanKaryashalaScreen> createState() =>
      _PadhadhikariParikshanKaryashalaScreenState();
}

class _PadhadhikariParikshanKaryashalaScreenState
    extends State<PadhadhikariParikshanKaryashalaScreen> {
  List<dynamic> data = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    const String apiUrl =
        'https://website.sadhumargi.in/api/padhadhikari-prashashan-karyashala';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        setState(() {
          data = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error fetching data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> downloadAndPrintPDF(String pdfPath) async {
    final url = 'https://website.sadhumargi.in/storage/$pdfPath';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        await Printing.layoutPdf(
          onLayout: (_) => response.bodyBytes,
          name: pdfPath.split('/').last,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ PDF डाउनलोड नहीं हो सका')),
        );
      }
    } catch (e) {
      print("PDF error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ PDF डाउनलोड में त्रुटि हुई')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      selectedIndex: -1,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : data.isEmpty
                ? const Center(child: Text('कोई डेटा उपलब्ध नहीं है'))
                : ListView.builder(
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      final item = data[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        elevation: 3,
                        child: ListTile(
                          title: Text(item['name'] ?? ''),
                          trailing: IconButton(
                            icon: const Icon(Icons.download, color: Colors.green),
                            onPressed: () {
                              downloadAndPrintPDF(item['pdf']);
                            },
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
