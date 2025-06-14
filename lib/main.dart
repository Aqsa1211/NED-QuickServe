import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cart/cart.dart';
import 'package:food/FirebaseChat/firebase_chat.dart';
import 'package:food/api/firebase_api.dart';
import 'package:persistent_shopping_cart/persistent_shopping_cart.dart';
import 'favorites/favourite_controller.dart';
import 'menu_screen/menu_screen.dart';
import 'splash.dart';

void main() async {
  await PersistentShoppingCart().init();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: FirebaseOptions(
          apiKey: 'AIzaSyCfSNa_8iJ4Yhchu9oYI361JWAnxpiamjQ',
          appId: '1:962513905106:android:4bd40c0077fcb9705cd40b',
          messagingSenderId: '962513905106',
          projectId: 'ecomerce-b0581'));
  await FirebaseApi().initNotifications();
  var cart = FlutterCart();
  await cart.initializeCart(isPersistenceSupportEnabled: true);

  // Initialize a FirebaseChat instance and call createUser
  FirebaseChat firebaseChat = FirebaseChat();
  firebaseChat.createUser(
    user_id: '3',
    name: 'Fatima',
    image: 'https://www.example.com/user_image.jpg',
  );
  await FavoritesManager.loadFavorites();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NED Cafeteria',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SplashScreen(), // Start with SplashScreen
    );
  }
}