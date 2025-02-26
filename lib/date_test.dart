//  Column(
//                       children: [
//                         InkWell(
//                           onTap: () {
//                             _showDatePicker(context);
//                           },
//                           child: Container(
//                             padding: const EdgeInsets.all(16.0),
//                             width: MediaQuery.of(context).size.width * 0.8,
//                             decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(10.0),
//                               border: Border.all(color: Colors.grey),
//                             ),
//                             child: Column(
//                               children: [
//                                 const Text(
//                                   'Selected Date',
//                                   style: TextStyle(
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.white,
//                                   ),
//                                 ),
//                                 const SizedBox(height: 8.0),
//                                 Text(
//                                   selectedDate != null
//                                       ? '${selectedDate!.toLocal()}'
//                                           .split(' ')[0]
//                                       : 'Tap to select date',
//                                   style: const TextStyle(color: Colors.white),
//                                   textAlign: TextAlign.center,
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 16.0),
//                         InkWell(
//                           onTap: () {
//                             _showTimePicker(context);
//                           },
//                           child: Container(
//                             width: MediaQuery.of(context).size.width * 0.8,
//                             padding: const EdgeInsets.all(16.0),
//                             decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(10.0),
//                               border: Border.all(color: Colors.grey),
//                             ),
//                             child: Column(
//                               children: [
//                                 const Text(
//                                   'Selected Time',
//                                   style: TextStyle(
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.white,
//                                   ),
//                                 ),
//                                 const SizedBox(height: 8.0),
//                                 Text(
//                                   selectedTime != null
//                                       ? selectedTime!.format(context)
//                                       : 'Tap to select time',
//                                   style: const TextStyle(color: Colors.white),
//                                   textAlign: TextAlign.center,
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
                    