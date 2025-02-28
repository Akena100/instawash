class CarCategorySelect {
  String id; // Unique ID for the car category selection
  String categoryName; // Name of the car category (e.g., Sedan, SUV)
  String serviceId; // ID of the related service (e.g., Car Wash, Detailing)
  String number; // Could represent car number, order number, etc.
  double price; // Price of the selected service for the car category
  String bookId; // ID of the related booking
  String userId; // ID of the user who made the selection
  String model; // New field: Model of the car
  String moreInfo; // New field: Additional information about the selection

  CarCategorySelect({
    required this.id,
    required this.categoryName,
    required this.serviceId,
    required this.number,
    required this.price,
    required this.bookId,
    required this.userId,
    required this.model, // Added model to the constructor
    required this.moreInfo, // Added moreInfo to the constructor
  });

  // Factory constructor to create a CarCategorySelect object from JSON data
  factory CarCategorySelect.fromJson(Map<String, dynamic> json) {
    return CarCategorySelect(
      id: json['id'] as String,
      categoryName: json['categoryName'] as String,
      serviceId: json['serviceId'] as String,
      number: json['number'] as String,
      price: (json['price'] as num).toDouble(),
      bookId: json['bookId'] as String,
      userId: json['userId'] as String,
      model: json['model'] as String, // Parse the new model field
      moreInfo: json['moreInfo'] as String, // Parse the new moreInfo field
    );
  }

  // Method to convert CarCategorySelect object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'categoryName': categoryName,
      'serviceId': serviceId,
      'number': number,
      'price': price,
      'bookId': bookId,
      'userId': userId,
      'model': model, // Include the new model in the JSON output
      'moreInfo': moreInfo, // Include the new moreInfo in the JSON output
    };
  }
}
