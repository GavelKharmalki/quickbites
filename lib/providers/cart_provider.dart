import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

import '../consts/firebase_consts.dart';
import '../models/cart_model.dart';

class CartProvider with ChangeNotifier {
  //Initialize empty list/map
  Map<String, CartModel> _cartItems = {};

  //Return the items when added to _cartItems
  Map<String, CartModel> get getCartItems {
    return _cartItems;
  }

  //Adding product to cart
  // void addProductsToCart({
  //   required String productId,
  //   required int quantity,
  // }) {
  //   _cartItems.putIfAbsent(
  //     productId,
  //     () => CartModel(
  //       id: DateTime.now().toString(),
  //       productId: productId,
  //       quantity: quantity,
  //     ),
  //   );
  //   notifyListeners();
  // }
  //Fetch user product from cart

  final userCollection = FirebaseFirestore.instance.collection('users');
  Future<void> fetchCart() async {
    final User? user = authInstance.currentUser;
    final DocumentSnapshot userDoc = await userCollection.doc(user!.uid).get();
    if (userDoc == null) {
      return;
    }
    final leng = userDoc.get('userCart').length;
    for (int i = 0; i < leng; i++) {
      _cartItems.putIfAbsent(
          userDoc.get('userCart')[i]['productId'],
          () => CartModel(
                id: userDoc.get('userCart')[i]['cartId'],
                productId: userDoc.get('userCart')[i]['productId'],
                quantity: userDoc.get('userCart')[i]['quantity'],
              ));
    }
    notifyListeners();
  }

//Decrease quantity by 1
  void reduceQuantityByOne(String productId) {
    _cartItems.update(
      productId,
      (value) => CartModel(
        id: value.id,
        productId: productId,
        quantity: value.quantity - 1,
      ),
    );
    notifyListeners();
  }

//Increase quantity by 1
  void increaseQuantityByOne(String productId) {
    _cartItems.update(
      productId,
      (value) => CartModel(
        id: value.id,
        productId: productId,
        quantity: value.quantity + 1,
      ),
    );
    notifyListeners();
  }

  //Remove item from Cart
  Future<void> removeOneItem(
      {required String cartId,
      required String productId,
      required int quantity}) async {
    final User? user = authInstance.currentUser;
    await userCollection.doc(user!.uid).update({
      'userCart': FieldValue.arrayRemove([
        {
          'cartId': cartId,
          'productId': productId,
          'quantity': quantity,
        }
      ])
    });
    _cartItems.remove(productId);
    await fetchCart();
    notifyListeners();
  }

  //Clear cart
  Future<void> clearOnlineCart() async {
    final User? user = authInstance.currentUser;
    await userCollection.doc(user!.uid).update({
      'userCart': [],
    });
    _cartItems.clear();
    notifyListeners();
  }

  void clearlocalCart() {
    _cartItems.clear();
    notifyListeners();
  }
}
