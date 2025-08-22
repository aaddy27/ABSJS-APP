import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';

class PhotoGalleryScreen extends StatefulWidget {
  const PhotoGalleryScreen({super.key});

  @override
  State<PhotoGalleryScreen> createState() => _PhotoGalleryScreenState();
}

class _PhotoGalleryScreenState extends State<PhotoGalleryScreen> {
  List<dynamic> _events = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    fetchGallery();
  }

  Future<void> fetchGallery() async {
    try {
      final response = await http.get(
        Uri.parse("https://website.sadhumargi.in/api/photo-gallery/fetch/yuva"),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _events = data;
          _loading = false;
        });
      } else {
        setState(() => _loading = false);
      }
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  void _openGallery(List photos, int initialIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FullScreenGallery(
          photos: photos,
          initialIndex: initialIndex,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_events.isEmpty) {
      return const Center(child: Text("No photos available"));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _events.length,
      itemBuilder: (context, index) {
        final event = _events[index];
        final photos = event['photos'] as List;
        final firstPhoto = photos.isNotEmpty ? photos[0]['url'] : null;

        return Card(
          elevation: 4,
          margin: const EdgeInsets.only(bottom: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.brown.shade200, width: 1),
          ),
          color: Colors.brown.shade50,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _openGallery(photos, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (firstPhoto != null)
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    child: Image.network(
                      firstPhoto,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return const SizedBox(
                          height: 200,
                          child: Center(child: CircularProgressIndicator()),
                        );
                      },
                      errorBuilder: (context, error, stack) => Container(
                        height: 200,
                        color: Colors.grey.shade300,
                        child: const Icon(Icons.broken_image, size: 50),
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Center(
                    child: Text(
                      event['event_name'] ?? "Event",
                      style: GoogleFonts.amita(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.brown.shade800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// 🔹 Full Screen Gallery
class FullScreenGallery extends StatefulWidget {
  final List photos;
  final int initialIndex;

  const FullScreenGallery({
    super.key,
    required this.photos,
    required this.initialIndex,
  });

  @override
  State<FullScreenGallery> createState() => _FullScreenGalleryState();
}

class _FullScreenGalleryState extends State<FullScreenGallery> {
  late PageController _pageController;
  late int _current;

  @override
  void initState() {
    super.initState();
    _current = widget.initialIndex;
    _pageController = PageController(initialPage: _current);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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
            onPageChanged: (i) => setState(() => _current = i),
            itemBuilder: (context, index) {
              final url = widget.photos[index]['url'];
              return InteractiveViewer(
                child: Center(
                  child: Image.network(
                    url,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return const Center(child: CircularProgressIndicator(color: Colors.white));
                    },
                    errorBuilder: (context, error, stack) => const Icon(Icons.broken_image, color: Colors.white, size: 80),
                  ),
                ),
              );
            },
          ),
          // Close Button
          Positioned(
            top: 40,
            right: 20,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          // Counter
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                "${_current + 1} / ${widget.photos.length}",
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          )
        ],
      ),
    );
  }
}
