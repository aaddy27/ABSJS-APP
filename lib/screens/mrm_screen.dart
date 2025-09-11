import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'base_scaffold.dart';
import 'family_screen.dart';
import 'address.dart';
import 'education.dart';
import 'employment_screen.dart';
import 'achievements_screen.dart';
import 'general_details.dart';
import 'trust.dart';
import 'sadasyata_screen.dart';
import 'change_mukhiya_screen.dart';

class MrmScreen extends StatefulWidget {
  final String memberId;
  const MrmScreen({super.key, required this.memberId});

  @override
  State<MrmScreen> createState() => _MrmScreenState();
}

class _MrmScreenState extends State<MrmScreen> {
  bool isHeadOfFamily = false;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    isHeadOfFamily = prefs.getBool('is_head_of_family') ?? true;
    setState(() {});
  }

  void navigateTo(int index) {
    Widget? targetScreen;
    switch (index) {
      case 0:
        targetScreen = FamilyScreen();
        break;
      case 1:
        targetScreen = const AddressScreen();
        break;
      case 2:
        targetScreen = Education();
        break;
      case 3:
        targetScreen = EmploymentScreen();
        break;
      case 4:
        targetScreen = AchievementsScreen();
        break;
      case 5:
        targetScreen = GeneralDetails();
        break;
      case 6:
        targetScreen = Trust();
        break;
      case 7:
        targetScreen = const ActivitiesScreen();
        break;
      case 8:
        targetScreen = ChangeMukhiyaScreen();
        break;
      default:
        targetScreen = null;
    }

    if (targetScreen != null) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => targetScreen!));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Screen not implemented for this item.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = <_DashItem>[
      _DashItem("सामान्य विवरण", Icons.person, 5),
      _DashItem("परिवार", Icons.family_restroom, 0),
      _DashItem("पता", Icons.location_on, 1),
      _DashItem("शिक्षा", Icons.school, 2),
      _DashItem("पेशा", Icons.work, 3),
      // **FIXED**: achievements must map to index 4 (not 3)
      _DashItem("उपलब्धियाँ", Icons.emoji_events, 4),
      _DashItem("न्यास-ट्रस्ट", Icons.home_work, 6),
      _DashItem("सदस्यता", Icons.badge, 7),
      if (isHeadOfFamily) _DashItem("मुखिया बदलो", Icons.switch_account, 8),
    ];

    return BaseScaffold(
      selectedIndex: -1,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.grey.shade50, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              // Banner
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 16, 12, 16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.asset(
                            'assets/images/Global-Card.jpg',
                            fit: BoxFit.cover,
                          ),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.black.withOpacity(0.05),
                                  Colors.black.withOpacity(0.35)
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                          ),
                          Positioned(
                            left: 14,
                            right: 14,
                            bottom: 12,
                            child: Row(
                              children: [
                                Icon(Icons.shield_moon,
                                    color: Colors.white.withOpacity(0.95)),
                                const SizedBox(width: 8),
                                Text(
                                  "MRM Profile Center",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                    shadows: [
                                      Shadow(
                                          color: Colors.black.withOpacity(0.3),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Grid
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 20),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 2.7,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => _DashCard(
                      title: items[i].title,
                      icon: items[i].icon,
                      onTap: () => navigateTo(items[i].index),
                    ),
                    childCount: items.length,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashCard extends StatefulWidget {
  const _DashCard({required this.title, required this.icon, required this.onTap});
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  @override
  State<_DashCard> createState() => _DashCardState();
}

class _DashCardState extends State<_DashCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      duration: const Duration(milliseconds: 120),
      scale: _pressed ? 0.98 : 1.0,
      child: Material(
        color: const Color.fromARGB(255, 255, 255, 255),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: const Color.fromARGB(255, 4, 18, 97)),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: widget.onTap,
          onHighlightChanged: (v) => setState(() => _pressed = v),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 227, 230, 253),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color.fromARGB(255, 13, 16, 179)),
                  ),
                  child: Icon(widget.icon, color: const Color.fromARGB(255, 9, 11, 151)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: const Color.fromARGB(255, 8, 17, 138),
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Icon(Icons.chevron_right, color: const Color.fromARGB(255, 9, 7, 139)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DashItem {
  final String title;
  final IconData icon;
  final int index;
  _DashItem(this.title, this.icon, this.index);
}
