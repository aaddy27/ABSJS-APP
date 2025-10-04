import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class IdamNaMamScreen extends StatefulWidget {
  const IdamNaMamScreen({super.key});

  @override
  State<IdamNaMamScreen> createState() => _IdamNaMamScreenState();
}

class _IdamNaMamScreenState extends State<IdamNaMamScreen> {
  List announcements = [];
  Map<String, dynamic>? summary;
  bool isLoading = true;
  bool isLoadingAnnouncements = false;
  String? memberId;
  bool showAnnouncements = false;

  // Cache keys & duration
  static const Duration cacheDuration = Duration(minutes: 10);
  static const String _cachePrefixSummary = 'idam_summary_';
  static const String _cachePrefixAnnouncements = 'idam_announcements_';
  static const String _cacheTimeSuffix = '_time';

  @override
  void initState() {
    super.initState();
    loadMemberId();
  }

  Future<void> loadMemberId() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString("member_id");
    if (id != null) {
      memberId = id;
      // Try loading summary from cache first
      final cachedSummary = await _loadSummaryFromCache(id, prefs);
      if (cachedSummary != null) {
        summary = cachedSummary;
      } else {
        await fetchSummary(id);
      }
    }
    if (mounted) setState(() => isLoading = false);
  }

  /// Fetch summary from API and cache it
  Future<void> fetchSummary(String mid, {bool forceRefresh = false}) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (!forceRefresh) {
        final cached = await _loadSummaryFromCache(mid, prefs);
        if (cached != null) {
          setState(() => summary = cached);
          return;
        }
      }

      final url =
          "https://misapp.sadhumargi.com/api/donor-announcements/idam/summary/$mid";
      final res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        // If API returns object with data or raw map, normalize to Map<String, dynamic>
        Map<String, dynamic>? normalized;
        if (decoded is Map<String, dynamic>) {
          normalized = decoded;
        } else if (decoded is List && decoded.isNotEmpty) {
          // unlikely, but fallback
          normalized = Map<String, dynamic>.from(decoded.first);
        }

        // अगर total_activity_amount 0 है तो summary null मान लो
        if (normalized == null ||
            normalized['total_activity_amount'] == null ||
            normalized['total_activity_amount'] == 0) {
          normalized = null;
        }

        // cache normalized (if not null)
        final key = '$_cachePrefixSummary$mid';
        final timeKey = '${key}$_cacheTimeSuffix';
        if (normalized != null) {
          await prefs.setString(key, jsonEncode(normalized));
          await prefs.setString(timeKey, DateTime.now().toIso8601String());
        } else {
          // remove existing cached summary if any
          await prefs.remove(key);
          await prefs.remove(timeKey);
        }

        if (mounted) setState(() => summary = normalized);
      } else {
        debugPrint('Summary API failed: ${res.statusCode}');
      }
    } catch (e) {
      debugPrint("Error fetching summary: $e");
    }
  }

  /// Fetch announcements (with cache handling)
  Future<void> fetchAnnouncements(String mid, {bool forceRefresh = false}) async {
    setState(() => isLoadingAnnouncements = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_cachePrefixAnnouncements$mid';
      final timeKey = '${key}$_cacheTimeSuffix';

      if (!forceRefresh) {
        final cached = await _loadAnnouncementsFromCache(mid, prefs);
        if (cached != null) {
          setState(() {
            announcements = cached;
            isLoadingAnnouncements = false;
          });
          return;
        }
      }

      final url = "https://misapp.sadhumargi.com/api/donor-announcements/idam/$mid";
      final res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        List<dynamic> normalizedList = [];

        if (decoded is List) {
          normalizedList = decoded;
        } else if (decoded is Map && decoded.containsKey('data') && decoded['data'] is List) {
          normalizedList = decoded['data'];
        } else if (decoded is Map) {
          // Fallback: wrap single map into list
          normalizedList = [decoded];
        }

        // cache
        await prefs.setString(key, jsonEncode(normalizedList));
        await prefs.setString(timeKey, DateTime.now().toIso8601String());

        if (mounted) setState(() => announcements = normalizedList);
      } else {
        debugPrint('Announcements API failed: ${res.statusCode}');
        // try cache (fallback)
        final cached = await _loadAnnouncementsFromCache(mid, prefs);
        if (cached != null && mounted) {
          setState(() => announcements = cached);
        }
      }
    } catch (e) {
      debugPrint("Error fetching announcements: $e");
      final prefs = await SharedPreferences.getInstance();
      final cached = await _loadAnnouncementsFromCache(mid, prefs);
      if (cached != null && mounted) {
        setState(() => announcements = cached);
      }
    } finally {
      if (mounted) setState(() => isLoadingAnnouncements = false);
    }
  }

  /// Load summary from cache if not expired; returns null otherwise
  Future<Map<String, dynamic>?> _loadSummaryFromCache(String mid, SharedPreferences prefs) async {
    try {
      final key = '$_cachePrefixSummary$mid';
      final timeKey = '${key}$_cacheTimeSuffix';
      final str = prefs.getString(key);
      final timeStr = prefs.getString(timeKey);
      if (str == null || timeStr == null) return null;
      final cachedTime = DateTime.tryParse(timeStr);
      if (cachedTime == null) return null;
      if (DateTime.now().difference(cachedTime) > cacheDuration) {
        return null;
      }
      final decoded = jsonDecode(str);
      if (decoded is Map<String, dynamic>) return decoded;
      return null;
    } catch (e) {
      debugPrint("Error loading summary cache: $e");
      return null;
    }
  }

  /// Load announcements from cache if not expired; returns null otherwise
  Future<List<dynamic>?> _loadAnnouncementsFromCache(String mid, SharedPreferences prefs) async {
    try {
      final key = '$_cachePrefixAnnouncements$mid';
      final timeKey = '${key}$_cacheTimeSuffix';
      final str = prefs.getString(key);
      final timeStr = prefs.getString(timeKey);
      if (str == null || timeStr == null) return null;
      final cachedTime = DateTime.tryParse(timeStr);
      if (cachedTime == null) return null;
      if (DateTime.now().difference(cachedTime) > cacheDuration) {
        return null;
      }
      final decoded = jsonDecode(str);
      if (decoded is List) return decoded;
      // handle case where saved single object
      if (decoded is Map) return [decoded];
      return null;
    } catch (e) {
      debugPrint("Error loading announcements cache: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (memberId == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            "सदस्य आईडी नहीं मिली। कृपया पुनः लॉगिन करें।",
            style: TextStyle(fontSize: 16, color: Colors.red),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    // 🔹 अगर summary और announcements दोनों empty/null हैं → सिर्फ empty message दिखाओ
    if (summary == null && announcements.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.grey.shade100,
        body: SafeArea(child: _buildEmptyState(theme)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              // 🔹 Summary Card (Only if available)
              if (summary != null) _buildSummaryCard(summary!, theme),

              const SizedBox(height: 10),

              // 🔹 Toggle Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (!showAnnouncements) {
                        // when opening announcements, try cache first (handled in fetchAnnouncements)
                        fetchAnnouncements(memberId!);
                      }
                      setState(() {
                        showAnnouncements = !showAnnouncements;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: Icon(
                      showAnnouncements
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    label: Text(
                      showAnnouncements ? "घोषणाएँ छिपाएँ" : "घोषणाएँ देखें",
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),

              // 🔹 Announcements List (Toggle show/hide)
              if (showAnnouncements)
                if (isLoadingAnnouncements)
                  const Padding(
                    padding: EdgeInsets.all(20.0),
                    child: CircularProgressIndicator(),
                  )
                else if (announcements.isEmpty)
                  _buildEmptyState(theme)
                else
                  Column(
                    children: announcements
                        .map((item) => _buildAnnouncementCard(item, theme))
                        .toList(),
                  ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  /// Empty state
  Widget _buildEmptyState(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Icon(Icons.volunteer_activism_outlined,
              size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 20),
          Text(
            "आपकी कोई 'इदम् न मम' घोषणा नहीं है।",
            style:
                theme.textTheme.titleLarge?.copyWith(color: Colors.grey.shade700),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            "दान की इस पवित्र धारा से जुड़ें और पुण्य के भागी बनें।",
            style:
                theme.textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Announcement card
  Widget _buildAnnouncementCard(Map<String, dynamic> item, ThemeData theme) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item['Activity Name'] ?? 'N/A',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Divider(height: 16),
            _buildInfoRow(Icons.calendar_today_outlined, "घोषणा तिथि:",
                item['Announcement Date']?.toString() ?? "-"),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.account_balance_wallet_outlined, "घोषणा राशि:",
                "₹${item['Announcement Amount'] ?? 0}"),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.check_circle_outline, "सोजन्य से प्राप्त राशि:",
                "₹${item['Received Amount'] ?? 0}"),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.hourglass_empty_outlined, "बकाया राशि:",
                "₹${item['OutStanding Amount'] ?? 0}",
                valueColor: Colors.orange.shade800),
          ],
        ),
      ),
    );
  }

  /// Summary card
  Widget _buildSummaryCard(Map<String, dynamic> summaryData, ThemeData theme) {
    return Card(
      margin: const EdgeInsets.all(12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      color: Colors.deepPurple.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "📊 कुल सारांश",
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const Divider(height: 20),
            _buildInfoRow(Icons.date_range_outlined, "प्रथम घोषणा:",
                "${summaryData['first_announcement_date'] ?? '-'}"),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.account_balance_wallet, "कुल घोषणा:",
                "₹${summaryData['total_activity_amount'] ?? 0}"),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.check_circle, "सोजन्य से प्राप्त राशि:",
                "₹${summaryData['total_received_amount'] ?? 0}",
                valueColor: Colors.green.shade700),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.error_outline, "कुल बकाया राशि:",
                "₹${summaryData['total_outstanding_amount'] ?? 0}",
                valueColor: Colors.red.shade700),
          ],
        ),
      ),
    );
  }

  /// Info row
  Widget _buildInfoRow(IconData icon, String title, String value,
      {Color? valueColor}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
              color: Colors.grey.shade700, fontWeight: FontWeight.w500),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: valueColor ?? Colors.black87,
          ),
        ),
      ],
    );
  }
}
