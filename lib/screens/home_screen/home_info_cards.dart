import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../home_screen.dart'; // provides AppStyle

/// HomeInfoCards - shows created_at date for thought, and date once (chip) for vihar.
class HomeInfoCards extends StatelessWidget {
  final VoidCallback onTapSampark;
  final VoidCallback onTapPakhi;
  final VoidCallback onTapChaturmas;

  /// For thought we expect an ISO datetime (created_at) e.g. "2025-08-11T12:39:30.000000Z"
  final String? thoughtDate;
  final String? thoughtText;
  final bool isThoughtLoading;

  /// For vihar we may receive formatted_date (DD-MM-YYYY) or created_at
  final String? viharDate;
  final String? viharThana;
  final String? viharLocation;
  final bool isViharLoading;

  const HomeInfoCards({
    super.key,
    required this.onTapSampark,
    required this.onTapPakhi,
    required this.onTapChaturmas,
    required this.thoughtDate,
    required this.thoughtText,
    required this.isThoughtLoading,
    required this.viharDate,
    required this.viharThana,
    required this.viharLocation,
    required this.isViharLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Action tiles (responsive)
        LayoutBuilder(builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 720;
          final tiles = [
            _ActionTile.v2(
              title: 'संपर्क',
              subtitle: 'सम्पर्क जानकारी देखें',
              icon: Icons.phone,
              iconBg: const LinearGradient(colors: [Color(0xFF2E7D32), Color(0xFF60A15A)]),
              onTap: onTapSampark,
            ),
            _ActionTile.v2(
              title: 'पक्खी का पाना',
              subtitle: 'पक्खी का पाना',
              icon: Icons.calendar_month,
              iconBg: const LinearGradient(colors: [Color(0xFFEF6C00), Color(0xFFF7A93C)]),
              onTap: onTapPakhi,
            ),
            _ActionTile.v2(
              title: 'चातुर्मास सूची',
              subtitle: 'वर्तमान चातुर्मास सूची देखें',
              icon: Icons.menu_book,
              iconBg: const LinearGradient(colors: [Color(0xFF1E3A8A), Color(0xFF6AA6FF)]),
              onTap: onTapChaturmas,
            ),
          ];

          if (isWide) {
            return Row(
              children: tiles
                  .asMap()
                  .entries
                  .map((e) => Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(right: e.key == tiles.length - 1 ? 0 : 12.0),
                          child: e.value,
                        ),
                      ))
                  .toList(),
            );
          }

          return Column(
            children: tiles.map((t) => Padding(padding: const EdgeInsets.only(bottom: 12.0), child: t)).toList(),
          );
        }),

        const SizedBox(height: 18),

        // Thought card (date shown in chip + inside card)
        isThoughtLoading
            ? const _PulsingSkeleton()
            : _ExpandableInfoCard(
                title: '🧠 आज का विचार',
                titleGradient: const LinearGradient(colors: [Color(0xFF1E3A8A), Color(0xFF6AA6FF)]),
                meta: _metaFromIsoOrRaw(thoughtDate), // chip (compact)
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // inside card show full human date (if available) - REQUIRED per your request
                    Text(
                      '📅 ${_formatHumanDateOrRaw(thoughtDate)}',
                      style: AppStyle.caption.copyWith(color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      thoughtText ?? '-',
                      style: AppStyle.body.copyWith(fontStyle: FontStyle.italic, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),

        const SizedBox(height: 14),

        // Vihar card (date only in chip/header; do NOT duplicate inside)
        isViharLoading
            ? const _PulsingSkeleton()
            : _ExpandableInfoCard(
                title: '🔔 आज की विहार जानकारी',
                titleGradient: const LinearGradient(colors: [Color(0xFF2E7D32), Color(0xFF60A15A)]),
                meta: _metaFromFormattedOrRaw(viharDate), // chip only
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // NOTE: date intentionally omitted inside (per request). Show other details:
                    _iconRow(Icons.place, 'आदि थाना', viharThana),
                    const SizedBox(height: 8),
                    _iconRow(Icons.hotel, 'रात्रि विश्राम हेतु', viharLocation),
                  ],
                ),
              ),
      ],
    );
  }
}

