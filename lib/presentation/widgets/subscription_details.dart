import 'package:flutter/material.dart';
import 'package:instawash/models/user_subscription.dart';
import 'package:intl/intl.dart'; // For formatting dates

class SubscriptionDetailsPage extends StatelessWidget {
  final UserSubscription subscription;

  const SubscriptionDetailsPage({super.key, required this.subscription});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEE, MMM d, yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text("Subscription Details"),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Section
            Row(
              children: [
                const Icon(Icons.category, color: Colors.teal, size: 28),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    subscription.category,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 20, thickness: 1),

            // Service Information
            _detailRow(
              icon: Icons.build,
              label: "Service ID",
              value: subscription.serviceId,
            ),
            _detailRow(
              icon: Icons.extension,
              label: "Sub-Service ID",
              value: subscription.subServiceId,
            ),
            _detailRow(
              icon: Icons.layers,
              label: "More Service ID",
              value: subscription.moreServiceId,
            ),

            const SizedBox(height: 20),

            // Pricing Information
            _detailRow(
              icon: Icons.monetization_on,
              label: "Price",
              value: subscription.price.toStringAsFixed(2),
              valueStyle: const TextStyle(
                fontSize: 18,
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
            _detailRow(
              icon: Icons.discount,
              label: "Discount",
              value: "${subscription.discount.toStringAsFixed(2)}%",
              valueStyle: const TextStyle(
                fontSize: 16,
                color: Colors.blue,
              ),
            ),

            const SizedBox(height: 20),

            // Date Information
            _detailRow(
              icon: Icons.date_range,
              label: "Created On",
              value: dateFormat.format(subscription.createdAt),
            ),
            _detailRow(
              icon: Icons.timer_off,
              label: "Ends On",
              value: dateFormat.format(subscription.endDate),
              valueStyle: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),

            const Spacer(),

            // Action Button
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  // Handle action, e.g., cancel or modify subscription
                },
                icon: const Icon(Icons.edit),
                label: const Text("Modify Subscription"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 24,
                  ),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Helper widget to create a row for details
  Widget _detailRow({
    required IconData icon,
    required String label,
    required String value,
    TextStyle? valueStyle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.teal, size: 20),
          const SizedBox(width: 10),
          Text(
            "$label: ",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          Expanded(
            child: Text(
              value,
              style: valueStyle ??
                  const TextStyle(fontSize: 16, color: Colors.black87),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
