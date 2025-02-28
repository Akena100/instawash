import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:instawash/connectivity/no_internet_connection_page.dart';
import 'package:instawash/connectivity/service.dart';
import 'package:instawash/core/constants/colors.dart';
import 'package:instawash/forms/car_category.dart';

import 'package:instawash/models/car_category.dart';
import 'package:instawash/models/repo.dart';

class CarCategoryPage extends StatefulWidget {
  const CarCategoryPage({super.key});

  @override
  CarCategoryPageState createState() => CarCategoryPageState();
}

class CarCategoryPageState extends State<CarCategoryPage> {
  bool _isConnected = true;

  Future<void> _checkInternetConnection() async {
    bool isConnected = await InternetConnectivityService.isConnected();
    setState(() {
      _isConnected = isConnected;
    });
  }

  @override
  void initState() {
    super.initState();
    _checkInternetConnection();
  }

  @override
  Widget build(BuildContext context) {
    return !_isConnected
        ? NoInternetConnectionPage()
        : Scaffold(
            backgroundColor: AppColors.bgColor,
            appBar: AppBar(
              title: const Text(
                'Car Categories',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: AppColors.secondaryColor,
            ),
            body: Padding(
              padding: const EdgeInsets.all(10.0),
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('carCategories')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  var carCategories = snapshot.data!.docs.map((doc) {
                    var data = doc.data() as Map<String, dynamic>;
                    return CarCategory(
                      id: data['id'],
                      name: data['name'],
                      description: data['description'],
                      imageUrl: data['imageUrl'],
                      price: data['price'],
                    );
                  }).toList();

                  return ListView.builder(
                    itemCount: carCategories.length,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          // Optional: Navigate to category details page
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(15),
                            color: AppColors.secondaryColor,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CachedNetworkImage(
                                imageUrl: carCategories[index].imageUrl,
                                placeholder: (context, url) =>
                                    CircularProgressIndicator(),
                                errorWidget: (context, url, error) =>
                                    Icon(Icons.error),
                              ),
                              const SizedBox(height: 10),
                              ListTile(
                                title: Text(
                                  carCategories[index].name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                                trailing: Visibility(
                                  visible: isAdmin(),
                                  child: PopupMenuButton<String>(
                                    onSelected: (value) {
                                      if (value == 'edit') {
                                        Get.to(() => CarCategoryForm(
                                              carCategory: carCategories[index],
                                            ));
                                      } else if (value == 'delete') {
                                        _confirmDelete(
                                            context, carCategories[index]);
                                      }
                                    },
                                    itemBuilder: (context) => [
                                      const PopupMenuItem(
                                        value: 'edit',
                                        child: Text('Edit'),
                                      ),
                                      const PopupMenuItem(
                                        value: 'delete',
                                        child: Text('Delete'),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            floatingActionButton: Visibility(
              visible: isAdmin(),
              child: FloatingActionButton(
                onPressed: () {
                  Get.to(() => const CarCategoryForm());
                },
                child: const Icon(Icons.add),
              ),
            ),
          );
  }

  bool isAdmin() {
    final u = FirebaseAuth.instance.currentUser;
    if (u != null &&
        (u.email == 'iakena420@gmail.com' ||
            u.email == 'samomwony909@gmail.com')) {
      return true;
    }
    return false;
  }
}

void _confirmDelete(BuildContext context, CarCategory carCategory) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete ${carCategory.name}?'),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text('Delete'),
            onPressed: () {
              Repo().deleteCarCategory(carCategory); // Implement this method
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('${carCategory.name} deleted'),
              ));
            },
          ),
        ],
      );
    },
  );
}
