import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:food/receipt.dart';
import 'package:persistent_shopping_cart/model/cart_model.dart';
import 'package:persistent_shopping_cart/persistent_shopping_cart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'utils/colors.dart';
import 'order_service.dart';

class ConfirmOrder extends StatefulWidget {
  final double cartTotal;
  final List<Map<String, dynamic>> cartItems;

  ConfirmOrder({required this.cartTotal, required this.cartItems});

  @override
  _ConfirmOrderState createState() => _ConfirmOrderState();
}

class _ConfirmOrderState extends State<ConfirmOrder> {
  String? selectedLocation;
  String selectedPaymentMethod = "Cash on Delivery"; // Default
  double deliveryCharge = 0.0;
  String userName = "User";
  String userEmail = "example@email.com";
  List<PersistentShoppingCartItem>? cartItem;
  final OrderService orderService = OrderService();

  final Map<String, double> locationCharges = {
    'Architecture': 11.0,
    'Automotive': 13.0,
    'BCIT': 8.0,
    'Chemical': 12.0,
    'CIS': 6.0,
    'Civil Engineering': 5.0,
    'Chemistry': 6.0,
    'Economics': 9.0,
    'Electronic': 9.0,
    'English Linguistics ': 10.0,
    'Environmental': 15.0,
    'Essential Studies': 12.0,
    'Earthquake': 12.0,
    'Food Engineering': 5.0,
    'Industrial': 9.0,
    'Mathematics': 7.0,
    'Mechanical': 10.0,
    'Metallurgical': 7.0,
    'Petroleum': 10.0,
    'Physics': 8.0,
    'Polymer': 14.0,
    'Software': 11.0,
    'Telecommunications': 14.0,
    'Textile': 10.0,
    'Urban ': 8.0,
    'Materials': 8.0,
  };



  @override
  void initState() {
    super.initState();
    cartItem = PersistentShoppingCart().getCartData()['cartItems'];
    _loadUserData();
    if (locationCharges.isNotEmpty) {
      setState(() {
        selectedLocation = locationCharges.keys.first;
        deliveryCharge = locationCharges[selectedLocation] ?? 0.0;
      });
    }
  }

  double get totalAmountWithDelivery => widget.cartTotal + deliveryCharge;

  // Calculate the subtotal by summing the totalPrice for each item
  double get subtotal {
    return widget.cartItems.fold(0.0, (sum, item) {
      return sum + item['totalPrice'];
    });
  }

