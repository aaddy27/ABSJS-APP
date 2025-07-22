import 'package:flutter/material.dart';
import 'base_scaffold.dart';
import 'change_head/change_head.dart';
import 'change_head/create_new_family.dart';
import 'change_head/add_new_member.dart';
import 'change_head/view_requests.dart';

class ChangeMukhiyaScreen extends StatelessWidget {
  const ChangeMukhiyaScreen({super.key});

  void navigateTo(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  Widget buildCard(
      BuildContext context, String title, IconData icon, Widget screen) {
    return GestureDetector(
      onTap: () => navigateTo(context, screen),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.deepPurple.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.deepPurple.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(2, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, size: 32, color: Colors.deepPurple),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      selectedIndex: -1,
      body: Scaffold(
     
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              buildCard(context, "मुखिया बदलें", Icons.swap_horiz, const ChangeHeadScreen()),
              buildCard(context, "नया परिवार बनाएँ", Icons.group_add, const CreateNewFamilyScreen()),
              buildCard(context, "नया सदस्य जोड़ें", Icons.person_add, const AddNewMemberScreen()),
              buildCard(context, "अनुरोध देखें", Icons.receipt_long, const ViewRequestsScreen()),
            ],
          ),
        ),
      ),
    );
  }
}
