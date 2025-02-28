import 'package:flutter/material.dart';

class VisitorDetailPage extends StatelessWidget {
  final Map<String, dynamic> visitorData;

  const VisitorDetailPage({super.key, required this.visitorData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Visitor Details'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildDetail('Visitor ID', visitorData['visitorID']),
            _buildDetail('First Name', visitorData['firstName']),
            _buildDetail('Last Name', visitorData['lastName']),
            _buildDetail('Contact Number', visitorData['contactNumber']),
            _buildDetail('Email', visitorData['email']),
            _buildDetail('Company/Organization', visitorData['company']),
            _buildDetail('Visitor Type', visitorData['visitorType']),
            _buildDetail('Date of Visit', visitorData['dateOfVisit']),
            _buildDetail('Time of Check-in', visitorData['timeOfCheckIn']),
            _buildDetail(
                'Time of Check-out', visitorData['timeOfCheckOut'] ?? 'N/A'),
            _buildDetail('Purpose of Visit', visitorData['purposeOfVisit']),
            _buildDetail('Person to Meet', visitorData['personToMeet']),
            _buildDetail('Visitor Badge Number',
                visitorData['visitorBadgeNumber'] ?? 'N/A'),
            _buildDetail('ID Type', visitorData['IDType'] ?? 'N/A'),
            _buildDetail('ID Number', visitorData['IDNumber']),
            _buildDetail('Vehicle Number Plate',
                visitorData['vehicleNumberPlate'] ?? 'N/A'),
            _buildDetail('Items Carried',
                _convertListToString(visitorData['itemsCarried'])),
            _buildDetail('Notes', visitorData['notes'] ?? 'N/A'),
            _buildDetail('Signature', visitorData['signature'] ?? 'None'),
          ],
        ),
      ),
    );
  }

  // Helper function to convert list to string
  String _convertListToString(dynamic value) {
    if (value is List) {
      return value.join(', '); // Join the list elements into a string
    }
    return value?.toString() ?? 'N/A';
  }

  Widget _buildDetail(String label, String? value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              value ?? 'N/A',
              style: TextStyle(fontSize: 16.0),
            ),
          ),
        ],
      ),
    );
  }
}