/// Build compact meta for chip when thoughtDate is ISO or raw
String _metaFromIsoOrRaw(String? raw) {
  if (raw == null || raw.trim().isEmpty) return '-';
  // Try ISO first
  try {
    final dt = DateTime.parse(raw);
    final label = '${dt.day.toString().padLeft(2, '0')} ${_monthShortHindi(dt.month)}';
    if (dt.year != DateTime.now().year) return '$label ${dt.year}';
    return label;
  } catch (_) {
    // fallback: try to extract YYYY-MM-DD or DD-MM-YYYY or return trimmed short
    final extracted = _tryExtractDateToken(raw);
    if (extracted != null) return extracted;
    final t = raw.trim();
    return t.length <= 12 ? t : '${t.substring(0, 12)}...';
  }
}

/// Build compact meta for vihar: handle DD-MM-YYYY or ISO or raw
String _metaFromFormattedOrRaw(String? raw) {
  if (raw == null || raw.trim().isEmpty) return '-';
  final t = raw.trim();
  // If formatted like 05-09-2025 (DD-MM-YYYY), convert to '05 Sep' or '05 Sep 2025' if different year
  final ddmmyyyy = RegExp(r'^(\d{2})-(\d{2})-(\d{4})$');
  final m = ddmmyyyy.firstMatch(t);
  if (m != null) {
    final day = int.tryParse(m.group(1)!) ?? 0;
    final month = int.tryParse(m.group(2)!) ?? 0;
    final year = int.tryParse(m.group(3)!) ?? 0;
    final label = '${day.toString().padLeft(2, '0')} ${_monthShortHindi(month)}';
    if (year != DateTime.now().year) return '$label $year';
    return label;
  }

  // Try ISO
  try {
    final dt = DateTime.parse(t);
    final label = '${dt.day.toString().padLeft(2, '0')} ${_monthShortHindi(dt.month)}';
    if (dt.year != DateTime.now().year) return '$label ${dt.year}';
    return label;
  } catch (_) {}

  // fallback trimmed
  return t.length <= 12 ? t : '${t.substring(0, 12)}...';
}

/// Full inside human date or raw
String _formatHumanDateOrRaw(String? raw) {
  if (raw == null || raw.trim().isEmpty) return '-';
  final t = raw.trim();

  // If formatted_date DD-MM-YYYY
  final ddmmyyyy = RegExp(r'^(\d{2})-(\d{2})-(\d{4})$');
  final m = ddmmyyyy.firstMatch(t);
  if (m != null) {
    final day = int.tryParse(m.group(1)!) ?? 0;
    final month = int.tryParse(m.group(2)!) ?? 0;
    final year = int.tryParse(m.group(3)!) ?? 0;
    return '${day.toString().padLeft(2, '0')} ${_monthFullHindi(month)} ${year}';
  }

  // Try ISO
  try {
    final dt = DateTime.parse(t);
    return '${dt.day.toString().padLeft(2, '0')} ${_monthFullHindi(dt.month)} ${dt.year}';
  } catch (_) {
    // fallback: return raw
    return t;
  }
}

/// Utility wrapper duplicates for clarity used above
String _formatHumanDateOrRaw_forThought(String? raw) => _formatHumanDateOrRaw(raw);

/// Helper used in widget to keep naming simple
String _formatHumanDate(String raw) => _formatHumanDateOrRaw(raw);

/// Try extract a date-like token and return compact label (e.g. '05 Sep')
String? _tryExtractDateToken(String s) {
  final ymd = RegExp(r'(\d{4}-\d{2}-\d{2})'); // 2025-08-11
  final m = ymd.firstMatch(s);
  if (m != null) {
    try {
      final dt = DateTime.parse(m.group(1)!);
      return '${dt.day.toString().padLeft(2, '0')} ${_monthShortHindi(dt.month)}';
    } catch (_) {}
  }

  final dmy = RegExp(r'(\d{2}[\/-]\d{2}[\/-]\d{4})'); // 05-09-2025 or 05/09/2025
  final m2 = dmy.firstMatch(s);
  if (m2 != null) {
    final token = m2.group(1)!;
    final parts = token.split(RegExp(r'[\/-]'));
    if (parts.length == 3) {
      final day = int.tryParse(parts[0]) ?? 0;
      final month = int.tryParse(parts[1]) ?? 0;
      final year = int.tryParse(parts[2]) ?? 0;
      final label = '${day.toString().padLeft(2, '0')} ${_monthShortHindi(month)}';
      if (year != DateTime.now().year) return '$label $year';
      return label;
    }
  }

  return null;
}

String _monthShortHindi(int m) {
  const names = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  if (m < 1 || m > 12) return '';
  return names[m - 1];
}

String _monthFullHindi(int m) {
  const names = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];
  if (m < 1 || m > 12) return '';
  return names[m - 1];
}

