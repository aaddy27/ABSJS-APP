import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:ui';
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
      CupertinoPageRoute(
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
      return const Center(child: CupertinoActivityIndicator());
    }

    if (_events.isEmpty) {
      return const SafeArea(
        child: Center(child: Text("कोई फ़ोटो उपलब्ध नहीं है")),
      );
    }

    final bg = CupertinoTheme.of(context).scaffoldBackgroundColor;

    return SafeArea(
      child: Container(
        color: bg,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Heading
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Text(
                "फोटो गैलरी",
                textAlign: TextAlign.center,
                style: GoogleFonts.amita(
                  fontSize: 38,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.3,
                ),
              ),
            ),

            // Content
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                itemCount: _events.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final event = _events[index];
                  final List photos = (event['photos'] as List?) ?? [];
                  final String? firstPhoto =
                      photos.isNotEmpty ? photos[0]['url'] as String? : null;

                  return GestureDetector(
                    onTap: () => _openGallery(photos, 0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemBackground.resolveFrom(context),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                        border: Border.all(
                          color: CupertinoColors.separator.resolveFrom(context),
                          width: 0.5,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Event Title
                          Padding(
                            padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                            child: Text(
                              (event['event_name'] ?? "कार्यक्रम").toString(),
                              textAlign: TextAlign.center,
                              style: GoogleFonts.amita(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),

                          // Cover Image
                          if (firstPhoto != null)
                            ClipRRect(
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(20),
                                bottomRight: Radius.circular(20),
                              ),
                              child: Stack(
                                children: [
                                  AspectRatio(
                                    aspectRatio: 16 / 9,
                                    child: Image.network(
                                      firstPhoto,
                                      fit: BoxFit.cover,
                                      loadingBuilder: (context, child, progress) {
                                        if (progress == null) return child;
                                        return const Center(
                                          child: CupertinoActivityIndicator(),
                                        );
                                      },
                                      errorBuilder: (context, error, stack) => Container(
                                        color: CupertinoColors.systemGrey4,
                                        child: const Center(
                                          child: Icon(CupertinoIcons.exclamationmark_triangle),
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (photos.length > 1)
                                    Positioned(
                                      right: 10,
                                      bottom: 10,
                                      child: _MultiBadge(count: photos.length),
                                    ),
                                ],
                              ),
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
    );
  }
}

class _MultiBadge extends StatelessWidget {
  final int count;
  const _MultiBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.35),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white.withOpacity(0.25), width: 0.8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(CupertinoIcons.photo_on_rectangle, size: 16, color: Colors.white),
              const SizedBox(width: 6),
              Text(
                "$count",
                style: GoogleFonts.notoSansDevanagari(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Full Screen Gallery
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
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.black,
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          "${_current + 1} / ${widget.photos.length}",
          style: GoogleFonts.notoSansDevanagari(
            color: CupertinoColors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: CupertinoColors.black.withOpacity(0.4),
        border: null,
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.of(context).pop(),
          child: const Icon(CupertinoIcons.xmark, color: CupertinoColors.white),
        ),
      ),
      child: SafeArea(
        top: false,
        child: PageView.builder(
          controller: _pageController,
          itemCount: widget.photos.length,
          onPageChanged: (i) => setState(() => _current = i),
          itemBuilder: (context, index) {
            final url = widget.photos[index]['url'] as String?;
            return InteractiveViewer(
              child: Center(
                child: url == null
                    ? const Icon(CupertinoIcons.photo, color: CupertinoColors.white, size: 80)
                    : Image.network(
                        url,
                        fit: BoxFit.contain,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return const CupertinoActivityIndicator(color: CupertinoColors.white);
                        },
                        errorBuilder: (context, error, stack) =>
                            const Icon(CupertinoIcons.photo, color: CupertinoColors.white, size: 80),
                      ),
              ),
            );
          },
        ),
      ),
    );
  }
}
