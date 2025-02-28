import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instawash/connectivity/no_internet_connection_page.dart';
import 'package:instawash/connectivity/service.dart';
import 'package:instawash/models/repo.dart';
import 'package:instawash/models/service.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';

class ServiceForm extends StatefulWidget {
  final Service? service; // Optional, for editing an existing service

  const ServiceForm({super.key, this.service});

  @override
  ServiceFormState createState() => ServiceFormState();
}

class ServiceFormState extends State<ServiceForm> {
  File? _imageFile;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String? _imageUrl;
  String imageUrl = '';

  bool _isConnected = true;

  @override
  void initState() {
    super.initState();
    _checkInternetConnection();

    if (widget.service != null) {
      // If in edit mode, populate the fields with the existing service data
      _nameController.text = widget.service!.name;
      _descriptionController.text = widget.service!.description;
      _imageUrl = widget.service!.imageUrl; // Display the current image
    }
  }

  Future<void> _checkInternetConnection() async {
    bool isConnected = await InternetConnectivityService.isConnected();
    setState(() {
      _isConnected = isConnected;
    });
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
            'service_images/${DateTime.now().millisecondsSinceEpoch}.jpg');
        final UploadTask uploadTask = storageRef.putFile(_imageFile!);
        await uploadTask.whenComplete(() async {
          uploadedImageUrl = await storageRef.getDownloadURL();
        });
      }

      // If editing an existing service
      if (widget.service != null) {
        Service updatedService = Service(
          id: widget.service!.id, // Keep the same ID
          name: _nameController.text,
          description: _descriptionController.text,
          imageUrl: uploadedImageUrl!, createDate: widget.service!.createDate,
        );
        Repo().addService(updatedService); // Update service in the repository
      } else {
        // If creating a new service
        Service newService = Service(
          id: const Uuid().v4(),
          name: _nameController.text,
          description: _descriptionController.text,
          imageUrl: uploadedImageUrl!,
          createDate: DateTime.now(),
        );
        Repo().addService(newService); // Add new service to the repository
      }

      if (kDebugMode) {
        print('$uploadedImageUrl Image and data uploaded');
      }

      Navigator.pop(context); // Close the form after upload
    }
  }

  @override
  Widget build(BuildContext context) {
    return !_isConnected
        ? NoInternetConnectionPage()
        : Scaffold(
            appBar: AppBar(
              title: Text(
                  widget.service == null ? 'Create Service' : 'Edit Service'),
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
                    else if (_imageUrl !=
                        null) // Show existing image if in edit mode
                      Image.network(
                        _imageUrl!,
                        width: 100,
                        height: 100,
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
                        labelText: 'Service Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the service name';
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
                          return 'Please enter the service description';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: _uploadImageAndData,
                      child: Text(widget.service == null
                          ? 'Create Service'
                          : 'Update Service'),
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
    super.dispose();
  }
}
