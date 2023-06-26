import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:food/consts/firebase_consts.dart';
import 'package:food/providers/wishlist_provider.dart';
import 'package:food/services/global.dart';
import 'package:provider/provider.dart';
import '../providers/products_provider.dart';
import '../services/utils.dart';

class HeartBtn extends StatefulWidget {
  const HeartBtn(
      {Key? key, required this.productId, required this.isInWishlist})
      : super(key: key);
  final String productId;
  final bool? isInWishlist;
  @override
  State<HeartBtn> createState() => _HeartBtnState();
}

class _HeartBtnState extends State<HeartBtn> {
  bool loading = false;
  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductsProvider>(context);
    final getCurrProduct = productProvider.findProdByID(widget.productId);
    final Color color = Utils(context: context).color;
    final wishlistProvider = Provider.of<WishlistProvider>(context);
    //To check if user is registered or not
    final User? user = authInstance.currentUser;

    //
    return GestureDetector(
      onTap: () async {
        setState(() {
          loading = true;
        });
        try {
          final User? user = authInstance.currentUser;

          if (user == null) {
            GlobalMethods.errorDialog(
                subtitle: 'No user found, Please login first',
                context: context);
            return;
          }
          if (widget.isInWishlist == false && widget.isInWishlist != null) {
            await GlobalMethods.addToWishlist(
                productId: widget.productId, context: context);
          } else {
            await wishlistProvider.removeOneItem(
                wishlistId:
                    wishlistProvider.getWishlistItems[getCurrProduct.id]!.id,
                productId: widget.productId);
          }
          await wishlistProvider.fetchWishlist();
          setState(() {
            loading = false;
          });
        } catch (error) {
          GlobalMethods.errorDialog(subtitle: '$error', context: context);
        } finally {
          setState(() {
            loading = false;
          });
        }
        // print('user id is ${user.uid}');
        // wishlistProvider.addRemoveProductToWishlist(productId: productId);
      },
      child: loading
          ? const Padding(
              padding: EdgeInsets.all(8.0),
              child: SizedBox(
                  height: 5, width: 5, child: CircularProgressIndicator()),
            )
          : Icon(
              widget.isInWishlist != null && widget.isInWishlist == true
                  ? Icons.favorite
                  : Icons.favorite_border,
              size: 22,
              color: widget.isInWishlist != null && widget.isInWishlist == true
                  ? Colors.red
                  : color,
            ),
    );
  }
}
