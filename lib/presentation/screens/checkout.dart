import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:instawash/connectivity/no_internet_connection_page.dart';
import 'package:instawash/connectivity/service.dart';
import 'package:instawash/core/core.dart';
import 'package:instawash/models/booking.dart';
import 'package:instawash/models/car_category_select.dart';

import 'package:instawash/models/repo.dart';
import 'package:instawash/models/selected_more_service.dart';

import 'package:instawash/models/sub_service.dart';
import 'package:instawash/models/more_service.dart';
import 'package:instawash/models/subscription.dart';

import 'package:instawash/ordersuccess.dart';
import 'package:instawash/presentation/screens/payment.dart';

import 'package:uuid/uuid.dart';

class CheckoutPage extends StatefulWidget {
  final String serviceId;
  final SubService subservice;
  final List<MoreService> selectedMoreServices;
  final double total;

  final String uid;
  final Subscription? subscription;
  final String pickUpAddress;
  final double pickUpLongitude;
  final double pickUpLatitude;
  final CarCategorySelect selectedCar;
  final DateTime? date;
  final TimeOfDay? time;

  const CheckoutPage(
      {super.key,
      required this.serviceId,
      required this.subservice,
      required this.selectedMoreServices,
      required this.total,
      required this.uid,
      this.subscription,
      required this.pickUpAddress,
      required this.pickUpLongitude,
      required this.pickUpLatitude,
      required this.selectedCar,
      required this.date,
      required this.time});

  @override
  CheckoutPageState createState() => CheckoutPageState();
}

class CheckoutPageState extends State<CheckoutPage> {
  bool _isConnected = true;
  // Default to true, assuming there's a connection
  TextEditingController controller = TextEditingController();
  final uid = FirebaseAuth.instance.currentUser;

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
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double totalPrice = calculateTotalPrice();

