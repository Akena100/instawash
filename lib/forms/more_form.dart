import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instawash/connectivity/no_internet_connection_page.dart';
import 'package:instawash/connectivity/service.dart';
import 'package:instawash/models/more.dart';
import 'package:instawash/models/repo.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';


// Assuming you have a More class

class MoreForm extends StatefulWidget {
  const MoreForm({super.key});

  @override
  MoreFormState createState() => MoreFormState();
}

class MoreFormState extends State<MoreForm> {
  File? _imageFile;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();

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
    if (_imageFile == null) return;

    final storage = FirebaseStorage.instance;
    final Reference storageRef = storage
        .ref()
        .child('More_images/${DateTime.now().millisecondsSinceEpoch}.jpg');
    final UploadTask uploadTask = storageRef.putFile(_imageFile!);

    await uploadTask.whenComplete(() async {
      var x = await storageRef.getDownloadURL();

      imageUrl = x;

      More more = More(
        id: const Uuid().v4(),
        name: _nameController.text,
        imageUrl: imageUrl,
      );

      Repo().addMore(more);
      if (kDebugMode) {
        print('$imageUrl Image and data uploaded');
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
    // TODO: implement initState
    _checkInternetConnection();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return !_isConnected
        ? NoInternetConnectionPage()
        : Scaffold(
            appBar: AppBar(title: const Text('More Form')),
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
                        labelText: 'More Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the name';
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
                          Navigator.pop(context);
                        }
                      },
                      child: const Text('Upload More'),
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

    super.dispose();
  }
}
