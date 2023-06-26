import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

import '../consts/firebase_consts.dart';
import '../models/cart_model.dart';
import '../models/wishlist_model.dart';

class WishlistProvider with ChangeNotifier {
  //Initialize empty list/map
  Map<String, WishlistModel> _wishlistItems = {};

  //Return the items when added to _cartItems
  Map<String, WishlistModel> get getWishlistItems {
    return _wishlistItems;
  }

  //Adding product to cart
  // void addRemoveProductToWishlist({required String productId}) {
  //   if (_wishlistItems.containsKey(productId)) {
  //     removeOneItem(productId);
  //   } else {
  //     _wishlistItems.putIfAbsent(
  //         productId,
  //         () => WishlistModel(
  //             id: DateTime.now().toString(), productId: productId));
  //   }
  //   notifyListeners();
  // }

  final userCollection = FirebaseFirestore.instance.collection('users');

  Future<void> fetchWishlist() async {
    final User? user = authInstance.currentUser;
    final DocumentSnapshot userDoc = await userCollection.doc(user!.uid).get();
    if (userDoc == null) {
      return;
    }
    final leng = userDoc.get('userWishlist').length;
    for (int i = 0; i < leng; i++) {
      _wishlistItems.putIfAbsent(
          userDoc.get('userWishlist')[i]['productId'],
          () => WishlistModel(
                id: userDoc.get('userWishlist')[i]['wishlistId'],
                productId: userDoc.get('userWishlist')[i]['productId'],
              ));
    }
    notifyListeners();
  }

  //Remove wishlist item
  Future<void> removeOneItem({
    required String wishlistId,
    required String productId,
  }) async {
    final User? user = authInstance.currentUser;
    await userCollection.doc(user!.uid).update({
      'userWishlist': FieldValue.arrayRemove([
        {
          'wishlistId': wishlistId,
          'productId': productId,
        }
      ])
    });
    _wishlistItems.remove(productId);
    await fetchWishlist();
    notifyListeners();
  }

  //Clear cart
  Future<void> clearOnlineWishlist() async {
    final User? user = authInstance.currentUser;
    await userCollection.doc(user!.uid).update({
      'userWishlist': [],
    });
    _wishlistItems.clear();
    notifyListeners();
  }

  void clearLocalWishlist() {
    _wishlistItems.clear();
    notifyListeners();
  }
}
