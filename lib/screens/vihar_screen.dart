import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'base_scaffold.dart';

class ViharScreen extends StatefulWidget {
  const ViharScreen({super.key});

  @override
  State<ViharScreen> createState() => _ViharScreenState();
}

class _ViharScreenState extends State<ViharScreen> {
  DateTime selectedDate = DateTime.now();
  List<dynamic> viharData = [];
  bool isLoading = false;
  bool isHtml = false;
  String htmlUrl = '';

  late final WebViewController _webViewController;

  @override
  void initState() {
    super.initState();

    // Enable hybrid composition for Android WebView
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted);

    fetchViharData();
  }

  Future<void> fetchViharData() async {
    setState(() {
      isLoading = true;
      isHtml = false;
    });

    final formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
    final url = 'https://vihar.sadhumargi.com/test_api.php?viewby_date=$formattedDate';
    htmlUrl = url;

    try {
      final response = await http.get(Uri.parse(url), headers: {
        "Accept": "application/json",
        "User-Agent": "Flutter-App",
      });

      print("API URL: $url");
      print("Response Status: ${response.statusCode}");

      if (response.statusCode == 200) {
        if (response.body.trimLeft().startsWith("<!DOCTYPE html")) {
          print("⚠️ HTML response received instead of JSON");
          isHtml = true;
          viharData = [];
          _webViewController.loadRequest(Uri.parse(htmlUrl));
        } else {
          final parsed = json.decode(response.body);
          if (parsed is List) {
            viharData = parsed;
            print("✅ ${viharData.length} items loaded");
          } else {
            print("⚠️ Invalid JSON format (not List)");
            viharData = [];
          }
        }
      } else {
        print("❌ Server Error: ${response.statusCode}");
        viharData = [];
      }
    } catch (e) {
      print("❌ Exception: $e");
      viharData = [];
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2024, 1),
      lastDate: DateTime(2026, 12),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
      fetchViharData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      selectedIndex: -1,
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDate(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today),
                          const SizedBox(width: 10),
                          Text(
                            DateFormat('dd MMM yyyy').format(selectedDate),
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (isLoading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (isHtml)
              Expanded(
                child: WebViewWidget(controller: _webViewController),
              )
            else if (viharData.isEmpty)
              const Expanded(child: Center(child: Text("कोई डेटा नहीं मिला")))
            else
              Expanded(
                child: ListView.builder(
                  itemCount: viharData.length,
                  itemBuilder: (context, index) {
                    final item = viharData[index];
                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("क्रम संख्या: ${index + 1}", style: const TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 5),
                            _row("चारित्रात्माओं के नाम", item['charitraatmaon_ke_naam']),
                            _row("ठाणा", item['thana']),
                            _row("विहार कहाँ से", item['vihar_kaha_se']),
                            _row("विहार कहाँ तक", item['vihar_kaha_tak']),
                            _row("किमी", item['km']),
                            _row("विराजने का स्थान", item['virajne_ka_sthan']),
                            _row("विहारकर्मी", item['vihar_karmi']),
                            _row("सक्रिय व्यक्ति", item['sakriya_vyakti']),
                          ],
                        ),
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

  Widget _row(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label: ",
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          Expanded(
            child: Text(value ?? ''),
          ),
        ],
      ),
    );
  }
}
