import 'package:flutter/material.dart';
import 'package:instawash/connectivity/no_internet_connection_page.dart';
import 'package:instawash/connectivity/service.dart';
import 'package:instawash/core/constants/colors.dart';
import 'package:instawash/drawer.dart';
import 'package:instawash/presentation/screens/booking_status.dart';

class BookingTabs extends StatefulWidget {
  const BookingTabs({super.key});

  @override
  State<BookingTabs> createState() => _BookingTabsState();
}

class _BookingTabsState extends State<BookingTabs> {
  bool _isConnected = true;
  Future<void> _checkInternetConnection() async {
    bool isConnected = await InternetConnectivityService.isConnected();
    setState(() {
      _isConnected = isConnected;
    });
  }

  @override
  void initState() {
    _checkInternetConnection();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return !_isConnected
        ? NoInternetConnectionPage()
        : DefaultTabController(
            length: 7,
            child: Scaffold(
              drawer: CustomDrawer(),
              appBar: AppBar(
                iconTheme: IconThemeData(color: Colors.white),
                title: Text('INSTA WASH MOBILE',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                centerTitle: true,
                backgroundColor: AppColors.secondaryColor,
                elevation: 4.0,
                bottom: TabBar(
                  isScrollable: true,
                  indicatorColor: Colors.white,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white70,
                  labelStyle:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  tabs: [
                    Tab(text: 'Pending'),
                    Tab(text: 'Confirmed'),
                    Tab(text: 'On Route'),
                    Tab(text: 'Arrived'),
                    Tab(text: 'Complete'),
                    Tab(text: 'Cancelled'),
                    Tab(text: 'All'),
                  ],
                ),
              ),
              body: TabBarView(
                children: [
                  BookingStatus(title: 'Pending'),
                  BookingStatus(title: 'Confirmed'),
                  BookingStatus(title: 'On Route'),
                  BookingStatus(title: 'Arrived'),
                  BookingStatus(title: 'Complete'),
                  BookingStatus(title: 'Cancelled'),
                  BookingStatus(title: 'All'),
                ],
              ),
            ),
          );
  }
}
