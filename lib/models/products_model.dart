import 'package:flutter/foundation.dart';

class ProductModel with ChangeNotifier {
  final String id, title, description, imageUrl, productCategoryName;
  final double price;
  final int salePrice;
  final bool isOnSale;
  //isPiece;

  ProductModel({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.productCategoryName,
    required this.price,
    required this.salePrice,
    required this.isOnSale,
    //required this.isPiece
  });
}
