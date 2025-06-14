import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:persistent_shopping_cart/model/cart_model.dart';
import 'package:persistent_shopping_cart/persistent_shopping_cart.dart';
import '../data/all_food_items.dart';
import '../favorites/favourite_controller.dart';
import '../menu_screen/product_card.dart';
import '../utils/colors.dart';

class FoodPairingsRecommendationsPage extends StatefulWidget {
  @override
  _FoodPairingsRecommendationsPageState createState() => _FoodPairingsRecommendationsPageState();
}

class _FoodPairingsRecommendationsPageState extends State<FoodPairingsRecommendationsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ValueNotifier<List<int>> favoriteNotifier = ValueNotifier<List<int>>([]);

  List<Map<String, dynamic>> recommendations = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecommendations();
  }

  Future<void> _loadRecommendations() async {
    try {
      // Step 1: Get current cart items
      List<PersistentShoppingCartItem>? cartItems =
      PersistentShoppingCart().getCartData()['cartItems'];
      if (cartItems == null || cartItems.isEmpty) {
        setState(() {
          isLoading = false;
        });
        return;
      }
      List<String> currentCartProductNames =
      cartItems.map((e) => e.productName).toList();

      // Step 2: Fetch all orders from all users
      QuerySnapshot allOrdersSnapshot =
      await _firestore.collectionGroup('orders').get();

      // Step 3: Analyze co-occurrence frequencies
      Map<String, Map<String, int>> pairFrequency = {};
      Map<String, int> itemFrequency = {};

      for (var doc in allOrdersSnapshot.docs) {
        List<dynamic> items = doc['items'] ?? [];

        for (var i = 0; i < items.length; i++) {
          String item1 = items[i]['productName'];
          itemFrequency[item1] = (itemFrequency[item1] ?? 0) + 1;

          for (var j = i + 1; j < items.length; j++) {
            String item2 = items[j]['productName'];

            pairFrequency.putIfAbsent(item1, () => {});
            pairFrequency[item1]![item2] = (pairFrequency[item1]![item2] ?? 0) + 1;

            pairFrequency.putIfAbsent(item2, () => {});
            pairFrequency[item2]![item1] = (pairFrequency[item2]![item1] ?? 0) + 1;
          }
        }
      }

      // Step 4: Score items based on co-occurrence with current cart items
      Map<String, double> scoredItems = {};
      for (String cartItem in currentCartProductNames) {
        if (pairFrequency.containsKey(cartItem)) {
          pairFrequency[cartItem]!.forEach((pairedItem, count) {
            if (!currentCartProductNames.contains(pairedItem)) {
              double confidence = count / (itemFrequency[cartItem] ?? 1);
              scoredItems[pairedItem] = (scoredItems[pairedItem] ?? 0) + confidence;
            }
          });
        }
      }

      // Step 5: Build recommendation list from `allFoodItems`
      List<Map<String, dynamic>> recommendationsList = [];
      scoredItems.forEach((product, score) {
        var matchingItem = allFoodItems.firstWhere(
              (item) => item['name'] == product,
          orElse: () => {'description': '', 'imagePath': '', 'productId': '', 'name': ''},
        );

        recommendationsList.add({
          'productName': product,
          'name': matchingItem['name'] ?? product,
          'productId': matchingItem['productId'] ?? '',
          'score': score,
          'price': matchingItem['price'] ?? 0.0,
          'description': matchingItem['description'] ?? '',
          'imagePath': matchingItem['imagePath'] ?? '',
          'category': matchingItem['category'] ?? '',
          'subcategory': matchingItem['subcategory'] ?? '',
        });
      });

      // Sort and trim to top 5
      recommendationsList.sort((a, b) => b['score'].compareTo(a['score']));
      if (recommendationsList.length > 5) {
        recommendationsList = recommendationsList.sublist(0, 5);
      }

      setState(() {
        recommendations = recommendationsList;
        isLoading = false;
      });
    } catch (e) {
      print('Error generating recommendations: $e');
      setState(() {
        isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(child: CircularProgressIndicator())
        : recommendations.isEmpty
        ? Center(child: Text('No recommendations yet'))
        : SingleChildScrollView(
      child: GridView.builder(
        padding: EdgeInsets.all(16),
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
            valueListenable: favoriteNotifier,
            builder: (context, favorites, child) {
              final isFavorite = favorites.contains(item['productId']);

              return ProductCard(
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
                  favoriteNotifier.value = await FavoritesManager.getFavorites();
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
              );
            },
          );
        },
      ),
    );
  }
}
