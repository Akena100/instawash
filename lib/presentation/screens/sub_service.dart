import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:instawash/connectivity/no_internet_connection_page.dart';
import 'package:instawash/connectivity/service.dart';
import 'package:instawash/core/constants/colors.dart';
import 'package:instawash/forms/more.dart';

import 'package:instawash/forms/sub_service.dart';
import 'package:instawash/models/repo.dart';

import 'package:instawash/models/sub_service.dart';
import 'package:instawash/models/subscription.dart';

class SubServicesPage extends StatefulWidget {
  final String serviceId;
  final Subscription? subscription;
  const SubServicesPage(
      {super.key, required this.serviceId, this.subscription});

  @override
  SubServicesPageState createState() => SubServicesPageState();
}

class SubServicesPageState extends State<SubServicesPage> {
  bool _isConnected = true; // Default to true, assuming there's a connection

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
              iconTheme: const IconThemeData(color: Colors.white),
              backgroundColor: AppColors.secondaryColor,
            ),
            body: SingleChildScrollView(
              // Wrap the entire body in SingleChildScrollView
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('subServices')
                      .where('serviceId', isEqualTo: widget.serviceId)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    var subservices = snapshot.data!.docs.map((doc) {
                      var data = doc.data() as Map<String, dynamic>;
                      return SubService(
                        id: data['id'],
                        serviceId: data['serviceId'],
                        name: data['name'],
                        description: data['description'],
                        price: data['price'].toDouble(),
                        imageUrl: data['imageUrl'],
                      );
                    }).toList();

                    return ListView.builder(
                      shrinkWrap:
                          true, // Allows ListView to take up only the space it needs
                      physics:
                          const NeverScrollableScrollPhysics(), // Disable internal scrolling
                      itemCount: subservices.length,
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () {
                            Get.to(() => CarForm(
                                  amount: subservices[index].price,
                                  serviceId: widget.serviceId,
                                  subService: subservices[index],
                                  subscription: widget.subscription,
                                ));
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
                                Image.network(
                                  subservices[index].imageUrl,
                                  height: 200,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                                const SizedBox(height: 10),
                                ListTile(
                                  title: Text(
                                    subservices[index].name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                  trailing: Visibility(
                                    visible: x(),
                                    child: PopupMenuButton<String>(
                                      onSelected: (value) {
                                        if (value == 'edit') {
                                          Get.to(() => SubServiceForm(
                                                subService: subservices[index],
                                                serviceId: widget.serviceId,
                                              ));
                                        } else if (value == 'delete') {
                                          _confirmDelete(
                                              context, subservices[index]);
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
            ),
            floatingActionButton: Visibility(
              visible: x(),
              child: FloatingActionButton(
                onPressed: () {
                  Get.to(() => SubServiceForm(serviceId: widget.serviceId));
                },
                child: const Icon(Icons.add),
              ),
            ),
          );
  }

  bool x() {
    final u = FirebaseAuth.instance.currentUser;
    if (u != null && u.email == 'iakena420@gmail.com' ||
        u!.email == 'samomwony909@gmail.com') {
      return true;
    }
    return false;
  }
}

void _confirmDelete(BuildContext context, SubService subservic) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete ${subservic.name}?',
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
              Repo().deleteSubService(subservic);
              // Handle delete action
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('${subservic.name} deleted'),
              ));
            },
          ),
        ],
      );
    },
  );
}
