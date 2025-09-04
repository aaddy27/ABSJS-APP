// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


import 'base_scaffold.dart';
import 'family_screen/family_members_tab.dart';
import 'family_screen/member_info_form_tab.dart';
import 'family_screen/parivaranjali_tab.dart';
import 'family_screen/vir_pariwar_tab.dart';

class FamilyScreen extends StatefulWidget {
  const FamilyScreen({super.key});

  @override
  State<FamilyScreen> createState() => _FamilyScreenState();
}

class _FamilyScreenState extends State<FamilyScreen> {
  bool isLoading = true;
  bool isHead = false;
  String? memberId;
  String? familyId;

  @override
  void initState() {
    super.initState();
    _loadIds();
  }

  Future<void> _loadIds() async {
    final prefs = await SharedPreferences.getInstance();
    memberId = prefs.getString('member_id');
    familyId = prefs.getString('family_id');
    isHead = prefs.getBool('is_head_of_family') ?? false;

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const BaseScaffold(
        selectedIndex: -1,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Default tabs
    final List<Tab> tabs = [const Tab(text: '👨‍👩‍👧‍👦 परिवार')];
    final List<Widget> views = [
      FamilyMembersTab(
        memberId: memberId,
        familyId: familyId,
      ),
    ];

    // Extra tabs only for Head of Family
    if ((isHead) && memberId != null && familyId != null) {
      tabs.addAll(const [
        Tab(text: '📋 सामान्य जानकारी'),
        Tab(text: '➕  परिवारांजलि'),
        Tab(text: '✅ वीर परिवार'),
      ]);
      views.addAll([
        MemberInfoFormTab(memberId: memberId!),
        ParivaranjaliTab(memberId: memberId!),
        VirPariwarTab(familyId: familyId!),
      ]);
    }

    return BaseScaffold(
      selectedIndex: -1,
      body: DefaultTabController(
        length: tabs.length,
        child: Column(
          children: [
            Material(
              color: Colors.blue.shade50,
              child: TabBar(
                isScrollable: true,
                labelColor: Colors.blue.shade900,
                indicatorColor: Colors.blue,
                tabs: tabs,
              ),
            ),
            Expanded(child: TabBarView(children: views)),
          ],
        ),
      ),
    );
  }
}
