import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'base_scaffold.dart';

class ActivitiesScreen extends StatefulWidget {
  const ActivitiesScreen({super.key});

  @override
  State<ActivitiesScreen> createState() => _ActivitiesScreenState();
}

class _ActivitiesScreenState extends State<ActivitiesScreen> {
  static const _kCacheAll = 'cache_all_activities';
  static const _kCacheMember = 'cache_member_activities';
  static const _kCacheUpdatedAt = 'cache_activities_updated_at';

  List<dynamic> allActivities = [];
  List<int> memberActivities = [];
  bool isLoading = true;
  bool isRefreshing = false;
  DateTime? lastUpdated;

  String searchQuery = '';
  bool showOnlyPending = false;

  @override
  void initState() {
    super.initState();
    _loadCacheThenFetch();
  }

  Future<void> _loadCacheThenFetch() async {
    setState(() => isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedAll = prefs.getString(_kCacheAll);
      final cachedMember = prefs.getString(_kCacheMember);
      final cachedTime = prefs.getString(_kCacheUpdatedAt);

      if (cachedAll != null) {
        try {
          final decoded = jsonDecode(cachedAll);
          if (decoded is List) allActivities = decoded;
        } catch (_) {}
      }
      if (cachedMember != null) {
        try {
          final decoded2 = jsonDecode(cachedMember);
          if (decoded2 is List) memberActivities = List<int>.from(decoded2);
        } catch (_) {}
      }
      if (cachedTime != null) {
        try {
          lastUpdated = DateTime.parse(cachedTime);
        } catch (_) {}
      }

      // show cached immediately
      setState(() {});

      // then fetch fresh in background (and await to update UI)
      await _fetchFromNetwork();
    } catch (e) {
      // if cache read fails, still fetch from network
      await _fetchFromNetwork();
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _fetchFromNetwork() async {
    if (isRefreshing) return;
    setState(() {
      isRefreshing = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final rawMemberId = prefs.getString('member_id') ?? '';
      final memberId = int.tryParse(rawMemberId) ?? 0;
      if (memberId == 0) throw Exception('member_id missing');

      final res = await http.post(
        Uri.parse('https://mrmapi.sadhumargi.in/api/member-activities'),
        headers: {"Accept": "application/json"},
        body: {"member_id": memberId.toString()},
      );

      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        final List<dynamic> all = data['activities'] ?? [];
        final List<int> taken = (data['member_activities'] as List<dynamic>?)?.map((e) => int.tryParse(e.toString()) ?? 0).where((v) => v != 0).toList() ?? [];

        // sort: taken first
        all.sort((a, b) {
          final aTaken = taken.contains(a['activity_number']);
          final bTaken = taken.contains(b['activity_number']);
          if (aTaken == bTaken) return 0;
          return aTaken ? -1 : 1;
        });

        setState(() {
          allActivities = all;
          memberActivities = taken;
          lastUpdated = DateTime.now();
        });

        // cache results
        prefs.setString(_kCacheAll, jsonEncode(all));
        prefs.setString(_kCacheMember, jsonEncode(taken));
        prefs.setString(_kCacheUpdatedAt, lastUpdated!.toIso8601String());
      } else {
        // non-200: keep cache, but show snackbar
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('सर्वर से डेटा प्राप्त करने में समस्या'))); 
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      setState(() {
        isRefreshing = false;
      });
    }
  }

  void _onSearch(String q) {
    setState(() => searchQuery = q.trim().toLowerCase());
  }

  List<dynamic> get _filteredActivities {
    final q = searchQuery;
    final onlyPending = showOnlyPending;
    return allActivities.where((a) {
      final name = (a['activity_name_en'] ?? '').toString().toLowerCase();
      final desc = (a['activity_description'] ?? '').toString().toLowerCase();
      final taken = memberActivities.contains(a['activity_number']);
      if (onlyPending && taken) return false;
      if (q.isEmpty) return true;
      return name.contains(q) || desc.contains(q) || a['activity_number'].toString().contains(q);
    }).toList();
  }

  String _formatUpdated() {
    if (lastUpdated == null) return 'Never';
    final d = lastUpdated!;
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')} ${d.hour.toString().padLeft(2,'0')}:${d.minute.toString().padLeft(2,'0')}';
  }

  Future<void> _onRefresh() async {
    await _fetchFromNetwork();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Colors.deepPurple;
    return BaseScaffold(
      selectedIndex: -1,
      body: SafeArea(
        child: isLoading && allActivities.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  // Header: title + last-updated + actions
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10),
                    child: Row(
                      children: [
                        const Icon(Icons.list_alt, size: 28, color: Colors.deepPurple),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'सदस्यता जानकारी',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ),
                        if (lastUpdated != null)
                          Text('Updated: ${_formatUpdated()}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                        const SizedBox(width: 8),
                        // refresh icon (manual) - optional
                        IconButton(
                          icon: isRefreshing ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.refresh),
                          onPressed: isRefreshing ? null : _fetchFromNetwork,
                          tooltip: 'Refresh',
                        ),
                      ],
                    ),
                  ),

                  // Search & filters
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.search, color: Colors.grey),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    onChanged: _onSearch,
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      hintText: 'Search activities...',
                                    ),
                                  ),
                                ),
                                if (searchQuery.isNotEmpty)
                                  GestureDetector(
                                    onTap: () => _onSearch(''),
                                    child: const Icon(Icons.close, size: 18, color: Colors.grey),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Tooltip(
                          message: showOnlyPending ? 'Show all' : 'Show only pending',
                          child: InkWell(
                            onTap: () => setState(() => showOnlyPending = !showOnlyPending),
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                color: showOnlyPending ? primary.withOpacity(0.12) : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: showOnlyPending ? primary : Colors.grey.shade300),
                              ),
                              child: Row(
                                children: [
                                  Icon(showOnlyPending ? Icons.filter_alt_off : Icons.filter_list, color: showOnlyPending ? primary : Colors.grey.shade700),
                                  const SizedBox(width: 6),
                                  Text(showOnlyPending ? 'Pending' : 'All', style: TextStyle(color: showOnlyPending ? primary : Colors.grey.shade700)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _onRefresh,
                      child: _filteredActivities.isEmpty
                          ? ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: [
                                const SizedBox(height: 40),
                                Center(child: Text('कोई गतिविधि नहीं मिली।', style: TextStyle(color: Colors.grey.shade700))),
                              ],
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                              itemCount: _filteredActivities.length,
                              itemBuilder: (context, index) {
                                final activity = _filteredActivities[index];
                                final int activityNum = activity['activity_number'] is int ? activity['activity_number'] : int.tryParse(activity['activity_number'].toString()) ?? 0;
                                final bool isTaken = memberActivities.contains(activityNum);
                                final bgColor = isTaken ? Colors.green.shade50 : Colors.white;
                                final accent = isTaken ? Colors.green : Colors.deepPurple;
                                final title = activity['activity_name_en'] ?? activity['activity_name'] ?? 'Activity';
                                final subtitle = activity['activity_description'] ?? '';

                                return Card(
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                  margin: const EdgeInsets.symmetric(vertical: 8),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(14),
                                    onTap: () {
                                      // Optionally show details bottom sheet
                                      showModalBottomSheet(
                                        context: context,
                                        shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                                        ),
                                        builder: (_) {
                                          return Padding(
                                            padding: const EdgeInsets.all(16.0),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Expanded(child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                                      decoration: BoxDecoration(
                                                        color: accent.withOpacity(0.12),
                                                        borderRadius: BorderRadius.circular(20),
                                                      ),
                                                      child: Text(isTaken ? 'पूर्ण' : 'शेष', style: TextStyle(color: accent, fontWeight: FontWeight.bold)),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 12),
                                                if (subtitle.toString().isNotEmpty) Text(subtitle),
                                                const SizedBox(height: 12),
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.end,
                                                  children: [
                                                    TextButton(
                                                      onPressed: () => Navigator.pop(context),
                                                      child: const Text('Close'),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(14),
                                      decoration: BoxDecoration(
                                        color: bgColor,
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 26,
                                            backgroundColor: accent.withOpacity(0.12),
                                            child: Icon(isTaken ? Icons.emoji_events : Icons.assignment, color: accent, size: 28),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87)),
                                                const SizedBox(height: 6),
                                                Text(
                                                  subtitle,
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: TextStyle(color: Colors.grey.shade600),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                                decoration: BoxDecoration(
                                                  color: isTaken ? Colors.green.shade100 : Colors.deepPurple.shade50,
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: Text(
                                                  isTaken ? 'पूर्ण' : 'शेष',
                                                  style: TextStyle(color: isTaken ? Colors.green.shade800 : Colors.deepPurple, fontWeight: FontWeight.bold),
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Text('#${activityNum}', style: TextStyle(color: Colors.grey.shade500)),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ),

                  const SizedBox(height: 10),
                ],
              ),
      ),
    );
  }
}
