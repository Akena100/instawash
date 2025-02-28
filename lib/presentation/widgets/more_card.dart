// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:instawash/configs/app_typography.dart';
// import 'package:instawash/configs/space.dart';
// import 'package:instawash/core/constants/colors.dart';
// import 'package:instawash/models/more.dart';

// class MoreCard extends StatefulWidget {
//   const MoreCard({super.key});

//   @override
//   State<MoreCard> createState() => _MoreCardState();
// }

// class _MoreCardState extends State<MoreCard> {
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.all(10),
//       padding: const EdgeInsets.all(10),
//       decoration: BoxDecoration(
//           color: AppColors.secondaryColor,
//           borderRadius: BorderRadius.circular(10)),
//       child: Column(
//         children: [
//           Padding(
//             padding: Space.hf(),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   "Bills and More",
//                   style: AppText.h2b?.copyWith(letterSpacing: 2),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(
//             height: 5,
//           ),
//           FutureBuilder<QuerySnapshot>(
//             future: FirebaseFirestore.instance.collection('mores').get(),
//             builder: (context, snapshot) {
//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 return const CircularProgressIndicator();
//               } else if (snapshot.hasError) {
//                 return Text('Error: ${snapshot.error}');
//               } else {
//                 List<More> mores = snapshot.data!.docs
//                     .map((doc) => More.fromSnapshot(doc))
//                     .toList();

//                 return GridView.builder(
//                   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                     crossAxisCount: 2,
//                     crossAxisSpacing: 10,
//                     mainAxisSpacing: 10,
//                   ),
//                   itemCount: mores.length,
//                   shrinkWrap: true,
//                   physics: const NeverScrollableScrollPhysics(),
//                   itemBuilder: (context, index) {
//                     More more = mores[index];
//                     return GestureDetector(
//                       onTap: () {
//                         // Get.to(() =>
//                         //     SubServicesPage(service: service));
//                       },
//                       child: Column(
//                         children: [
//                           Container(
//                             height: 140,
//                             decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(15),
//                               border: Border.all(
//                                 color: Colors.grey,
//                                 width: 1,
//                               ),
//                             ),
//                             child: ClipRRect(
//                               borderRadius: BorderRadius.circular(10),
//                               child: Image.network(
//                                 more.imageUrl,
//                                 // Adjust the height as needed
//                                 width: double.infinity,
//                                 fit: BoxFit.cover,
//                               ),
//                             ),
//                           ),
//                           const SizedBox(
//                             height: 5,
//                           ),
//                           Text(more.name)
//                         ],
//                       ),
//                     );
//                   },
//                 );
//               }
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }
