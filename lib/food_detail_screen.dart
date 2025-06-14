import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:food/weatherRecommendation/weather_recommendation.dart';
import 'package:persistent_shopping_cart/model/cart_model.dart';
import 'package:persistent_shopping_cart/persistent_shopping_cart.dart';
import '../cart/add_to_cart_screen.dart';
import 'data/all_food_items.dart';
import 'utils/colors.dart';

class FoodDetailScreen extends StatelessWidget {
  final String name;
  final double price;
  final String imagePath;
  final String description;
  final String subcategory;
  final String category;

  FoodDetailScreen({
    required this.name,
    required this.price,
    required this.imagePath,
    required this.description,
    required this.subcategory,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> recommendedItems = allFoodItems
        .where((item) =>
            item['subcategory'] == subcategory && item['name'] != name)
        .take(5)
        .toList();
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background Image
          Positioned(
            child: Container(
              height: 350,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(imagePath),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          // Back Button
          Positioned(
            top: 40,
            left: 20,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withOpacity(0.5),
                ),
                child: Icon(
                  Icons.arrow_back_ios,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
          // Main Content (Scrollable)
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.6,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Food Name and Price
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            name,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.blackColor,
                            ),
                          ),
                          Text(
                            'Rs. ${price.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.themeColor,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 5),
                      Row(
                        children: [
                          Icon(Icons.local_dining,
                              color: AppColors.darkGrey, size: 16),
                          SizedBox(width: 5),
                          Text(
                            category,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkGrey,
                            ),
                          ),
                          SizedBox(width: 5),
                          Text('•',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.darkGrey)),
                          SizedBox(width: 5),
                          Text(
                            subcategory,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkGrey,
                            ),
                          ),
                        ],
                      ),
                      //Tag
                      SizedBox(height: 10),
                      Container(
                        width: 150,
                        decoration: BoxDecoration(
                          color: AppColors
                              .themeColor, // You can change this color to fit your design
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(20), // Right side rounded
                            bottomRight:
                                Radius.circular(20), // Right side rounded
                          ),
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal:
                                    12), // Horizontal padding for text and icon
                            child: Row(
                              children: [
                                Icon(
                                  Icons
                                      .trending_up_sharp, // Icon you want to use
                                  color: Colors.white, // Icon color
                                  size: 18, // Adjust the icon size
                                ),
                                SizedBox(
                                    width: 8), // Spacing between icon and text
                                Text(
                                  'Popular',
                                  style: TextStyle(
                                    color: Colors.white, // Text color
                                    fontSize: 16, // Text size
                                    fontWeight: FontWeight.bold, // Text weight
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      Divider(),
                      SizedBox(height: 5),
                      // Description Section
                      Text(
                        "Description",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: AppColors.black,
                          height: 2,
                        ),
                      ),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.darkerGrey,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.justify,
                      ),
                      // Recommended Items (Horizontally Scrollable)
                      if (recommendedItems.isNotEmpty) ...[
                        SizedBox(height: 20),
                        Column(
                          children: [

                            Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                "You May Also Like",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: AppColors.blackColor,
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                "Discover items similar to $name",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.darkGrey,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        SizedBox(
                          height: 170,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: recommendedItems.length,
                            itemBuilder: (context, index) {
                              var item = recommendedItems[index];
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => FoodDetailScreen(
                                        name: item['name'],
                                        price: item['price'],
                                        imagePath: item['imagePath'],
                                        description: item['description'],
                                        subcategory: item['subcategory'],
                                        category: item['category'],
                                      ),
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: Container(
                                    width: 150,
                                    margin: EdgeInsets.only(right: 10),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: AppColors
                                            .grey, // Change this to your desired border color
                                        width: 1, // Adjust thickness as needed
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black12,
                                          blurRadius: 1,
                                          offset: Offset(0, 1),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.vertical(
                                              top: Radius.circular(10)),
                                          child: Image.asset(
                                            item['imagePath'],
                                            height: 100,
                                            width: 150,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 8.0),
                                          child: Column(
                                            children: [
                                              Align(
                                                alignment: Alignment.topLeft,
                                                child: Text(
                                                  item['name'],
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                              Align(
                                                alignment: Alignment.topLeft,
                                                child: Text(
                                                  'Rs. ${item['price'].toStringAsFixed(2) ?? 'N/A'}',
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color:
                                                          AppColors.themeColor),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                  textAlign: TextAlign.center,
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        SizedBox(height: 10),
                      ],
                      WeatherBasedRecommendations(foodCategory:category,),
                      SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 80,
          width: double.infinity,
          padding: EdgeInsets.all(15),
          color: Colors.white,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.themeColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
            ),
            onPressed: () async {
              List<PersistentShoppingCartItem>? cartItems;
              cartItems =
                  await PersistentShoppingCart().getCartData()['cartItems'];

              bool containsItem = cartItems!.any((item) =>
                  item.productId == name.hashCode.toString() ||
                  item.productName == name);

              if (containsItem) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Product already added to cart'),
                    duration: Duration(seconds: 1),
                    backgroundColor: AppColors.themeColor,
                    action: SnackBarAction(
                      label: 'View',
                      textColor: Colors.white,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => CartScreen()), // replace with your actual screen widget
                        );
                      },
                    ),
                  ),
                );
              } else {
                await PersistentShoppingCart().addToCart(
                  PersistentShoppingCartItem(
                    unitPrice: price,
                    productId: name.hashCode.toString(),
                    productName: name,
                    productThumbnail: imagePath,
                    quantity: 1,
                  ),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$name added to cart!'),
                    duration: Duration(seconds: 1),
                    backgroundColor: AppColors.themeColor,
                    action: SnackBarAction(
                      label: 'View',
                      textColor: Colors.white,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => CartScreen()), // replace with your actual screen widget
                        );
                      },
                    ),
                  ),
                );
              }
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(CupertinoIcons.cart, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text(
                  'Add to Cart',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
