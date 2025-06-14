import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'favourite_notifier.dart';

class FavoritesManager {
  static Future<List<int>> getFavorites() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> favoriteList = prefs.getStringList('favorites') ?? [];
    return favoriteList.map((e) => int.parse(e)).toList();
  }

  static Future<void> addToFavorites(int productId, BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> favoriteList = prefs.getStringList('favorites') ?? [];
    favoriteList.add(productId.toString());
    await prefs.setStringList('favorites', favoriteList);

    // Update the favoriteNotifier
    favoriteNotifier.value = favoriteList.map((e) => int.parse(e)).toList();
  }

  static Future<void> removeFromFavorites(int productId, BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> favoriteList = prefs.getStringList('favorites') ?? [];
    favoriteList.remove(productId.toString());
    await prefs.setStringList('favorites', favoriteList);

    // Update the favoriteNotifier
    favoriteNotifier.value = favoriteList.map((e) => int.parse(e)).toList();
  }

  // Load favorites when app starts
  static Future<void> loadFavorites() async {
    List<int> favorites = await getFavorites();
    favoriteNotifier.value = favorites;
  }
}
