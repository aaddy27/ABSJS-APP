import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../base_scaffold.dart';

// Screens
import 'sangh_sadasyata.dart';
import 'samta_chatravritti.dart';
import 'anya_vishisht_sadasyata.dart';
import 'anya_sadasyata.dart';
import 'pathshala.dart';
import 'shivir.dart';
import 'swadhyayi.dart';
import 'shree_samata_trust.dart';
import 'uchch_shiksha_yojana.dart';
import 'nanesh_puraskar.dart';
import 'seth_champalal_award.dart';
import 'pradeep_kumar_sahitya.dart';
import 'pariksha.dart';
import 'anya_aavedan.dart';
import 'prativad.dart';
import 'ganesh_jain_chhatravas.dart';

class AavedanPatraHomeScreen extends StatefulWidget {
  const AavedanPatraHomeScreen({super.key});

  @override
  State<AavedanPatraHomeScreen> createState() => _AavedanPatraHomeScreenState();
}

class _AavedanPatraHomeScreenState extends State<AavedanPatraHomeScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';

  // Professional metadata: icon + theme color per tile
  late final List<Map<String, dynamic>> _categories = [
    {'title': 'संघ सदस्यता आवेदन-पत्र', 'widget': const SanghSadasyataScreen(), 'icon': Icons.groups, 'color': const Color(0xFF2563EB)},
    {'title': 'समता छात्रवृत्ति आवेदन-पत्र', 'widget': const SamtaChatravrittiScreen(), 'icon': Icons.school, 'color': const Color(0xFF059669)},
    {'title': 'अन्य विशिष्ट सदस्यता आवेदन-पत्र', 'widget': const AnyaVishishtSadasyataScreen(), 'icon': Icons.verified, 'color': const Color(0xFF7C3AED)},
    {'title': 'अन्य सदस्यता आवेदन-पत्र', 'widget': const AnyaSadasyataScreen(), 'icon': Icons.how_to_reg, 'color': const Color(0xFF4F46E5)},
    {'title': 'पाठशाला आवेदन-पत्र', 'widget': const PathshalaScreen(), 'icon': Icons.menu_book, 'color': const Color(0xFFEA580C)},
    {'title': 'शिविर आवेदन-पत्र', 'widget': const ShivirScreen(), 'icon': Icons.terrain, 'color': const Color(0xFF16A34A)},
    {'title': 'स्वाध्यायी पंजीकरण आवेदन-पत्र', 'widget': const SwadhyayiScreen(), 'icon': Icons.self_improvement, 'color': const Color(0xFF0EA5E9)},
    {'title': 'श्री समता जनकल्याण प्रन्यास', 'widget': const ShreeSamataTrustScreen(), 'icon': Icons.favorite, 'color': const Color(0xFFDC2626)},
    {'title': 'पूज्य आचार्य श्री श्रीलाल उच्च शिक्षा योजना आवेदन-पत्र', 'widget': const UchchShikshaYojanaScreen(), 'icon': Icons.workspace_premium, 'color': const Color(0xFF9333EA)},
    {'title': 'आचार्य श्री नानेश समता पुरस्कार हेतु प्रविष्टियाँ आमंत्रित', 'widget': const NaneshPuraskarScreen(), 'icon': Icons.emoji_events, 'color': const Color(0xFF047857)},
    {'title': 'सेठ श्री चम्पालाल सांड स्मृति उच्च प्रशासनिक पुरस्कार', 'widget': const SethChampalalAwardScreen(), 'icon': Icons.star_rate, 'color': const Color(0xFF2563EB)},
    {'title': 'स्व. श्री प्रदीप कुमार रामपुरिया स्मृति साहित्य पुरस्कार प्रतियोगिता आवेदन प्रपत्र', 'widget': const PradeepKumarSahityaScreen(), 'icon': Icons.menu_book_outlined, 'color': const Color(0xFFCA8A04)},
    {'title': 'परीक्षा आवेदन-पत्र', 'widget': const ParikshaScreen(), 'icon': Icons.assignment, 'color': const Color(0xFF0EA5E9)},
    {'title': 'अन्य आवेदन-पत्र', 'widget': const AnyaAavedanScreen(), 'icon': Icons.post_add, 'color': const Color(0xFF334155)},
    {'title': 'प्रतिवेद', 'widget': const PrativadScreen(), 'icon': Icons.report, 'color': const Color(0xFFDC2626)},
    {'title': 'गणेश जैन छात्रावास', 'widget': const GaneshJainChhatravasScreen(), 'icon': Icons.apartment, 'color': const Color(0xFF16A34A)},
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _categories.where((e) {
      final t = (e['title'] as String).toLowerCase();
      return t.contains(_query.toLowerCase().trim());
    }).toList();

    return BaseScaffold(
      selectedIndex: -1,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Top gradient header
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'आवेदन-पत्र',
                      style: GoogleFonts.amita(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'अपनी श्रेणी चुनें और आगे बढ़ें',
                      style: GoogleFonts.hindSiliguri(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Search
                    _SearchField(
                      controller: _searchCtrl,
                      hint: 'खोजें (उदा. सदस्यता, पाठशाला, पुरस्कार...)',
                      onChanged: (v) => setState(() => _query = v),
                      onClear: () {
                        _searchCtrl.clear();
                        setState(() => _query = '');
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Grid
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              sliver: SliverLayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.crossAxisExtent;
                  // Responsive columns
                  int crossAxisCount = 2;
                  if (width > 1200) crossAxisCount = 5;
                  else if (width > 950) crossAxisCount = 4;
                  else if (width > 650) crossAxisCount = 3;

                  return SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      childAspectRatio: 1.1,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final item = filtered[index];
                        return _CategoryCard(
                          title: item['title'] as String,
                          icon: item['icon'] as IconData,
                          color: item['color'] as Color,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => item['widget'] as Widget),
                            );
                          },
                        );
                      },
                      childCount: filtered.length,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- UI Components ----------------

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _SearchField({
    required this.controller,
    required this.hint,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: GoogleFonts.hindSiliguri(fontSize: 15, color: Colors.white),
      cursorColor: Colors.white,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white.withOpacity(0.12),
        hintText: hint,
        hintStyle: GoogleFonts.hindSiliguri(color: Colors.white70, fontSize: 14),
        prefixIcon: const Icon(Icons.search, color: Colors.white),
        suffixIcon: controller.text.isNotEmpty
            ? IconButton(
                onPressed: onClear,
                icon: const Icon(Icons.close, color: Colors.white),
              )
            : null,
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.25)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white),
        ),
      ),
    );
  }
}

class _CategoryCard extends StatefulWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  State<_CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<_CategoryCard> with SingleTickerProviderStateMixin {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final bg = widget.color.withOpacity(0.10);
    final grad1 = widget.color.withOpacity(0.18);
    final grad2 = widget.color.withOpacity(0.06);

    return AnimatedScale(
      scale: _hover ? 1.02 : 1.0,
      duration: const Duration(milliseconds: 120),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          onHover: (v) => setState(() => _hover = v),
          borderRadius: BorderRadius.circular(16),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [grad1, grad2],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(color: widget.color.withOpacity(0.20), width: 1),
              boxShadow: [
                BoxShadow(
                  color: widget.color.withOpacity(0.10),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon badge
                  Container(
                    decoration: BoxDecoration(
                      color: bg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(10),
                    child: Icon(widget.icon, size: 26, color: widget.color),
                  ),
                  const Spacer(),
                  Text(
                    widget.title,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F172A),
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(Icons.arrow_forward_rounded, color: widget.color, size: 20),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
