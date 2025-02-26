import 'package:cached_network_image/cached_network_image.dart';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import 'package:instawash/connectivity/no_internet_connection_page.dart';
import 'package:instawash/connectivity/service.dart';
import 'package:instawash/core/core.dart';

import 'package:instawash/forms/more_service.dart';
import 'package:instawash/models/car_category.dart';

import 'package:instawash/models/car_category_select.dart';

import 'package:instawash/models/more_service.dart';

import 'package:instawash/models/sub_service.dart';
import 'package:instawash/models/subscription.dart';
import 'package:instawash/mp.dart';

import 'package:uuid/uuid.dart';

class CarForm extends StatefulWidget {
  final double amount;

  static const String id = 'CarForm';
  final String serviceId;
  final SubService subService;
  final Subscription? subscription;

  const CarForm({
    required this.amount,
    super.key,
    required this.subService,
    this.subscription,
    required this.serviceId,
  });

  @override
  CarFormState createState() => CarFormState();
}

class CarFormState extends State<CarForm> {
  List<MoreService>? moreServices;
  final uid = const Uuid().v4();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _numberController = TextEditingController();

  User user = FirebaseAuth.instance.currentUser!;
  String? _selectedCategory; // For selected category
  double categoryPrice = 0.0; // Store selected category price

  TextEditingController controller = TextEditingController();
  String? _selectedModel;
  double totalPrice = 0;

