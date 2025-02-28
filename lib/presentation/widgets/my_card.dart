import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import 'package:instawash/configs/space.dart';
import 'package:instawash/core/core.dart';
import 'package:instawash/forms/more.dart';
import 'package:instawash/models/sub_service.dart';

class MyCard extends StatelessWidget {
  MyCard({super.key});

  // Define a list of colors for services
  final List<Color> colorList = [
    Colors.blue,
    Colors.green,
    Colors.red,
    Colors.orange,
    Colors.purple,
    Colors.teal,
  ];

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance.collection('subServices').get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          var services = snapshot.data!.docs;
          return Column(
            children: [
              Padding(
                padding: Space.hf(),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Popular",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 25,
                      ),
                    ),
                    Icon(
                      Icons.star_border_outlined,
                      color: Colors.orangeAccent,
                    )
                  ],
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.96,
                decoration: const BoxDecoration(
                  color: AppColors.secondaryColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    bottomRight: Radius.circular(15),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: services.map((service) {
                        String name = service['name'] ?? "Unknown";
                        String imageUrl =
                            service['imageUrl'] ?? ''; // Get image URL
                        int index =
                            services.indexOf(service) % colorList.length;
                        Color color = colorList[index];

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5.5),
                          child:
                              _buildServiceCard(name, imageUrl, color, service),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ],
          );
        }
      },
    );
  }

  Widget _buildServiceCard(String label, String imageUrl, Color color,
      QueryDocumentSnapshot<Object?> service) {
    return InkWell(
      onTap: () {
        final subservices = SubService.fromSnapshot(service);
        Get.to(() => CarForm(
            amount: subservices.price,
            subService: subservices,
            serviceId: subservices.serviceId));
        if (kDebugMode) {
          print('Clicked $label');
        }
      },
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: color,
            child: ClipOval(
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                width: 100,
                height: 100,
                placeholder: (context, url) =>
                    const CircularProgressIndicator(),
                errorWidget: (context, url, error) => Icon(
                  Icons.image_not_supported,
                  color: Colors.white,
                  size: 50,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label.length > 11 ? '${label.substring(0, 11)}..' : label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
