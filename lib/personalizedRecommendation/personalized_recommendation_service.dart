import 'package:cloud_firestore/cloud_firestore.dart';

class RecommendationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> getTopOrderedItems(String safeEmail, {int topN = 3}) async {
    QuerySnapshot orderSnapshot = await _firestore
        .collection('user_orders')
        .doc(safeEmail)
        .collection('orders')
        .get();

    Map<String, Map<String, dynamic>> itemStats = {};

    for (var orderDoc in orderSnapshot.docs) {
      List items = orderDoc['items'];
      for (var item in items) {
        String name = item['productName'];
        int quantity = item['quantity'];
        double unitPrice = item['unitPrice'];
        String thumbnail = item['productThumbnail'];

        if (!itemStats.containsKey(name)) {
          itemStats[name] = {
            'productName': name,
            'quantity': 0,
            'unitPrice': unitPrice,
            'thumbnail': thumbnail,
          };
        }
        itemStats[name]!['quantity'] += quantity;
      }
    }

    // Sort by quantity
    var sortedItems = itemStats.values.toList()
      ..sort((a, b) => (b['quantity'] as int).compareTo(a['quantity'] as int));

    return sortedItems.take(topN).toList();
  }
}
