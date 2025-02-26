// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:get/get.dart';
// import 'package:instawash/connectivity/no_internet_connection_page.dart';
// import 'package:instawash/connectivity/service.dart';
// import 'package:instawash/core/constants/colors.dart';
// import 'package:instawash/forms/subscription.dart';
// import 'package:instawash/forms/subscription_offers.dart';
// import 'package:instawash/models/more_service.dart';
// import 'package:instawash/models/sub_service.dart';
// import 'package:instawash/models/subscription.dart';
// import 'package:instawash/models/subscription_offer.dart';

// class SubscriptionPage extends StatefulWidget {
//   final String serviceId;
//   final SubService subservice;
//   final List<MoreService> selectedMoreServices;
//   const SubscriptionPage(
//       {super.key,
//       required this.serviceId,
//       required this.subservice,
//       required double total,
//       required this.selectedMoreServices});

//   @override
//   SubscriptionPageState createState() => SubscriptionPageState();
// }

// class SubscriptionPageState extends State<SubscriptionPage> {
//   bool _isConnected = true; // Default to true, assuming there's a connection

//   Future<void> _checkInternetConnection() async {
//     bool isConnected = await InternetConnectivityService.isConnected();
//     setState(() {
//       _isConnected = isConnected;
//     });
//   }

//   @override
//   void initState() {
//     super.initState();
//     _checkInternetConnection();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return !_isConnected
//         ? NoInternetConnectionPage()
//         : Scaffold(
//             backgroundColor: AppColors.bgColor,
//             appBar: AppBar(
//               iconTheme: const IconThemeData(color: Colors.white),
//               title: const Text(
//                 'Subscriptions',
//                 style: TextStyle(color: Colors.white),
//               ),
//               backgroundColor: AppColors.secondaryColor,
//             ),
//             body: Container(
//               color: AppColors.bgColor,
//               padding: const EdgeInsets.all(16),
//               child: StreamBuilder(
//                 stream: FirebaseFirestore.instance
//                     .collection('subscriptions')
//                     .where('serviceId', isEqualTo: widget.serviceId)
//                     .snapshots(),
//                 builder: (BuildContext context,
//                     AsyncSnapshot<QuerySnapshot> snapshot) {
//                   if (snapshot.hasError) {
//                     return Center(
//                       child: Text('Error: ${snapshot.error}'),
//                     );
//                   }

//                   if (snapshot.connectionState == ConnectionState.waiting) {
//                     return const Center(
//                       child: CircularProgressIndicator(),
//                     );
//                   }

//                   return ListView.builder(
//                     itemCount: snapshot.data?.docs.length ?? 0,
//                     itemBuilder: (BuildContext context, int index) {
//                       DocumentSnapshot subscriptionDoc =
//                           snapshot.data!.docs[index];
//                       Subscription subscription = Subscription(
//                         id: subscriptionDoc.id,
//                         serviceId: subscriptionDoc['serviceId'],
//                         category: subscriptionDoc['category'],
//                         discount: subscriptionDoc['discount'].toDouble(),
//                         subServiceId: '',
//                         moreServiceId: '',
//                         numberOfDay: 0,
//                       );

//                       return Container(
//                         margin: const EdgeInsets.all(10),
//                         padding: const EdgeInsets.all(16),
//                         decoration: BoxDecoration(
//                           color: AppColors.secondaryColor,
//                           borderRadius: BorderRadius.circular(15),
//                         ),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.center,
//                           children: [
//                             const Icon(
//                               Icons.star_border_outlined,
//                               color: Colors.orangeAccent,
//                               size: 40,
//                             ),
//                             const SizedBox(
//                               height: 10,
//                             ),
//                             Text(
//                               subscription.category,
//                               style: const TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 25,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                             const SizedBox(height: 10),
//                             Text(
//                               ' ${subscription.discount.toString()}% OFF',
//                               style: const TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 16,
//                               ),
//                             ),
//                             const SizedBox(height: 10),
//                             ElevatedButton(
//                                 onPressed: () {},
//                                 style: ElevatedButton.styleFrom(
//                                     fixedSize: const Size(250, 50)),
//                                 child: const Text("Book Now")),
//                             const Divider(
//                               color: Colors.white,
//                             ),
//                             SubscriptionOffersList(
//                                 subscriptionId: subscription.id,
//                                 serviceId: widget.serviceId),
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 ElevatedButton(
//                                     onPressed: () =>
//                                         Get.to(() => SubscriptionOffersForm(
//                                               serviceId: widget.serviceId,
//                                               subId: subscription.id,
//                                             )),
//                                     child: const Text('Add +'))
//                               ],
//                             ),
//                           ],
//                         ),
//                       );
//                     },
//                   );
//                 },
//               ),
//             ),
//             floatingActionButton: Visibility(
//               visible: x(),
//               child: FloatingActionButton(
//                 onPressed: () {
//                   Get.to(() => SubscriptionForm(
//                         serviceId: widget.serviceId,
//                       ));
//                   // Implement logic to add new Subscription
//                 },
//                 backgroundColor: Colors.blue[900],
//                 child: const Icon(Icons.add, color: Colors.white),
//               ),
//             ));
//   }

//   x() {
//     final u = FirebaseAuth.instance.currentUser!;
//     if (u.email == 'iakena420@gmail.com') return true;
//     return false;
//   }
// }

// class SubscriptionOffersList extends StatelessWidget {
//   final String subscriptionId;
//   final String serviceId;

//   const SubscriptionOffersList(
//       {super.key, required this.subscriptionId, required this.serviceId});

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder(
//       stream: FirebaseFirestore.instance
//           .collection('subscriptionOffers')
//           .where('serviceId', isEqualTo: serviceId)
//           .where('subId', isEqualTo: subscriptionId)
//           .snapshots(),
//       builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
//         if (snapshot.hasError) {
//           return Text('Error: ${snapshot.error}');
//         }

//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const CircularProgressIndicator();
//         }

//         return ListView.builder(
//           shrinkWrap: true,
//           itemCount: snapshot.data?.docs.length ?? 0,
//           itemBuilder: (BuildContext context, int index) {
//             DocumentSnapshot offerDoc = snapshot.data!.docs[index];
//             SubscriptionOffer offer = SubscriptionOffer(
//               id: offerDoc.id,
//               name: offerDoc['name'],
//               serviceId: offerDoc['serviceId'],
//               subId: offerDoc['subId'],
//             );

//             return ListTile(
//               leading: const Icon(Icons.check, color: Colors.green),
//               title: Text(
//                 offer.name,
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontSize: 16,
//                 ),
//               ),
//               onTap: () {
//                 // Add your logic for handling subscription offer selection
//               },
//             );
//           },
//         );
//       },
//     );
//   }
// }
