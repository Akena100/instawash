import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:instawash/core/constants/colors.dart';
import 'package:instawash/models/user_subscription.dart';
import 'package:instawash/presentation/widgets/subscription_details.dart';

class UserSubscriptionPage extends StatelessWidget {
  const UserSubscriptionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("User Subscriptions"),
        ),
        body: const Center(
          child: Text("User not authenticated."),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        title: const Text(
          "My Subscriptions",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.secondaryColor,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('userSubscriptions')
            .where('userId', isEqualTo: userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No subscriptions found.",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          final subscriptions = snapshot.data!.docs.map((doc) {
            return UserSubscription.fromSnapshot(doc);
          }).toList();

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: subscriptions.length,
            itemBuilder: (context, index) {
              final subscription = subscriptions[index];
              return SubscriptionCard(subscription: subscription);
            },
          );
        },
      ),
    );
  }
}

class SubscriptionCard extends StatelessWidget {
  final UserSubscription subscription;

  const SubscriptionCard({super.key, required this.subscription});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.secondaryColor,
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.category, color: Colors.teal),
                const SizedBox(width: 8),
                Text(
                  subscription.category,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.lightBlue),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              "Price: ${subscription.price.toStringAsFixed(2)}",
              style: const TextStyle(fontSize: 16, color: Colors.white70),
            ),
            Text(
              "Discount: ${subscription.discount.toStringAsFixed(2)}%",
              style: const TextStyle(fontSize: 16, color: Colors.white38),
            ),
            const SizedBox(height: 8),
            Text(
              "Created: ${subscription.createdAt.toLocal()}",
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            Text(
              "Ends: ${subscription.endDate.toLocal()}",
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            SubscriptionDetailsPage(subscription: subscription),
                      ),
                    );
                  },
                  icon: const Icon(Icons.visibility, color: Colors.teal),
                  label: const Text(
                    "View Details",
                    style: TextStyle(color: Colors.teal),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
