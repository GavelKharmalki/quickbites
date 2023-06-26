import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:food/consts/firebase_consts.dart';
import 'package:food/models/products_model.dart';
import 'package:food/providers/cart_provider.dart';
import 'package:food/providers/wishlist_provider.dart';
import 'package:food/widgets/heart_btn.dart';
import 'package:food/widgets/price_widget.dart';
import 'package:food/widgets/text_widget.dart';
import 'package:provider/provider.dart';

import '../inner_screens/product_details_screen.dart';
import '../providers/products_provider.dart';
import '../providers/viewed_prod_provider.dart';
import '../services/global.dart';
import '../services/utils.dart';

class OnSaleWidget extends StatefulWidget {
  const OnSaleWidget({Key? key}) : super(key: key);

  @override
  State<OnSaleWidget> createState() => _OnSaleWidgetState();
}

class _OnSaleWidgetState extends State<OnSaleWidget> {
  @override
  Widget build(BuildContext context) {
    final Color color = Utils(context: context).color;
    final theme = Utils(context: context).getTheme;
    Size size = Utils(context: context).getScreenSize;

    //Providers
    final productsModel = Provider.of<ProductModel>(context);
    final cartProvider = Provider.of<CartProvider>(context);
    final wishlistProvider = Provider.of<WishlistProvider>(context);
    final viewedProdProvider = Provider.of<ViewedProdProvider>(context);
    bool? _isInCart = cartProvider.getCartItems.containsKey(productsModel.id);
    bool? _isInWishlist =
        wishlistProvider.getWishlistItems.containsKey(productsModel.id);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: 150,
        child: Material(
          color: Theme.of(context).cardColor.withOpacity(0.9),
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              viewedProdProvider.addProductToHistory(
                  productId: productsModel.id);
              Navigator.pushNamed(context, ProductDetails.routeName,
                  arguments: productsModel.id);
              // GlobalMethods.navigateTo(
              //     context: context, routeName: ProductDetails.routeName);
            },
            child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    //mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FancyShimmerImage(
                            imageUrl: productsModel.imageUrl,
                            height: size.width * 0.24,
                            //height: size.width * 0.18,
                            width: size.width * 0.20,
                            boxFit: BoxFit.scaleDown,
                          ),
                          // Image.network(
                          //   'https://i.ibb.co/F0s3FHQ/Apricots.png',
                          //   //width: size.width * 0.22,
                          //   height: size.width * 0.18,
                          //   fit: BoxFit.fill,
                          // ),
                          Column(
                            children: [
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: _isInCart
                                        ? null
                                        : () async {
                                            final User? user =
                                                authInstance.currentUser;
                                            if (user == null) {
                                              GlobalMethods.errorDialog(
                                                  subtitle:
                                                      "No user found. Please login",
                                                  context: context);
                                              return;
                                            }
                                            await GlobalMethods.addToCart(
                                                productId: productsModel.id,
                                                quantity: 1,
                                                context: context);
                                            await cartProvider.fetchCart();
                                            // cartProvider.addProductsToCart(
                                            //     productId: productsModel.id,
                                            //     quantity: 1);
                                          },
                                    child: Icon(
                                      _isInCart
                                          ? Icons.shopping_bag
                                          : Icons.shopping_bag_outlined,
                                      size: 22,
                                      color: _isInCart ? Colors.green : color,
                                    ),
                                  ),
                                  HeartBtn(
                                    productId: productsModel.id,
                                    isInWishlist: _isInWishlist,
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              // TextWidget(
                              //   text: productsModel.isPiece ? 'Non-veg' : 'A',
                              //   color: color,
                              //   textSize: 16,
                              //   isTitle: false,
                              // ),
                            ],
                          )
                        ],
                      ),
                      Flexible(
                        flex: 4,
                        child: PriceWidget(
                            isOnSale: true,
                            price: productsModel.price,
                            salePrice: productsModel.salePrice,
                            textPrice: '1'),
                      ),
                      SizedBox(
                        height: 1,
                      ),
                      Flexible(
                        flex: 2,
                        child: TextWidget(
                            text: productsModel.title,
                            color: color,
                            textSize: 16,
                            isTitle: true),
                      ),
                      SizedBox(
                        height: 1,
                      ),
                    ])),
          ),
        ),
      ),
    );
  }
}
