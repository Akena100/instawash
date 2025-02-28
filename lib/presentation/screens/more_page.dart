import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:instawash/connectivity/no_internet_connection_page.dart';
import 'package:instawash/connectivity/service.dart';
import 'package:instawash/core/constants/colors.dart';
import 'package:instawash/forms/more_form.dart';
import 'package:instawash/models/more.dart';
import 'package:instawash/presentation/screens/sub_more.dart';

class MoresPage extends StatefulWidget {
  const MoresPage({super.key});

  @override
  MoresPageState createState() => MoresPageState();
}

class MoresPageState extends State<MoresPage> {
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
              title: const Text(
                'More Services',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: AppColors.secondaryColor,
            ),
            body: Padding(
              padding: const EdgeInsets.all(10.0),
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance.collection('mores').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  var mores = snapshot.data!.docs.map((doc) {
                    var data = doc.data() as Map<String, dynamic>;
                    return More(
                      id: data['id'],
                      name: data['name'],
                      imageUrl: data['imageUrl'],
                    );
                  }).toList();

                  return ListView.builder(
                    itemCount: mores.length,
                    itemBuilder: (context, index) {
                      More more = mores[index];
                      return InkWell(
                          onTap: () {
                            Get.to(() => SubMoresPage(
                                  more: more,
                                ));
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 10),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(15),
                                color: AppColors.secondaryColor),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Display image first
                                Image.network(
                                  mores[index].imageUrl,
                                  height: 200, // Set your desired height
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                                const SizedBox(height: 10),
                                // Add your UI components here based on More attributes
                                Text(
                                  mores[index].name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ));
                    },
                  );
                },
              ),
            ),
            floatingActionButton: Visibility(
              visible: x(),
              child: FloatingActionButton(
                onPressed: () {
                  Get.to(() => const MoreForm());
                },
                child: const Icon(Icons.add),
              ),
            ));
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
