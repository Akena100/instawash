class CustomerCareChat {
  final String id;
  final String senderId;
  final String receiverId;
  final String message;
  final DateTime timestamp;

  CustomerCareChat({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.timestamp,
  });

  // Convert a JSON object into a CustomerCareChat instance
  factory CustomerCareChat.fromJson(Map<String, dynamic> json) {
    return CustomerCareChat(
      id: json['id'],
      senderId: json['senderId'],
      receiverId: json['receiverId'],
      message: json['message'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  // Convert a CustomerCareChat instance into a JSON object
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'receiverId': receiverId,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
