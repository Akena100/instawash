import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:instawash/connectivity/no_internet_connection_page.dart';
import 'package:instawash/connectivity/service.dart';
import 'package:instawash/core/core.dart';
import 'package:instawash/models/booking.dart';
import 'package:instawash/models/repo.dart';
import 'package:instawash/models/selected_more_service.dart';
import 'package:instawash/presentation/widgets/button_slider.dart';
import 'package:instawash/presentation/widgets/button_slider_complete.dart';
import 'package:instawash/presentation/widgets/button_slider_track.dart';
import 'package:search_page/search_page.dart';
import 'package:slider_button/slider_button.dart';
import 'package:url_launcher/url_launcher.dart';

class CheckoutPage2 extends StatefulWidget {
  final Booking booking;

  const CheckoutPage2({
    super.key,
    required this.booking,
  });

  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage2> {
  final x = FirebaseAuth.instance.currentUser!;
  List itemsTemp = [];
  List itemsTemp2 = [];
  int itemLength = 0;
  String publicKey = '';
  bool _isConnected = true; // Default to true, assuming there's a connection
  String xurl = '';
  User user = FirebaseAuth.instance.currentUser!;

  Future<void> _checkInternetConnection() async {
    bool isConnected = await InternetConnectivityService.isConnected();
    setState(() {
      _isConnected = isConnected;
    });
  }

  @override
  void initState() {
    fetch();
    _checkInternetConnection();

    super.initState();
  }

  String name = '';
  String contact = '';
  String imageUrl = '';
  String role = '';

  String name1 = '';
  String contact1 = '';
  String imageUrl1 = '';

  void fetch() async {
    try {
      QuerySnapshot querySnapshot3 = await FirebaseFirestore.instance
          .collection('users')
          .where('id', isEqualTo: user.uid)
          .get();
      QuerySnapshot querySnapshot4 = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'Driver')
          .get();

      QuerySnapshot querySnapshot1 = await FirebaseFirestore.instance
          .collection('users')
          .where('id', isEqualTo: widget.booking.dispatchId)
          .get();

      QuerySnapshot querySnapshot0 = await FirebaseFirestore.instance
          .collection('users')
          .where('id', isEqualTo: widget.booking.userId)
          .get();

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('selectedMoreServices')
          .where('bookingId', isEqualTo: widget.booking.id)
          .get();

      QuerySnapshot querySnapshot2 = await FirebaseFirestore.instance
          .collection('subServices')
          .where('name', isEqualTo: widget.booking.subServiceId)
          .get();

      if (querySnapshot3.docs.isNotEmpty) {
        setState(() {
          role = querySnapshot3.docs[0]['role'];
        });
      }

      if (querySnapshot1.docs.isNotEmpty) {
        setState(() {
          imageUrl = querySnapshot1.docs[0]['imageUrl'];
          name = querySnapshot1.docs[0]['fullName'];
          contact = querySnapshot1.docs[0]['phoneNumber'];
        });
      }

      if (querySnapshot0.docs.isNotEmpty) {
        setState(() {
          imageUrl1 = querySnapshot0.docs[0]['imageUrl'];
          name1 = querySnapshot0.docs[0]['fullName'];
          contact1 = querySnapshot0.docs[0]['phoneNumber'];
        });
      }

      if (querySnapshot.docs.isNotEmpty) {
        setState(() {
          itemsTemp = querySnapshot.docs
              .map((DocumentSnapshot document) =>
                  document.data() as Map<String, dynamic>)
              .toList();
          itemLength = itemsTemp.length;
        });
      }
      if (querySnapshot4.docs.isNotEmpty) {
        setState(() {
          itemsTemp2 = querySnapshot4.docs
              .map((DocumentSnapshot document) =>
                  document.data() as Map<String, dynamic>)
              .toList();
        });
      }

      if (querySnapshot2.docs.isNotEmpty) {
        setState(() {
          xurl = querySnapshot2.docs[0]['imageUrl'];
        });
      }
    } catch (e) {
      debugPrint("Error fetching data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    double totalPrice = calculateTotalPrice();

    return !_isConnected
        ? NoInternetConnectionPage()
        : Scaffold(
            backgroundColor: AppColors.bgColor,
            appBar: AppBar(
              backgroundColor: AppColors.secondaryColor,
              iconTheme: const IconThemeData(color: Colors.white),
              title: const Text(
                'My Booking',
                style: TextStyle(color: Colors.white),
              ),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: CircleAvatar(
                      radius: 150,
                      backgroundColor:
                          Colors.grey[300], // Set a default background color
                      child: ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: xurl,
                          fit: BoxFit.cover,
                          width: MediaQuery.of(context)
                              .size
                              .width, // Adjust to fit the CircleAvatar size
                          height: MediaQuery.of(context).size.height,
                          placeholder: (context, url) => Center(
                            child:
                                CircularProgressIndicator(), // Show loading indicator
                          ),
                          errorWidget: (context, url, error) => Icon(
                            Icons
                                .cleaning_services, // Default user icon if the image fails
                            size: 200,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  _buildSectionTitle('Service'),
                  Card(
                    color: AppColors.lightGrey,
                    elevation: 3.0,
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      title: Text(
                        widget.booking.subServiceId,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                        ),
                      ),
                      subtitle: Text(
                        widget.booking.price.toString(),
                        style: const TextStyle(
                          fontWeight: FontWeight.w200,
                        ),
                      ),
                    ),
                  ),
                  const Divider(),
                  const SizedBox(height: 16.0),
                  if (itemsTemp.isNotEmpty)
                    _buildSectionTitle('Selected Extra Services:'),
                  _buildSelectedMoreServicesList(),
                  const SizedBox(height: 16.0),
                  Visibility(visible: y(), child: _buildTotalPrice(totalPrice)),
                  Card(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    color: AppColors.lightGrey,
                    child: ListTile(
                      title: const Text(
                        'Location',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(widget.booking.location),
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  if (role == 'Customer Care')
                    Container(
                      decoration: BoxDecoration(
                          color: AppColors.secondaryColor,
                          borderRadius: BorderRadius.circular(15)),
                      child: Column(
                        children: [
                          userCard(
                            imageUrl: imageUrl,
                            name: name,
                            contact: contact,
                            title: 'Dispatch Details',
                          ),

                          SizedBox(height: 16),
                          // Customer Details
                          userCard(
                            imageUrl: imageUrl1,
                            name: name1,
                            contact: contact1,
                            title: 'Customer Details',
                          ),
                          SizedBox(height: 16),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            bottomNavigationBar: Visibility(
              visible: view(widget.booking),
              child: BottomAppBar(
                  color: AppColors.secondaryColor,
                  height: MediaQuery.of(context).size.height * 0.33,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      user.uid == widget.booking.userId
                          ? Column(
                              children: [
                                userCard(
                                  imageUrl: imageUrl,
                                  name: name,
                                  contact: contact,
                                  title: 'Dispatch Details',
                                ),
                                if (name.isNotEmpty &&
                                    widget.booking.status == 'On Route')
                                  JourneyButton1(booking: widget.booking)
                              ],
                            )
                          : Column(
                              children: [
                                userCard(
                                  imageUrl: imageUrl1,
                                  name: name1,
                                  contact: contact1,
                                  title: 'Customer Details',
                                ),
                                if (name.isNotEmpty &&
                                    (widget.booking.status == 'Confirmed' ||
                                        widget.booking.status == 'On Route'))
                                  JourneyButton(
                                    booking: widget.booking,
                                  ),
                                if (name.isNotEmpty &&
                                    widget.booking.status == 'Arrived')
                                  SliderButton(
                                    action: () async {
                                      FirebaseFirestore.instance
                                          .collection('bookings')
                                          .doc(widget.booking.id)
                                          .update({'status': 'Working'});
                                      setState(() {});
                                      return true;
                                    },
                                    label: Text(
                                      "Start Working",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 17,
                                      ),
                                    ),
                                    icon: Center(
                                      child: Icon(
                                        Icons.cleaning_services,
                                        color: Colors.orangeAccent,
                                        size: 40.0,
                                      ),
                                    ),
                                    width: 250,
                                    radius: 10,
                                    buttonColor: AppColors.secondaryColor,
                                    backgroundColor: Colors.grey.shade800,
                                    highlightedColor: Colors.orange,
                                    baseColor: AppColors.secondaryColor,
                                    boxShadow: BoxShadow(
                                        color: Colors.orange, blurRadius: 10),
                                  ),
                                if (name.isNotEmpty &&
                                    widget.booking.status == 'Working')
                                  CompleteButton(booking: widget.booking)
                              ],
                            ),
                    ],
                  )),
            ),
          );
  }

  Widget userCard(
      {required String imageUrl,
      required String name,
      required String contact,
      required String title}) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 10,
          ),
          Divider(),
          name != ''
              ? Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.grey[300],
                      child: ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: imageUrl,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          placeholder: (context, url) =>
                              const CircularProgressIndicator(),
                          errorWidget: (context, url, error) => const Icon(
                              Icons.person,
                              size: 40,
                              color: Colors.grey),
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: ListTile(
                          title: Text(
                            name,
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                          subtitle: Text(
                            contact,
                            style: const TextStyle(
                                fontSize: 16, color: Colors.grey),
                          ),
                          trailing: IconButton(
                              icon: FaIcon(
                                FontAwesomeIcons.phone,
                                color: Colors.greenAccent,
                              ),
                              onPressed: () {
                                _makePhoneCall(contact);
                              })),
                    )
                  ],
                )
              : role == 'Customer Care'
                  ? ElevatedButton(
                      onPressed: () {
                        showSearch(
                          context: context,
                          delegate: SearchPage(
                            showItemsOnEmpty: true,
                            barTheme: ThemeData(
                              textTheme: const TextTheme(
                                bodyLarge: TextStyle(color: Colors.black),
                              ),
                            ),
                            onQueryUpdate: print,
                            items: itemsTemp2,
                            searchLabel: 'Search Dispatcher',
                            suggestion: const Center(
                              child: Text(
                                  'Filter drivers by name, category or description'),
                            ),
                            failure: const Center(
                              child: Text('No item found :('),
                            ),
                            filter: (product) => [
                              product['fullName'],
                            ],
                            builder: (product) => ListTile(
                              leading: Image.network(
                                '${product['imageUrl']}',
                                width: 60,
                                height: 60,
                                fit: BoxFit.contain,
                              ),
                              title: Text(product['fullName']),
                              onTap: () async {
                                try {
                                  await FirebaseFirestore.instance
                                      .collection('bookings')
                                      .doc(widget.booking.id)
                                      .update({
                                    'dispatchId': product['id'],
                                    'status': 'Confirmed',
                                  });

                                  if (widget.booking.dispatchId.isNotEmpty) {
                                    await FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(widget.booking.dispatchId)
                                        .update({
                                      'address': 'Active',
                                    });
                                  }

                                  if (mounted) {
                                    Navigator.pop(context);
                                  }
                                } catch (e) {
                                  debugPrint("Error updating Firestore: $e");
                                }
                              },
                            ),
                          ),
                        );
                      },
                      child: Text('Disaptch'))
                  : Center(
                      child: Text(
                        'Awaiting.....',
                        style: TextStyle(color: Colors.white),
                      ),
                    )
        ],
      ),
    );
  }

  Widget _buildTotalPrice(double totalPrice) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: AppColors.lightGrey,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Visibility(
        visible: y(),
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

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
          fontWeight: FontWeight.bold, fontSize: 18.0, color: Colors.white),
    );
  }

  Widget _buildSelectedMoreServicesList() {
    if (itemsTemp.isNotEmpty) {
      return Column(
        children: [
          for (int i = 0; i < itemLength; i++)
            Card(
              color: AppColors.lightGrey,
              elevation: 3.0,
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: ListTile(
                title: Text(
                  itemsTemp[i].name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                  ),
                ),
                subtitle: Text(
                  'UGX ${itemsTemp[i].price}',
                  style: const TextStyle(
                    fontSize: 14.0,
                    color: AppColors.secondaryColor,
                  ),
                ),
                trailing: IconButton(
                  icon: const Icon(
                    Icons.delete,
                    color: Colors.red,
                  ),
                  onPressed: () {
                    setState(() {
                      Repo().deleteSelectedMoreService(itemsTemp[i]);
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

  double calculateTotalPrice() {
    double total = widget.booking.price;

    for (SelectedMoreService moreService in itemsTemp) {
      total += moreService.price;
    }

    return total;
  }

  y() {
    if (calculateTotalPrice() > 0) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> _makePhoneCall(String contact) async {
    final Uri launchUri = Uri(scheme: 'tel', path: contact);
    await launchUrl(launchUri, mode: LaunchMode.externalApplication);
  }

  view(Booking booking) {
    if (user.uid == widget.booking.userId ||
        user.uid == widget.booking.dispatchId) {
      if (widget.booking.status == 'Complete' ||
          widget.booking.status == 'Cancelled') {
        return false;
      } else {
        return true;
      }
    }

    return false;
  }
}
