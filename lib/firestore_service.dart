import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Method to add order to Firestore
  Future<void> addOrder(Map<String, dynamic> orderData) async {
    try {
      // Add data to 'orders' collection with auto-generated ID
      await _db.collection('orders').add(orderData);
      print("Order added successfully!");
    } catch (e) {
      print("Error adding order: $e");
    }
  }

  // Method to fetch orders from Firestore
  Stream<QuerySnapshot> getOrders() {
    return _db.collection('orders').snapshots();
  }
}