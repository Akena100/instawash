import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:instawash/application/blocs/auth_bloc/auth_bloc.dart';
import 'package:instawash/core/core.dart';

import 'package:instawash/presentation/car_category.dart';
import 'package:instawash/presentation/screens/ai_chat.dart';
import 'package:instawash/presentation/screens/booking.dart';

import 'package:instawash/presentation/screens/faq.dart';
import 'package:instawash/presentation/screens/notifications.dart';
import 'package:instawash/presentation/screens/services.dart';
import 'package:instawash/presentation/screens/users.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key});

  @override
  State<CustomDrawer> createState() => _DrawerState();
}

class _DrawerState extends State<CustomDrawer> {
  String email = '';
  String role = '';
  String name = '';
  int cartItemCount = 0;
  String iurl = '';
  bool isLoading = true;
  int unreadCount = 0;

  final User user = FirebaseAuth.instance.currentUser!;

  @override
  void initState() {
    super.initState();
    _fetchDataFromFirestore();
    _getUnreadNotifications();
  }

  Future<void> _getUnreadNotifications() async {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Fetch unread notifications for the current user
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('notifications')
          .where('userId', isEqualTo: user.uid)
          .where('read', isEqualTo: false)
          .get();

      setState(() {
        unreadCount = querySnapshot.size;
      });
    }
  }

  Future<void> _fetchDataFromFirestore() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: user.email)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        setState(() {
          email = querySnapshot.docs[0]['fullName'];
          iurl = querySnapshot.docs[0]['imageUrl'];
          role = querySnapshot.docs[0]['role'];
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching user data: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.bgColor,
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                DrawerHeader(
                  decoration: const BoxDecoration(
                    color: AppColors.secondaryColor,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.grey[300],
                        child: ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: iurl,
                            fit: BoxFit.cover,
                            width: 150,
                            height: 150,
                            placeholder: (context, url) =>
                                const CircularProgressIndicator(),
                            errorWidget: (context, url, error) => const Icon(
                                Icons.person,
                                size: 40,
                                color: Colors.grey),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(context).pushNamed(AppRouter.profile);
                            debugPrint(role);
                          },
                          child: Text(
                            email,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18.0,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (role != 'Driver')
                  ListTile(
                    leading: const Icon(Icons.home, color: Colors.purple),
                    title: const Text('Home',
                        style: TextStyle(color: Colors.white)),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).pushNamed(AppRouter.root);
                    },
                  ),
                ListTile(
                  leading: const Icon(Icons.receipt, color: Colors.orange),
                  title: const Text('Bookings',
                      style: TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.pop(context);
                    Get.to(() => const PackagesScreen());
                  },
                ),
                if (user.email == 'iakena420@gmail.com' ||
                    role == 'Administrator')
                  ListTile(
                    leading: const Icon(Icons.person_2, color: Colors.green),
                    title: const Text('Users',
                        style: TextStyle(color: Colors.white)),
                    onTap: () {
                      Navigator.pop(context);
                      Get.to(() => UserListPage());
                    },
                  ),
                ListTile(
                  leading: const Icon(Icons.notifications, color: Colors.red),
                  title: const Text('Notifications',
                      style: TextStyle(color: Colors.white)),
                  trailing: unreadCount > 0
                      ? Badge(
                          label: Text(
                            unreadCount.toString(),
                            style: const TextStyle(color: Colors.white),
                          ),
                          backgroundColor: Colors.red,
                        )
                      : null,
                  onTap: () {
                    Navigator.pop(context);
                    Get.to(() => NotificationsPage());
                  },
                ),
                if (user.email == 'iakena420@gmail.com' ||
                    role == 'Administrator')
                  ListTile(
                    leading: const Icon(Icons.shopping_basket,
                        color: Colors.blueGrey),
                    title: const Text('Car Category',
                        style: TextStyle(color: Colors.white)),
                    onTap: () {
                      Navigator.pop(context);
                      Get.to(() => const CarCategoryPage());
                    },
                  ),
                if (user.email == 'iakena420@gmail.com' ||
                    role == 'Administrator')
                  ListTile(
                    leading: const Icon(Icons.shopping_basket,
                        color: Colors.blueGrey),
                    title: const Text('Test Map',
                        style: TextStyle(color: Colors.white)),
                    onTap: () {
                      Navigator.pop(context);
                      Get.to(() => ChatScreen());
                    },
                  ),
                if (user.email == 'iakena420@gmail.com' ||
                    role == 'Administrator')
                  ListTile(
                    leading: const Icon(Icons.shopping_basket,
                        color: Colors.blueGrey),
                    title: const Text('Services',
                        style: TextStyle(color: Colors.white)),
                    onTap: () {
                      Navigator.pop(context);
                      Get.to(() => const ServiceListPage());
                    },
                  ),
                ListTile(
                  leading:
                      const Icon(Icons.contact_mail, color: Colors.lightBlue),
                  title: const Text('Contact Us',
                      style: TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context).pushNamed(AppRouter.contact);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.list_outlined, color: Colors.red),
                  title: const Text('Terms & Conditions',
                      style: TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context).pushNamed(AppRouter.terms);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.security, color: Colors.green),
                  title: const Text('Privacy Policy',
                      style: TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context).pushNamed(AppRouter.privacy);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.question_mark_outlined,
                      color: Colors.blueGrey),
                  title:
                      const Text('FAQ', style: TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.pop(context);
                    Get.to(() => FAQPage());
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.redAccent),
                  title: const Text('Logout',
                      style: TextStyle(color: Colors.white)),
                  onTap: () {
                    context.read<AuthBloc>().add(SignOutRequestedEvent());
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      AppRouter.splash,
                      (route) => false,
                    );
                  },
                ),
                const SizedBox(height: 100),
              ],
            ),
    );
  }
}
