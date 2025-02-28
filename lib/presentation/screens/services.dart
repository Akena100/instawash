import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:instawash/connectivity/no_internet_connection_page.dart';
import 'package:instawash/connectivity/service.dart';
import 'package:instawash/forms/service.dart';
import 'package:instawash/models/service.dart';
import 'package:instawash/core/constants/colors.dart';
import 'package:instawash/models/repo.dart';

class ServiceListPage extends StatefulWidget {
  const ServiceListPage({super.key});

  @override
  ServiceListPageState createState() => ServiceListPageState();
}

class ServiceListPageState extends State<ServiceListPage> {
  bool _isConnected = true; // Default to true, assuming there's a connection

  Future<void> _checkInternetConnection() async {
    // Replace with your actual internet connection check
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
              iconTheme: const IconThemeData(color: Colors.white),
              title: const Text(
                'Services',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: AppColors.secondaryColor,
            ),
            body: Padding(
              padding: const EdgeInsets.all(10.0),
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('services')
                    .orderBy('createDate', descending: false)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  var services = snapshot.data!.docs.map((doc) {
                    return Service.fromSnapshot(doc);
                  }).toList();

                  return ListView.builder(
                    itemCount: services.length,
                    itemBuilder: (context, index) {
                      final service = services[index];
                      return InkWell(
                        onTap: () {
                          // Navigate to the details page
                          // Get.to(() => SubDetails(service: service));
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
                              // Display image first
                              Image.network(
                                service.imageUrl,
                                height: 200, // Set your desired height
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                              const SizedBox(height: 10),
                              ListTile(
                                title: Text(
                                  service.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                trailing: PopupMenuButton<String>(
                                  onSelected: (value) {
                                    if (value == 'edit') {
                                      Get.to(() => ServiceForm(
                                            service: service,
                                          ));
                                    } else if (value == 'delete') {
                                      _confirmDelete(context, service);
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
                              // Add more components as needed
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
              visible: _isUserAdmin(),
              child: FloatingActionButton(
                onPressed: () {
                  // Navigate to add service form
                  Get.to(() => const ServiceForm());
                },
                child: const Icon(Icons.add),
              ),
            ),
          );
  }

  bool _isUserAdmin() {
    final user = FirebaseAuth.instance.currentUser;
    return user != null &&
        (user.email == 'iakena420@gmail.com' ||
            user.email == 'samomwony909@gmail.com');
  }

  void _confirmDelete(BuildContext context, Service service) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: Text('Are you sure you want to delete ${service.name}?',
              style: const TextStyle(color: Colors.black)),
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
                Repo().deleteService(service);
                // Handle delete action
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('${service.name} deleted'),
                ));
              },
            ),
          ],
        );
      },
    );
  }
}
