import 'package:flutter/material.dart'; // ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api

class NotificationPage extends StatefulWidget {
  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List<Map<String, dynamic>> notifications = [
    {
      'title': 'Suhu naik hingga 34° C',
      'action': 'Tindakan: Hidupkan lebih banyak kincir',
      'isUnread': true
    },
    {
      'title': 'Suhu turun hingga 28° C',
      'action': 'Tindakan: Taburkan kapur untuk menaikkan suhu kolam',
      'isUnread': true
    },
    {
      'title': 'Nilai pH naik hingga 10.50',
      'action': 'Tindakan: Tambahkan asam fosfat untuk menurunkan nilai pH',
      'isUnread': true
    },
    {
      'title': 'Nilai pH turun hingga 6.86',
      'action': 'Tindakan: Tambahkan kalsium karbonat untuk menaikkan nilai pH',
      'isUnread': true
    },
    {
      'title': 'Alkalinitas menurun',
      'action': 'Tindakan: Tambahkan natrium bikarbonat',
      'isUnread': false
    },
    {
      'title': 'Alkalinitas meningkat',
      'action': 'Tindakan: Periksa kadar lumpur kolam',
      'isUnread': false
    },
  ];

  bool showUnreadOnly = false;

  Widget _buildNeoBrutalButton({
    required String text,
    required bool isActive,
    required int count,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: Colors.black,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(
              color: Colors.black,
              offset: Offset(4, 4),
              spreadRadius: 0,
              blurRadius: 0,
            ),
          ],
        ),
        child: Row(
          children: [
            Text(
              text,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isActive ? Colors.black : Colors.grey,
                fontSize: 16,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: isActive ? Colors.green[800] : Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.black,
                  width: 1,
                ),
              ),
              child: Text(
                count.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification',
            style: TextStyle(
              color: Colors.black,
              fontWeight:
                  FontWeight.bold, // Menambahkan ini untuk membuat text bold
            )),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildNeoBrutalButton(
                  text: 'All',
                  isActive: !showUnreadOnly,
                  count: notifications.length,
                  onPressed: () {
                    setState(() {
                      showUnreadOnly = false;
                    });
                  },
                ),
                const SizedBox(width: 16),
                _buildNeoBrutalButton(
                  text: 'Unread',
                  isActive: showUnreadOnly,
                  count:
                      notifications.where((notif) => notif['isUnread']).length,
                  onPressed: () {
                    setState(() {
                      showUnreadOnly = true;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  if (showUnreadOnly && !notifications[index]['isUnread']) {
                    return const SizedBox.shrink();
                  }
                  return NotificationItem(
                    title: notifications[index]['title'],
                    action: notifications[index]['action'],
                    isUnread: notifications[index]['isUnread'],
                    onTap: () {
                      setState(() {
                        notifications[index]['isUnread'] = false;
                      });
                    },
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

class NotificationItem extends StatelessWidget {
  final String title;
  final String action;
  final bool isUnread;
  final VoidCallback onTap;

  const NotificationItem({
    required this.title,
    required this.action,
    this.isUnread = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: Colors.black,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(
              color: Colors.black,
              offset: Offset(4, 4),
              spreadRadius: 0,
              blurRadius: 0,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                if (isUnread)
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: Colors.black,
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.circle,
                      color: Colors.white,
                      size: 8,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                border: Border.all(
                  color: Colors.black,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                action,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
