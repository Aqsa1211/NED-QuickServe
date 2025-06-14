import 'package:flutter/material.dart';
import 'package:food/menu_screen/product_card.dart';
import 'package:persistent_shopping_cart/model/cart_model.dart';
import 'package:persistent_shopping_cart/persistent_shopping_cart.dart';
import '../../utils/colors.dart';
import 'favourite_controller.dart';
import 'favourite_notifier.dart';
import '../food_detail_screen.dart';
import 'package:food/utils/image_strings.dart';

class FavouritesPage extends StatelessWidget {
    final List<Map<String, dynamic>> allFoodItems;

    const FavouritesPage({Key? key, required this.allFoodItems}) : super(key: key);

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
                backgroundColor: AppColors.themeColor,
                title: Text(
                    'Favorites',
                    style: TextStyle(
                        color: AppColors.whiteColor,
                        fontWeight: FontWeight.bold,
                    ),
                ),
                leading: IconButton(
                    icon: Icon(Icons.arrow_back_ios, color: AppColors.whiteColor),
                    onPressed: () => Navigator.pop(context),
                ),
            ),
            body: ValueListenableBuilder<List<int>>(
                valueListenable: favoriteNotifier,
                builder: (context, favoriteList, child) {
                    List<Map<String, dynamic>> favoriteItems = allFoodItems
                        .where((item) => favoriteList.contains(item['productId']))
                        .toList();

                    if (favoriteItems.isEmpty) {
                        return Center(
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                    Image.asset(
                                      AppImages.noFav,
                                        width: 180,
                                        height: 180,
                                    ),
                                    SizedBox(height: 16),
                                    Text("No favorite items added",
                                        style: TextStyle(
                                        fontSize: 18,
                                        color: AppColors.greycolor,
                                        fontWeight: FontWeight.w600,
                                    ),),
                                ],
                            ),
                        );
                    }

                    return Padding(
                        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                        child: GridView.builder(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 15,
                                mainAxisSpacing: 15,
                                childAspectRatio: 0.68,
                            ),
                            itemCount: favoriteItems.length,
                            itemBuilder: (context, index) {
                                var item = favoriteItems[index];
                                final isFavorite = favoriteList.contains(item['productId']);

                                return ProductCard(
                                    item: item,
                                    isFavorite: isFavorite,
                                    onFavoriteToggle: () async {
                                        if (isFavorite) {
                                            await FavoritesManager.removeFromFavorites(item['productId'], context);
                                            ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                    content: Text('${item['name']} removed from favorites'),
                                                    duration: Duration(seconds: 1),
                                                    backgroundColor: AppColors.themeColor,
                                                ),
                                            );
                                        } else {
                                            await FavoritesManager.addToFavorites(item['productId'], context);
                                            ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                    content: Text('${item['name']} added to favorites'),
                                                    duration: Duration(seconds: 1),
                                                    backgroundColor: AppColors.themeColor,
                                                ),
                                            );
                                        }
                                        favoriteNotifier.value = List.from(await FavoritesManager.getFavorites());
                                    },
                                    onAddToCart: () async {
                                        var cartData = await PersistentShoppingCart().getCartData();
                                        List<PersistentShoppingCartItem>? cartItems = cartData['cartItems'];

                                        bool containsItem = cartItems != null &&
                                            cartItems.any((cartItem) => cartItem.productId == item['productId'].toString());

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
                                                builder: (context) => FoodDetailScreen(
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
                        ),
                    );
                },
            ),
        );
    }
}
