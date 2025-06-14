import 'package:flutter/material.dart';
import 'package:food/weatherRecommendation/weather_service.dart';
import 'package:persistent_shopping_cart/model/cart_model.dart';
import 'package:persistent_shopping_cart/persistent_shopping_cart.dart';
import '../data/all_food_items.dart';
import '../favorites/favourite_controller.dart';
import '../favorites/favourite_notifier.dart';
import '../food_detail_screen.dart';
import '../menu_screen/product_card.dart';
import '../utils/colors.dart';

class WeatherBasedRecommendations extends StatefulWidget {
  final String? foodCategory;

  WeatherBasedRecommendations({this.foodCategory});

  @override
  _WeatherBasedRecommendationsState createState() =>
      _WeatherBasedRecommendationsState();
}

class _WeatherBasedRecommendationsState extends State<WeatherBasedRecommendations> {
  String currentWeather = 'Unknown';
  List<Map<String, dynamic>> recommendedItems = [];
  bool isLoading = true; // Flag to track the loading state

  String getWeatherSubtitle(String weather) {
    switch (weather.toLowerCase()) {
      case 'hot':
        return "Beat the heat with these refreshing picks!";
      case 'cold':
        return "Stay warm with these cozy treats!";
      case 'rainy':
        return "Enjoy the rain with these comforting delights!";
      default:
        return "Enjoy these delicious recommendations!";
    }
  }

  @override
  void initState() {
    super.initState();
    fetchWeatherAndFilterItems();
  }

  Future<void> fetchWeatherAndFilterItems() async {
    String weather = await WeatherService.getWeatherCategory();
    setState(() {
      currentWeather = weather;
      recommendedItems = allFoodItems
          .where((item) =>
      item['weatherCategory'] == currentWeather &&
          (widget.foodCategory == null || item['category'] == widget.foodCategory))
          .toList();

      recommendedItems.shuffle();
      recommendedItems = recommendedItems.take(5).toList();

      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Show the loading indicator for both the heading and items if data is still being fetched
        isLoading
            ? Row(
          children: [
            CircularProgressIndicator(
              color: AppColors.themeColor, // Optional: customize color
            ),
            SizedBox(width: 10),
            Text(
              "Loading recommendations...",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        )
            : Column(
              children: [
                Align(
                  alignment:Alignment.topLeft,
                  child: Text(
                    "Recommended for the $currentWeather weather",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 5,),
                Align(
                  alignment:Alignment.topLeft,
                  child: Text(
                    getWeatherSubtitle(currentWeather),
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.greycolor,
                    ),
                  ),
                ),
              ],
            ),

        // Show the items only after the data is loaded
        isLoading
            ? Container() // Empty container while loading
            : recommendedItems.isEmpty
            ? Text("No recommendations available for this weather.")
            : GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.68,
            crossAxisSpacing: 10, // Adds space between cards horizontally
            mainAxisSpacing: 15,  // Adds space between cards vertically
          ),
          itemCount: recommendedItems.length,
          itemBuilder: (context, index) {
            final item = recommendedItems[index];
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
                            'category': item['category'] ?? 'Unknown Category',  // Default if category is missing
                            'subcategory': item['subcategory'] ?? 'Unknown Subcategory',  // Default if subcategory is missing
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            FoodDetailScreen(
                                name: item['name'],
                                price: item['price'],
                                imagePath: item['imagePath'],
                                description: item['description'],
                                subcategory: item['subcategory'],
                                category: item['category']
                            ),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ],
    );
  }
}
