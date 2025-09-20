// lib/screens/shree_sangh/sangh/vp_sec_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import '../../base_scaffold.dart';

class VpSecScreen extends StatefulWidget {
  const VpSecScreen({super.key});

  @override
  State<VpSecScreen> createState() => _VpSecScreenState();
}

class _VpSecScreenState extends State<VpSecScreen> {
  late Future<List<VpSec>> _futureVpList;

  final String apiUrl = 'https://website.sadhumargi.in/api/vp-sec';
  final String photoBaseUrl = 'https://website.sadhumargi.in/storage/';

  @override
  void initState() {
    super.initState();
    _futureVpList = fetchVpList();
  }

  Future<List<VpSec>> fetchVpList() async {
    final uri = Uri.parse(apiUrl);
    final resp = await http.get(uri);

    if (resp.statusCode != 200) {
      throw Exception('API returned status ${resp.statusCode}');
    }

    final decoded = json.decode(resp.body);
    if (decoded is! List) {
      throw Exception('Unexpected API response format');
    }

    final List<VpSec> all = [];
    for (final sub in decoded) {
      if (sub is List) {
        for (final item in sub) {
          if (item is Map<String, dynamic>) {
            all.add(VpSec.fromJson(item, photoBaseUrl));
          }
        }
      }
    }

    return all;
  }

  Future<void> _refresh() async {
    setState(() {
      _futureVpList = fetchVpList();
    });
    await _futureVpList;
  }

