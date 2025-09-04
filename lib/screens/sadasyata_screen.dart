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
  List<dynamic> allActivities = [];
  List<int> memberActivities = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchActivities();
  }

  Future<void> fetchActivities() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int? memberId = int.tryParse(prefs.getString('member_id') ?? '');

      if (memberId == null) throw Exception("Invalid member_id");

      var response = await http.post(
        Uri.parse("https://mrmapi.sadhumargi.in/api/member-activities"),
        headers: {"Accept": "application/json"},
        body: {"member_id": memberId.toString()},
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        List<dynamic> all = data['activities'];
        List<int> taken = List<int>.from(data['member_activities']);

        all.sort((a, b) {
          bool aTaken = taken.contains(a['activity_number']);
          bool bTaken = taken.contains(b['activity_number']);
          return (aTaken == bTaken) ? 0 : (aTaken ? -1 : 1);
        });

        setState(() {
          allActivities = all;
          memberActivities = taken;
          isLoading = false;
        });
      } else {
        throw Exception("Failed to fetch activities");
      }
    } catch (e) {
      print("Error: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      selectedIndex: -1,
      body: Scaffold(
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  const Padding(
  padding: EdgeInsets.symmetric(vertical: 10),
  child: Center(
    child: Text(
      "सदस्यता जानकारी",
      style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Colors.deepPurple,
      ),
    ),
  ),
),

                Expanded(
  child: ListView.builder(
    padding: const EdgeInsets.symmetric(vertical: 12),
    itemCount: allActivities.length,
    itemBuilder: (context, index) {
      final activity = allActivities[index];
      final isTaken = memberActivities.contains(activity['activity_number']);
      // choose a distinct color for each item or based on index
      final bgColor = isTaken ? Colors.green.shade200 : Colors.blue.shade100;
      final iconData = isTaken ? Icons.emoji_events : Icons.assignment;

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
        child: Container(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
                offset: const Offset(2, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(iconData, size: 36, color: isTaken ? Colors.green.shade700 : Colors.blue.shade700),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity['activity_name_en'],
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isTaken ? Colors.green.shade900 : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isTaken ? "पूर्ण" : "शेष", // or use a dynamic subtitle
                      style: TextStyle(
                        fontSize: 14,
                        color: isTaken ? Colors.green.shade800 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              if (isTaken)
                Icon(Icons.check_circle, color: Colors.green.shade700, size: 28),
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
      ),
    );
  }
}
