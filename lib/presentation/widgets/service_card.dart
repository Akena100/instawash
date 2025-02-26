import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instawash/models/sub_service.dart';
import 'package:instawash/presentation/screens/sub_details.dart';

class SubServiceCard extends StatelessWidget {
  final SubService subservice;
  final String service;

  const SubServiceCard(
      {super.key, required this.subservice, required this.service});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Get.to(() => SubDetails(
            amount: subservice.price,
            serviceId: service,
            subService: subservice));
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          image: DecorationImage(
            image: NetworkImage(subservice.imageUrl),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            // Background Image
            Container(
              decoration: BoxDecoration(
                color:
                    Colors.black.withOpacity(0.5), // Overlay with a dark color
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            // Content (Name at the bottom)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(),
                ),
                Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      children: [
                        _buildDetailRow('Name', subservice.name, 18),
                        _buildDetailRow('Name', 'UGX ${subservice.price}', 16),
                      ],
                    )),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value,
    double fontSize,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(color: Colors.white, fontSize: fontSize),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      height: 1,
      color: Colors.white.withOpacity(0.5),
    );
  }
}
