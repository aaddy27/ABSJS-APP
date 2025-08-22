// lib/screens/mahila_samiti/events/mahila_events_screen.dart
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';

class MahilaEventsScreen extends StatefulWidget {
  const MahilaEventsScreen({super.key});

  @override
  State<MahilaEventsScreen> createState() => _MahilaEventsScreenState();
}

class _MahilaEventsScreenState extends State<MahilaEventsScreen> {
  List events = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchEvents();
  }

  Future<void> fetchEvents() async {
    final url = Uri.parse('https://website.sadhumargi.in/api/mahila-events');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          events = data;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        debugPrint('Failed to load events: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      debugPrint('Error fetching events: $e');
    }
  }

  void showImageFullScreen(String imageUrl) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        insetPadding: EdgeInsets.all(10),
        child: Stack(
          children: [
            InteractiveViewer(
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: IconButton(
                icon: const Icon(Icons.close, size: 30, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showFullContent(String title, String content) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        insetPadding: EdgeInsets.all(20),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: GoogleFonts.amita(
                    fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                child: Text(
                  content,
                  style: GoogleFonts.amita(fontSize: 16),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  // Heading
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 20.0, horizontal: 16),
                    child: Text(
                      'गतिविधियाँ',
                      style: GoogleFonts.amita(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[800],
                      ),
                    ),
                  ),

                  // Events list
                  Expanded(
                    child: events.isEmpty
                        ? Center(
                            child: Text(
                              'कोई कार्यक्रम उपलब्ध नहीं हैं',
                              style: GoogleFonts.amita(fontSize: 18),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: events.length,
                            itemBuilder: (context, index) {
                              final event = events[index];
                              final content = event['content'] ?? '';
                              final isLongContent = content.length > 100;
                              return Card(
                                margin: const EdgeInsets.only(bottom: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 4,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                  if (event['photo'] != null)
  GestureDetector(
    onTap: () => showImageFullScreen(
        'https://website.sadhumargi.in/storage/${event['photo']}'),
    child: ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      child: Image.network(
        'https://website.sadhumargi.in/storage/${event['photo']}',
        fit: BoxFit.contain, // contain se portrait full visible
        width: double.infinity,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return const SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator()),
          );
        },
      ),
    ),
  ),

                                    Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            event['title'] ?? '',
                                            style: GoogleFonts.amita(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            isLongContent
                                                ? '${content.substring(0, 100)}...'
                                                : content,
                                            style: GoogleFonts.amita(
                                              fontSize: 16,
                                            ),
                                          ),
                                          if (isLongContent)
                                            Align(
                                              alignment: Alignment.centerRight,
                                              child: TextButton(
                                                onPressed: () =>
                                                    showFullContent(
                                                        event['title'] ?? '',
                                                        content),
                                                child: const Text('View More'),
                                              ),
                                            ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Date: ${event['created_at']?.substring(0, 10) ?? ''}',
                                            style: GoogleFonts.amita(
                                              fontSize: 14,
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
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
