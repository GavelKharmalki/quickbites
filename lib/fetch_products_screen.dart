import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:food/consts/consts.dart';
import 'package:food/consts/firebase_consts.dart';
import 'package:food/providers/cart_provider.dart';
import 'package:food/providers/orders_provider.dart';
import 'package:food/providers/orders_provider.dart';
import 'package:food/providers/orders_provider.dart';
import 'package:food/providers/products_provider.dart';

import 'package:food/providers/products_provider.dart';
import 'package:food/providers/wishlist_provider.dart';
import 'package:food/screens/btm_bar.dart';
import 'package:provider/provider.dart';

class FetchScreen extends StatefulWidget {
  const FetchScreen({Key? key}) : super(key: key);

  @override
  State<FetchScreen> createState() => _FetchScreenState();
}

class _FetchScreenState extends State<FetchScreen> {
  List<String> images = Consts.authImagesPaths;
  @override
  void initState() {
    images.shuffle();
    // TODO: implement initState
    Future.delayed(const Duration(microseconds: 5), () async {
      final productsProvider =
          Provider.of<ProductsProvider>(context, listen: false);
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      final wishlistProvider =
          Provider.of<WishlistProvider>(context, listen: false);
      final ordersProvider =
          Provider.of<OrdersProvider>(context, listen: false);
      final User? user = authInstance.currentUser;
      if (user == null) {
        await productsProvider.fetchProducts();
        cartProvider.clearlocalCart();
        wishlistProvider.clearLocalWishlist();
        ordersProvider.clearLocalOrders();
      } else {
        cartProvider.clearlocalCart();
        wishlistProvider.clearLocalWishlist();
        ordersProvider.clearLocalOrders();
        await productsProvider.fetchProducts();
        await cartProvider.fetchCart();
        await wishlistProvider.fetchWishlist();
      }

      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => const BottomBarScreen(),
      ));
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            //'assets/images/landing/buyfood.jpg',
            images[0],
            fit: BoxFit.cover,
            height: double.infinity,
          ),
          Container(
            color: Colors.black.withOpacity(0.7),
          ),
          Center(
            child: CircularProgressIndicator(color: Colors.white54),
          )
        ],
      ),
    );
  }
}
