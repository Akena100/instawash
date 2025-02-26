import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instawash/connectivity/no_internet_connection_page.dart';
import 'package:instawash/connectivity/service.dart';

import 'package:instawash/models/repo.dart';

import 'package:instawash/models/sub_service.dart';
import 'package:uuid/uuid.dart';

class SubServiceForm extends StatefulWidget {
  final String serviceId;
  final SubService?
      subService; // Optional parameter for editing an existing sub-service

  const SubServiceForm({Key? key, required this.serviceId, this.subService})
      : super(key: key);

  @override
  SubServiceFormState createState() => SubServiceFormState();
}

class SubServiceFormState extends State<SubServiceForm> {
  File? _imageFile;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  String? _imageUrl;
  String imageUrl = '';

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
    String id = widget.subService?.id ?? const Uuid().v4();
    if (_imageFile != null) {
      final storage = FirebaseStorage.instance;
      final Reference storageRef = storage.ref().child(
          'subservice_images/${DateTime.now().millisecondsSinceEpoch}.jpg');
      final UploadTask uploadTask = storageRef.putFile(_imageFile!);

      await uploadTask.whenComplete(() async {
        var x = await storageRef.getDownloadURL();
        imageUrl = x;
      });
    }

    // Parse price as optional
    double? price = _priceController.text.isNotEmpty
        ? double.tryParse(_priceController.text)
        : null;

    // Create or update the SubService object
    SubService subService = SubService(
      id: id,
      serviceId: widget.serviceId,
      name: _nameController.text,
      description: _descriptionController.text,
      price: price ?? 0.0, // Default to 0.0 if no price is provided
      imageUrl: imageUrl.isEmpty ? widget.subService?.imageUrl ?? '' : imageUrl,
    );

    Repo().addSubService(subService);

    if (kDebugMode) {
      print('Image and data uploaded');
    }
  }

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

    if (widget.subService != null) {
      // If we're editing, pre-fill the form with existing values
      _nameController.text = widget.subService!.name;
      _descriptionController.text = widget.subService!.description;
      _priceController.text = widget.subService!.price.toString();
      _imageUrl = widget.subService!.imageUrl;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return !_isConnected
        ? NoInternetConnectionPage()
        : Scaffold(
            appBar: AppBar(
                title: Text(widget.subService == null
                    ? 'Create SubService'
                    : 'Edit SubService')),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_imageFile != null)
                      Image.file(_imageFile!)
                    else if (_imageUrl != null)
                      Image.network(
                        _imageUrl!,
                        width: 100.0,
                        height: 100.0,
                      ),
                    ElevatedButton(
                      onPressed: _pickImage,
                      child: const Text('Pick Image'),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'SubService Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the SubService name';
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
                          return 'Please enter the SubService description';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    if (widget.serviceId == 'f54aa010-84ab-42c0-a464-866c129804ba' ||
                        widget.serviceId ==
                            '05f75bdc-b6db-48c5-aca5-f4ac9108d0b0' ||
                        widget.serviceId ==
                            '93d19373-2f2d-45c3-b984-c00ed488a208' ||
                        widget.serviceId ==
                            'cd40135b-f73b-46ea-a0bb-92814e5f1459')
                      TextFormField(
                        controller: _priceController,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Price',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (widget.serviceId == 'f54aa010-84ab-42c0-a464-866c129804ba' ||
                              widget.serviceId ==
                                  '05f75bdc-b6db-48c5-aca5-f4ac9108d0b0' ||
                              widget.serviceId ==
                                  '93d19373-2f2d-45c3-b984-c00ed488a208' ||
                              widget.serviceId ==
                                  'cd40135b-f73b-46ea-a0bb-92814e5f1459') {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the Price';
                            }
                            return null;
                          }
                          return null;
                        },
                      ),
                    const SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _uploadImageAndData();
                          Navigator.pop(context);
                        }
                      },
                      child: Text(widget.subService == null
                          ? 'Create SubService'
                          : 'Update SubService'),
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
