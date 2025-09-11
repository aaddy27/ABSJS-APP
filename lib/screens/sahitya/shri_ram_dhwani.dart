import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import '../base_scaffold.dart';

class ShriRamDhwaniScreen extends StatefulWidget {
  const ShriRamDhwaniScreen({super.key});

  @override
  State<ShriRamDhwaniScreen> createState() => _ShriRamDhwaniScreenState();
}

class _ShriRamDhwaniScreenState extends State<ShriRamDhwaniScreen> {
  static const String _cacheKey = 'shri_ram_dhwani_cache_v1';
  static const String _imagesDirName = 'shri_ram_dhwani_covers';

  List<dynamic> _books = [];
  bool _isLoading = true;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _loadCacheThenRefresh();
  }

  Future<void> _loadCacheThenRefresh() async {
    await _loadCache();
    _refreshFromNetwork();
  }

  Future<void> _loadCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString(_cacheKey);
      if (cached != null) {
        final List<dynamic> decoded = jsonDecode(cached);
        if (mounted) {
          setState(() {
            _books = decoded;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoading = true);
      }
    } catch (e) {
      debugPrint('Cache load error: $e');
      if (mounted) setState(() => _isLoading = true);
    }
  }

  Future<void> _refreshFromNetwork({bool showSnackOnError = false}) async {
    if (_isRefreshing) return;
    final hadCache = _books.isNotEmpty;

    if (hadCache) {
      if (mounted) setState(() => _isRefreshing = true);
    } else {
      if (mounted) setState(() => _isLoading = true);
    }

    try {
      final res = await http.get(Uri.parse("https://website.sadhumargi.in/api/sahitya/category/shri_ram_dhwani"));
      if (res.statusCode == 200) {
        final List<dynamic> fetched = jsonDecode(res.body);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_cacheKey, jsonEncode(fetched));

        if (mounted) setState(() => _books = fetched);

        _ensureImagesForBooks(fetched);
      } else {
        debugPrint("Error fetching: ${res.statusCode}");
        if (showSnackOnError && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to fetch latest books')));
        }
      }
    } catch (e) {
      debugPrint("Exception fetching: $e");
      if (showSnackOnError && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error fetching books')));
      }
    } finally {
      if (hadCache) {
        if (mounted) setState(() => _isRefreshing = false);
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _ensureImagesForBooks(List<dynamic> books) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final imagesDir = Directory('${dir.path}/$_imagesDirName');
      if (!await imagesDir.exists()) await imagesDir.create(recursive: true);

      for (final b in books) {
        final id = b['id']?.toString();
        final remotePath = b['cover_photo'];
        if (id == null || remotePath == null) continue;

        final localFile = File('${imagesDir.path}/shri_ram_dhwani_$id${_extensionFromUrl(remotePath)}');
        if (!await localFile.exists()) {
          final imageUrl = 'https://website.sadhumargi.in$remotePath';
          final resp = await http.get(Uri.parse(imageUrl));
          if (resp.statusCode == 200) {
            await localFile.writeAsBytes(resp.bodyBytes);
          }
        }
      }
    } catch (e) {
      debugPrint('Image caching error: $e');
    }
  }

  String _extensionFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final last = uri.pathSegments.last;
      final dot = last.lastIndexOf('.');
      if (dot != -1) return last.substring(dot);
    } catch (_) {}
    return '.jpg';
  }

  Future<File?> _localImageFileForBook(dynamic book) async {
    try {
      final id = book['id']?.toString();
      final remotePath = book['cover_photo'];
      if (id == null || remotePath == null) return null;

      final dir = await getApplicationDocumentsDirectory();
      final imagesDir = Directory('${dir.path}/$_imagesDirName');
      final candidate = File('${imagesDir.path}/shri_ram_dhwani_$id${_extensionFromUrl(remotePath)}');
      if (await candidate.exists()) return candidate;
    } catch (_) {}
    return null;
  }

  Future<void> _openLink(String? pdf, String? driveLink) async {
    final url = (driveLink != null && driveLink.isNotEmpty)
        ? driveLink
        : (pdf != null ? 'https://website.sadhumargi.in$pdf' : null);

    if (url == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No link available')));
      return;
    }

    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint('Could not launch $url');
    }
  }

  Future<void> _onRefresh() async {
    await _refreshFromNetwork(showSnackOnError: true);
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      selectedIndex: -1,
      body: SafeArea(
        child: Column(
          children: [
            // Heading
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'राम ध्वनि',
                textAlign: TextAlign.center,
                style: GoogleFonts.roboto(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: const Color.fromARGB(255, 102, 87, 3),
                ),
              ),
            ),

            if (_isRefreshing)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 6),
                child: Center(
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),

            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: _onRefresh,
                      child: _books.isEmpty
                          ? ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: const [SizedBox(height: 80), Center(child: Text('No books found'))],
                            )
                          : GridView.builder(
                              padding: const EdgeInsets.all(12),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 16,
                                crossAxisSpacing: 16,
                                childAspectRatio: 0.65,
                              ),
                              itemCount: _books.length,
                              itemBuilder: (context, index) {
                                final book = _books[index];
                                final title = book['name'] ?? '';
                                final pdf = book['pdf'];
                                final driveLink = book['drive_link'];

                                return GestureDetector(
                                  onTap: () => _openLink(pdf, driveLink),
                                  child: Card(
                                    elevation: 3,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        Expanded(
                                          child: FutureBuilder<File?>(
                                            future: _localImageFileForBook(book),
                                            builder: (context, snap) {
                                              if (snap.connectionState == ConnectionState.done && snap.data != null) {
                                                return ClipRRect(
                                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                                  child: Image.file(snap.data!, fit: BoxFit.cover),
                                                );
                                              }
                                              final cover = book['cover_photo'];
                                              final coverUrl = cover != null ? 'https://website.sadhumargi.in$cover' : null;
                                              if (coverUrl != null) {
                                                return ClipRRect(
                                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                                  child: Image.network(
                                                    coverUrl,
                                                    fit: BoxFit.cover,
                                                    loadingBuilder: (context, child, progress) {
                                                      if (progress == null) return child;
                                                      return const Center(child: CircularProgressIndicator());
                                                    },
                                                    errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 40),
                                                  ),
                                                );
                                              }
                                              return Container(color: Colors.grey.shade200);
                                            },
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            title,
                                            textAlign: TextAlign.center,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
