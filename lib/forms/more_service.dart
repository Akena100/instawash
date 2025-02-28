import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instawash/connectivity/no_internet_connection_page.dart';
import 'package:instawash/connectivity/service.dart';
import 'package:instawash/models/more_service.dart'; // Replace with the actual MoreService model
import 'package:instawash/models/repo.dart';
import 'package:instawash/models/sub_service.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';


class MoreServiceForm extends StatefulWidget {
  final String serviceId;
  final SubService subservice;
  final MoreService? moreService; // Optional parameter for editing

  const MoreServiceForm({
    super.key,
    required this.serviceId,
    required this.subservice,
    this.moreService, // Initialize to null for new entries
  });

  @override
  _MoreServiceFormState createState() => _MoreServiceFormState();
}

class _MoreServiceFormState extends State<MoreServiceForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  File? _imageFile;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  String _imageUrl = '';
  String? _existingId; // Track if it's an edit

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
    String id = _existingId ?? const Uuid().v4(); // Use existing id if editing
    if (_imageFile == null && _imageUrl.isEmpty) return;

    if (_imageFile != null) {
      final storage = FirebaseStorage.instance;
      final Reference storageRef = storage.ref().child(
          'moreservice_images/${DateTime.now().millisecondsSinceEpoch}.jpg');
      final UploadTask uploadTask = storageRef.putFile(_imageFile!);

      await uploadTask.whenComplete(() async {
        _imageUrl = await storageRef.getDownloadURL();
      });
    }

    MoreService moreService = MoreService(
      id: id,
      name: _nameController.text,
      description: _descriptionController.text,
      price: double.parse(_priceController.text),
      subServiceId: widget.subservice.id,
      serviceId: widget.serviceId,
      imageUrl: _imageUrl,
      isSelected: false,
    );

    Repo().addMoreService(moreService); // Add new entry

    if (kDebugMode) {
      print('Image and data uploaded');
    }
  }

  bool _isConnected = true; // Default to true, assuming there's a connection

  Future<void> _checkInternetConnection() async {
    bool isConnected = await InternetConnectivityService.isConnected();
    setState(() {
      _isConnected = isConnected;
    });
  }

  @override
  void initState() {
    _checkInternetConnection();

    // Populate fields if editing
    if (widget.moreService != null) {
      _existingId = widget.moreService!.id;
      _nameController.text = widget.moreService!.name;
      _descriptionController.text = widget.moreService!.description;
      _priceController.text = widget.moreService!.price.toString();
      _imageUrl = widget.moreService!.imageUrl;
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return !_isConnected
        ? NoInternetConnectionPage()
        : Scaffold(
            appBar: AppBar(
                title: Text(widget.moreService != null
                    ? 'Edit MoreService'
                    : 'New MoreService')),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_imageFile != null)
                      Image.file(_imageFile!)
                    else if (_imageUrl.isNotEmpty)
                      Image.network(_imageUrl)
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
                        labelText: 'MoreService Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the MoreService name';
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
                          return 'Please enter the MoreService description';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: _priceController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Price',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the MoreService price';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    if (_imageUrl.isNotEmpty)
                      Image.network(
                        _imageUrl,
                        width: 100.0,
                        height: 100.0,
                      ),
                    const SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _uploadImageAndData();
                          Navigator.pop(context);
                        }
                      },
                      child: Text(widget.moreService != null
                          ? 'Update MoreService'
                          : 'Upload MoreService'),
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
