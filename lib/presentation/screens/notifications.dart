import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:instawash/models/notifications.dart';
import 'package:instawash/presentation/screens/notification_details.dart';
import 'package:intl/intl.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  NotificationsPageState createState() => NotificationsPageState();
}

class NotificationsPageState extends State<NotificationsPage> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  User user = FirebaseAuth.instance.currentUser!;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.blue,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestore
            .collection('notifications')
            .where('userId', isEqualTo: user.uid)
            .orderBy('notificationDate', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final notifications = snapshot.data?.docs
              .map((doc) => Notifications.fromFirestore(
                  doc.data() as Map<String, dynamic>))
              .toList();

          if (notifications == null || notifications.isEmpty) {
            return const Center(child: Text('No notifications available.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return GestureDetector(
                child: NotificationCard(notification: notification),
                onTap: () {
                  // Navigate to notification details and mark it as read
                  Get.to(() => NotificationDetailPage(
                        notification: notification,
                      ));
                  FirebaseFirestore.instance
                      .collection('notifications')
                      .doc(notification.id)
                      .update({'read': true});
                },
              );
            },
          );
        },
      ),
    );
  }
}

class NotificationCard extends StatelessWidget {
  final Notifications notification;

  const NotificationCard({Key? key, required this.notification})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('MMM dd, yyyy hh:mm a')
        .format(notification.notificationDate);

    // Decide the background color based on the 'read' status
    Color cardColor = notification.read == false
        ? Colors.yellow.shade100 // Unread notifications are highlighted
        : Colors.white; // Read notifications have default white color

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.notifications_active,
              color: notification.read == false ? Colors.blue : Colors.grey,
              size: 40,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.message,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    formattedDate,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            if (notification.imageUrl != null)
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Image.network(
                  notification.imageUrl!,
                  height: 40,
                  width: 40,
                  fit: BoxFit.cover,
                ),
              ),
            // Display "New" badge for unread notifications
            if (notification.read == false)
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'New',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
