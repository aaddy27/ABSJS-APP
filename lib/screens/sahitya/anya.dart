// anya_screen.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../base_scaffold.dart';

class AnyaScreen extends StatefulWidget {
  const AnyaScreen({super.key});

  @override
  State<AnyaScreen> createState() => _AnyaScreenState();
}

class _AnyaScreenState extends State<AnyaScreen> {
  static const String _cacheKey = 'anya_books_cache_v1';
  static const String _imagesDirName = 'anya_covers';

  List<dynamic> _books = [];
  bool _isLoading = true; // true when no cache & initial fetch
  bool _isRefreshing = false; // background refresh running

  @override
  void initState() {
    super.initState();
    _loadCacheThenRefresh();
  }

  /// Load cached JSON quickly (if any), then refresh from network in background
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
      debugPrint('Cache load error (Anya): $e');
      if (mounted) setState(() => _isLoading = true);
    }
  }

  /// Refresh from network (non-blocking if cache exists)
  Future<void> _refreshFromNetwork({bool showSnackOnError = false}) async {
    if (_isRefreshing) return;
    final hadCache = _books.isNotEmpty;

    if (hadCache) {
      if (mounted) setState(() => _isRefreshing = true);
    } else {
      if (mounted) setState(() => _isLoading = true);
    }

    try {
      const apiUrl = 'https://website.sadhumargi.in/api/sahitya/category/any';
      final res = await http.get(Uri.parse(apiUrl));

      if (res.statusCode == 200) {
        final List<dynamic> fetched = jsonDecode(res.body);

        final existingIds = _books.map((e) => e['id']?.toString()).whereType<String>().toSet();
        final fetchedIds = fetched.map((e) => e['id']?.toString()).whereType<String>().toSet();
        final differs = !setEquals(existingIds, fetchedIds) || fetched.length != _books.length;

        if (differs) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_cacheKey, jsonEncode(fetched));
          if (mounted) setState(() => _books = fetched);
        }

        // Ensure images - download any missing ones (non-blocking)
        _ensureImagesForBooks(fetched);
      } else {
        debugPrint('Anya fetch failed: ${res.statusCode}');
        if (showSnackOnError && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to fetch latest books')));
        }
      }
    } catch (e) {
      debugPrint('Network refresh error (Anya): $e');
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

  /// Download missing cover images into app documents dir
  Future<void> _ensureImagesForBooks(List<dynamic> books) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final imagesDir = Directory('${dir.path}/$_imagesDirName');
      if (!await imagesDir.exists()) await imagesDir.create(recursive: true);

      for (final b in books) {
        try {
          final id = b['id']?.toString();
          final remotePath = b['cover_photo'];
          if (id == null || remotePath == null) continue;

          final localFile = File('${imagesDir.path}/anya_$id${_extensionFromUrl(remotePath)}');
          if (!await localFile.exists()) {
            final imageUrl = 'https://website.sadhumargi.in$remotePath';
            final resp = await http.get(Uri.parse(imageUrl));
            if (resp.statusCode == 200) {
              await localFile.writeAsBytes(resp.bodyBytes);
            }
          }
        } catch (e) {
          debugPrint('Single image download error (Anya): $e');
        }
      }
    } catch (e) {
      debugPrint('Ensure images error (Anya): $e');
    }
  }

  String _extensionFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final last = uri.pathSegments.isNotEmpty ? uri.pathSegments.last : '';
      final dot = last.lastIndexOf('.');
      if (dot != -1 && dot < last.length - 1) return last.substring(dot);
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
      final candidate = File('${imagesDir.path}/anya_$id${_extensionFromUrl(remotePath)}');
      if (await candidate.exists()) return candidate;
    } catch (_) {}
    return null;
  }

  Future<void> _openBook(dynamic book) async {
    final base = 'https://website.sadhumargi.in';
    String? url;
    if (book['pdf'] != null && book['pdf'].toString().isNotEmpty) {
      url = '$base${book['pdf']}';
    } else if (book['drive_link'] != null && book['drive_link'].toString().isNotEmpty) {
      url = book['drive_link'];
    }

    if (url == null) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No file available')));
      return;
    }

    final uri = Uri.tryParse(url);
    if (uri == null) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid URL')));
      return;
    }

    if (!await canLaunchUrl(uri)) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open link')));
      return;
    }
    await launchUrl(uri, mode: LaunchMode.externalApplication);
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
            const SizedBox(height: 20),
            Text(
              'अन्य प्रकाशित साहित्य',
              style: GoogleFonts.roboto(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: const Color.fromARGB(255, 102, 87, 3),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Updating indicator
            if (_isRefreshing)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                    SizedBox(width: 8),
                    Text('Updating...', style: TextStyle(fontSize: 13)),
                  ],
                ),
              ),

            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: _onRefresh,
                      color: Theme.of(context).primaryColor,
                      child: _books.isEmpty
                          ? ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: const [SizedBox(height: 80), Center(child: Text('No books found'))],
                            )
                          : Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: GridView.builder(
                                padding: const EdgeInsets.only(top: 8, bottom: 12),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  mainAxisSpacing: 12,
                                  crossAxisSpacing: 12,
                                  childAspectRatio: 0.65,
                                ),
                                itemCount: _books.length,
                                itemBuilder: (context, index) {
                                  final book = _books[index];
                                  final title = (book['name'] ?? '').toString();

                                  return GestureDetector(
                                    onTap: () => _openBook(book),
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
                                                      loadingBuilder: (context, child, loadingProgress) {
                                                        if (loadingProgress == null) return child;
                                                        return const Center(child: CircularProgressIndicator());
                                                      },
                                                      errorBuilder: (context, error, stackTrace) {
                                                        return Container(
                                                          color: Colors.grey[200],
                                                          child: const Icon(Icons.broken_image, size: 40),
                                                        );
                                                      },
                                                    ),
                                                  );
                                                }
                                                return Container(color: Colors.grey.shade200);
                                              },
                                            ),
                                          ),
                                          const SizedBox(height: 6),
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
            ),
          ],
        ),
      ),
    );
  }
}

/// small helper to compare sets (because SetEquality not imported)
bool setEquals(Set? a, Set? b) {
  if (identical(a, b)) return true;
  if (a == null || b == null) return false;
  if (a.length != b.length) return false;
  for (final e in a) if (!b.contains(e)) return false;
  return true;
}
