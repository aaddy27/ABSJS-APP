import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../layout_screen.dart';

class MahilaExPresidentScreen extends StatefulWidget {
  const MahilaExPresidentScreen({super.key});

  @override
  State<MahilaExPresidentScreen> createState() => _MahilaExPresidentScreenState();
}

class _MahilaExPresidentScreenState extends State<MahilaExPresidentScreen> {
  List<dynamic> exPresidents = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchExPresidents();
  }

  Future<void> fetchExPresidents() async {
    const String url = "https://website.sadhumargi.in/api/mahila-ex-prsident";
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        setState(() {
          exPresidents = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        throw Exception("Failed to load data");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      debugPrint("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutScreen(
      title: "गौरवमयी अध्यक्षाएँ",
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : exPresidents.isEmpty
              ? const Center(child: Text("No data found"))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: exPresidents.length,
                  itemBuilder: (context, index) {
                    final item = exPresidents[index];
                    final String name = item["name"] ?? "";
                    final String place = item["place"] ?? "";
                    final String karyakal = item["karyakal"]?.toString() ?? "";
                    final String photoUrl =
                        "https://website.sadhumargi.in${item['photo']}";

                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      elevation: 4,
                      child: ListTile(
                        leading: CircleAvatar(
                          radius: 30,
                          backgroundImage: NetworkImage(photoUrl),
                          backgroundColor: Colors.grey[200],
                        ),
                        title: Text(
                          name,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          "स्थान: $place\nकार्यकाल: ${karyakal.isEmpty ? "—" : karyakal}",
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
