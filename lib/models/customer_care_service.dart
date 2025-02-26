import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerCareSystem {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Method to fetch free customer care agents
  Future<List<String>> getFreeAgents() async {
    QuerySnapshot snapshot = await _firestore
        .collection('users')
        .where('role', isEqualTo: 'Customer Care')
        .where('status', isEqualTo: 'Active')
        .get();

    List<String> freeAgents = [];
    for (var doc in snapshot.docs) {
      freeAgents.add(doc.id);
    }

    return freeAgents;
  }

  Future<void> assignBookings() async {
    List<String> freeAgents = await getFreeAgents();

    if (freeAgents.isEmpty) {
      print('No free agents available.');
      return;
    }

    // Fetch the pending bookings that need to be assigned
    QuerySnapshot bookingSnapshot = await _firestore
        .collection('bookings')
        .where('customercare', isEqualTo: null) // Only unassigned bookings
        .get();

    if (bookingSnapshot.docs.isEmpty) {
      print('No new bookings to assign.');
      return;
    }

    // Round-robin or even assignment
    int agentIndex = 0;

    // Assign bookings to available free agents
    for (var bookingDoc in bookingSnapshot.docs) {
      var bookingId = bookingDoc.id;
      // var bookingData = bookingDoc.data() as Map<String, dynamic>;

      // Get the next free agent
      String agentId = freeAgents[agentIndex];

      // Update the booking with the assigned agent
      await _firestore.collection('bookings').doc(bookingId).update({
        'customercare': agentId,
      });

      // Update the agent's status to 'busy'
      await _firestore.collection('users').doc(agentId).update({
        'status': 'busy',
      });

      print('Booking $bookingId assigned to agent $agentId.');

      // Move to the next agent for the next booking
      agentIndex = (agentIndex + 1) % freeAgents.length;
    }
  }

  // Method to free up an agent once they are done
  Future<void> freeUpAgent(String agentId) async {
    await _firestore.collection('users').doc(agentId).update({
      'status': 'free',
    });

    print('Agent $agentId is now free.');
  }
}

void main() async {
  CustomerCareSystem system = CustomerCareSystem();
  await system.assignBookings(); // Assign available bookings
}
