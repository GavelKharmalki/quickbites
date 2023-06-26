import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:food/models/products_model.dart';
import 'package:provider/provider.dart';

class ProductsProvider with ChangeNotifier {
  static List<ProductModel> _productsList = [];
  //Fetch products from db
  Future<void> fetchProducts() async {
    await FirebaseFirestore.instance
        .collection('products')
        .get()
        .then((QuerySnapshot productSnapshot) {
      _productsList = [];
      // _productsList.clear();
      productSnapshot.docs.forEach((element) {
        _productsList.insert(
            0,
            ProductModel(
              id: element.get('id'),
              title: element.get('title'),
              description: element.get('description'),
              imageUrl: element.get('imageUrl'),
              productCategoryName: element.get('productCategoryName'),
              price: double.parse(element.get('price')),
              salePrice: (element.get('salePrice')).toInt(),
              isOnSale: element.get('isOnSale'),
              //isPiece: element.get('isVeg'),
            ));
      });
    });
    notifyListeners();
  }

  List<ProductModel> get getProducts {
    return _productsList;
  }

  List<ProductModel> get getOnSaleProducts {
    return _productsList.where((element) => element.isOnSale).toList();
  }

  ProductModel findProdByID(String productId) {
    return _productsList.firstWhere((element) => element.id == productId);
  }

//Find by category name
  List<ProductModel> findByCategory(String categoryName) {
    List<ProductModel> _categoryList = _productsList
        .where((element) => element.productCategoryName
            .toLowerCase()
            .contains(categoryName.toLowerCase()))
        .toList();
    return _categoryList;
  }

//Search products
  List<ProductModel> searchQuery(String searchText) {
    List<ProductModel> _searchList = _productsList
        .where(
          (element) => element.title.toLowerCase().contains(
                searchText.toLowerCase(),
              ),
        )
        .toList();
    return _searchList;
  }

  //static final List<ProductModel> _productsList = [
  //   ProductModel(
  //     id: '1234',
  //     title: 'Fried Noodles',
  //     description:
  //         "For the unacquainted, the 1975 is one of the most innovative, influential and divisive bands of the past decade. They tour arenas all over the world and Matty can’t walk down the street in any major British city without getting mobbed by fans. For all intents and purposes, he is a superstar, even though his band exists slightly outside the mainstream. For the unacquainted, For the unacquainted, the 1975 is one of the most innovative, influential and divisive bands of the past decade. They tour arenas all over the world and Matty can’t walk down the street in any major British city without getting mobbed by fans. For all intents and purposes, he is a superstar, even though his band exists slightly outside the mainstream. For the unacquainted,XD  ",
  //     //imageUrl: 'https://i.ibb.co/F0s3FHQ/Apricots.png',
  //     imageUrl:
  //         'https://rasamalaysia.com/wp-content/uploads/2021/06/soba-noodle-soup1.jpg',
  //     productCategoryName: 'Noodles',
  //     price: 100,
  //     salePrice: 50,
  //     isOnSale: true,
  //     isPiece: false,
  //   ),
  //   ProductModel(
  //     id: '2344',
  //     title: 'Ramen noodles',
  //     description: 'description',
  //     price: 0.88,
  //     salePrice: 0.5,
  //     //imageUrl: 'https://i.ibb.co/9VKXw5L/Avocat.png',
  //     imageUrl:
  //         'https://rasamalaysia.com/wp-content/uploads/2014/12/sriracha_soba_noodles_thumb-166x166.jpg',
  //     productCategoryName: 'Noodles',
  //     isOnSale: false,
  //     isPiece: true,
  //   ),
  //   ProductModel(
  //     id: 'Pizza',
  //     title: 'Pizza',
  //     description: 'description',
  //     price: 1.22,
  //     salePrice: 0.7,
  //     //imageUrl: 'https://i.ibb.co/c6w5zrC/Black-Grapes-PNG-Photos.png',
  //     imageUrl:
  //         'https://rasamalaysia.com/wp-content/uploads/2012/06/chicken-tikka-masala-pizza-thumb-300x300.jpg',
  //     productCategoryName: 'Pizza',
  //     isOnSale: true,
  //     isPiece: false,
  //   ),
  //   ProductModel(
  //     id: '7',
  //     title: 'Butter Chicken',
  //     description: 'description ahnjkdahkjsdkjasjkasjndsajnasmnsd,m',
  //     price: 1.5,
  //     salePrice: 0.5,
  //     //imageUrl: 'https://i.ibb.co/HKx2bsp/Fresh-green-grape.png',
  //     imageUrl:
  //         'https://rasamalaysia.com/wp-content/uploads/2019/11/chicken-tenders.jpg',
  //     productCategoryName: 'Chicken',
  //     isOnSale: true,
  //     isPiece: false,
  //   ),
  // ];
}
