import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instawash/connectivity/no_internet_connection_page.dart';
import 'package:instawash/connectivity/service.dart';
import 'package:instawash/core/constants/colors.dart';
import 'package:instawash/forms/more.dart';

import 'package:instawash/models/sub_service.dart';
import 'package:instawash/models/subscription.dart';

class SubDetails extends StatefulWidget {
  final SubService subService;
  final double amount;
  final String serviceId;
  final Subscription? subscription;

  const SubDetails(
      {required this.amount,
      super.key,
      required this.subService,
      this.subscription,
      required this.serviceId});

  @override
  SubDetailsState createState() => SubDetailsState();
}

class SubDetailsState extends State<SubDetails> {
  bool _isConnected = true; // Default to true, assuming there's a connection

  Future<void> _checkInternetConnection() async {
    bool isConnected = await InternetConnectivityService.isConnected();
    setState(() {
      _isConnected = isConnected;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _checkInternetConnection();
  }

  @override
  @override
  Widget build(BuildContext context) {
    final subServiceName = widget.subService.name;
    final subServiceDescription = widget.subService.description;
    final subServiceImageUrl = widget.subService.imageUrl;

    return !_isConnected
        ? NoInternetConnectionPage()
        : Scaffold(
            backgroundColor: AppColors.bgColor,
            // appBar: AppBar(
            //   title: Text(
            //     subServiceName,
            //     style: const TextStyle(color: Colors.white),
            //   ),
            //   backgroundColor: AppColors.secondaryColor,
            //   iconTheme: const IconThemeData(color: Colors.white),
            // ),
            body: Stack(
              children: [
                // Image
                if (subServiceImageUrl.isNotEmpty)
                  Positioned.fill(
                    child: Image.network(
                      subServiceImageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Center(child: Text('Image Not Available')),
                    ),
                  )
                else
                  const Center(child: Text('Image Not Available')),

                // Details Container
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.9),
                        ],
                      ),
                    ),
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Service Name
                        Text(
                          subServiceName,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        // Service Details
                        Text(subServiceDescription,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.justify),
                        // Book Button
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            Get.to(() => CarForm(
                                  amount: widget.amount,
                                  serviceId: widget.serviceId,
                                  subService: widget.subService,
                                  subscription: widget.subscription,
                                ));
                          },
                          child: const Text('Book Now'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
  }
}
