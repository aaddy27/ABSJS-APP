import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'yuva_pst_screen.dart';
import 'yuva_ex_president_screen.dart';
import 'yuva_vp_sec_screen.dart';

class KaryakariniSadasyaScreen extends StatelessWidget {
  const KaryakariniSadasyaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cards = [
      {
        "title": "युवा संघ PST",
        "subtitle": "कार्यकारिणी सदस्य",
        "icon": Icons.groups,
        "gradient": [const Color(0xFFF76B1C), const Color(0xFFFFA62B)],
        "screen": const YuvaPstScreen(),
      },
      {
        "title": "युवा संघ पूर्व अध्यक्षगण",
        "subtitle": "पूर्व अध्यक्षगण",
        "icon": Icons.workspace_premium,
        "gradient": [const Color(0xFF6C63FF), const Color(0xFF8E7CFF)],
        "screen": const YuvaExPresidentScreen(),
      },
      {
        "title": "युवा संघ Vice President & Secretary",
        "subtitle": "उपाध्यक्ष एवं मंत्री",
        "icon": Icons.supervisor_account,
        "gradient": [const Color(0xFF00B4AA), const Color(0xFF4ADEDE)],
        "screen": const YuvaVpSecScreen(),
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 👉 Top heading centred
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
            child: Center(
              child: Text(
                "कार्यकारिणी सदस्य",
                textAlign: TextAlign.center,
                style: GoogleFonts.amita(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1D2433),
                ),
              ),
            ),
          ),

          // 👉 Cards list
          Expanded(
            child: ListView.separated(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
              itemCount: cards.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final item = cards[index];
                return _PressableScale(
                  onTap: () {
                    Navigator.of(context).push(_SmoothRoute(page: item['screen'] as Widget));
                  },
                  child: _GradientFeatureCard(
                    title: item['title'] as String,
                    subtitle: item['subtitle'] as String,
                    icon: item['icon'] as IconData,
                    gradientColors: (item['gradient'] as List<Color>),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

///––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
/// Gradient Feature Card (glass overlay + pattern + better layout)
class _GradientFeatureCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> gradientColors;

  const _GradientFeatureCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: gradientColors.last.withOpacity(0.25),
            blurRadius: 18,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: _circle(90, Colors.white.withOpacity(0.08)),
          ),
          Positioned(
            right: 30,
            bottom: -10,
            child: _circle(120, Colors.white.withOpacity(0.06)),
          ),
          Positioned(
            left: -25,
            bottom: -25,
            child: _circle(80, Colors.white.withOpacity(0.05)),
          ),
          Row(
            children: [
              const SizedBox(width: 16),
              Container(
                height: 64,
                width: 64,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.white.withOpacity(0.25), width: 1),
                ),
                child: Icon(icon, size: 34, color: Colors.white),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.amita(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.amita(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              _ChevronPill(),
              const SizedBox(width: 10),
            ],
          ),
        ],
      ),
    );
  }

  Widget _circle(double size, Color color) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}

class _ChevronPill extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.22),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(0.28), width: 1),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Open", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          SizedBox(width: 8),
          Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.white),
        ],
      ),
    );
  }
}

class _PressableScale extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final double scale;
  final Duration duration;

  const _PressableScale({
    required this.child,
    required this.onTap,
    this.scale = 0.98,
    this.duration = const Duration(milliseconds: 110),
  });

  @override
  State<_PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<_PressableScale> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) {
        setState(() => _pressed = false);
        Feedback.forTap(context);
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _pressed ? widget.scale : 1.0,
        duration: widget.duration,
        child: widget.child,
      ),
    );
  }
}

class _SmoothRoute extends PageRouteBuilder {
  _SmoothRoute({required Widget page})
      : super(
          transitionDuration: const Duration(milliseconds: 260),
          reverseTransitionDuration: const Duration(milliseconds: 220),
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final slide = Tween<Offset>(begin: const Offset(0.08, 0), end: Offset.zero)
                .animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
            final fade = Tween<double>(begin: 0.0, end: 1.0)
                .animate(CurvedAnimation(parent: animation, curve: Curves.easeOut));
            return SlideTransition(position: slide, child: FadeTransition(opacity: fade, child: child));
          },
        );
}
