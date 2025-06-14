import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:persistent_shopping_cart/model/cart_model.dart';
import 'package:persistent_shopping_cart/persistent_shopping_cart.dart';
import 'dart:math';

import '../data/all_food_items.dart';
import '../favorites/favourite_controller.dart';
import '../favorites/favourite_notifier.dart'; // Import the global notifier
import '../menu_screen/product_card.dart';
import '../utils/colors.dart';

class PersonalizedRecommendationsPage extends StatefulWidget {
  @override
  _PersonalizedRecommendationsPageState createState() => _PersonalizedRecommendationsPageState();
}

class _PersonalizedRecommendationsPageState extends State<PersonalizedRecommendationsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // Remove the local favoriteNotifier - we'll use the global one

  List<Map<String, dynamic>> recommendations = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecommendations();
    _loadInitialFavorites(); // Load favorites when the page initializes
  }

  // Add this method to load initial favorites
  Future<void> _loadInitialFavorites() async {
    await FavoritesManager.loadFavorites();
  }

  String normalizeProductName(String name) {
    return name.trim().toLowerCase();
  }

  Future<void> _loadRecommendations() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        print('DEBUG: No authenticated user');
        setState(() {
          isLoading = false;
        });
        return;
      }

      String safeEmail = user.email!.split('@')[0];
      print('DEBUG: Loading recommendations for user: $safeEmail');

      // Get all three types of recommendations
      List<Map<String, dynamic>> favoritesBasedRecs = await _getFavoritesBasedRecommendations(safeEmail);
      List<Map<String, dynamic>> frequentOrderRecs = await _getFrequentOrderRecommendations(safeEmail);
      List<Map<String, dynamic>> collaborativeRecs = await _getCollaborativeRecommendations(safeEmail);

      print('DEBUG: Favorites-based recommendations: ${favoritesBasedRecs.length}');
      print('DEBUG: Frequent order recommendations: ${frequentOrderRecs.length}');
      print('DEBUG: Collaborative recommendations: ${collaborativeRecs.length}');

      // If no recommendations from any method, add some popular items as fallback
      if (favoritesBasedRecs.isEmpty && frequentOrderRecs.isEmpty && collaborativeRecs.isEmpty) {
        print('DEBUG: No recommendations found, adding popular items as fallback');
        List<Map<String, dynamic>> popularItems = _getPopularItemsFallback();

        setState(() {
          recommendations = popularItems;
          isLoading = false;
        });
        return;
      }

      // Combine and score recommendations
      Map<String, Map<String, dynamic>> combinedRecs = {};

      // Add favorites-based recommendations (highest weight)
      for (var rec in favoritesBasedRecs) {
        String key = rec['productId'].toString();
        combinedRecs[key] = rec;
        combinedRecs[key]!['score'] = (combinedRecs[key]!['score'] ?? 0.0) + 3.0;
        combinedRecs[key]!['reasons'] = (combinedRecs[key]!['reasons'] ?? <String>[])..add('You may like');
      }

      // Add frequent order recommendations (medium weight)
      for (var rec in frequentOrderRecs) {
        String key = rec['productId'].toString();
        if (combinedRecs.containsKey(key)) {
          combinedRecs[key]!['score'] = (combinedRecs[key]!['score'] ?? 0.0) + 2.0;
          combinedRecs[key]!['reasons'] = (combinedRecs[key]!['reasons'] ?? <String>[])..add('Frequently ordered');
        } else {
          combinedRecs[key] = rec;
          combinedRecs[key]!['score'] = 2.0;
          combinedRecs[key]!['reasons'] = ['Frequently ordered'];
        }
      }

      // Add collaborative filtering recommendations (lower weight)
      for (var rec in collaborativeRecs) {
        String key = rec['productId'].toString();
        if (combinedRecs.containsKey(key)) {
          combinedRecs[key]!['score'] = (combinedRecs[key]!['score'] ?? 0.0) + 1.0;
          combinedRecs[key]!['reasons'] = (combinedRecs[key]!['reasons'] ?? <String>[])..add('Users also liked');
        } else {
          combinedRecs[key] = rec;
          combinedRecs[key]!['score'] = 1.0;
          combinedRecs[key]!['reasons'] = ['Users also liked'];
        }
      }

      // Convert to list and sort by score
      List<Map<String, dynamic>> finalRecommendations = combinedRecs.values.toList();
      finalRecommendations.sort((a, b) => b['score'].compareTo(a['score']));

      // Take top 10 recommendations
      if (finalRecommendations.length > 10) {
        finalRecommendations = finalRecommendations.sublist(0, 10);
      }

      print('DEBUG: Final recommendations count: ${finalRecommendations.length}');

      setState(() {
        recommendations = finalRecommendations;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading recommendations: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> _getPopularItemsFallback() {
    // Return first 6 items from allFoodItems as popular items fallback
    List<Map<String, dynamic>> popularItems = [];

    for (int i = 0; i < min(6, allFoodItems.length); i++) {
      var item = allFoodItems[i];
      popularItems.add({
        'productId': item['productId'],
        'name': item['name'],
        'price': item['price'] ?? 0.0,
        'description': item['description'],
        'imagePath': item['imagePath'],
        'category': item['category'],
        'subcategory': item['subcategory'],
        'score': 1.0,
        'reasons': ['Popular item'],
      });
    }

    return popularItems;
  }

  Future<List<Map<String, dynamic>>> _getFavoritesBasedRecommendations(String safeEmail) async {
    List<Map<String, dynamic>> recommendations = [];

    try {
      // Get user's current favorites
      List<int> currentFavorites = await FavoritesManager.getFavorites();
      print('DEBUG: Current favorites count: ${currentFavorites.length}');

      if (currentFavorites.isEmpty) {
        print('DEBUG: No favorites found');
        return recommendations;
      }

      // Get categories and subcategories of user's favorites
      Set<String> favoriteCategories = {};
      Set<String> favoriteSubcategories = {};

      for (int favId in currentFavorites) {
        var item = allFoodItems.firstWhere(
              (item) => item['productId'] == favId,
          orElse: () => {},
        );
        if (item.isNotEmpty) {
          if (item['category'] != null && item['category'].toString().isNotEmpty) {
            favoriteCategories.add(item['category']);
          }
          if (item['subcategory'] != null && item['subcategory'].toString().isNotEmpty) {
            favoriteSubcategories.add(item['subcategory']);
          }
        }
      }

      print('DEBUG: Favorite categories: $favoriteCategories');
      print('DEBUG: Favorite subcategories: $favoriteSubcategories');

      // Find items in same categories/subcategories that aren't already favorites
      for (var item in allFoodItems) {
        if (!currentFavorites.contains(item['productId']) &&
            (favoriteCategories.contains(item['category']) ||
                favoriteSubcategories.contains(item['subcategory']))) {

          recommendations.add({
            'productId': item['productId'],
            'name': item['name'],
            'price': item['price'] ?? 0.0,
            'description': item['description'] ?? '',
            'imagePath': item['imagePath'] ?? '',
            'category': item['category'] ?? '',
            'subcategory': item['subcategory'] ?? '',
          });
        }
      }

      print('DEBUG: Favorites-based recommendations found: ${recommendations.length}');
    } catch (e) {
      print('Error getting favorites-based recommendations: $e');
    }

    recommendations.shuffle(); // randomize order
    return recommendations.take(2).toList();
  }

  Future<List<Map<String, dynamic>>> _getFrequentOrderRecommendations(String safeEmail) async {
    List<Map<String, dynamic>> recommendations = [];

    try {
      // Get user's order history
      QuerySnapshot orderSnapshot = await _firestore
          .collection('user_orders')
          .doc(safeEmail)
          .collection('orders')
          .get();

      print('DEBUG: Found ${orderSnapshot.docs.length} orders for frequent recommendations');

      if (orderSnapshot.docs.isEmpty) {
        print('DEBUG: No order history found');
        return recommendations;
      }

      // Count item frequencies
      Map<String, int> itemFrequency = {};
      Map<String, Map<String, dynamic>> itemDetails = {};

      for (var doc in orderSnapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        if (data.containsKey('items')) {
          List<dynamic> items = data['items'];
          print('DEBUG: Processing order with ${items.length} items');

          for (var item in items) {
            String productName = item['productName'] ?? '';
            if (productName.isNotEmpty) {
              int quantity = (item['quantity'] is int) ? item['quantity'] : (item['quantity'] as num).toInt();
              itemFrequency[productName] = (itemFrequency[productName] ?? 0) + quantity;

              // Store item details
              if (!itemDetails.containsKey(productName)) {
                var foodItem = allFoodItems.firstWhere(
                      (food) => food['name'] == productName,
                  orElse: () => {},
                );

                if (foodItem.isNotEmpty) {
                  itemDetails[productName] = {
                    'productId': foodItem['productId'],
                    'name': foodItem['name'],
                    'price': foodItem['price'] ?? 0.0,
                    'description': foodItem['description'] ?? '',
                    'imagePath': foodItem['imagePath'] ?? '',
                    'category': foodItem['category'] ?? '',
                    'subcategory': foodItem['subcategory'] ?? '',
                  };
                }
              }
            }
          }
        }
      }

      print('DEBUG: Item frequencies: $itemFrequency');

      // Sort by frequency and take top items
      var sortedItems = itemFrequency.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      for (var entry in sortedItems.take(5)) {
        if (itemDetails.containsKey(entry.key)) {
          var item = Map<String, dynamic>.from(itemDetails[entry.key]!);
          item['orderCount'] = entry.value;
          recommendations.add(item);
        }
      }

      print('DEBUG: Frequent order recommendations found: ${recommendations.length}');
    } catch (e) {
      print('Error getting frequent order recommendations: $e');
    }

    recommendations.shuffle(); // randomize order
    return recommendations.take(2).toList();
  }

  Future<List<Map<String, dynamic>>> _getCollaborativeRecommendations(String safeEmail) async {
    try {
      print('DEBUG: Starting collaborative filtering for $safeEmail');

      // Step 1: Get my order history and calculate item frequencies
      Map<String, int> myItemFrequencies = {};
      QuerySnapshot myOrders = await _firestore
          .collection('user_orders')
          .doc(safeEmail)
          .collection('orders')
          .get();

      print('DEBUG: Found ${myOrders.docs.length} of my orders');

      // Calculate my item frequencies
      for (var doc in myOrders.docs) {
        var data = doc.data() as Map<String, dynamic>;
        if (data.containsKey('items')) {
          List<dynamic> items = data['items'];
          for (var item in items) {
            String productName = normalizeProductName(item['productName'] ?? '');
            if (productName.isNotEmpty) {
              int quantity = (item['quantity'] is int) ? item['quantity'] : (item['quantity'] as num).toInt();
              myItemFrequencies[productName] = (myItemFrequencies[productName] ?? 0) + quantity;
            }
          }
        }
      }

      if (myItemFrequencies.isEmpty) {
        print('DEBUG: No order history found for current user');
        return [];
      }

      // Get my top 3 most frequently ordered items
      var myTopItems = myItemFrequencies.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      myTopItems = myTopItems.take(3).toList();

      Set<String> myFrequentItems = myTopItems.map((e) => e.key).toSet();
      Set<String> allMyItems = myItemFrequencies.keys.toSet();

      print('DEBUG: My top 3 items: ${myFrequentItems.toList()}');
      print('DEBUG: All my items count: ${allMyItems.length}');

      // Step 2: Get all possible user emails by using collection group query
      // Since parent documents don't exist, we need to get all orders and extract user emails
      Map<String, double> candidateScores = {};
      Set<String> processedUsers = {};

      // Query all orders across all users using collectionGroup
      QuerySnapshot allOrders = await _firestore
          .collectionGroup('orders')
          .get();

      print('DEBUG: Found ${allOrders.docs.length} total orders across all users');

      // Group orders by user
      Map<String, List<QueryDocumentSnapshot>> ordersByUser = {};

      for (var orderDoc in allOrders.docs) {
        // Extract user email from the document path
        // Path format: user_orders/{userEmail}/orders/{orderId}
        String docPath = orderDoc.reference.path;
        List<String> pathParts = docPath.split('/');

        if (pathParts.length >= 2) {
          String otherUserEmail = pathParts[1]; // user_orders/{THIS_PART}/orders/...

          if (otherUserEmail != safeEmail) {
            if (!ordersByUser.containsKey(otherUserEmail)) {
              ordersByUser[otherUserEmail] = [];
            }
            ordersByUser[otherUserEmail]!.add(orderDoc);
          }
        }
      }

      print('DEBUG: Found ${ordersByUser.length} other users to check for similarity');

      // Step 3: Process each other user
      for (String otherEmail in ordersByUser.keys) {
        List<QueryDocumentSnapshot> otherOrders = ordersByUser[otherEmail]!;

        Map<String, int> otherItemFrequencies = {};

        // Calculate other user's item frequencies
        for (var doc in otherOrders) {
          var data = doc.data() as Map<String, dynamic>;
          if (data.containsKey('items')) {
            List<dynamic> items = data['items'];
            for (var item in items) {
              String productName = normalizeProductName(item['productName'] ?? '');
              if (productName.isNotEmpty) {
                int quantity = (item['quantity'] is int) ? item['quantity'] : (item['quantity'] as num).toInt();
                otherItemFrequencies[productName] = (otherItemFrequencies[productName] ?? 0) + quantity;
              }
            }
          }
        }

        if (otherItemFrequencies.isEmpty) continue;

        // Get other user's top items
        var otherTopItems = otherItemFrequencies.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
        Set<String> otherFrequentItems = otherTopItems.take(5).map((e) => e.key).toSet();

        // Calculate similarity: how many of my frequent items does this user also order frequently?
        Set<String> commonItems = myFrequentItems.intersection(otherFrequentItems);

        if (commonItems.isNotEmpty) {
          // This user is similar - they also frequently order items I frequently order
          double similarity = commonItems.length / myFrequentItems.length;

          print('DEBUG: Found similar user $otherEmail with ${commonItems.length} common items (similarity: ${similarity.toStringAsFixed(2)})');
          print('DEBUG: Common items: ${commonItems.toList()}');
          print('DEBUG: Other user\'s top items: ${otherTopItems.take(5).map((e) => e.key).toList()}');

          // Find items this similar user orders that I haven't tried or don't order frequently
          for (var otherItem in otherTopItems.take(5)) {
            String candidateItem = otherItem.key;

            // Only recommend if:
            // 1. I haven't ordered this item at all, OR
            // 2. I've ordered it but not frequently (less than 2 times)
            if (!allMyItems.contains(candidateItem) ||
                (myItemFrequencies[candidateItem] ?? 0) < 2) {

              // Score based on similarity and how frequently the other user orders this item
              double score = similarity * otherItem.value;
              candidateScores[candidateItem] = (candidateScores[candidateItem] ?? 0) + score;

              print('DEBUG: Adding candidate: $candidateItem with score: ${score.toStringAsFixed(2)}');
            }
          }
        }
      }

      print('DEBUG: Found ${candidateScores.length} candidate items');

      // Step 4: Convert to recommendations and sort by score
      List<Map<String, dynamic>> recommendations = [];

      var sortedCandidates = candidateScores.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      for (var candidate in sortedCandidates.take(5)) {
        String productName = candidate.key;

        // Find the actual food item
        var foodItem = allFoodItems.firstWhere(
              (item) => normalizeProductName(item['name']) == productName,
          orElse: () => {},
        );

        if (foodItem.isNotEmpty) {
          recommendations.add({
            'productId': foodItem['productId'],
            'name': foodItem['name'],
            'price': foodItem['price'] ?? 0.0,
            'description': foodItem['description'] ?? '',
            'imagePath': foodItem['imagePath'] ?? '',
            'category': foodItem['category'] ?? '',
            'subcategory': foodItem['subcategory'] ?? '',
            'score': candidate.value,
            'reasons': ['People with similar taste also liked it'],
          });
        }
      }

      print('DEBUG: Final collaborative recommendations: ${recommendations.length}');
      for (var rec in recommendations) {
        print('DEBUG: - ${rec['name']} (score: ${rec['score']})');
      }

      return recommendations;

    } catch (e) {
      print('Error in collaborative filtering: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(child: CircularProgressIndicator())
        : recommendations.isEmpty
        ? Center(child: Text('No recommendations available yet'))
        : SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Recommended for You',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.themeColor,
              ),
            ),
          ),
          GridView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16),
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.68,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: recommendations.length,
            itemBuilder: (context, index) {
              final item = recommendations[index];
              return ValueListenableBuilder<List<int>>(
                valueListenable: favoriteNotifier, // Use the global notifier
                builder: (context, favorites, child) {
                  final isFavorite = favorites.contains(item['productId']);

                  return Stack(
                    children: [
                      ProductCard(
                        item: item,
                        isFavorite: isFavorite,
                        onFavoriteToggle: () async {
                          if (isFavorite) {
                            await FavoritesManager.removeFromFavorites(
                                item['productId'], context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${item['name']} removed from favorites'),
                                duration: Duration(seconds: 1),
                                backgroundColor: AppColors.themeColor,
                              ),
                            );
                          } else {
                            await FavoritesManager.addToFavorites(
                                item['productId'], context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${item['name']} added to favorites'),
                                duration: Duration(seconds: 1),
                                backgroundColor: AppColors.themeColor,
                              ),
                            );
                          }
                          // No need to manually update favoriteNotifier here
                          // It's already handled in FavoritesManager
                        },
                        onAddToCart: () async {
                          List<PersistentShoppingCartItem>? cartItem =
                          await PersistentShoppingCart().getCartData()['cartItems'];
                          bool containsItem = cartItem!.any((items) =>
                          items.productId == item['productId'].toString());

                          if (containsItem) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Product already added to cart'),
                                duration: Duration(seconds: 1),
                                backgroundColor: AppColors.themeColor,
                              ),
                            );
                          } else {
                            await PersistentShoppingCart().addToCart(
                              PersistentShoppingCartItem(
                                unitPrice: item['price'] ?? 0,
                                productId: item['productId'].toString(),
                                productName: item['name'] ?? '',
                                productThumbnail: item['imagePath'] ?? '',
                                quantity: 1,
                                productDescription: item['description'],
                                productDetails: {
                                  'category': item['category'] ?? 'Unknown Category',
                                  'subcategory': item['subcategory'] ?? 'Unknown Subcategory',
                                },
                              ),
                            );

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${item['name']} added to cart!'),
                                duration: Duration(seconds: 1),
                                backgroundColor: AppColors.themeColor,
                              ),
                            );
                          }
                        },
                        onTap: () {
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //     builder: (context) => FoodDetailScreen(
                          //         name: item['name'],
                          //         price: item['price'],
                          //         imagePath: item['imagePath'],
                          //         description: item['description'],
                          //         subcategory: item['subcategory'],
                          //         category: item['category']
                          //     ),
                          //   ),
                          // );
                        },
                      ),
                      // Recommendation reason badge
                      if (item['reasons'] != null && (item['reasons'] as List).isNotEmpty)
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.themeColor.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              (item['reasons'] as List).first,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              );
            },
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}