class Visitor {
  final String visitorID;
  final String firstName;
  final String lastName;
  final String contactNumber;
  final String email;
  final String? company;
  final String visitorType;
  final DateTime dateOfVisit;
  final DateTime timeOfCheckIn;
  final DateTime? timeOfCheckOut;
  final String purposeOfVisit;
  final String personToMeet;
  final String visitorBadgeNumber;
  final String? photo; // URL or base64 string if supported
  final String IDType;
  final String IDNumber;
  final String? vehicleNumberPlate;
  final List<String>? itemsCarried; // List of items
  final String? notes;
  final String? signature; // Digital signature if applicable

  Visitor({
    required this.visitorID,
    required this.firstName,
    required this.lastName,
    required this.contactNumber,
    required this.email,
    this.company,
    required this.visitorType,
    required this.dateOfVisit,
    required this.timeOfCheckIn,
    this.timeOfCheckOut,
    required this.purposeOfVisit,
    required this.personToMeet,
    required this.visitorBadgeNumber,
    this.photo,
    required this.IDType,
    required this.IDNumber,
    this.vehicleNumberPlate,
    this.itemsCarried,
    this.notes,
    this.signature,
  });

  // Convert JSON to Visitor object
  factory Visitor.fromJson(Map<String, dynamic> json) {
    return Visitor(
      visitorID: json['visitorID'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      contactNumber: json['contactNumber'],
      email: json['email'],
      company: json['company'],
      visitorType: json['visitorType'],
      dateOfVisit: DateTime.parse(json['dateOfVisit']),
      timeOfCheckIn: DateTime.parse(json['timeOfCheckIn']),
      timeOfCheckOut: json['timeOfCheckOut'] != null
          ? DateTime.parse(json['timeOfCheckOut'])
          : null,
      purposeOfVisit: json['purposeOfVisit'],
      personToMeet: json['personToMeet'],
      visitorBadgeNumber: json['visitorBadgeNumber'],
      photo: json['photo'],
      IDType: json['IDType'],
      IDNumber: json['IDNumber'],
      vehicleNumberPlate: json['vehicleNumberPlate'],
      itemsCarried: json['itemsCarried'] != null
          ? List<String>.from(json['itemsCarried'])
          : null,
      notes: json['notes'],
      signature: json['signature'],
    );
  }

  // Convert Visitor object to JSON
  Map<String, dynamic> toJson() {
    return {
      'visitorID': visitorID,
      'firstName': firstName,
      'lastName': lastName,
      'contactNumber': contactNumber,
      'email': email,
      'company': company,
      'visitorType': visitorType,
      'dateOfVisit': dateOfVisit.toIso8601String(),
      'timeOfCheckIn': timeOfCheckIn.toIso8601String(),
      'timeOfCheckOut': timeOfCheckOut?.toIso8601String(),
      'purposeOfVisit': purposeOfVisit,
      'personToMeet': personToMeet,
      'visitorBadgeNumber': visitorBadgeNumber,
      'photo': photo,
      'IDType': IDType,
      'IDNumber': IDNumber,
      'vehicleNumberPlate': vehicleNumberPlate,
      'itemsCarried': itemsCarried,
      'notes': notes,
      'signature': signature,
    };
  }
}
