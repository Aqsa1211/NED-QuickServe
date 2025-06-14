import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:badges/badges.dart' as badges;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:food/menu_screen/product_card.dart';
import 'package:food/selectrole.dart';
import 'package:food/utils/colors.dart';
import 'package:food/utils/image_strings.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:persistent_shopping_cart/model/cart_model.dart';
import 'package:persistent_shopping_cart/persistent_shopping_cart.dart';
import '../cart/add_to_cart_screen.dart';
import '../Controller/api_busyness_controller.dart';
import '../data/all_food_items.dart';
import '../favorites/favourite_controller.dart';
import '../favorites/favourite_notifier.dart';
import '../favorites/favourites.dart';
import '../food_detail_screen.dart';
import '../../history.dart';
import '../../contact_us.dart';
import '../../about_us.dart';
import '../profile/profile.dart';

class MenuScreen extends StatefulWidget {
  @override
  _MenuScreenState createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  int _selectedCategoryIndex = 0;
  String _selectedSubcategory = '';
  String _searchText = '';
  final FocusNode _searchFocusNode = FocusNode();
  bool _showSearchSuggestions = false;
  String? _suggestedQuery;
  bool _noResultsFound = false;

  // Busyness status variables
  String _cafeteriaStatus = 'Loading...';
  Color _statusColor = Colors.grey;
  Timer? _statusTimer;
  bool _isLoadingStatus = false;
  List<Map<String, dynamic>> _searchSuggestions = [];

  // Draggable cart variables
  Offset _cartPosition = Offset(0, 0);
  bool _isCartDragging = false;
  final double _bottomNavBarHeight = 56.0;

  final List<String> categories = ['Fastfood', 'Snacks', 'Breakfast'];
  final Map<String, List<String>> subcategories = {
    'Fastfood': [
      'Snacks', 'Biryani/Pulao', 'Chinese', 'Pizza', 'Shakes',
      'Roll', 'Burger', 'Fries', 'Pasta', 'Sandwich'
    ],
    'Snacks': ['Beverages', 'Chips', 'Biscuits'],
    'Breakfast': ['Paratha', 'Tea', 'Egg'],
  };