Widget _iconRow(IconData icon, String label, String? value) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18, color: AppStyle.blue),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppStyle.caption),
            const SizedBox(height: 4),
            Text(value ?? '-', style: AppStyle.body),
          ],
        ),
      ),
    ],
  );
}

/// Modern action tile (reused)
class _ActionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final LinearGradient iconBg;
  final VoidCallback onTap;

  const _ActionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconBg,
    required this.onTap,
  });

  factory _ActionTile.v2({
    required String title,
    required String subtitle,
    required IconData icon,
    required LinearGradient iconBg,
    required VoidCallback onTap,
  }) {
    return _ActionTile(title: title, subtitle: subtitle, icon: icon, iconBg: iconBg, onTap: onTap);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 6,
      borderRadius: BorderRadius.circular(AppStyle.rMd),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppStyle.rMd),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppStyle.rMd),
            border: Border.all(color: AppStyle.blue.withOpacity(0.08)),
          ),
          child: Row(
            children: [
              Container(
                height: 52,
                width: 52,
                decoration: BoxDecoration(
                  gradient: iconBg,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: AppStyle.blue.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 6))],
                ),
                child: Icon(icon, color: Colors.white, size: 26),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppStyle.titleSm),
                    const SizedBox(height: 4),
                    Text(subtitle, style: AppStyle.caption),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }
}

/// Expandable info card (title + optional meta chip)
class _ExpandableInfoCard extends StatefulWidget {
  final String title;
  final LinearGradient titleGradient;
  final Widget child;
  final String? meta;

  const _ExpandableInfoCard({required this.title, required this.titleGradient, required this.child, this.meta});

  @override
  State<_ExpandableInfoCard> createState() => _ExpandableInfoCardState();
}

class _ExpandableInfoCardState extends State<_ExpandableInfoCard> with SingleTickerProviderStateMixin {
  bool _expanded = true;
  late final AnimationController _anim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(vsync: this, duration: const Duration(milliseconds: 260));
    if (_expanded) _anim.value = 1.0;
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _expanded = !_expanded);
    if (_expanded) {
      _anim.forward();
    } else {
      _anim.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 6,
      borderRadius: BorderRadius.circular(14),
      child: Column(
        children: [
          InkWell(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            onTap: _toggle,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                gradient: widget.titleGradient,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Title + optional subtitle (meta shown under title as well)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.title, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
                        if (widget.meta != null) const SizedBox(height: 4),
                        if (widget.meta != null) Text(widget.meta!, style: GoogleFonts.inter(fontSize: 12, color: Colors.white70)),
                      ],
                    ),
                  ),

                  // Right-side chip
                  if (widget.meta != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: Colors.white24),
                        boxShadow: [BoxShadow(color: Colors.black26.withOpacity(0.2), blurRadius: 6, offset: const Offset(0, 3))],
                      ),
                      child: Text(widget.meta!, style: GoogleFonts.inter(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600)),
                    ),
                  ],

                  RotationTransition(
                    turns: Tween(begin: 0.0, end: 0.5).animate(CurvedAnimation(parent: _anim, curve: Curves.easeInOut)),
                    child: const Icon(Icons.expand_more, color: Colors.white),
                  )
                ],
              ),
            ),
          ),
          SizeTransition(
            sizeFactor: _anim,
            axisAlignment: -1.0,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(14)),
                border: Border.all(color: AppStyle.blue.withOpacity(0.06)),
              ),
              child: widget.child,
            ),
          ),
        ],
      ),
    );
  }
}

/// Pulsing skeleton for loading state
class _PulsingSkeleton extends StatefulWidget {
  const _PulsingSkeleton();

  @override
  State<_PulsingSkeleton> createState() => _PulsingSkeletonState();
}

class _PulsingSkeletonState extends State<_PulsingSkeleton> with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween(begin: 0.8, end: 1.0).animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppStyle.rLg),
          boxShadow: AppStyle.shadow,
          border: Border.all(color: AppStyle.blue.withOpacity(.08)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(height: 14, width: 160, color: const Color(0xFFEFF2F7)),
            const SizedBox(height: 12),
            Container(height: 12, width: double.infinity, color: const Color(0xFFEFF2F7)),
            const SizedBox(height: 8),
            Container(height: 12, width: double.infinity, color: const Color(0xFFEFF2F7)),
            const SizedBox(height: 8),
            Container(height: 12, width: 180, color: const Color(0xFFEFF2F7)),
          ],
        ),
      ),
    );
  }
}
