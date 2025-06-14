import 'package:flutter/material.dart';
import '../../utils/colors.dart';

class ProductCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;
  final VoidCallback onAddToCart;
  final VoidCallback onTap;

  const ProductCard({
    Key? key,
    required this.item,
    required this.isFavorite,
    required this.onFavoriteToggle,
    required this.onAddToCart,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.grey, width: 1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                  child: Image.asset(
                    item['imagePath'] ?? '',
                    fit: BoxFit.cover,
                    height: 130,
                    width: double.infinity,
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: onFavoriteToggle,
                    child: Container(
                      height: 28,
                      width: 28,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4,
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? AppColors.accent : Colors.black54,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['name'] ?? 'Unknown',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12.5,
                            color: AppColors.black,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4),
                        Text(
                          _getShortDescription(item['description']),
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.greycolor,
                          ),
                        ),
                        SizedBox(height: 2),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Text(
                                'Rs. ${item['price'].toStringAsFixed(2) ?? 'N/A'}',
                                style: TextStyle(
                                  color: AppColors.themeColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(width: 8),
                            GestureDetector(
                              onTap: onAddToCart,
                              child: Container(
                                height: 30,
                                width: 30,
                                decoration: BoxDecoration(
                                  color: AppColors.themeColor,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 4,
                                      offset: Offset(2, 2),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.add,
                                    color: AppColors.white,
                                    size: 22,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  String _getShortDescription(String? description) {
    if (description == null || description.isEmpty) return '';
    List<String> words = description.split(' ');
    return words.length > 2 ? '${words[0]} ${words[1]}...' : description;
  }
}