  @override
  void initState() {
    super.initState();
    _selectedSubcategory = subcategories[categories[_selectedCategoryIndex]]!.first;
    _fetchBusynessStatus();
    _startStatusTimer();

    _searchFocusNode.addListener(() {
      if (!_searchFocusNode.hasFocus) {
        setState(() {
          _showSearchSuggestions = false;
        });
      }
    });

    // Initialize cart position
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final size = MediaQuery.of(context).size;
      setState(() {
        _cartPosition = Offset(size.width - 80, size.height - _bottomNavBarHeight - 100);
      });
    });
  }

  List<Map<String, dynamic>> _getSearchSuggestions(String query) {
    final queryLower = query.toLowerCase();
    return allFoodItems.where((item) {
      final name = item['name'].toString().toLowerCase();
      return name.startsWith(queryLower) ||
          name.split(' ').any((word) => word.startsWith(queryLower)) ||
          name.contains(queryLower);
    }).toList();
  }

  void _startStatusTimer() {
    _statusTimer?.cancel();
    _statusTimer = Timer.periodic(Duration(seconds: 10), (timer) {
      _fetchBusynessStatus();
    });
  }

  Future<void> _fetchBusynessStatus() async {
    setState(() => _isLoadingStatus = true);
    try {
      final response = await ApiTestController.fetchBusynessStatus();
      if (response['status'] == true) {
        final statusData = response['data'];
        setState(() {
          _cafeteriaStatus = statusData['state'] ?? 'Unknown';
          _updateStatusColor();
        });
      } else {
        setState(() {
          _cafeteriaStatus = 'Error: ${response['message'] ?? 'Unknown error'}';
          _statusColor = Colors.grey;
        });
      }
    } catch (e) {
      setState(() {
        _cafeteriaStatus = 'Error';
        _statusColor = Colors.grey;
      });
    } finally {
      setState(() => _isLoadingStatus = false);
    }
  }

  void _updateStatusColor() {
    switch (_cafeteriaStatus.toLowerCase()) {
      case 'busy':
        _statusColor = Colors.red;
        break;
      case 'moderate':
        _statusColor = Colors.orange;
        break;
      case 'free':
        _statusColor = Colors.green;
        break;
      default:
        _statusColor = Colors.grey;
    }
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    super.dispose();
  }

  int _levenshteinDistance(String s, String t) {
    if (s == t) return 0;
    if (s.isEmpty) return t.length;
    if (t.isEmpty) return s.length;

    List<int> v0 = List<int>.filled(t.length + 1, 0);
    List<int> v1 = List<int>.filled(t.length + 1, 0);

    for (int i = 0; i < t.length + 1; i++) {
      v0[i] = i;
    }

    for (int i = 0; i < s.length; i++) {
      v1[0] = i + 1;

      for (int j = 0; j < t.length; j++) {
        int cost = (s[i] == t[j]) ? 0 : 1;
        v1[j + 1] = min(v1[j] + 1, min(v0[j + 1] + 1, v0[j] + cost));
      }

      for (int j = 0; j < t.length + 1; j++) {
        v0[j] = v1[j];
      }
    }

    return v1[t.length];
  }

  String? _findClosestMatch(String query, List<Map<String, dynamic>> items) {
    String? closestMatch;
    int minDistance = double.maxFinite.toInt();

    query = query.trim().toLowerCase();

    for (var item in items) {
      String name = item['name'].toString().trim().toLowerCase();
      int distance = _levenshteinDistance(query, name);

      if (distance < minDistance ||
          (distance == minDistance && name.length < (closestMatch?.length ?? 9999))) {
        minDistance = distance;
        closestMatch = item['name'];
      }
    }

    int dynamicThreshold = (query.length / 3).ceil();
    if (dynamicThreshold < 2) dynamicThreshold = 2;

    return (minDistance <= dynamicThreshold) ? closestMatch : null;
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredFoodItems = allFoodItems.where((item) {
      return item['name'].toLowerCase().contains(_searchText.toLowerCase()) &&
          (_selectedSubcategory == 'View All' || _selectedSubcategory == '' || item['subcategory'] == _selectedSubcategory);
    }).toList();

    if (filteredFoodItems.isEmpty && _searchText.isNotEmpty) {
      _suggestedQuery = _findClosestMatch(_searchText, allFoodItems);
    } else {
      _suggestedQuery = null;
    }

    return Scaffold(
      drawer: _buildDrawer(),
      body: Stack(
        children: [
          // Scrollable content
          SingleChildScrollView(
            child: Column(
              children: [
                _buildAppBar(),
                _buildCarousel(),
                _buildBusynessStatus(),
                SizedBox(height: 15),
                _buildSubcategorySelector(),
                if (_suggestedQuery != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _searchText = _suggestedQuery!;
                        });
                      },
                      child: Text(
                        'Did you mean: $_suggestedQuery?',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                _buildFoodItemsGrid(filteredFoodItems),
                SizedBox(height: _bottomNavBarHeight + 20),
              ],
            ),
          ),

          // ✅ Draggable Cart Only
          Positioned(
            left: _cartPosition.dx,
            top: _cartPosition.dy,
            child: GestureDetector(
              onPanStart: (details) {
                setState(() {
                  _isCartDragging = true;
                });
              },
              onPanUpdate: (details) {
                setState(() {
                  _cartPosition += details.delta;
                });
              },
              onPanEnd: (details) {
                setState(() {
                  _isCartDragging = false;
                  final size = MediaQuery.of(context).size;
                  if (_cartPosition.dx < size.width / 2) {
                    _cartPosition = Offset(20, _cartPosition.dy);
                  } else {
                    _cartPosition = Offset(size.width - 80, _cartPosition.dy);
                  }
                });
              },
              child: PersistentShoppingCart().showCartItemCountWidget(
                cartItemCountWidgetBuilder: (itemCount) => badges.Badge(
                  badgeContent: Text(
                    '$itemCount',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  position: badges.BadgePosition.topEnd(top: -6, end: -6),
                  showBadge: itemCount > 0,
                  child: FloatingActionButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => CartScreen()),
                      );
                    },
                    backgroundColor: AppColors.themeColor,
                    child: Icon(CupertinoIcons.shopping_cart, color: Colors.white),
                    tooltip: 'View Cart',
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  @override
  Widget _buildBusynessStatus() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: _statusColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _statusColor, width: 1),
      ),
      child: _isLoadingStatus
          ? Center(
        child: SizedBox(
          width: 25, // Set width of the CircularProgressIndicator
          height: 25, // Set height of the CircularProgressIndicator
          child: CircularProgressIndicator(
            color: _statusColor,
            strokeWidth: 1.5,
          ),
        ),
      )
          : Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.group, color: _statusColor),
          SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Cafeteria Status: $_cafeteriaStatus',
                style: TextStyle(
                  color: _statusColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),

            ],
          ),
        ],
      ),
    );
  }




  String _selectedItem = 'Menu'; // Default selected item

  Widget _buildDrawer() {
    return ClipRRect(
      borderRadius: BorderRadius.horizontal(right: Radius.circular(50)),
      child: Drawer(
        backgroundColor: Colors.white,
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: AppColors.themeColor),
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 35,
                      backgroundImage: AssetImage('assets/images/neduet.webp'),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Welcome to NED QuickServe!',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Good food, good mood, every day!',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildDrawerItem(CupertinoIcons.doc_plaintext, 'Menu', MenuScreen()),
                  _buildDrawerItem(Icons.history, 'Order History', OrderHistory()),
                  _buildDrawerItem(Icons.favorite, 'Favourites', FavouritesPage(allFoodItems: allFoodItems)),
                  _buildDrawerItem(Icons.person, 'Profile', ProfileScreen()),
                  Divider(),
                  _buildDrawerItem(CupertinoIcons.info, 'About Us', AboutUsScreen()),
                  _buildDrawerItem(CupertinoIcons.phone_fill, 'Contact Us', ContactUsScreen()),
                  _buildDrawerItem(Icons.exit_to_app, 'Logout', UserTypeScreen()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, Widget destination) {
    bool isSelected = _selectedItem == title;

    return GestureDetector(
      onTap: () {
        _selectedItem = title;
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => destination),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? Colors.grey[200] : Colors.transparent,
        ),
        child: Row(
          children: [
            if (isSelected)
              Container(
                width: 5,
                height: 40,
                color: AppColors.themeColor, // Vertical selection indicator
              ),
            Expanded(
              child: ListTile(
                leading: Icon(icon, color: AppColors.themeColor),
                title: Text(
                  title,
                  style: TextStyle(
                    color: isSelected ? AppColors.themeColor :AppColors.darkGrey,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        color: AppColors.themeColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Builder(
                  builder: (context) => IconButton(
                    icon: Icon(Icons.menu, color: AppColors.whiteColor),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      'Explore the Menu',
                      style: TextStyle(
                        color: AppColors.whiteColor,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                PersistentShoppingCart().showCartItemCountWidget(
                  cartItemCountWidgetBuilder: (itemCount) => Stack(
                    children: [
                      IconButton(
                        icon: Icon(CupertinoIcons.cart, color: AppColors.whiteColor),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => CartScreen()),
                          );
                        },
                      ),
                      if (itemCount > 0)
                        Positioned(
                          right: 0,
                          child: CircleAvatar(
                            radius: 8,
                            backgroundColor: AppColors.redColor,
                            child: Text(
                              '$itemCount',
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColors.whiteColor,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Column(
              children: [
                TextField(
                  focusNode: _searchFocusNode,
                  decoration: InputDecoration(
                    hintText: 'Search for your favourite item',
                    filled: true,
                    fillColor: AppColors.whiteColor,
                    contentPadding: EdgeInsets.symmetric(horizontal: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: Icon(Icons.search, color: AppColors.greycolor),
                  ),
                  onChanged: (text) {
                    setState(() {
                      _searchText = text;
                      if (text.isNotEmpty) {
                        _searchSuggestions = _getSearchSuggestions(text);
                        _noResultsFound = _searchSuggestions.isEmpty;
                        _showSearchSuggestions = true;
                      } else {
                        _noResultsFound = false;
                        _showSearchSuggestions = false;
                      }
                    });
                  },
                  onTap: () {
                    if (_searchText.isNotEmpty) {
                      setState(() {
                        _searchSuggestions = _getSearchSuggestions(_searchText);
                        _noResultsFound = _searchSuggestions.isEmpty;
                        _showSearchSuggestions = true;
                      });
                    }
                  },
                ),
                if (_showSearchSuggestions)
                  Container(
                    margin: EdgeInsets.only(top: 5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 5,
                          offset: Offset(0, 2),
                        )
                      ],
                    ),
                    constraints: BoxConstraints(
                      maxHeight: 200,
                      minHeight: _noResultsFound ? 50 : 0,
                    ),
                    child: _noResultsFound
                        ? Center(
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: Text(
                          'This item is not in our menu',
                          style: TextStyle(

                            color: Colors.grey,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    )
                        : ListView.builder(
                        padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: _searchSuggestions.length,
                        itemBuilder: (context, index) {
                          final item = _searchSuggestions[index];
                          return Column(
                            children: [
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      _searchText = item['name'];
                                      _showSearchSuggestions = false;
                                      _searchFocusNode.unfocus();
                                    });
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => FoodDetailScreen(
                                          name: item['name'],
                                          price: double.tryParse(item['price'].toString()) ?? 0.0,
                                          imagePath: item['imagePath'] ?? '',
                                          description: item['description'] ?? '',
                                          subcategory: item['subcategory'] ?? '',
                                          category: item['category'] ?? '',
                                        ),
                                      ),
                                    );
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.search,
                                          color: AppColors.greycolor,
                                          size: 20,
                                        ),
                                        SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            item['name'],
                                            style: TextStyle(
                                              color: Colors.black87,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              if (index < _searchSuggestions.length - 1)
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 16),
                                  child: Divider(
                                    height: 1,
                                    thickness: 1,
                                    color: Colors.grey[300],
                                  ),
                                ),
                            ],
                          );
                        }

                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildCarousel() {
    return Column(
      children: [
        Container(
          width: double.infinity, // Full width
          height: 200.0,
          child: FlutterCarousel(
            options: FlutterCarouselOptions(
              aspectRatio: 2.1,
              enlargeCenterPage: true,
              viewportFraction: 0.9,
              autoPlay: true,
              autoPlayInterval: Duration(seconds: 3),
              showIndicator: true,
              // Enables indicator
              slideIndicator: CircularSlideIndicator(
                slideIndicatorOptions: SlideIndicatorOptions(
                  indicatorRadius: 3.0,
                  // Dot size
                  itemSpacing: 12,
                  // Space between dots
                  currentIndicatorColor: AppColors.white.withOpacity(0.4),
                  // Active dot color
                  indicatorBackgroundColor: Colors.grey.withOpacity(0.4),
                  // Inactive dot color
                  alignment: Alignment.bottomCenter,
                  // Position at the bottom
                  padding: EdgeInsets.only(
                      bottom: 24.0), // Adjust bottom margin
                ),
              ),
            ),
            items: [
              for (var imagePath in [
                '${AppImages.localImage}${AppImages.carousel1}',
                '${AppImages.localImage}${AppImages.carousel2}',
                '${AppImages.localImage}${AppImages.carousel3}',

              ])
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: Image.asset(
                      imagePath, fit: BoxFit.cover, width: double.infinity),
                ),
            ],
          ),
        ),
        // SizedBox(height: 5.0), // Space below the carousel
      ],
    );
  }


  Widget _buildSubcategorySelector() {
    List<String> currentSubcategories = [
      'View All',
      ...subcategories[categories[_selectedCategoryIndex]]!,
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(
            currentSubcategories.length,
                (index) {
              String subcategory = currentSubcategories[index];
              return GestureDetector(
                onTap: () => setState(() => _selectedSubcategory = subcategory, ),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  margin: EdgeInsets.symmetric(horizontal: 5),
                  decoration: BoxDecoration(
                    color: _selectedSubcategory == subcategory
                        ? AppColors.themeColor
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _selectedSubcategory == subcategory
                          ? AppColors.themeColor
                          : AppColors.greycolor,
                    ),
                  ),
                  child: Text(
                    subcategory,
                    style: TextStyle(
                      color: _selectedSubcategory == subcategory
                          ? AppColors.whiteColor
                          : AppColors.b54,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }


  Widget _buildFoodItemsGrid(List<Map<String, dynamic>> filteredFoodItems) {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 15,
        crossAxisSpacing: 15,
        childAspectRatio: 0.7,
      ),
      itemCount: filteredFoodItems.length,
      itemBuilder: (context, index) {
        var item = filteredFoodItems[index];

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
                      content: Text(
                        '${item['name']} added to favorites',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(fontSize: 14),
                      ),
                      duration: Duration(seconds: 2),
                      backgroundColor: AppColors.themeColor,
                      behavior: SnackBarBehavior.floating,
                      action: SnackBarAction(
                        label: 'View',
                        textColor: Colors.white,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FavouritesPage(allFoodItems: allFoodItems),
                            ),
                          );
                        },
                      ),
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
                      content: Text('Product already added to cart!',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(fontSize: 14),),
                      duration: Duration(seconds: 2),
                      backgroundColor: AppColors.themeColor,
                      behavior: SnackBarBehavior.floating,
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
                  // After successfully adding to cart
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${item['name']} added to cart!',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(fontSize: 14),),
                      duration: Duration(seconds: 2),
                      backgroundColor: AppColors.themeColor,
                      behavior: SnackBarBehavior.floating,

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
    );
  }





  BottomNavigationBar _buildBottomNavigationBar() {
    return BottomNavigationBar(
      selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
      selectedItemColor: AppColors.themeColor,
      unselectedItemColor: AppColors.greycolor,
      selectedIconTheme: IconThemeData(color: AppColors.themeColor, size: 30),
      unselectedIconTheme: IconThemeData(color: AppColors.greycolor, size: 20),
      currentIndex: _selectedCategoryIndex,
      onTap: (index) {
        setState(() {
          _selectedCategoryIndex = index;
          _selectedSubcategory = subcategories[categories[index]]!.first;
        });
      },
      items: [
        BottomNavigationBarItem(
            icon: Icon(Icons.lunch_dining), label: 'Fast Food'),
        BottomNavigationBarItem(icon: Icon(Symbols.grocery), label: 'Snacks'),
        BottomNavigationBarItem(
            icon: Icon(Symbols.egg_alt), label: 'Breakfast'),
      ],
    );
  }
}