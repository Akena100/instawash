import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';

// Replace with your actual imports
import '../models/repo.dart'; // Replace with your actual imports
import '../models/car_category.dart'; // Replace with your CarCategory model

class CarCategoryForm extends StatefulWidget {
  final CarCategory?
      carCategory; // Optional, for editing an existing car category

  const CarCategoryForm({super.key, this.carCategory});

  @override
  CarCategoryFormState createState() => CarCategoryFormState();
}

class CarCategoryFormState extends State<CarCategoryForm> {
  File? _imageFile;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  String? _imageUrl;

  @override
  void initState() {
    super.initState();

    if (widget.carCategory != null) {
      // If in edit mode, populate the fields with the existing car category data
      _nameController.text = widget.carCategory!.name;
      _descriptionController.text = widget.carCategory!.description;
      _priceController.text = widget.carCategory!.price.toString();
      _imageUrl = widget.carCategory!.imageUrl; // Display the current image
    }
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadImageAndData() async {
    if (_formKey.currentState!.validate()) {
      String? uploadedImageUrl =
          _imageUrl; // Keep existing image if no new image is picked

      // Upload a new image if one is picked
      if (_imageFile != null) {
        final storage = FirebaseStorage.instance;
        final Reference storageRef = storage.ref().child(
            'car_category_images/${DateTime.now().millisecondsSinceEpoch}.jpg');
        final UploadTask uploadTask = storageRef.putFile(_imageFile!);
        await uploadTask.whenComplete(() async {
          uploadedImageUrl = await storageRef.getDownloadURL();
        });
      }

      // If editing an existing car category
      if (widget.carCategory != null) {
        CarCategory updatedCarCategory = CarCategory(
          id: widget.carCategory!.id, // Keep the same ID
          name: _nameController.text,
          description: _descriptionController.text,
          price: double.parse(_priceController.text),
          imageUrl: uploadedImageUrl!,
        );
        Repo().addCarCategory(
            updatedCarCategory); // Update category in the repository
      } else {
        // If creating a new car category
        CarCategory newCarCategory = CarCategory(
          id: const Uuid().v4(),
          name: _nameController.text,
          description: _descriptionController.text,
          price: double.parse(_priceController.text),
          imageUrl: uploadedImageUrl!,
        );
        Repo().addCarCategory(
            newCarCategory); // Add new category to the repository
      }

      if (kDebugMode) {
        print('$uploadedImageUrl Image and data uploaded');
      }

      Navigator.pop(context); // Close the form after upload
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.carCategory == null
            ? 'Create Car Category'
            : 'Edit Car Category'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_imageFile != null)
                Image.file(_imageFile!)
              else if (_imageUrl != null) // Show existing image if in edit mode
                CachedNetworkImage(
                  imageUrl: _imageUrl!,
                  placeholder: (context, url) => CircularProgressIndicator(),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                )
              else
                const SizedBox(height: 45),
              ElevatedButton(
                onPressed: _pickImage,
                child: const Text('Pick Image'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Category Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the category name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the category description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Price',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the price';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _uploadImageAndData,
                child: Text(widget.carCategory == null
                    ? 'Create Car Category'
                    : 'Update Car Category'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }
}
