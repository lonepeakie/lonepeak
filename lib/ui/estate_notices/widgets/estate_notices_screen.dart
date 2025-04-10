import 'package:flutter/material.dart';

class EstateNoticesScreen extends StatelessWidget {
  const EstateNoticesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notices = [
      {
        'title': 'Annual General Meeting',
        'description':
            'The annual general meeting will be held on November 15th at 7:00 PM in the community center.',
        'date': '2023-10-25',
        'category': 'General',
        'categoryColor': Colors.blue,
      },
      {
        'title': 'Maintenance Fee Due',
        'description':
            'A friendly reminder that the quarterly maintenance fee of €350 is due by October 31st.',
        'date': '2023-10-20',
        'category': 'Urgent',
        'categoryColor': Colors.red,
      },
      {
        'title': 'Community Clean-up Day',
        'description':
            'Join us for our monthly community clean-up day this Saturday from 10:00 AM to 1:00 PM.',
        'date': '2023-10-18',
        'category': 'Social',
        'categoryColor': Colors.green,
      },
      {
        'title': 'Water Outage Notice',
        'description':
            'There will be a scheduled water outage on Wednesday, October 11th from 9:00 AM to 2:00 PM due to maintenance work.',
        'date': '2023-10-09',
        'category': 'Urgent',
        'categoryColor': Colors.red,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications & Notices'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.notifications_active_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: notices.length,
        itemBuilder: (context, index) {
          final notice = notices[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: notice['categoryColor'] as Color,
                        radius: 8,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        notice['title'] as String,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87, // Slightly lighter black
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 4.0,
                        ),
                        decoration: BoxDecoration(
                          color: (notice['categoryColor'] as Color).withOpacity(
                            0.2,
                          ),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Text(
                          notice['category'] as String,
                          style: TextStyle(
                            color: notice['categoryColor'] as Color,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    notice['description'] as String,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54, // Lighter text color
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Posted on ${notice['date']}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey, // Keep this as is
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.thumb_up_alt_outlined),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.comment_outlined),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.check_circle_outline),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
