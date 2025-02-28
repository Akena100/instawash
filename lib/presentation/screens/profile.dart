import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instawash/connectivity/no_internet_connection_page.dart';
import 'package:instawash/connectivity/service.dart';
import 'package:instawash/models/user_model.dart';
import 'package:instawash/presentation/screens/change_password.dart';

import 'package:instawash/presentation/screens/login.dart';
import 'package:instawash/presentation/screens/signupuser.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isConnected = true;

  @override
  void initState() {
    super.initState();
    _checkInternetConnection();
  }

  Future<void> _checkInternetConnection() async {
    bool isConnected = await InternetConnectivityService.isConnected();
    setState(() => _isConnected = isConnected);
  }

  @override
  Widget build(BuildContext context) {
    if (!_isConnected) return NoInternetConnectionPage();

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .snapshots(), // Listen to real-time changes
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('No user data found.'));
          }

          Map<String, dynamic> user =
              snapshot.data!.data() as Map<String, dynamic>;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile image section
                  Center(
                    child: CircleAvatar(
                      radius: 80,
                      backgroundColor: Colors.grey[300],
                      child: ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: user['imageUrl'] ?? '',
                          fit: BoxFit.cover,
                          width: 150,
                          height: 150,
                          placeholder: (context, url) => Center(
                            child: CircularProgressIndicator(),
                          ),
                          errorWidget: (context, url, error) => Icon(
                            Icons.person,
                            size: 40,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  // User details
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(user['fullName'], style: _infoTextStyle()),
                        SizedBox(height: 10),
                        Text(user['email'], style: _infoTextStyle()),
                        SizedBox(height: 10),
                        Text(user['phoneNumber'], style: _infoTextStyle()),
                        SizedBox(height: 10),
                        Text(user['role'], style: _infoTextStyle()),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: () => Get.to(() => SignUpScreen2(
                              userModel: UserModel.fromMap(user),
                            )),
                        child: Text('Edit Info'),
                      ),
                      ElevatedButton(
                        onPressed: () => Get.to(() => ChangePasswordPage()),
                        child: Text('Edit Password'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: Visibility(
        visible: viz(),
        child: BottomAppBar(
          child: ElevatedButton(
            onPressed: () => Get.offAll(() => LoginScreen()),
            child: Center(
              child: Text('LOG OUT'),
            ),
          ),
        ),
      ),
    );
  }

  TextStyle _infoTextStyle() {
    return TextStyle(fontSize: 18, fontWeight: FontWeight.w500);
  }

  bool viz() {
    return FirebaseAuth.instance.currentUser!.uid ==
        FirebaseAuth.instance.currentUser!.uid;
  }
}
