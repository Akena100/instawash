import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

class UserProfilePage extends StatefulWidget {
  final String userId;

  const UserProfilePage({super.key, required this.userId});

  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  File? _imageFile;
  final picker = ImagePicker();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Pick image from gallery
  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  // Upload image and save data to Firestore
  Future<void> _uploadImageAndData(BuildContext context) async {
    saving(context);
    if (_formKey.currentState!.validate()) {
      String? uploadedImageUrl =
          _imageFile == null ? '' : ''; // Default to empty URL if no new image

      // Upload the new image if one is selected
      if (_imageFile != null) {
        final storageRef = FirebaseStorage.instance.ref().child(
            'profile_pictures/${DateTime.now().millisecondsSinceEpoch}.jpg');
        final uploadTask = storageRef.putFile(_imageFile!);
        await uploadTask.whenComplete(() async {
          uploadedImageUrl = await storageRef.getDownloadURL();
        });
      }

      // Save the profile data to Firestore
      try {
        final userProfile = UserProfile(
          userId: widget.userId,
          profilePictureUrl: uploadedImageUrl!,
        );

        // Save to Firestore's 'profile_pictures' collection
        await FirebaseFirestore.instance
            .collection('profile_pictures')
            .add(userProfile.toJson());

        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('User profile saved successfully!')));

        Navigator.pop(context); // Close the page after saving
      } catch (e) {
        print('Error: $e');
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to save profile.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Profile'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Display picked image
                _imageFile == null
                    ? Icon(Icons.photo, size: 150, color: Colors.grey)
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(
                          _imageFile!,
                          height: 200,
                          width: 200,
                          fit: BoxFit.cover,
                        ),
                      ),
                SizedBox(height: 20),

                // Button to pick image
                ElevatedButton(
                  onPressed: _pickImage,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                    backgroundColor: Colors.blueAccent,
                    textStyle: TextStyle(fontSize: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text('Pick Image'),
                ),
                SizedBox(height: 20),

                // Save button
                ElevatedButton(
                  onPressed: () {
                    _uploadImageAndData(context);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                    backgroundColor: Colors.green,
                    textStyle: TextStyle(fontSize: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text('Save Profile'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void saving(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: CupertinoActivityIndicator(),
          );
        });
  }
}

class UserProfile {
  final String userId;
  final String profilePictureUrl;

  UserProfile({required this.userId, required this.profilePictureUrl});

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'profilePictureUrl': profilePictureUrl,
    };
  }
}