    return !_isConnected
        ? NoInternetConnectionPage()
        : GestureDetector(
            onTap: () {
              _dismissKeyboard(context);
            },
            child: Scaffold(
              backgroundColor: AppColors.bgColor,
              appBar: AppBar(
                backgroundColor: AppColors.secondaryColor,
                iconTheme: const IconThemeData(color: Colors.white),
                title: const Text(
                  'Checkout',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // _buildSectionTitle('Selected Service:'),
                    // _buildServiceInfo(widget.service),
                    _buildSectionTitle('Service'),
                    _buildServiceInfo2(widget.subservice),
                    const SizedBox(height: 16.0),
                    if (widget.serviceId ==
                        'f54aa010-84ab-42c0-a464-866c129804ba')
                      Card(
                        margin: EdgeInsets.symmetric(vertical: 8),
                        color: AppColors.lightGrey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionTitle('  Car Details:'),
                            ListTile(
                              title: Text(
                                widget.selectedCar.number,
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.selectedCar.categoryName,
                                  ),
                                  Text(
                                    widget.selectedCar.model,
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                    if (widget.selectedMoreServices.isNotEmpty)
                      _buildSectionTitle('Selected Extra Services:'),
                    _buildSelectedMoreServicesList(),
                    const SizedBox(height: 16.0),
                    if (calculateTotalPrice() > 0) _buildTotalPrice(totalPrice),

                    Card(
                      margin: EdgeInsets.symmetric(vertical: 8),
                      color: AppColors.lightGrey,
                      child: ListTile(
                        title: const Text(
                          'Location',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(widget.pickUpAddress),
                      ),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 8),
                      padding: EdgeInsets.all(15),
                      color: AppColors.lightGrey,
                      child: TextField(
                        controller: controller,
                        maxLines: 5,
                        decoration: InputDecoration(
                            hintText: 'More Information(optional)',
                            labelText: 'More Information(optional)',
                            border: OutlineInputBorder()),
                      ),
                    )
                  ],
                ),
              ),
              bottomNavigationBar: BottomAppBar(
                color: AppColors.secondaryColor,
                child: Padding(
                  padding: const EdgeInsets.all(5),
                  child: ElevatedButton(
                    onPressed: () {
                      _onPressed();
                    },
                    child: Text(pay()),
                  ),
                ),
              ),
            ),
          );
  }

  void _onPressed() async {
    if (calculateTotalPrice() > 0) {
      Get.to(
        () => ServicePayment(
            uid: widget.uid,
            serviceId: widget.serviceId,
            subservice: widget.subservice,
            total: widget.total,
            selectedMoreServices: widget.selectedMoreServices,
            pickUpAddress: widget.pickUpAddress,
            pickUpLongitude: widget.pickUpLongitude,
            pickUpLatitude: widget.pickUpLatitude,
            date: widget.date,
            time: widget.time),
      );
    } else {
      debugPrint('price is empty');

      final user = FirebaseAuth.instance.currentUser!;
      final txRef = Uuid().v4();

      Booking booking = Booking(
        id: txRef,
        userId: user.uid,
        subscriptionId: '',
        subscriptionName: '',
        serviceName: widget.serviceId,
        subServiceId: widget.subservice.name,
        moreServiceId: '',
        price: 0.0,
        status: 'Pending',
        date: widget.date!,
        additionalInfo: '',
        durationInMinutes: 0,
        startDate: DateTime.now(),
        completeDate: DateTime.now(),
        comment: controller.text,
        location: widget.pickUpAddress,
        latitude: widget.pickUpLatitude,
        longitude: widget.pickUpLongitude,
        savedTime: DateTime.now(),
        time: widget.time!,
        type: 'Quotation',
        dispatchId: '',
        customerCare: '',
      );

      Repo().addBooking(booking).catchError((onError) {
        debugPrint(onError.toString());
      });

      for (MoreService moreService in widget.selectedMoreServices) {
        SelectedMoreService selectedMoreService = SelectedMoreService(
          id: Uuid().v4(),
          serviceId: moreService.serviceId,
          subServiceId: moreService.subServiceId,
          userId: user.uid,
          bookingId: txRef,
          name: moreService.name,
          description: moreService.description,
          price: moreService.price,
          imageUrl: moreService.imageUrl,
          moreServiceId: moreService.id,
        );
        Repo().addSelectedMoreService(selectedMoreService);
      }
      Get.to(() => OrderSuccessfulPage());
    }
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
          fontWeight: FontWeight.bold, fontSize: 18.0, color: Colors.white),
    );
  }

  Widget _buildServiceInfo(dynamic serviceInfo) {
    return Card(
      color: AppColors.lightGrey,
      elevation: 3.0,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        title: Text(
          serviceInfo.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16.0,
          ),
        ),
      ),
    );
  }

  Widget _buildServiceInfo2(dynamic serviceInfo) {
    return Card(
      color: AppColors.lightGrey,
      elevation: 3.0,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        title: Text(
          serviceInfo.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16.0,
          ),
        ),
        subtitle: Visibility(
          visible: x(),
          child: Text(
            'UGX ${serviceInfo.price}',
            style: const TextStyle(
              fontSize: 14.0,
              color: AppColors.secondaryColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedMoreServicesList() {
    if (widget.selectedMoreServices.isNotEmpty) {
      return Column(
        children: [
          for (int i = 0; i < widget.selectedMoreServices.length; i++)
            Card(
              color: AppColors.lightGrey,
              elevation: 3.0,
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: ListTile(
                title: Text(
                  widget.selectedMoreServices[i].name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                  ),
                ),
                subtitle: Visibility(
                  visible: x(),
                  child: Text(
                    'UGX ${widget.selectedMoreServices[i].price}',
                    style: const TextStyle(
                      fontSize: 14.0,
                      color: AppColors.secondaryColor,
                    ),
                  ),
                ),
                trailing: IconButton(
                  icon: const Icon(
                    Icons.delete,
                    color: Colors.red,
                  ),
                  onPressed: () {
                    setState(() {
                      widget.selectedMoreServices.removeAt(i);
                    });
                  },
                ),
              ),
            ),
        ],
      );
    } else {
      return const Text(
        'No more services selected',
        style: TextStyle(color: Colors.white),
      );
    }
  }

  Widget _buildTotalPrice(double totalPrice) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: AppColors.lightGrey,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Visibility(
        visible: x(),
        child: Text(
          'UGX $totalPrice',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18.0,
            color: AppColors.secondaryColor,
          ),
        ),
      ),
    );
  }

  double calculateTotalPrice() {
    double total = widget.subservice.price;

    for (MoreService moreService in widget.selectedMoreServices) {
      total += moreService.price;
    }
    return total;
  }

  String pay() {
    if (calculateTotalPrice() == 0 && widget.subscription == null) {
      return 'Request for Quotation';
    } else {
      return 'Pay UGX ${calculateTotalPrice()} ';
    }
  }

  x() {
    if (calculateTotalPrice() > 0) {
      return true;
    } else {
      return false;
    }
  }

  String getLoc() {
    if (widget.pickUpAddress.isNotEmpty) {
      return widget.pickUpAddress;
    } else {
      return 'No location';
    }
  }

  void _dismissKeyboard(BuildContext context) {
    FocusScope.of(context).requestFocus(FocusNode());
  }
}
