import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import '../../base_scaffold.dart';

class ExPresidentScreen extends StatefulWidget {
  const ExPresidentScreen({super.key});

  @override
  State<ExPresidentScreen> createState() => _ExPresidentScreenState();
}

class _ExPresidentScreenState extends State<ExPresidentScreen> {
  List<dynamic> _exPresidents = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    fetchExPresidents();
  }

  Future<void> fetchExPresidents() async {
    final url = Uri.parse('https://website.sadhumargi.in/api/ex-president');
    try {
      final response = await http.get(url);

      print("Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _exPresidents = data;
          _loading = false;
        });
      } else {
        setState(() {
          _error = 'Server error: ${response.statusCode}';
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Exception: $e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      selectedIndex: -1,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                       Center(
  child: Text(
    'पूर्व अध्यक्षगण',
    style: GoogleFonts.hind(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: Colors.black87,
    ),
  ),
),

                        const SizedBox(height: 16),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _exPresidents.length,
                          itemBuilder: (context, index) {
                            final item = _exPresidents[index];
                            return Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              margin: const EdgeInsets.only(bottom: 16),
                              child: ListTile(
                                leading: CircleAvatar(
                                  radius: 30,
                                  backgroundImage: NetworkImage(
                                    "https://website.sadhumargi.in/storage/${item['photo']}",
                                  ),
                                ),
                                title: Text(
                                  item['name'],
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("स्थान: ${item['place']}"),
                                    Text("कार्यकाल: ${item['karaykal']}"),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}
