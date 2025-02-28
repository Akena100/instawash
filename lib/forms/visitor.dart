import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VisitorForm extends StatefulWidget {
  final String? visitorID; // Optional visitorID for editing an existing visitor

  const VisitorForm({super.key, this.visitorID});

  @override
  _VisitorFormState createState() => _VisitorFormState();
}

class _VisitorFormState extends State<VisitorForm> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Controllers for text fields
  final TextEditingController visitorIDController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController contactNumberController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController companyController = TextEditingController();
  final TextEditingController purposeController = TextEditingController();
  final TextEditingController personToMeetController = TextEditingController();
  final TextEditingController visitorBadgeController = TextEditingController();
  final TextEditingController idNumberController = TextEditingController();
  final TextEditingController vehicleNumberPlateController =
      TextEditingController();
  final TextEditingController itemsCarriedController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  final TextEditingController signatureController = TextEditingController();

  // Dropdown selections
  String? visitorType;
  String? idType;
  DateTime dateOfVisit = DateTime.now();
  DateTime? timeOfCheckIn;
  DateTime? timeOfCheckOut;

  // For tracking the editing mode
  bool isEditing = false;

  // Load visitor data if we are editing
  @override
  void initState() {
    super.initState();
    if (widget.visitorID != null) {
      isEditing = true;
      _loadVisitorData(widget.visitorID!);
    }
  }

  // Load visitor data from Firestore
  Future<void> _loadVisitorData(String visitorID) async {
    try {
      DocumentSnapshot visitorSnapshot =
          await _firestore.collection('visitors').doc(visitorID).get();
      if (visitorSnapshot.exists) {
        var data = visitorSnapshot.data() as Map<String, dynamic>;

        // Set the controllers with the existing data
        visitorIDController.text = data['visitorID'] ?? '';
        firstNameController.text = data['firstName'] ?? '';
        lastNameController.text = data['lastName'] ?? '';
        contactNumberController.text = data['contactNumber'] ?? '';
        emailController.text = data['email'] ?? '';
        companyController.text = data['company'] ?? '';
        visitorType = data['visitorType'];
        dateOfVisit = DateTime.parse(data['dateOfVisit']);
        timeOfCheckIn = data['timeOfCheckIn'] != null
            ? DateTime.parse(data['timeOfCheckIn'])
            : null;
        timeOfCheckOut = data['timeOfCheckOut'] != null
            ? DateTime.parse(data['timeOfCheckOut'])
            : null;
        purposeController.text = data['purposeOfVisit'] ?? '';
        personToMeetController.text = data['personToMeet'] ?? '';
        visitorBadgeController.text = data['visitorBadgeNumber'] ?? '';
        idType = data['IDType'];
        idNumberController.text = data['IDNumber'] ?? '';
        vehicleNumberPlateController.text = data['vehicleNumberPlate'] ?? '';
        itemsCarriedController.text = data['itemsCarried']?.join(',') ?? '';
        notesController.text = data['notes'] ?? '';
        signatureController.text = data['signature'] ?? '';

        setState(() {});
      }
    } catch (e) {
      print("Error loading visitor data: $e");
    }
  }

  // Submit form to Firestore
  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      Map<String, dynamic> visitorData = {
        'visitorID': visitorIDController.text.trim(),
        'firstName': firstNameController.text.trim(),
        'lastName': lastNameController.text.trim(),
        'contactNumber': contactNumberController.text.trim(),
        'email': emailController.text.trim(),
        'company': companyController.text.trim().isEmpty
            ? null
            : companyController.text.trim(),
        'visitorType': visitorType,
        'dateOfVisit': dateOfVisit.toIso8601String(),
        'timeOfCheckIn': timeOfCheckIn?.toIso8601String(),
        'timeOfCheckOut': timeOfCheckOut?.toIso8601String(),
        'purposeOfVisit': purposeController.text.trim(),
        'personToMeet': personToMeetController.text.trim(),
        'visitorBadgeNumber': visitorBadgeController.text.trim(),
        'IDType': idType,
        'IDNumber': idNumberController.text.trim(),
        'vehicleNumberPlate': vehicleNumberPlateController.text.trim().isEmpty
            ? null
            : vehicleNumberPlateController.text.trim(),
        'itemsCarried': itemsCarriedController.text.trim().isEmpty
            ? null
            : itemsCarriedController.text.trim().split(','),
        'notes': notesController.text.trim().isEmpty
            ? null
            : notesController.text.trim(),
        'signature': signatureController.text.trim().isEmpty
            ? null
            : signatureController.text.trim(),
      };

      try {
        if (isEditing) {
          // Update existing visitor data
          await _firestore
              .collection('visitors')
              .doc(widget.visitorID) // Use visitorID for editing
              .update(visitorData);
        } else {
          // Add new visitor data
          await _firestore.collection('visitors').add(visitorData);
        }

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(isEditing
                ? 'Visitor updated successfully!'
                : 'Visitor registered successfully!')));
        _formKey.currentState!.reset();
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  // Select time function for check-in and check-out
  Future<void> _selectTime(BuildContext context, bool isCheckIn) async {
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(isCheckIn
          ? (timeOfCheckIn ?? DateTime.now())
          : (timeOfCheckOut ?? DateTime.now())),
    );
    if (time != null) {
      setState(() {
        final now = DateTime.now();
        final selectedTime =
            DateTime(now.year, now.month, now.day, time.hour, time.minute);
        if (isCheckIn) {
          timeOfCheckIn = selectedTime;
        } else {
          timeOfCheckOut = selectedTime;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(isEditing ? 'Edit Visitor' : 'Visitor Registration')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: visitorIDController,
                  decoration: InputDecoration(labelText: 'Visitor ID'),
                  validator: (value) => value!.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  controller: firstNameController,
                  decoration: InputDecoration(labelText: 'First Name'),
                  validator: (value) => value!.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  controller: lastNameController,
                  decoration: InputDecoration(labelText: 'Last Name'),
                  validator: (value) => value!.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  controller: contactNumberController,
                  decoration: InputDecoration(labelText: 'Contact Number'),
                  keyboardType: TextInputType.phone,
                  validator: (value) => value!.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                ),
                TextFormField(
                  controller: companyController,
                  decoration: InputDecoration(
                      labelText: 'Company/Organization (Optional)'),
                ),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(labelText: 'Visitor Type'),
                  value: visitorType,
                  items: [
                    'Client',
                    'Vendor',
                    'Job Applicant',
                    'Personal Visitor'
                  ]
                      .map((type) =>
                          DropdownMenuItem(value: type, child: Text(type)))
                      .toList(),
                  onChanged: (value) => setState(() => visitorType = value),
                  validator: (value) =>
                      value == null ? 'Select visitor type' : null,
                ),
                TextFormField(
                  controller: purposeController,
                  decoration: InputDecoration(labelText: 'Purpose of Visit'),
                  validator: (value) => value!.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  controller: personToMeetController,
                  decoration: InputDecoration(labelText: 'Person to Meet'),
                  validator: (value) => value!.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  controller: visitorBadgeController,
                  decoration:
                      InputDecoration(labelText: 'Visitor Badge Number'),
                  validator: (value) => value!.isEmpty ? 'Required' : null,
                ),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(labelText: 'ID Type'),
                  value: idType,
                  items: ['National ID', 'Passport', 'Driver’s License']
                      .map((type) =>
                          DropdownMenuItem(value: type, child: Text(type)))
                      .toList(),
                  onChanged: (value) => setState(() => idType = value),
                  validator: (value) => value == null ? 'Select ID Type' : null,
                ),
                TextFormField(
                  controller: idNumberController,
                  decoration: InputDecoration(labelText: 'ID Number'),
                  validator: (value) => value!.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  controller: vehicleNumberPlateController,
                  decoration:
                      InputDecoration(labelText: 'Vehicle Number Plate'),
                ),
                TextFormField(
                  controller: itemsCarriedController,
                  decoration: InputDecoration(labelText: 'Items Carried'),
                ),
                TextFormField(
                  controller: notesController,
                  decoration: InputDecoration(labelText: 'Notes'),
                ),
                TextFormField(
                  controller: signatureController,
                  decoration: InputDecoration(labelText: 'Signature'),
                ),
                Column(
                  children: [
                    ElevatedButton(
                      onPressed: () =>
                          _selectTime(context, true), // Check-In Time
                      child: Text(timeOfCheckIn == null
                          ? 'Set Check-In Time'
                          : 'Check-In Time: ${timeOfCheckIn!.hour}:${timeOfCheckIn!.minute}'),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () =>
                          _selectTime(context, false), // Check-Out Time
                      child: Text(timeOfCheckOut == null
                          ? 'Set Check-Out Time'
                          : 'Check-Out Time: ${timeOfCheckOut!.hour}:${timeOfCheckOut!.minute}'),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _submitForm,
                  child:
                      Text(isEditing ? 'Update Visitor' : 'Register Visitor'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
