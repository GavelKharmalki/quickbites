import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:food/providers/wishlist_provider.dart';
import 'package:food/services/global.dart';
import 'package:food/widgets/heart_btn.dart';
import 'package:food/widgets/text_widget.dart';
import 'package:provider/provider.dart';

import '../../inner_screens/product_details_screen.dart';
import '../../models/wishlist_model.dart';
import '../../providers/products_provider.dart';
import '../../services/utils.dart';

class WishlistWidget extends StatelessWidget {
  const WishlistWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final wishlistModel = Provider.of<WishlistModel>(context);
    final productProvider = Provider.of<ProductsProvider>(context);
    final wishlistProvider = Provider.of<WishlistProvider>(context);
    final getCurrProduct =
        productProvider.findProdByID(wishlistModel.productId);

    final Color color = Utils(context: context).color;
    Size size = Utils(context: context).getScreenSize;
    num usedPrice = getCurrProduct.isOnSale
        ? getCurrProduct.salePrice
        : getCurrProduct.price;
    bool? _isInWishlist =
        wishlistProvider.getWishlistItems.containsKey(getCurrProduct.id);
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, ProductDetails.routeName,
              arguments: wishlistModel.productId);
        },
        child: Container(
            height: size.height * 0.20,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              border: Border.all(color: color, width: 1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Flexible(
                  flex: 2,
                  child: Container(
                    margin: const EdgeInsets.only(left: 8),
                    width: size.width * 0.2,
                    height: size.width * 0.25,
                    child: FancyShimmerImage(
                      //width: size.width * 0.2,
                      imageUrl: getCurrProduct.imageUrl,
                      boxFit: BoxFit.scaleDown,
                    ),
                    // Image.network(
                    //   'https://i.ibb.co/F0s3FHQ/Apricots.png',
                    //   //width: size.width * 0.22,
                    //   //height: size.width * 0.18,
                    //   fit: BoxFit.fill,
                    // ),
                  ),
                ),
                Flexible(
                  flex: 3,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    //crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                onPressed: () {},
                                icon: Icon(Icons.shopping_bag_outlined,
                                    color: color),
                              ),
                              HeartBtn(
                                productId: getCurrProduct.id,
                                isInWishlist: _isInWishlist,
                              ),
                            ],
                          ),
                        ),
                      ),
                      TextWidget(
                          text: getCurrProduct.title,
                          color: color,
                          textSize: 20,
                          maxLines: 1,
                          isTitle: true),
                      const SizedBox(
                        height: 5,
                      ),
                      TextWidget(
                          text: '\u20B9 ${usedPrice.toStringAsFixed(2)}',
                          color: color,
                          textSize: 18,
                          maxLines: 2,
                          isTitle: true),
                    ],
                  ),
                )
              ],
            )),
      ),
    );
  }
}
