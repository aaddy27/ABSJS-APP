import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';

import '../../base_scaffold.dart';

class CurrentPstScreen extends StatefulWidget {
  const CurrentPstScreen({super.key});

  @override
  State<CurrentPstScreen> createState() => _CurrentPstScreenState();
}

class _CurrentPstScreenState extends State<CurrentPstScreen> {
  List<dynamic> pstMembers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPstMembers();
  }

  Future<void> fetchPstMembers() async {
    final url = Uri.parse('https://website.sadhumargi.in/api/pst');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        setState(() {
          pstMembers = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching data: $e');
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
            : Column(
                children: [
                  Center(
                    child: Text(
                      'वर्तमान कार्यकारिणी',
                      style: GoogleFonts.amita(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: Colors.black87,
    ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView.builder(
                      itemCount: pstMembers.length,
                      itemBuilder: (context, index) {
                        final member = pstMembers[index];
                        final imageUrl =
                            'https://website.sadhumargi.in/storage/${member['photo']}';

                        return Card(
                          elevation: 3,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(imageUrl),
                              radius: 30,
                            ),
                            title: Text(
                              member['name'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(member['post']),
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
}
