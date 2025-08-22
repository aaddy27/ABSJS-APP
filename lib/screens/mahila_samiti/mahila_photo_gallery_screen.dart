// lib/screens/mahila_samiti/mahila_photo_gallery_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class MahilaPhotoGalleryScreen extends StatefulWidget {
  const MahilaPhotoGalleryScreen({super.key});

  @override
  State<MahilaPhotoGalleryScreen> createState() => _MahilaPhotoGalleryScreenState();
}

class _MahilaPhotoGalleryScreenState extends State<MahilaPhotoGalleryScreen> {
  List<dynamic> events = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchGallery();
  }

  Future<void> fetchGallery() async {
    final url = Uri.parse('https://website.sadhumargi.in/api/photo-gallery/fetch/mahila');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          events = json.decode(response.body);
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        throw Exception('Failed to load gallery');
      }
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint('Error fetching gallery: $e');
    }
  }

  void openFullScreenGallery(List<dynamic> photos, int initialIndex, String eventName) {
    List<String> photoUrls = photos.map((p) => p['url'].toString()).toList();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FullScreenGalleryScreen(
          photos: photoUrls,
          initialIndex: initialIndex,
          eventName: eventName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Heading
                    Text(
                      ' Photo Gallery',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.amita(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.pink.shade800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: ListView.builder(
                        itemCount: events.length,
                        itemBuilder: (context, index) {
                          final event = events[index];
                          final photos = event['photos'] as List<dynamic>;
                          return Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                            elevation: 4,
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    event['event_name'] ?? 'Event',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.amita(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.pink.shade700,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  GridView.builder(
                                    physics: const NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    itemCount: photos.length,
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3,
                                      crossAxisSpacing: 4,
                                      mainAxisSpacing: 4,
                                    ),
                                    itemBuilder: (context, photoIndex) {
                                      final photoUrl = photos[photoIndex]['url'];
                                      return GestureDetector(
                                        onTap: () => openFullScreenGallery(
                                            photos, photoIndex, event['event_name']),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: Image.network(
                                            photoUrl,
                                            fit: BoxFit.cover,
                                            loadingBuilder:
                                                (context, child, progress) {
                                              if (progress == null) return child;
                                              return const Center(
                                                  child:
                                                      CircularProgressIndicator());
                                            },
                                          ),
                                        ),
                                      );
                                    },
                                  ),
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
            ),
    );
  }
}

// Full screen swipeable gallery with buttons
class FullScreenGalleryScreen extends StatefulWidget {
  final List<String> photos;
  final int initialIndex;
  final String eventName;

  const FullScreenGalleryScreen({
    super.key,
    required this.photos,
    this.initialIndex = 0,
    required this.eventName,
  });

  @override
  State<FullScreenGalleryScreen> createState() =>
      _FullScreenGalleryScreenState();
}

class _FullScreenGalleryScreenState extends State<FullScreenGalleryScreen> {
  late PageController _pageController;
  late int currentIndex;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: currentIndex);
  }

  void goToPrevious() {
    if (currentIndex > 0) {
      _pageController.previousPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  void goToNext() {
    if (currentIndex < widget.photos.length - 1) {
      _pageController.nextPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.photos.length,
            onPageChanged: (index) {
              setState(() {
                currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return InteractiveViewer(
                child: Center(
                  child: Image.network(
                    widget.photos[index],
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return const Center(child: CircularProgressIndicator());
                    },
                  ),
                ),
              );
            },
          ),
          Positioned(
            top: 40,
            left: 16,
            right: 16,
            child: Center(
              child: Text(
                widget.eventName,
                style: GoogleFonts.amita(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Positioned(
            top: 40,
            right: 20,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          Positioned(
            bottom: 30,
            left: 30,
            child: ElevatedButton(
              onPressed: goToPrevious,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white54,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: const Icon(Icons.arrow_back, color: Colors.black),
            ),
          ),
          Positioned(
            bottom: 30,
            right: 30,
            child: ElevatedButton(
              onPressed: goToNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white54,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: const Icon(Icons.arrow_forward, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
