import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instawash/connectivity/no_internet_connection_page.dart';
import 'package:instawash/connectivity/service.dart';
import 'package:instawash/models/bills/submore.dart';
import 'package:instawash/models/more.dart';
import 'package:instawash/models/repo.dart';

import 'package:uuid/uuid.dart';
import 'dart:io';

class SubMoreForm extends StatefulWidget {
  final More more;
  const SubMoreForm({super.key, required this.more});

  @override
  SubMoreFormState createState() => SubMoreFormState();
}

class SubMoreFormState extends State<SubMoreForm> {
  File? _imageFile;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String? _imageUrl;

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
    String id = const Uuid().v4();
    if (_imageFile == null) return;

    final storage = FirebaseStorage.instance;
    final Reference storageRef = storage.ref().child(
        'subservice_images/${DateTime.now().millisecondsSinceEpoch}.jpg');
    final UploadTask uploadTask = storageRef.putFile(_imageFile!);

    await uploadTask.whenComplete(() async {
      var x = await storageRef.getDownloadURL();

      String imageUrl = x;

      SubMore subMore = SubMore(
          id: id,
          serviceId: widget.more.id,
          name: _nameController.text,
          description: _descriptionController.text,
          imageUrl: imageUrl);

      Repo().addSub(subMore);

      // Perform any additional logic needed before uploading to Firestore

      if (kDebugMode) {
        print('Image and data uploaded');
      }
    });
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
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return !_isConnected
        ? NoInternetConnectionPage()
        : Scaffold(
            appBar: AppBar(title: const Text('SubMore Form')),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_imageFile != null)
                      Image.file(_imageFile!)
                    else
                      const SizedBox(
                        height: 45,
                      ),
                    ElevatedButton(
                      onPressed: _pickImage,
                      child: const Text('Pick Image'),
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'SubMore Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the SubMore name';
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
                          return 'Please enter the SubMore description';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),

                    // Display the selected image
                    if (_imageUrl != null)
                      Image.network(
                        _imageUrl!,
                        width: 100.0,
                        height: 100.0,
                      ),
                    const SizedBox(height: 16.0),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _uploadImageAndData();
                          // Implement logic to add SubMore to Firestore here
                          Navigator.pop(context);
                        }
                      },
                      child: const Text('Upload SubMore'),
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