  bool _isConnected = true; // Default to true, assuming there's a connection
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
        _dateController.text =
            "${pickedDate.toLocal()}".split(' ')[0]; // Format date
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (pickedTime != null && pickedTime != _selectedTime) {
      setState(() {
        _selectedTime = pickedTime;
        _timeController.text = pickedTime.format(context); // Format time
      });
    }
  }

  Future<void> _checkInternetConnection() async {
    bool isConnected = await InternetConnectivityService.isConnected();
    setState(() {
      _isConnected = isConnected;
    });
  }

  @override
  void initState() {
    super.initState();
    totalPrice = widget.amount;

    _checkInternetConnection();
    getMoreServices().then((services) {
      setState(() {
        moreServices = services;
      });
    });
  }

  Future<List<MoreService>> getMoreServices() async {
    List<MoreService> moreServices = [];

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('moreServices')
        .where('serviceId', isEqualTo: widget.serviceId)
        .where('subServiceId', isEqualTo: widget.subService.id)
        .get();

    for (var doc in querySnapshot.docs) {
      MoreService moreService = MoreService(
        name: doc['name'],
        price: doc['price'],
        id: doc['id'],
        description: doc['description'],
        imageUrl: doc['imageUrl'],
        serviceId: doc['serviceId'],
        subServiceId: doc['subServiceId'],
        isSelected: null,
      );
      moreServices.add(moreService);
    }

    return moreServices;
  }

  List<MoreService> getSelectedMoreServices() {
    return moreServices
            ?.where((service) => service.isSelected == true)
            .toList() ??
        [];
  }

  final u = FirebaseAuth.instance.currentUser!;
  double categoryTotal = 0;
  Stream<List<CarCategory>> _fetchCarCategories() {
    return FirebaseFirestore.instance
        .collection('carCategories')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              return CarCategory.fromJson(doc.data());
            }).toList());
  }

  @override
  Widget build(BuildContext context) {
    return !_isConnected
        ? NoInternetConnectionPage()
        : Scaffold(
            backgroundColor: AppColors.bgColor,
            appBar: AppBar(
              backgroundColor: AppColors.bgColor,
              iconTheme: IconThemeData(color: Colors.white),
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height * 0.4,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10)),
                      child: CachedNetworkImage(
                        imageUrl: widget.subService.imageUrl,
                        placeholder: (context, url) =>
                            CircularProgressIndicator(),
                        errorWidget: (context, url, error) => Icon(Icons.error),
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(color: Colors.white),
                      child: ExpansionTile(
                        backgroundColor: Colors.white,
                        childrenPadding: EdgeInsets.all(15),
                        title: Text(
                          widget.subService.name,
                        ),
                        children: [
                          Text(
                            widget.subService.description,
                            textAlign: TextAlign.justify,
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    if (widget.serviceId ==
                        'f54aa010-84ab-42c0-a464-866c129804ba')
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Car Details',
                            style: TextStyle(fontSize: 20, color: Colors.white),
                          ),
                          SizedBox(
                            height: 16,
                          ),
                          StreamBuilder<List<CarCategory>>(
                            stream: _fetchCarCategories(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const CircularProgressIndicator();
                              } else if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}');
                              } else if (!snapshot.hasData ||
                                  snapshot.data!.isEmpty) {
                                return const Text('No categories available');
                              } else {
                                return DropdownButtonFormField<String>(
                                  style: TextStyle(color: Colors.white),
                                  dropdownColor: Colors.black,
                                  value: _selectedCategory,
                                  items: snapshot.data!.map((category) {
                                    return DropdownMenuItem<String>(
                                      value: category.name,
                                      child: Text(
                                          '${category.name}   ${category.price}'),
                                      onTap: () async {
                                        setState(() {
                                          totalPrice -= categoryPrice;
                                        });
                                        // We won't use onTap here, but it can be used if needed.
                                        category.price;
                                      },
                                    );
                                  }).toList(),
                                  decoration: const InputDecoration(
                                    labelText: 'Select Category',
                                    labelStyle: TextStyle(color: Colors.white),
                                    border: OutlineInputBorder(),
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedCategory =
                                          value; // Update selected category

                                      final selectedCategory = snapshot.data!
                                          .firstWhere((category) =>
                                              category.name == value);

                                      setState(() {
                                        categoryPrice = selectedCategory.price;
                                        totalPrice += categoryPrice;
                                      });
                                    });
                                  },
                                  validator: (value) {
                                    if (value == null) {
                                      return 'Please select a category';
                                    }
                                    return null;
                                  },
                                );
                              }
                            },
                          ),
                          SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            style: TextStyle(color: Colors.white),
                            dropdownColor: Colors.black,
                            decoration: const InputDecoration(
                              labelText: 'Car Model',
                              labelStyle: TextStyle(color: Colors.white),
                              border: OutlineInputBorder(),
                            ),
                            items: [
                              'Toyota',
                              'Ford',
                              'BMW',
                              'Kia',
                              'Nissan',
                              'Mercedes-Benz',
                              'Honda',
                              'Mitsubishi',
                              'Subaru',
                              'Suzuki',
                              'Hyundai',
                              'Mazda',
                              'Volkswagen',
                              'Peugeot',
                              'Isuzu',
                              'Other'
                            ].map((String model) {
                              return DropdownMenuItem<String>(
                                value: model,
                                child: Text(model),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              _selectedModel = newValue;

                              // Handle selection
                            },
                          ),
                          const SizedBox(height: 16.0),
                          TextFormField(
                            style: TextStyle(color: Colors.white),
                            controller: _numberController,
                            decoration: const InputDecoration(
                              labelText: 'Plate Number e.g UBB 123G',
                              labelStyle: TextStyle(color: Colors.white),
                              fillColor: Colors.white,
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a number plate';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    SizedBox(
                      height: 10,
                    ),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Date TextFormField
                          TextFormField(
                            controller: _dateController,
                            decoration: InputDecoration(
                              labelText: 'Service Date',
                              labelStyle: TextStyle(color: Colors.white),
                              fillColor: Colors.white,
                              border: OutlineInputBorder(),
                              suffixIcon: Icon(Icons.calendar_today,
                                  color: Colors.white),
                            ),
                            style: TextStyle(color: Colors.white),
                            onTap: () async {
                              FocusScope.of(context).requestFocus(FocusNode());
                              await _selectDate(context);
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select a date';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 20),

                          // Time TextFormField
                          TextFormField(
                            controller: _timeController,
                            decoration: InputDecoration(
                              labelText: 'Service Time',
                              labelStyle: TextStyle(color: Colors.white),
                              fillColor: Colors.white,
                              border: OutlineInputBorder(),
                              suffixIcon:
                                  Icon(Icons.access_time, color: Colors.white),
                            ),
                            style: TextStyle(color: Colors.white),
                            onTap: () async {
                              FocusScope.of(context).requestFocus(FocusNode());
                              await _selectTime(context);
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select a time';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    if (widget.serviceId == 'f54aa010-84ab-42c0-a464-866c129804ba' ||
                        widget.serviceId ==
                            '05f75bdc-b6db-48c5-aca5-f4ac9108d0b0' ||
                        widget.serviceId ==
                            '93d19373-2f2d-45c3-b984-c00ed488a208' ||
                        widget.serviceId ==
                            'cd40135b-f73b-46ea-a0bb-92814e5f1459')
                      Column(
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(15),
                            child: Text(
                              'Select Extras',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          // // Column with null checks and fallback values
                          Column(
                            children: [
                              if (moreServices !=
                                  null) // Check if moreServices is not null
                                for (int i = 0; i < moreServices!.length; i++)
                                  CheckboxListTile(
                                    tileColor: Colors.white,
                                    title: Text(
                                      '${moreServices![i].name} ', // Fallback for null name
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Text(
                                      'UGX ${moreServices![i].price}', // Fallback for null price
                                    ),
                                    value: moreServices![i].isSelected ??
                                        false, // Fallback for null isSelected
                                    onChanged: (value) {
                                      setState(() {
                                        moreServices![i].isSelected = value;
                                      });
                                      if (value == true) {
                                        setState(() {
                                          totalPrice += moreServices![i].price;
                                        });
                                      } else {
                                        setState(() {
                                          totalPrice -= moreServices![i].price;
                                        });
                                      }
                                    },
                                    secondary: Visibility(
                                      visible: check(
                                          u), // Ensure `check(u)` handles null safely
                                      child: PopupMenuButton<String>(
                                        onSelected: (value) {
                                          if (value == 'edit') {
                                            Get.to(
                                              () => MoreServiceForm(
                                                serviceId: widget.serviceId,
                                                subservice: widget.subService,
                                                moreService: moreServices![i],
                                              ),
                                            );
                                          } else if (value == 'delete') {
                                            _confirmDelete(
                                                context, moreServices![i]);
                                          } else if (value == 'view') {
                                            _showInfoBottomSheet(
                                                moreServices![i]);
                                          }
                                        },
                                        itemBuilder: (context) => [
                                          const PopupMenuItem(
                                            value: 'view',
                                            child: Text('View'),
                                          ),
                                          const PopupMenuItem(
                                            value: 'edit',
                                            child: Text('Edit'),
                                          ),
                                          const PopupMenuItem(
                                            value: 'delete',
                                            child: Text('Delete'),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                            ],
                          ),
                        ],
                      ),
                    if (u.email == 'iakena420@gmail.com')
                      ElevatedButton(
                        onPressed: () {
                          Get.to(
                            () => MoreServiceForm(
                              serviceId: widget.serviceId,
                              subservice: widget.subService,
                            ),
                          )!
                              .then((_) async {
                            // Fetch updated more services after adding
                            List<MoreService> updatedMoreServices =
                                await getMoreServices();
                            setState(() {
                              moreServices =
                                  updatedMoreServices; // Update the state
                            });
                          });
                        },
                        child: const Text('Add More'),
                      ),
                    const SizedBox(height: 16.0),
                  ],
                ),
              ),
            ),
            bottomNavigationBar: BottomAppBar(
              color: AppColors.secondaryColor,
              child: Padding(
                  padding: const EdgeInsets.all(5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (widget.serviceId == 'f54aa010-84ab-42c0-a464-866c129804ba' ||
                          widget.serviceId ==
                              '05f75bdc-b6db-48c5-aca5-f4ac9108d0b0' ||
                          widget.serviceId ==
                              '93d19373-2f2d-45c3-b984-c00ed488a208' ||
                          widget.serviceId ==
                              'cd40135b-f73b-46ea-a0bb-92814e5f1459')
                        Text(
                          'Total: UGX $totalPrice',
                          style: TextStyle(color: Colors.white),
                        ),
                      ElevatedButton(
                        onPressed: () {
                          if (widget.serviceId ==
                                  'f54aa010-84ab-42c0-a464-866c129804ba' &&
                              (_numberController.text.isEmpty ||
                                  _selectedCategory == null ||
                                  _selectedCategory!.isEmpty ||
                                  _selectedModel == null ||
                                  _selectedModel!.isEmpty)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text('Please enter your Full Car Details'),
                              ),
                            );
                          } else {
                            if (_formKey.currentState!.validate()) {
                              CarCategorySelect carCategorySelect =
                                  CarCategorySelect(
                                id: Uuid().v4(),
                                categoryName: _selectedCategory ?? '',
                                serviceId: widget.serviceId,
                                number: _numberController.text,
                                price: widget.amount,
                                bookId: '',
                                userId: user.uid,
                                model: _selectedModel ?? '',
                                moreInfo: '',
                              );

                              Get.to(() => MyHomePagez(
                                    uid: uid,
                                    date: _selectedDate,
                                    time: _selectedTime,
                                    serviceId: widget.serviceId,
                                    subservice: widget.subService,
                                    total: totalPrice,
                                    selectedMoreServices:
                                        getSelectedMoreServices(),
                                    subscription: widget.subscription,
                                    selectedCar: carCategorySelect,
                                    number: _numberController.text,
                                  ));
                            }
                          }
                        },
                        child: const Text('Book Now'),
                      ),
                    ],
                  )),
            ),
          );
  }

  void _showInfoBottomSheet(MoreService moreService) {
    final size = MediaQuery.of(context).size;
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.secondaryColor,
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(25),
              topLeft: Radius.circular(25),
            ),
            border: Border.all(color: Colors.white),
          ),
          width: size.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.network(
                moreService.imageUrl,
                height: 200,
              ),
              const SizedBox(height: 8.0),
              Text(moreService.description),
              const SizedBox(height: 8.0),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
              const SizedBox(height: 50),
            ],
          ),
        );
      },
    );
  }

  void deleteSelectedMoreServiceFromFirestore(
      MoreService moreService, String uid) async {
    // Fetch and delete the document(s) from Firestore
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('selectedMoreServices')
        .where('id', isEqualTo: uid)
        .where('moreServiceId', isEqualTo: moreService.id)
        .get();

    for (var doc in querySnapshot.docs) {
      await doc.reference.delete();
    }

    // Remove the deleted service from the list and refresh UI
    setState(() {
      moreServices?.remove(moreService);
    });
  }

  check(User u) {
    if (u.email == 'iakena420@gmail.com') {
      return true;
    } else {
      return false;
    }
  }

  void _confirmDelete(BuildContext context, MoreService moreService) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: Text(
            'Are you sure you want to delete ${moreService.name}?',
            style: const TextStyle(color: Colors.black),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                // Delete the service and close the dialog
                deleteSelectedMoreServiceFromFirestore(moreService, uid);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _confirmDelete2(BuildContext context, CarCategorySelect category) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: Text(
            'Are you sure you want to delete ${category.categoryName}?',
            style: const TextStyle(color: Colors.black),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                // Delete the service and close the dialog
                deleteSelectedMoreServiceFromFirestore2(category, uid);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void deleteSelectedMoreServiceFromFirestore2(
      CarCategorySelect category, String uid) async {
    // Fetch and delete the document(s) from Firestore
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('carCartSelects')
        .where('id', isEqualTo: category.id)
        .get();

    for (var doc in querySnapshot.docs) {
      await doc.reference.delete();
    }
  }
}
