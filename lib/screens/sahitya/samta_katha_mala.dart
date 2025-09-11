import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../base_scaffold.dart';

class SamtaKathaMalaScreen extends StatefulWidget {
  const SamtaKathaMalaScreen({super.key});

  @override
  State<SamtaKathaMalaScreen> createState() => _SamtaKathaMalaScreenState();
}

class _SamtaKathaMalaScreenState extends State<SamtaKathaMalaScreen> {
  static const String _cacheKey = 'samta_katha_mala_cache_v1';
  static const String _imagesDirName = 'samta_katha_mala_covers';

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
      debugPrint("Cache load error: $e");
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
      const apiUrl = 'https://website.sadhumargi.in/api/sahitya/category/samta_katha_mala';
      final res = await http.get(Uri.parse(apiUrl));
      if (res.statusCode == 200) {
        final List<dynamic> fetched = jsonDecode(res.body);

        final existingIds = _books.map((e) => e['id']?.toString()).toSet();
        final fetchedIds = fetched.map((e) => e['id']?.toString()).toSet();
        final differs = existingIds.length != fetchedIds.length || !existingIds.containsAll(fetchedIds);

        if (differs) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_cacheKey, jsonEncode(fetched));
          if (mounted) setState(() => _books = fetched);
        }

        _ensureImagesForBooks(fetched);
      } else {
        debugPrint("Fetch error: ${res.statusCode}");
        if (showSnackOnError && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to fetch books")));
        }
      }
    } catch (e) {
      debugPrint("Network error: $e");
      if (showSnackOnError && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error fetching data")));
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
        final cover = b['cover_photo'];
        if (id == null || cover == null) continue;

        final localFile = File('${imagesDir.path}/samta_$id${_extFromUrl(cover)}');
        if (!await localFile.exists()) {
          final url = 'https://website.sadhumargi.in$cover';
          final resp = await http.get(Uri.parse(url));
          if (resp.statusCode == 200) {
            await localFile.writeAsBytes(resp.bodyBytes);
          }
        }
      }
    } catch (e) {
      debugPrint("Image caching error: $e");
    }
  }

  String _extFromUrl(String url) {
    final idx = url.lastIndexOf('.');
    return idx != -1 ? url.substring(idx) : '.jpg';
  }

  Future<File?> _localImage(dynamic book) async {
    try {
      final id = book['id']?.toString();
      final cover = book['cover_photo'];
      if (id == null || cover == null) return null;

      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$_imagesDirName/samta_$id${_extFromUrl(cover)}');
      if (await file.exists()) return file;
    } catch (_) {}
    return null;
  }

  Future<void> _openFile(Map<String, dynamic> book) async {
    String? url;
    if (book['pdf'] != null && book['pdf'].toString().isNotEmpty) {
      url = "https://website.sadhumargi.in${book['pdf']}";
    } else if (book['drive_link'] != null && book['drive_link'].toString().isNotEmpty) {
      url = book['drive_link'];
    }

    if (url == null) return;
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Cannot open file")));
      }
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
            const SizedBox(height: 16),
            Text(
              'समता कथा माला',
              textAlign: TextAlign.center,
              style: GoogleFonts.roboto(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: const Color.fromARGB(255, 102, 87, 3),
              ),
            ),
            const SizedBox(height: 12),
            if (_isRefreshing)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text("Updating...", style: TextStyle(fontSize: 13)),
              ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: _onRefresh,
                      child: _books.isEmpty
                          ? ListView(children: const [Center(child: Text("No books found"))])
                          : GridView.builder(
                              padding: const EdgeInsets.all(16),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: 0.65,
                              ),
                              itemCount: _books.length,
                              itemBuilder: (context, index) {
                                final book = _books[index];
                                return GestureDetector(
                                  onTap: () => _openFile(book),
                                  child: Card(
                                    elevation: 3,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        Expanded(
                                          child: FutureBuilder<File?>(
                                            future: _localImage(book),
                                            builder: (context, snap) {
                                              if (snap.connectionState == ConnectionState.done && snap.data != null) {
                                                return ClipRRect(
                                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                                  child: Image.file(snap.data!, fit: BoxFit.cover),
                                                );
                                              }
                                              final cover = book['cover_photo'];
                                              final coverUrl = cover != null ? "https://website.sadhumargi.in$cover" : null;
                                              return ClipRRect(
                                                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                                child: coverUrl != null
                                                    ? Image.network(
                                                        coverUrl,
                                                        fit: BoxFit.cover,
                                                        errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
                                                      )
                                                    : const Icon(Icons.broken_image),
                                              );
                                            },
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            book['name'] ?? 'अनाम प्रकाशन',
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
