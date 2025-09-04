import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ParivaranjaliTab extends StatefulWidget {
  final String memberId;
  const ParivaranjaliTab({super.key, required this.memberId});

  @override
  State<ParivaranjaliTab> createState() => _ParivaranjaliTabState();
}

class _ParivaranjaliTabState extends State<ParivaranjaliTab> {
  bool isLoading = true;
  bool isSaving = false;

  Map<String, bool> fields = {
    "ratri_bhoj": false,
    "sachit_jal": false,
    "gyan": false,
    "poshad": false,
    "sanvar": false,
    "sudh_bhiksha": false,
    "sankalp": false,
    "sewa": false,
    "sant_bhakti": false,
    "vihaar_bhakti": false,
  };

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => isLoading = true);
    final int apiMemberId = int.tryParse(widget.memberId) ?? 0;
    if (apiMemberId < 100000) {
      setState(() => isLoading = false);
      return;
    }

    final url = Uri.parse(
        "https://mrmapi.sadhumargi.in/api/parivaranjali/${apiMemberId - 100000}");
    try {
      final resp = await http.get(url);
      final jsonResp = json.decode(resp.body);
      if (jsonResp['success'] == true && jsonResp['data'] != null) {
        final Map<String, dynamic> data = jsonResp['data'];
        setState(() {
          fields = fields.map((key, _) => MapEntry(key, data[key] == 1));
        });
      }
    } catch (_) {}
    setState(() => isLoading = false);
  }

  Future<void> _updateData() async {
    setState(() => isSaving = true);

    final int actualId = int.tryParse(widget.memberId) ?? 0;
    final int apiMemberId = actualId - 100000;

    final url = Uri.parse("https://mrmapi.sadhumargi.in/api/parivaranjali");

    final body = {
      "member_id": apiMemberId,
      for (final e in fields.entries) e.key: e.value
    };

    try {
      final resp = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode(body),
      );

      final jsonResp = json.decode(resp.body);
      if (resp.statusCode == 200 && jsonResp["success"] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ सफलतापूर्वक सेव हो गया!")),
        );
        await _fetchData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Error: ${resp.body}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("❌ अपवाद: $e")));
    }

    setState(() => isSaving = false);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator());

    return Padding(
      padding: const EdgeInsets.all(14.0),
      child: Column(
        children: [
          Text(
            "🌸 परिवारांजलि संकल्प",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.purple.shade700),
          ),
          const Divider(),
          const SizedBox(height: 5),
          Expanded(
            child: ListView(
              children: fields.entries
                  .map((e) => SwitchListTile(
                        value: e.value,
                        onChanged: (val) =>
                            setState(() => fields[e.key] = val),
                        title: Text(_label(e.key)),
                        activeColor: Colors.purple,
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.check),
              label: const Text(
                "परिवारांजलि सेव करें",
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                padding: const EdgeInsets.symmetric(vertical: 13),
                foregroundColor: Colors.white,
              ),
              onPressed: isSaving ? null : _updateData,
            ),
          ),
        ],
      ),
    );
  }

  String _label(String key) {
    switch (key) {
      case 'ratri_bhoj':
        return "रात्रिभोज का त्याग";
      case 'sachit_jal':
        return "सचित जल";
      case 'gyan':
        return "ज्ञान";
      case 'poshad':
        return "पोषद";
      case 'sanvar':
        return "संवर";
      case 'sudh_bhiksha':
        return "शुद्ध भिक्षा";
      case 'sankalp':
        return "संकल्प";
      case 'sewa':
        return "सेवा";
      case 'sant_bhakti':
        return "संत-भक्ति";
      case 'vihaar_bhakti':
        return "विहार-भक्ति";
      default:
        return key;
    }
  }
}
