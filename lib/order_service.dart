import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // Method to get today's order sequence
  Future<int> getOrderSequenceForToday() async {

    String today = DateFormat('ddMMyyyy').format(DateTime.now());
    DocumentReference sequenceDoc = _firestore.collection('orderSequences').doc(today);

    // Check if the document exists
    DocumentSnapshot snapshot = await sequenceDoc.get();

    if (snapshot.exists) {
      // If it exists, increment the sequence number
      int currentSequence = snapshot.get('sequence');
      await sequenceDoc.update({'sequence': currentSequence + 1});
      return currentSequence + 1;
    } else {
      // If it does not exist, create the document with sequence 1
      await sequenceDoc.set({'sequence': 1});
      return 1;
    }
  }

  Future<String> placeOrder({
    required String deliveryLocation,
    required List<Map<String, dynamic>> cartItems,
    required double totalAmount,
    required double deliveryCharge,
    required String paymentMethod,
    required String userEmail, // <-- use email
  }) async {
    DateTime timestamp = DateTime.now();
    print("Raw Timestamp: $timestamp"); // Debugging

    // Format date and time
    String orderTime = DateFormat('hh:mm a').format(timestamp);

    int orderSequence = await getOrderSequenceForToday();
    // Generate order ID: date + 4-digit sequence
    String orderId = "${DateFormat('ddMMyyyy').format(DateTime.now())}${orderSequence.toString().padLeft(4, '0')}";

    List<Map<String, dynamic>> items = cartItems.map((item) => {
      'productName': item['productName'],
      'quantity': item['quantity'],
      'unitPrice': item['unitPrice'],
      'totalPrice': item['unitPrice'] * item['quantity'],
      'productThumbnail': item['imagePath'] ?? 'assets/images/placeholder.png',
    }).toList();

    // Sanitize email (Firestore doesn’t allow '@' and '.' in doc paths)
    String safeEmail = userEmail.split('@')[0]; // Only username before @

    await _firestore
        .collection('user_orders')
        .doc(safeEmail)
        .collection('orders')
        .doc(orderId)
        .set({
      'orderId': orderId,
      'orderDate': Timestamp.now(),
      'orderTime': orderTime,
      'deliveryLocation': deliveryLocation,
      'items': items,
      'time': DateTime.now().millisecondsSinceEpoch,
      'totalAmount': totalAmount,
      'deliveryCharge': deliveryCharge,
      'paymentMethod': paymentMethod,
    });

    return orderId;
  }



}