import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instawash/models/car_category.dart';
import 'package:instawash/models/car_category_select.dart';
import 'package:instawash/models/repo.dart';
import 'package:uuid/uuid.dart';

class CarCategorySelectForm extends StatefulWidget {
  final CarCategorySelect? carCategorySelect; // Optional parameter for editing
  final String serviceId;

  const CarCategorySelectForm(
      {super.key, this.carCategorySelect, required this.serviceId});

  @override
  CarCategorySelectFormState createState() => CarCategorySelectFormState();
}

class CarCategorySelectFormState extends State<CarCategorySelectForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _moreInfoController =
      TextEditingController(); // Controller for more info
  String? _existingId; // Track if it's an edit
  User user = FirebaseAuth.instance.currentUser!;
  String? _selectedCategory; // For selected category
  double categoryPrice = 0.0; // Store selected category price
  String? _bookId;

  @override
  void initState() {
    // Populate fields if editing
    if (widget.carCategorySelect != null) {
      _existingId = widget.carCategorySelect!.id;
      _selectedCategory = widget.carCategorySelect!.categoryName;
      _numberController.text = widget.carCategorySelect!.number.toString();
      _modelController.text =
          widget.carCategorySelect!.model; // Prepopulate model if exists
      _moreInfoController.text =
          widget.carCategorySelect!.moreInfo; // Prepopulate moreInfo if exists
      _bookId = widget.carCategorySelect!.bookId;
    }

    super.initState();
  }

  Stream<List<CarCategory>> _fetchCarCategories() {
    return FirebaseFirestore.instance
        .collection('carCategories')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              return CarCategory.fromJson(doc.data());
            }).toList());
  }

  void _updatePrice(CarCategory selectedCategory) {
    setState(() {
      categoryPrice = selectedCategory.price; // Update the category price
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(widget.carCategorySelect != null
              ? 'Edit Car Category'
              : 'New Car Category')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              StreamBuilder<List<CarCategory>>(
                stream: _fetchCarCategories(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text('No categories available');
                  } else {
                    return DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      items: snapshot.data!.map((category) {
                        return DropdownMenuItem<String>(
                          value: category.name,
                          child: Text(category.name),
                          onTap: () {
                            _updatePrice(
                                category); // Update price when selected
                          },
                        );
                      }).toList(),
                      decoration: const InputDecoration(
                        labelText: 'Select Category',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value; // Update selected category
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
              const SizedBox(height: 16.0),

              TextFormField(
                controller: _modelController,
                decoration: const InputDecoration(
                  labelText: 'Car Type (Optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _numberController,
                decoration: const InputDecoration(
                  labelText: 'Plate Number e.g UBB 123G',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a number plate';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              // TextField for More Info (Optional)
              TextFormField(
                controller: _moreInfoController,
                maxLines: 4, // Provide more space for this field
                decoration: const InputDecoration(
                  labelText: 'More Information (Optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Calculate total price

                    String id2 = _bookId ?? '';
                    String id = _existingId ?? const Uuid().v4();
                    CarCategorySelect carCategorySelect = CarCategorySelect(
                      id: id,
                      categoryName: _selectedCategory!,
                      serviceId: widget.serviceId,
                      number: _numberController.text,
                      price: categoryPrice, // Calculated price
                      bookId: id2, // Set bookId to empty string
                      userId: user.uid,
                      model: _modelController.text, // Optional model field
                      moreInfo:
                          _moreInfoController.text, // Optional moreInfo field
                    );
                    Repo().addCarCategorySelect(carCategorySelect);

                    Navigator.pop(context); // Close the form
                  }
                },
                child: Text(widget.carCategorySelect != null
                    ? 'Update Car Category'
                    : 'Add Car Category'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _numberController.dispose();
    _modelController.dispose();
    _moreInfoController.dispose();
    super.dispose();
  }
}
