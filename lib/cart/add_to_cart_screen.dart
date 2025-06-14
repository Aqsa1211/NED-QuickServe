import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:food/utils/image_strings.dart';
import 'package:persistent_shopping_cart/model/cart_model.dart';
import 'package:persistent_shopping_cart/persistent_shopping_cart.dart';
import '../confirmation_screen.dart';
import '../menu_screen/menu_screen.dart';
import '../utils/colors.dart';
import 'food_pairings.dart';

class CartScreen extends StatefulWidget {
  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<PersistentShoppingCartItem>? cartItem;


  @override
  void initState() {
    super.initState();
    cartItem = PersistentShoppingCart().getCartData()['cartItems'];
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.whiteColor),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: AppColors.themeColor,
        title: Text(
          'Your Cart',
          style: TextStyle(
            color: AppColors.whiteColor,
            fontWeight: FontWeight.bold,
            fontSize: 22,
            letterSpacing: 1.2,
          ),
        ),
        actions: [
          // Trash icon to clear the cart
          if (cartItem != null && cartItem!.isNotEmpty)
          IconButton(
            icon: Icon(CupertinoIcons.trash, color: AppColors.whiteColor),
            onPressed: cartItem == null || cartItem!.isEmpty
                ? null
                : () {
              // Show confirmation dialog
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Column(
                      children: [
                        Icon(
                          CupertinoIcons.trash, // Cupertino Trash Icon
                          color: AppColors.themeColor,
                          size: 40,
                        ),
                        SizedBox(height: 10), // Add space between icon and title
                        Text(
                          "Clear Cart",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: AppColors.blackColor,
                          ),
                        ),
                      ],
                    ),
                    content: Text(
                      "Are you sure you want to remove all items from the cart?",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.dark,
                      ),
                    ),
                    actions: [
                      // Row to center the buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.themeColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();  // Close the dialog without doing anything
                              },
                              child: Text(
                                "No",
                                style: TextStyle(
                                  color: AppColors.whiteColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: TextButton.styleFrom(padding: EdgeInsets.symmetric(horizontal: 20)),
                            ),
                          ),
                          SizedBox(width: 20), // Add space between buttons
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.themeColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: TextButton(
                              onPressed: () {
                                PersistentShoppingCart().clearCart();  // Clear the cart
                                setState(() {
                                  cartItem = [];  // Update the cart to empty
                                });
                                Navigator.of(context).pop();  // Close the dialog
                              },
                              child: Text(
                                "Yes",
                                style: TextStyle(
                                  color: AppColors.whiteColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: TextButton.styleFrom(padding: EdgeInsets.symmetric(horizontal: 20)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              );
            },
          ),

        ],
      ),
        body: Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: SafeArea(
            child: cartItem == null || cartItem!.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    AppImages.emptyCart,
                    width: 180,
                    height: 180,
                  ),
                  Text(
                    'Your cart is empty.',
                    style: TextStyle(
                      fontSize: 18,
                      color: AppColors.greycolor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MenuScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.themeColor,
                      padding: EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 40,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: Text(
                      'Add to Cart',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.whiteColor,
                      ),
                    ),
                  ),
                ],
              ),
            )
                : SingleChildScrollView(
              child: Column(
                children: [
                  // List of Cart Items
                  Column(
                    children: cartItem!.map((item) {
                      return Column(
                        children: [
                          // Item Card
                          Card(
                            margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 15),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            color: Colors.transparent,
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.asset(
                                      item.productThumbnail ?? 'assets/images/placeholder.png',
                                      fit: BoxFit.cover,
                                      width: 80,
                                      height: 80,
                                    ),
                                  ),

                                  SizedBox(width: 15),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.productName ?? "",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: AppColors.blackColor,
                                          ),
                                        ),
                                        SizedBox(height: 5),
                                        Text(
                                          'Rs. ${(item.unitPrice * item.quantity).toStringAsFixed(2)}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            color: AppColors.themeColor,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      SizedBox(height: 8, width: 16),
                                      Row(
                                        children: [
                                          _buildQuantityButton(
                                            icon: Icons.remove,
                                            onPressed: () async {
                                              if (item.quantity > 1) {
                                                await PersistentShoppingCart()
                                                    .decrementCartItemQuantity(item.productId);
                                              } else {
                                                await PersistentShoppingCart()
                                                    .removeFromCart(item.productId);
                                              }
                                              setState(() {
                                                cartItem = PersistentShoppingCart()
                                                    .getCartData()['cartItems'];
                                              });
                                            },
                                          ),
                                          SizedBox(
                                            width: 30,
                                            child: Text(
                                              '${item.quantity}',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.blackColor,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                          _buildQuantityButton(
                                            icon: Icons.add,
                                            onPressed: () async {
                                              await PersistentShoppingCart()
                                                  .incrementCartItemQuantity(item.productId);
                                              setState(() {
                                                cartItem = PersistentShoppingCart()
                                                    .getCartData()['cartItems'];
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Divider(
                            color: AppColors.grey,
                            thickness: 0.7,
                            indent: 20,
                            endIndent: 20,
                          ),
                        ],
                      );
                    }).toList(),

                  ),
                  // "Add more items" section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MenuScreen(),
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          Icon(
                            Icons.add,
                            color: AppColors.accent,
                            size: 20,
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Add more items',
                            style: TextStyle(
                              color: AppColors.accent,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height:30,),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18.0),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text('Popular with your order',
                        style: TextStyle(
                          color: AppColors.darkerGrey,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18.0),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text('Other customers also bought these',
                        style: TextStyle(
                          color: AppColors.darkerGrey,
                          fontSize: 12,
                        ),),
                    ),
                  ),
                  FoodPairingsRecommendationsPage(),
                  SizedBox(height: 500),
                ],
              ),
            ),
          ),
        ),
      bottomSheet: _buildBottomSection(), // Bottom section for total amount and confirmation
    );
  }



  Widget _buildBottomSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 5,
            spreadRadius: 2,
            offset: Offset(0, -2),
          ),
        ],
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PersistentShoppingCart().showTotalAmountWidget(
            cartTotalAmountWidgetBuilder: (double amount) {
              return Padding(
                padding: EdgeInsets.only(bottom: 8, left: 16),
                child: Text(
                  textAlign: TextAlign.center,
                  'Total Amount : Rs. ${amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.themeColor,
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: cartItem == null || cartItem!.isEmpty
                    ? AppColors.greycolor
                    : AppColors.themeColor,
                padding: EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              onPressed: (cartItem == null || cartItem!.isEmpty)
                  ? null
                  : () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ConfirmOrder(
                      cartTotal: PersistentShoppingCart()
                          .calculateTotalPrice(),
                      cartItems: cartItem!.map((item) {
                        return {
                          "productName": item.productName,
                          "quantity": item.quantity,
                          "unitPrice": item.unitPrice,
                          "totalPrice": item.unitPrice * item.quantity,
                        };
                      }).toList(),
                    ),
                  ),
                );
              },
              icon: Icon(
                Icons.location_pin,
                color: AppColors.whiteColor,
                size: 20,
              ),
              label: Text(
                'Confirm Location',
                style: TextStyle(
                  color: AppColors.whiteColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityButton(
      {required IconData icon, required VoidCallback onPressed}) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.themeColor.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: IconButton(
        icon: Icon(icon, color: AppColors.themeColor),
        onPressed: onPressed,
        padding: EdgeInsets.zero,
      ),
    );
  }
}