// lib/screens/mahila_samiti/karyakarini/mahila_pst_screen.dart
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../layout_screen.dart';

class MahilaPstScreen extends StatefulWidget {
  const MahilaPstScreen({super.key});

  @override
  State<MahilaPstScreen> createState() => _MahilaPstScreenState();
}

class _MahilaPstScreenState extends State<MahilaPstScreen> {
  List<dynamic> presidents = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPresidents();
  }

  Future<void> fetchPresidents() async {
    const String url = "https://website.sadhumargi.in/api/mahila-pst";
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        setState(() {
          presidents = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        throw Exception("Failed to load data");
      }
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint("Error fetching presidents: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutScreen(
      title: "वर्तमान कार्यकारिणी",
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : presidents.isEmpty
              ? const Center(child: Text("No data found"))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: presidents.length,
                  itemBuilder: (context, index) {
                    final item = presidents[index];
                    final String name = item["name"] ?? "";
                    final String post = item["post"] ?? "";
                    final String photoUrl =
                        "https://website.sadhumargi.in${item['photo']}";

                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      elevation: 3,
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
                        subtitle: Text("पद: $post"),
                      ),
                    );
                  },
                ),
    );
  }
}
