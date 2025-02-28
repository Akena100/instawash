import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instawash/core/constants/colors.dart';
import 'package:instawash/presentation/screens.dart';
import 'package:instawash/presentation/screens/booking_driver.dart';
import 'package:instawash/presentation/screens/booking_tabs.dart';
import 'package:instawash/presentation/screens/visitors.dart';

class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  int _currentIndex = 0;
  final User user = FirebaseAuth.instance.currentUser!;
  String role = '';

  @override
  void initState() {
    super.initState();
    _fetchDataFromFirestore();
  }

  void _fetchDataFromFirestore() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: user.email)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      setState(() {
        role = querySnapshot.docs[0]['role']; // Fetch role

        // Ensure Drivers don't start on HomeScreen
        if (role == "Driver" && _currentIndex == 0) {
          _currentIndex = 0; // Keep it within available pages
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Pages based on role
    final List<Widget> bottomBarPages = role == "Customer Care"
        ? [
            BookingTabs(), // Customer Care sees only BookingStatus and More
            const MoreScreen(),
          ]
        : role == "Driver"
            ? [DriverBooking(), const MoreScreen()]
            : role == "Receptionist"
                ? [VisitorListPage(), const MoreScreen()]
                : [const HomeScreen(), PackagesScreen(), const MoreScreen()];

    // Bottom navigation items based on role
    final List<BottomNavigationBarItem> bottomBarItems = role == "Customer Care"
        ? [
            const BottomNavigationBarItem(
              icon: Icon(Icons.book_online),
              label: 'Bookings',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.more_horiz),
              label: 'More',
            ),
          ]
        : role == "Driver"
            ? [
                const BottomNavigationBarItem(
                  icon: Icon(Icons.list),
                  label: 'Bookings',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.more_horiz),
                  label: 'More',
                ),
              ]
            : role == "Receptionist"
                ? [
                    const BottomNavigationBarItem(
                      icon: Icon(Icons.people),
                      label: 'Visitors',
                    ),
                    const BottomNavigationBarItem(
                      icon: Icon(Icons.more_horiz),
                      label: 'More',
                    ),
                  ]
                : [
                    const BottomNavigationBarItem(
                      icon: Icon(Icons.home),
                      label: 'Home',
                    ),
                    const BottomNavigationBarItem(
                      icon: Icon(Icons.list),
                      label: 'Bookings',
                    ),
                    const BottomNavigationBarItem(
                      icon: Icon(Icons.more_horiz),
                      label: 'More',
                    ),
                  ];

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: bottomBarPages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.secondaryColor,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.orangeAccent,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: bottomBarItems,
      ),
    );
  }
}
