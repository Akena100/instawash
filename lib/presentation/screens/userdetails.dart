import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instawash/models/user_model.dart';
import 'package:instawash/presentation/screens.dart';
import 'package:instawash/presentation/screens/change_password.dart';
import 'package:instawash/presentation/screens/signupuser.dart';

class UserDetailsPage extends StatelessWidget {
  final UserModel user;

  const UserDetailsPage({super.key, required this.user});

  TextStyle _infoTextStyle() {
    return TextStyle(fontSize: 18, fontWeight: FontWeight.w500);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Details'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(user.id)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return Center(child: Text("User not found"));
            }

            var userData = snapshot.data!.data() as Map<String, dynamic>;

            return SingleChildScrollView(
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
                          imageUrl: userData['imageUrl'],
                          fit: BoxFit.cover,
                          width: 150,
                          height: 150,
                          placeholder: (context, url) =>
                              CircularProgressIndicator(),
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(userData['fullName'], style: _infoTextStyle()),
                        SizedBox(height: 10),
                        Text(userData['email'], style: _infoTextStyle()),
                        SizedBox(height: 10),
                        Text(userData['phoneNumber'], style: _infoTextStyle()),
                        SizedBox(height: 10),
                        Text(userData['role'], style: _infoTextStyle()),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: () => Get.to(() => SignUpScreen2(
                              userModel: UserModel.fromMap(userData),
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
            );
          },
        ),
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

  viz() {
    if (user.id == FirebaseAuth.instance.currentUser!.uid) {
      return true;
    } else {
      return false;
    }
  }
}
