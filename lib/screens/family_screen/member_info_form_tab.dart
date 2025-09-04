import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MemberInfoFormTab extends StatefulWidget {
  final String memberId;
  const MemberInfoFormTab({super.key, required this.memberId});

  @override
  State<MemberInfoFormTab> createState() => _MemberInfoFormTabState();
}

class _MemberInfoFormTabState extends State<MemberInfoFormTab> {
  final _formKey = GlobalKey<FormState>();
  String selectedIntro = '1';
  final TextEditingController distanceController = TextEditingController();
  bool isLoading = true;

  final List<Map<String, String>> sanghIntroOptions = const [
    {'value': '1', 'label': 'अभी अभी'},
    {'value': '2', 'label': 'कुछ वर्षों से'},
    {'value': '3', 'label': 'पूर्वाचार्य भगवान के समय से'},
    {'value': '4', 'label': 'जन्म से'},
  ];

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    final url = Uri.parse(
        "https://mrmapi.sadhumargi.in/api/members-family-details/${widget.memberId}");
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final data = jsonResponse['data'];
        setState(() {
          selectedIntro = data['sangh_intro']?.toString() ?? '1';
          distanceController.text = data['samtabhawan_distance']?.toString() ?? '';
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Future<void> _updateMemberDetails() async {
    final url = Uri.parse(
        "https://mrmapi.sadhumargi.in/api/members-family-details");
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'member_id': widget.memberId,
          'sangh_intro': selectedIntro,
          'samtabhawan_distance': distanceController.text,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ जानकारी सफलतापूर्वक अपडेट हो गई।')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ अपडेट में समस्या: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('❌ अपवाद: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator());

    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Preview Card
            Card(
              color: Colors.indigo.shade50,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.visibility, color: Colors.indigo),
                        SizedBox(width: 8),
                        Text(
                          ' जानकारी ',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.indigo),
                        ),
                      ],
                    ),
                    const Divider(height: 20, thickness: 1.2),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.person_outline, color: Colors.black87),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "श्री साधुमार्गी संघ से परिचय: ${sanghIntroOptions.firstWhere((opt) => opt['value'] == selectedIntro)['label']}",
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.map, color: Colors.black87),
                        const SizedBox(width: 8),
                        Text(
                          "समता भवन दूरी: ${distanceController.text} कि.मी.",
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Edit Card
            Card(
              elevation: 3,
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.edit, color: Colors.deepPurple),
                          SizedBox(width: 8),
                          Text(
                            'जानकारी में परिवर्तन करें',
                            style: TextStyle(
                                fontSize: 17, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      DropdownButtonFormField<String>(
                        value: selectedIntro,
                        decoration: InputDecoration(
                          labelText: '🔹 श्री साधुमार्गी संघ से परिचय',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: sanghIntroOptions
                            .map((option) => DropdownMenuItem<String>(
                                  value: option['value'],
                                  child: Text(option['label']!),
                                ))
                            .toList(),
                        onChanged: (value) =>
                            setState(() => selectedIntro = value ?? '1'),
                      ),

                      const SizedBox(height: 20),

                      TextFormField(
                        controller: distanceController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: '📍 समता भवन की अनुमानित दूरी (कि.मी.)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'कृपया दूरी दर्ज करें';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              _updateMemberDetails();
                            }
                          },
                          icon: const Icon(Icons.check_circle_outline),
                          label: const Text('परिवर्तन करें',
                              style: TextStyle(fontSize: 16)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
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
