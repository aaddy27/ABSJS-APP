import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../base_scaffold.dart';

// Import all other screens
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
import 'ganesh_jain_chhatravas.dart'; // नया जोड़ा गया

class AavedanPatraHomeScreen extends StatelessWidget {
  AavedanPatraHomeScreen({super.key});

  final List<Map<String, dynamic>> categories = const [
    {'title': 'संघ सदस्यता आवेदन-पत्र', 'widget': SanghSadasyataScreen()},
    {'title': 'समता छात्रवृत्ति आवेदन-पत्र', 'widget': SamtaChatravrittiScreen()},
    {'title': 'अन्य विशिष्ट सदस्यता आवेदन-पत्र', 'widget': AnyaVishishtSadasyataScreen()},
    {'title': 'अन्य सदस्यता आवेदन-पत्र', 'widget': AnyaSadasyataScreen()},
    {'title': 'पाठशाला आवेदन-पत्र', 'widget': PathshalaScreen()},
    {'title': 'शिविर आवेदन-पत्र', 'widget': ShivirScreen()},
    {'title': 'स्वाध्यायी पंजीकरण आवेदन-पत्र', 'widget': SwadhyayiScreen()},
    {'title': 'श्री समता जनकल्याण प्रन्यास', 'widget': ShreeSamataTrustScreen()},
    {'title': 'पूज्य आचार्य श्री श्रीलाल उच्च शिक्षा योजना आवेदन-पत्र', 'widget': UchchShikshaYojanaScreen()},
    {'title': 'आचार्य श्री नानेश समता पुरस्कार हेतु प्रविष्टियाँ आमंत्रित', 'widget': NaneshPuraskarScreen()},
    {'title': 'सेठ श्री चम्पालाल सांड स्मृति उच्च प्रशासनिक पुरस्कार', 'widget': SethChampalalAwardScreen()},
    {'title': 'स्व. श्री प्रदीप कुमार रामपुरिया स्मृति साहित्य पुरस्कार प्रतियोगिता आवेदन प्रपत्र', 'widget': PradeepKumarSahityaScreen()},
    {'title': 'परीक्षा आवेदन-पत्र', 'widget': ParikshaScreen()},
    {'title': 'अन्य आवेदन-पत्र', 'widget': AnyaAavedanScreen()},
    {'title': 'प्रतिवेद', 'widget': PrativadScreen()},
    {'title': 'गणेश जैन छात्रावास', 'widget': GaneshJainChhatravasScreen()}, // नया जोड़ा गया
  ];

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      selectedIndex: -1,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          itemCount: categories.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.7,
          ),
          itemBuilder: (context, index) {
            return InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => categories[index]['widget']),
                );
              },
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 2,
                color: Colors.deepPurple.shade50,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      categories[index]['title'],
                      style: GoogleFonts.hindSiliguri(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.deepPurple.shade800,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