  /// This function sorts the aanchal keys according to the preferred sequence (image),
  /// but uses flexible substring matching so small spelling/language differences won't break it.
  List<String> _orderAanchalKeys(List<String> keys) {
    final List<String> remaining = List.of(keys);
    final List<String> ordered = [];

    // Preferred sequence derived from your image (each entry is a list of matching keywords/variants).
    // Add more variants if your API returns other spellings or languages.
    final List<List<String>> preferredOrderVariants = [
      ['मेवाड', 'mewar', 'मेवाड्'],
      ['बीकानेर', 'मारवाड़', 'marwar', 'bikaner'],
      ['जयपुर', 'jaipur'],
      ['मध्यप्रदेश', 'madhya', 'madhya pradesh', 'madhyapradesh'],
      ['छत्तीसगढ़', 'छत्तीसगढ़', 'chhattisgarh', 'odisha'], // combined in image
      ['ओडिशा', 'odisha'],
      ['कर्नाटक', 'karnataka', 'आंध्र', 'andhra', 'आंध्रप्रदेश', 'andhra pradesh'],
      ['तमिलनाडु', 'tamilnadu', 'tamil'],
      ['मुंबई', 'mumbai', 'गुजरात', 'gujarat'],
      ['महाराष्ट्र', 'vidarbha', 'खानदेश', 'khandesh', 'vidarbh'],
      ['बंगाल', 'bengal', 'बिहार', 'bihar', 'नेपाल', 'nepal'],
      ['पर्वोत्तर', 'northeast', 'northeastern', 'north east'],
      ['दिल्ली', 'delhi', 'पंजाब', 'punjab', 'हरियाणा', 'haryana', 'उत्तर', 'uttar']
    ];

    String keyLower(String s) => s.toLowerCase();

    bool matchesAny(String key, List<String> variants) {
      final kl = keyLower(key);
      for (final v in variants) {
        final vv = v.toLowerCase();
        if (vv.isEmpty) continue;
        if (kl.contains(vv)) return true;
      }
      return false;
    }

    // For each preferred group, find all keys that match and append them in the same order as they appear.
    for (final variants in preferredOrderVariants) {
      final matched = remaining.where((k) => matchesAny(k, variants)).toList();
      if (matched.isNotEmpty) {
        ordered.addAll(matched);
        remaining.removeWhere((k) => matched.contains(k));
      }
    }

    // Append any remaining keys (not matched) at the end, sorted alphabetically.
    remaining.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    ordered.addAll(remaining);

    return ordered;
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      selectedIndex: -1,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: FutureBuilder<List<VpSec>>(
            future: _futureVpList,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return ListView(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      alignment: Alignment.center,
                      child: Column(
                        children: [
                          Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
                          const SizedBox(height: 16),
                          Text(
                            'Failed to load data.\n${snapshot.error}',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.hindSiliguri(fontSize: 14),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _refresh,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              } else {
                final list = snapshot.data ?? [];

                if (list.isEmpty) {
                  return ListView(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        alignment: Alignment.center,
                        child: Text(
                          'No VP Sec data found.',
                          style: GoogleFonts.hindSiliguri(fontSize: 16),
                        ),
                      ),
                    ],
                  );
                }

                // Group by aanchal
                final Map<String, List<VpSec>> grouped = {};
                for (final vp in list) {
                  final key = (vp.aanchal.trim().isEmpty) ? 'अनजान' : vp.aanchal.trim();
                  grouped.putIfAbsent(key, () => []).add(vp);
                }

                // Get keys and order them according to preferred sequence
                final originalKeys = grouped.keys.toList();
                final orderedKeys = _orderAanchalKeys(originalKeys);

                // Build a single list of widgets (so RefreshIndicator works reliably)
                final List<Widget> children = [];
                for (final key in orderedKeys) {
                  final items = grouped[key]!;
                  // Section header
                  children.add(Padding(
                    padding: const EdgeInsets.only(top: 12, bottom: 6, left: 16, right: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            key, // aanchal name
                            style: GoogleFonts.kalam(fontSize: 18, fontWeight: FontWeight.w700),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${items.length}',
                            style: GoogleFonts.hindSiliguri(fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ));

                  // Each member card for this aanchal
                  for (final vp in items) {
                    children.add(Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      child: Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 3,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            // Optional: implement detail view later
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: vp.photoUrl != null
                                      ? Image.network(
                                          vp.photoUrl!,
                                          width: 78,
                                          height: 78,
                                          fit: BoxFit.cover,
                                          errorBuilder: (ctx, err, st) => _placeholderImage(),
                                        )
                                      : _placeholderImage(),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        vp.name,
                                        style: GoogleFonts.kalam(fontSize: 16, fontWeight: FontWeight.w700),
                                      ),
                                      const SizedBox(height: 6),
                                      if (vp.post.isNotEmpty)
                                        Text(
                                          vp.post,
                                          style: GoogleFonts.hindSiliguri(fontSize: 14, fontWeight: FontWeight.w600),
                                        ),
                                      const SizedBox(height: 6),
                                      if (vp.city.isNotEmpty)
                                        Text(
                                          vp.city,
                                          style: GoogleFonts.hindSiliguri(fontSize: 13),
                                        ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          const Icon(Icons.phone, size: 14),
                                          const SizedBox(width: 6),
                                          Text(
                                            vp.mobile ?? '—',
                                            style: GoogleFonts.hindSiliguri(fontSize: 13),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ));
                  }

                  // small spacer after each section
                  children.add(const SizedBox(height: 8));
                }

                return ListView(
                  padding: const EdgeInsets.only(top: 8, bottom: 12),
                  children: children,
                );
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _placeholderImage() {
    return Container(
      width: 78,
      height: 78,
      color: Colors.grey.shade200,
      alignment: Alignment.center,
      child: const Icon(Icons.person, size: 36, color: Colors.grey),
    );
  }
}

/// Simple model for VP Sec
class VpSec {
  final int id;
  final String name;
  final String post;
  final String city;
  final String aanchal;
  final String? mobile;
  final String? photoUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  VpSec({
    required this.id,
    required this.name,
    required this.post,
    required this.city,
    required this.aanchal,
    this.mobile,
    this.photoUrl,
    this.createdAt,
    this.updatedAt,
  });

  factory VpSec.fromJson(Map<String, dynamic> json, String photoBaseUrl) {
    String? photoPath = json['photo'] as String?;
    String? photoUrl;
    if (photoPath != null && photoPath.trim().isNotEmpty) {
      photoUrl = photoBaseUrl + photoPath;
    }

    DateTime? parseDate(String? s) => s == null ? null : DateTime.tryParse(s);

    return VpSec(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}') ?? 0,
      name: (json['name'] ?? '').toString(),
      post: (json['post'] ?? '').toString(),
      city: (json['city'] ?? '').toString(),
      aanchal: (json['aanchal'] ?? '').toString(),
      mobile: (json['mobile'] ?? '').toString(),
      photoUrl: photoUrl,
      createdAt: parseDate(json['created_at'] as String?),
      updatedAt: parseDate(json['updated_at'] as String?),
    );
  }
}
