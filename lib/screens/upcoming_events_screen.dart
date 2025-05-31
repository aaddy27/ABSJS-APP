import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class UpcomingEventsScreen extends StatelessWidget {
  const UpcomingEventsScreen({super.key});

  final List<Map<String, dynamic>> _events = const [
    {
      'title': 'Annual Meditation Retreat',
      'date': '2025-06-15',
      'location': 'Mount Abu, Rajasthan',
      'description':
          'Join us for a 3-day spiritual retreat focused on deep meditation, silence, and self-reflection.',
      'imageUrl':
          'https://sadhumargi.com/wp-content/uploads/2025/03/WhatsApp-Image-2025-03-07-at-17.12.18.jpeg'
    },
    {
      'title': 'Youth Empowerment Workshop',
      'date': '2025-07-10',
      'location': 'Ahmedabad, Gujarat',
      'description':
          'Interactive workshop with talks, activities, and training aimed at empowering the youth.',
      'imageUrl': 'https://sadhumargi.com/wp-content/uploads/2025/01/WhatsApp-Image-2025-01-26-at-09.51.20.jpeg'
    },
    {
      'title': 'Shramdaan Seva Camp',
      'date': '2025-08-05',
      'location': 'Pune, Maharashtra',
      'description':
          'Participate in a seva camp for community service, cleanliness drive, and humanitarian efforts.',
      'imageUrl': 'https://sadhumargi.com/wp-content/uploads/2023/12/WhatsApp-Image-2023-12-11-at-2.11.19-PM.jpeg'
    },
  ];

  String _formatDate(String dateString) {
    final date = DateTime.parse(dateString);
    return DateFormat('dd MMM yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _events.length,
      itemBuilder: (context, index) {
        final event = _events[index];
        final String? imageUrl = event['imageUrl'] as String?;

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (imageUrl != null && imageUrl.isNotEmpty)
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Image.network(
                    imageUrl,
                    width: double.infinity,
                    height: 180,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 180,
                      color: Colors.grey[300],
                      child: const Center(child: Icon(Icons.broken_image, size: 40)),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event['title'],
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(event['date']),
                          style: const TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        const SizedBox(width: 12),
                        const Icon(Icons.location_on, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            event['location'],
                            style: const TextStyle(fontSize: 14, color: Colors.grey),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      event['description'],
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
