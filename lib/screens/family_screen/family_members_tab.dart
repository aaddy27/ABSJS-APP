import 'dart:convert';
import 'package:flutter/foundation.dart'; // for compute()
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class FamilyMembersTab extends StatefulWidget {
  final String? memberId;
  final String? familyId;

  const FamilyMembersTab({
    super.key,
    required this.memberId,
    required this.familyId,
  });

  @override
  State<FamilyMembersTab> createState() => _FamilyMembersTabState();
}

class _FamilyMembersTabState extends State<FamilyMembersTab>
    with AutomaticKeepAliveClientMixin {
  // ---- State ----
  List<dynamic> familyMembers = [];
  bool isLoading = true;
  bool isRefreshing = false;

  // ---- HTTP Client (persistent) ----
  late final http.Client _client;

  // ---- Cache Keys ----
  String get _cacheKey =>
      'family_members_cache_${widget.familyId ?? "NA"}';
  String get _etagKey =>
      'family_members_etag_${widget.familyId ?? "NA"}';
  String get _cachedAtKey =>
      'family_members_cached_at_${widget.familyId ?? "NA"}';

  @override
  void initState() {
    super.initState();
    _client = http.Client();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    // 1) Try cache first (instant UI)
    await _loadFromCache();
    // 2) Then refresh from network
    await _fetchFamilyMembers();
  }

  Future<void> _loadFromCache() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(_cacheKey);
    if (cached != null && cached.isNotEmpty) {
      try {
        final cachedList = await compute(_parseMembersFromCache, cached);
        if (mounted) {
          setState(() {
            familyMembers = cachedList;
            isLoading = false; // show cached instantly
          });
        }
      } catch (_) {
        // ignore bad cache
      }
    } else {
      if (mounted) setState(() => isLoading = true);
    }
  }

  // static/top-level for compute()
  static List<dynamic> _parseMembersFromCache(String jsonStr) {
    return json.decode(jsonStr) as List<dynamic>;
  }

  // Isolate parse for fresh response
  static List<dynamic> _parseMembersFromResponse(String body) {
    final jsonResponse = json.decode(body) as Map<String, dynamic>;
    final List<dynamic> allMembers = [];
    if (jsonResponse['head'] != null) {
      allMembers.add(jsonResponse['head']);
    }
    if (jsonResponse['members'] != null) {
      allMembers.addAll(jsonResponse['members'] as List<dynamic>);
    }
    return allMembers;
  }

  Future<void> _fetchFamilyMembers({bool userInitiated = false}) async {
    if (widget.familyId == null || widget.memberId == null) {
      if (mounted) setState(() => isLoading = false);
      return;
    }

    if (userInitiated) setState(() => isRefreshing = true);

    final prefs = await SharedPreferences.getInstance();
    final url = Uri.parse(
        "https://mrmapi.sadhumargi.in/api/family-members/${widget.familyId}");

    // ETag header if available
    final etag = prefs.getString(_etagKey);

    try {
      final response = await _client.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'member_id': widget.memberId!,
          'Connection': 'keep-alive',
          if (etag != null) 'If-None-Match': etag, // Conditional fetch
          'Accept-Encoding': 'gzip', // allow gzip
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        // Parse on isolate
        final parsed = await compute(
            _parseMembersFromResponse, response.body);

        if (mounted) {
          setState(() {
            familyMembers = parsed;
            isLoading = false;
          });
        }

        // Save cache atomically
        await prefs.setString(_cacheKey, json.encode(parsed));
        await prefs.setString(_cachedAtKey,
            DateTime.now().toIso8601String());

        // Persist new ETag if provided
        final newETag = response.headers['etag'];
        if (newETag != null && newETag.isNotEmpty) {
          await prefs.setString(_etagKey, newETag);
        }
      } else if (response.statusCode == 304) {
        // Not Modified -> keep cache/UI
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
      } else {
        // Fall back to cache if present
        if (mounted) setState(() => isLoading = false);
      }
    } catch (_) {
      // Network error -> keep cached if any
      if (mounted) setState(() => isLoading = false);
    } finally {
      if (mounted) setState(() => isRefreshing = false);
    }
  }

  // Simple skeleton without packages
  Widget _skeletonList() {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 12, bottom: 80),
      itemCount: 6,
      itemBuilder: (_, __) => Card(
        elevation: 2,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              shape: BoxShape.circle,
            ),
          ),
          title: Container(
            height: 14,
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 8),
            color: Colors.grey.shade300,
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(height: 12, color: Colors.grey.shade200),
              const SizedBox(height: 6),
              Container(height: 12, width: 180, color: Colors.grey.shade200),
              const SizedBox(height: 6),
              Container(height: 12, width: 120, color: Colors.grey.shade200),
            ],
          ),
          trailing: Container(
            width: 64,
            height: 22,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMemberCard(dynamic member) {
    final bool isFamilyHead = member['is_head_of_family'] == 1;

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: isFamilyHead ? Colors.green.shade50 : Colors.orange.shade50,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: isFamilyHead ? Colors.green : Colors.orange,
          child: Icon(
            isFamilyHead ? Icons.verified_user : Icons.person,
            color: Colors.white,
          ),
        ),
        title: Text(
          "${member['salution'] ?? ''} ${member['first_name'] ?? ''} ${member['last_name'] ?? ''}".trim(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isFamilyHead ? Colors.green.shade800 : Colors.orange.shade800,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text("M_ID: ${member['member_id'] ?? 'N/A'}"),
            Text("जन्मतिथि: ${member['birth_day'] ?? 'N/A'}"),
            Text("मोबाइल: ${member['mobile'] ?? 'N/A'}"),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isFamilyHead ? Colors.green : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            isFamilyHead ? '👑 मुखिया' : 'सदस्य',
            style: TextStyle(
              color: isFamilyHead ? Colors.white : Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _onRefresh() async {
    await _fetchFamilyMembers(userInitiated: true);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    // Skeleton while first-time loading (no cache yet)
    if (isLoading && familyMembers.isEmpty) {
      return _skeletonList();
    }

    if (familyMembers.isEmpty) {
      return RefreshIndicator(
        onRefresh: _onRefresh,
        child: ListView(
          children: const [
            SizedBox(height: 100),
            Center(
              child: Text("📭 कोई सदस्य नहीं मिला।", style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 12, bottom: 80),
        itemCount: familyMembers.length,
        itemBuilder: (_, i) => _buildMemberCard(familyMembers[i]),
      ),
    );
  }

  @override
  void dispose() {
    _client.close();
    super.dispose();
  }

  // keep tab alive for faster switching
  @override
  bool get wantKeepAlive => true;
}
