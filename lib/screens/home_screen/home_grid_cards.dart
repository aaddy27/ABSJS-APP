import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import '../home_screen.dart'; // for AppStyle

/// Professional, modern redesign of HomeGridCards with highlighted gradient borders
class HomeGridCards extends StatelessWidget {
  final int columns;
  final List<Map<String, dynamic>> dashboardItems;

  const HomeGridCards({
    super.key,
    required this.columns,
    required this.dashboardItems,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final crossAxisCount = columns;

    final childAspectRatio = width >= 1200
        ? 1.25
        : width >= 900
            ? 1.2
            : width >= 720
                ? 1.15
                : 1.5;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: dashboardItems.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 18,
        childAspectRatio: childAspectRatio,
      ),
      itemBuilder: (context, index) {
        final item = dashboardItems[index];
        return _ProCard(
          title: item['title'] ?? '',
          subtitle: item['subtitle'] ?? '',
          imagePath: item['image'] ?? '',
          badge: item['badge'] as int?,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => item['screen'])),
        );
      },
    );
  }
}

class _ProCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final String imagePath;
  final int? badge;
  final VoidCallback onTap;

  const _ProCard({
    required this.title,
    required this.subtitle,
    required this.imagePath,
    this.badge,
    required this.onTap,
  });

  @override
  State<_ProCard> createState() => _ProCardState();
}

class _ProCardState extends State<_ProCard> with SingleTickerProviderStateMixin {
  bool hovering = false;
  bool pressing = false;

  void _showActions() => showModalBottomSheet<void>(
        context: context,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
        builder: (c) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.open_in_new),
                title: const Text('Open'),
                onTap: () {
                  Navigator.pop(c);
                  widget.onTap();
                },
              ),
              ListTile(
                leading: const Icon(Icons.share),
                title: const Text('Share'),
                onTap: () => Navigator.pop(c),
              ),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('Details'),
                onTap: () => Navigator.pop(c),
              ),
            ],
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final double translateY = hovering ? -6 : 0;
    final double scale = pressing ? 0.985 : 1.0;

    return Semantics(
      button: true,
      label: widget.title,
      child: MouseRegion(
        onEnter: (_) => setState(() => hovering = true),
        onExit: (_) => setState(() => hovering = false),
        child: GestureDetector(
          onTapDown: (_) => setState(() => pressing = true),
          onTapUp: (_) => setState(() => pressing = false),
          onTapCancel: () => setState(() => pressing = false),
          onTap: widget.onTap,
          onLongPress: _showActions,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            transform: Matrix4.identity()..translate(0.0, translateY)..scale(scale),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF1E3A8A),
                    Color(0xFF6AA6FF),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: const EdgeInsets.all(1.8), // gradient border thickness
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: widget.onTap,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        colors: [Colors.white, Colors.grey.shade50],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            _AdaptiveImage(imagePath: widget.imagePath),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(widget.title, style: AppStyle.titleMd, maxLines: 2, overflow: TextOverflow.ellipsis),
                                  if (widget.subtitle.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(widget.subtitle, style: AppStyle.body.copyWith(color: AppStyle.subtle), maxLines: 2, overflow: TextOverflow.ellipsis),
                                  ],
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 6.0),
                              child: Icon(Icons.chevron_right, color: AppStyle.blue.withOpacity(0.9), size: 26),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: Text('View details', style: AppStyle.caption),
                            ),
                            if (widget.badge != null && widget.badge! > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppStyle.blue.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(color: AppStyle.blue.withOpacity(0.12)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.notifications, size: 13, color: AppStyle.blue),
                                    const SizedBox(width: 4),
                                    Text('${widget.badge}', style: AppStyle.caption.copyWith(color: AppStyle.blue)),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AdaptiveImage extends StatelessWidget {
  final String imagePath;
  const _AdaptiveImage({required this.imagePath});

  bool _looksLikeNetwork(String s) => s.startsWith('http://') || s.startsWith('https://');

  @override
  Widget build(BuildContext context) {
    final double size = math.min(72, MediaQuery.of(context).size.width * 0.1);

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: size,
        width: size,
        decoration: BoxDecoration(color: Colors.grey.shade100),
        child: _looksLikeNetwork(imagePath)
            ? Image.network(
                imagePath,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 30, color: Colors.grey),
                loadingBuilder: (context, child, progress) => progress == null
                    ? child
                    : const Center(child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))),
              )
            : Image.asset(
                imagePath,
                fit: BoxFit.contain,
              ),
      ),
    );
  }
}