  void _showLocationBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView( // Make it scrollable
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    margin: EdgeInsets.only(top: 8),
                    decoration: BoxDecoration(
                      color: AppColors.darkGrey,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizedBox(height: 30),
                Text(
                  "Select Delivery Location",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: AppColors.themeColor,
                  ),
                ),
                SizedBox(height: 10),
                ...locationCharges.keys.map((location) {
                  return Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedLocation = location;
                            deliveryCharge = locationCharges[location] ?? 0.0;
                          });
                          Navigator.pop(context); // Close the bottom sheet
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: selectedLocation == location
                                ? AppColors.themeColor.withOpacity(0.1) // Selected background color
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(15), // Rounded corners
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10.0),
                            child: Row(
                              children: [
                                Icon(Icons.pin_drop_outlined, color: AppColors.themeColor),
                                SizedBox(width: 10),
                                Text(
                                  "$location (Rs. ${locationCharges[location]})",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.darkerGrey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Divider(), // Divider below each option
                    ],
                  );
                }).toList(),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('name') ?? "User";
      userEmail = prefs.getString('id') ?? "example@email.com";
    });
  }



  void _showPaymentMethodSelection() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  margin: EdgeInsets.only(top: 8),
                  decoration: BoxDecoration(
                    color: AppColors.darkGrey,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 30),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Select Payment Method',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w900,
                    color: AppColors.themeColor,
                  ),
                ),
              ),
              SizedBox(height: 10),
              ListView(
                shrinkWrap: true,
                children: ["Cash on Delivery"].map((method) {
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: selectedPaymentMethod == method
                                ? AppColors.themeColor.withOpacity(0.1) // Background color for selected option
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(15), // Rounded corners
                          ),
                          child: ListTile(
                            // Wrap icon in Padding to move it left
                            leading: Icon(Icons.payments_outlined, color: AppColors.themeColor),
                            title: Text(
                              method,
                              style: TextStyle(
                                fontSize: 14.0,
                                color: AppColors.darkerGrey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            onTap: () {
                              setState(() {
                                selectedPaymentMethod = method;
                              });
                              Navigator.pop(context); // Close the bottom sheet
                            },
                          ),
                        ),
                      ),
                      // Divider(color: AppColors.darkGrey),
                    ],
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }





  void _confirmOrder() async {
    if (selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select a delivery location")),
      );
      return;
    }

    // Show confirmation dialog
    bool confirmOrder = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Column(
          children: [
            Icon(
              CupertinoIcons.cart, // Cupertino Cart Icon
              color: AppColors.themeColor,
              size: 40,
            ),
            SizedBox(height: 15),
            Text(
              "Proceed to Checkout ?",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.blackColor,
              ),
            ),
            SizedBox(height: 15),
            Text(
              "Are you sure you want to place this order ?",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.dark,
              ),
            ),
            SizedBox(height: 10),
          ],
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 15),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.themeColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextButton(
                  onPressed: () => Navigator.pop(context, false), // No
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 40), // Adjust padding to increase the size
                  ),
                  child: Text(
                    "No",
                    style: TextStyle(
                      color: AppColors.whiteColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

              ),
              SizedBox(width: 10), // Space between buttons
              // Yes Button
              Container(
                decoration: BoxDecoration(
                  color: AppColors.themeColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextButton(
                  onPressed: () =>
                      Navigator.pop(context, true),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 40), // Adjust padding to increase the size
                  ),
                  child: Text(
                    "Yes",
                    style: TextStyle(
                      color: AppColors.whiteColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
    // If user confirms, place the order
    if (confirmOrder == true) {
      try {
        String orderId = await orderService.placeOrder(
          deliveryLocation: selectedLocation!,
          cartItems: widget.cartItems,
          totalAmount: totalAmountWithDelivery,
          deliveryCharge: deliveryCharge,
          paymentMethod: selectedPaymentMethod,  userEmail: userEmail,
        );

        // Navigate to ReceiptScreen with the orderId
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ReceiptScreen(
              orderId: orderId,
              totalAmount: totalAmountWithDelivery,
              firebaseUser: FirebaseAuth.instance.currentUser!,
            ),
          ),
        );
        // ✅ Clear the cart after placing the order
        PersistentShoppingCart().clearCart();  // Clear the cart
        setState(() {
          cartItem = []; }); // Update the cart to empty

      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Order failed. Please try again.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.whiteColor),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: AppColors.themeColor, // Maroon color to match your theme
        title: Text(
          'Confirm Order',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

// Delivery Location Section
            Text(
              "Select Delivery Location",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            TextButton(
              onPressed: _showLocationBottomSheet,
              child: Row(
                mainAxisSize: MainAxisSize.min, // This makes the button size wrap tightly around the content
                children: [
                  Icon(CupertinoIcons.chevron_down_circle, color: AppColors.themeColor, size: 20),
                  SizedBox(width: 10),
                  Text(
                    selectedLocation ?? "Select Delivery Location",
                    style: TextStyle(
                      fontSize: 16,
                      color: selectedLocation == null ? Colors.grey : AppColors.themeColor,
                    ),
                  ),
                ],
              ),
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 6), // Reduced padding to make it wrap the content
                backgroundColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(color: Colors.grey.shade400, width: 1),
                ),
              ),
            ),
            SizedBox(height: 20),

// Payment Method Section
            Text(
              "Select Payment Method",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            TextButton(
              onPressed: _showPaymentMethodSelection,
              child: Row(
                mainAxisSize: MainAxisSize.min, // This makes the button size wrap tightly around the content
                children: [
                  Icon(CupertinoIcons.chevron_down_circle, color: AppColors.themeColor, size: 20),
                  SizedBox(width: 10),
                  Text(
                    selectedPaymentMethod.isEmpty ? "Select Payment Method" : selectedPaymentMethod,
                    style: TextStyle(
                      fontSize: 16,
                      color: selectedPaymentMethod.isEmpty ? Colors.grey : AppColors.themeColor,
                    ),
                  ),
                ],
              ),
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 6), // Reduced padding to make it wrap the content
                backgroundColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(color: Colors.grey.shade400, width: 1),
                ),
              ),
            ),
            SizedBox(height: 20),




            // Order Summary Card
            Card(
              margin: EdgeInsets.only(top: 20),
              elevation: 7,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // Order Summary Title
                    Align(
                      child: Text(
                        "Order Summary",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: AppColors.themeColor),
                      ),
                    ),
                    SizedBox(height: 10),
                    Divider(),
                    SizedBox(height: 10),

                    // Delivery Location and Payment Method
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          textAlign: TextAlign.justify,
                          "Delivery\nLocation: ",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Expanded(
                          child: Text(
                            textAlign: TextAlign.right,
                            "${selectedLocation ?? "N/A"} Dept.",
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Payment Method:",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          selectedPaymentMethod,
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Divider(),
                    SizedBox(height: 10),
                    // Cart Items
                    Text(
                      "Items Ordered:",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.themeColor),
                    ),
                    SizedBox(height: 5),
                    ...widget.cartItems.map((item) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "${item["productName"]} x ${item["quantity"]}",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, height: 2),
                          ),
                          Text(
                            "Rs. ${item["totalPrice"]}",
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      );
                    }).toList(),
                    SizedBox(height: 10),
                    Divider(),
                    SizedBox(height: 10),
                    // Subtotal Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Subtotal:",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          "Rs. $subtotal",
                          style: TextStyle( fontSize: 16),
                        ),
                      ],
                    ),
                    SizedBox(height: 5),

                    // Delivery Charge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Delivery Charges:",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          "Rs. $deliveryCharge",
                          style: TextStyle( fontSize: 16),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Divider(),
                    SizedBox(height: 10),
                    // Total Amount
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Total Amount:",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: AppColors.themeColor),
                        ),
                        Text(
                          "Rs. $totalAmountWithDelivery",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),

            // Confirm Button
            SizedBox(
              width: double.infinity, // Makes the button full width
              child: ElevatedButton(
                onPressed: selectedLocation != null ? _confirmOrder : null, // Disable if no location selected
                child: Text(
                  "Confirm Order",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  foregroundColor: AppColors.white,
                  backgroundColor: selectedLocation != null
                      ? AppColors.themeColor
                      : Colors.grey, // Grey out if disabled
                  padding: EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
