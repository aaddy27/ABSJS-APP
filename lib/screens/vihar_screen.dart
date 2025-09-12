import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
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
  bool triedOpenExternal = false;
  String htmlUrl = '';

  // Browser-like UA (helps bypass some WAF rules)
  static const String _browserLikeUA =
      'Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/115.0.0.0 Mobile Safari/537.36';

  @override
  void initState() {
    super.initState();
    fetchViharData();
  }

  Future<void> fetchViharData() async {
    setState(() {
      isLoading = true;
      triedOpenExternal = false;
    });

    final formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
    final url = 'https://vihar.sadhumargi.com/test_api.php?viewby_date=$formattedDate';
    htmlUrl = url;

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Accept": "application/json",
          "User-Agent": _browserLikeUA,
        },
      );

      print("API URL: $url");
      print("Response Status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final body = response.body ?? '';
        final trimmed = body.trimLeft();

        // अगर HTML response मिला → सीधे external browser में खोल दो
        if (trimmed.startsWith("<!DOCTYPE html") || trimmed.startsWith('<html')) {
          print("HTML received — opening external browser: $url");
          await _openInExternalBrowser(url);
          // mark that we attempted external open so UI can show message
          triedOpenExternal = true;
          viharData = [];
        } else {
          // कोशिश करो JSON parse करने की
          try {
            final parsed = json.decode(body);
            if (parsed is List) {
              viharData = parsed;
              print("Loaded ${viharData.length} items");
            } else {
              print("JSON parsed but not a List. Showing empty.");
              viharData = [];
            }
          } catch (e) {
            print("JSON parse error: $e — opening external browser as fallback.");
            // JSON parse failed — open external browser
            await _openInExternalBrowser(url);
            triedOpenExternal = true;
            viharData = [];
          }
        }
      } else {
        print("Server error ${response.statusCode} — trying to open external browser as fallback.");
        await _openInExternalBrowser(url);
        triedOpenExternal = true;
        viharData = [];
      }
    } catch (e) {
      print("Exception while fetching: $e — opening external browser as fallback.");
      await _openInExternalBrowser(url);
      triedOpenExternal = true;
      viharData = [];
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _openInExternalBrowser(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      // अगर external open न हो पाए तो user को बताओ
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('बाहरी ब्राउज़र खोलने में विफल।')),
        );
      }
    }
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
            else if (triedOpenExternal)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.open_in_browser, size: 64, color: Colors.blue),
                      const SizedBox(height: 12),
                      const Text(
                        "यह सामग्री ब्राउज़र में खुल गयी है।\nयदि ब्राउज़र नहीं खुला, तो नीचे बटन से फिर खोलें।",
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () => _openInExternalBrowser(htmlUrl),
                        child: const Text("ब्राउज़र में फिर खोलें"),
                      ),
                    ],
                  ),
                ),
              )
            else if (viharData.isEmpty)
              Expanded(child: Center(child: Text("कोई डेटा नहीं मिला", style: TextStyle(color: Colors.grey.shade700))))
            else
              Expanded(
                child: ListView.builder(
                  itemCount: viharData.length,
                  itemBuilder: (context, index) {
                    final item = viharData[index] as Map<String, dynamic>;
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

  Widget _row(String label, dynamic value) {
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
            child: Text(value?.toString() ?? ''),
          ),
        ],
      ),
    );
  }
}
