import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:food/models/products_model.dart';
import 'package:food/providers/cart_provider.dart';
import 'package:food/providers/products_provider.dart';
import 'package:food/providers/viewed_prod_provider.dart';
import 'package:food/services/global.dart';
import 'package:food/widgets/price_widget.dart';
import 'package:food/widgets/text_widget.dart';
import 'package:provider/provider.dart';
import '../consts/firebase_consts.dart';
import '../inner_screens/product_details_screen.dart';
import '../providers/wishlist_provider.dart';
import '../services/utils.dart';
import 'heart_btn.dart';

class FeedsWidget extends StatefulWidget {
  const FeedsWidget({Key? key}) : super(key: key);

  @override
  State<FeedsWidget> createState() => _FeedsWidgetState();
}

class _FeedsWidgetState extends State<FeedsWidget> {
  final _quantityTextController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    _quantityTextController.text = '1';
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _quantityTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = Utils(context: context).getScreenSize;
    final Color color = Utils(context: context).color;
    final productsModel = Provider.of<ProductModel>(context);
    final cartProvider = Provider.of<CartProvider>(context);
    final wishlistProvider = Provider.of<WishlistProvider>(context);
    bool? _isInCart = cartProvider.getCartItems.containsKey(productsModel.id);
    bool? _isInWishlist =
        wishlistProvider.getWishlistItems.containsKey(productsModel.id);
    final viewedProdProvider = Provider.of<ViewedProdProvider>(context);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Material(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).cardColor,
        //color: Colors.red,
        child: InkWell(
          onTap: () {
            viewedProdProvider.addProductToHistory(productId: productsModel.id);
            Navigator.pushNamed(context, ProductDetails.routeName,
                arguments: productsModel.id);
            // GlobalMethods.navigateTo(
            //     context: context, routeName: ProductDetails.routeName);
          },
          borderRadius: BorderRadius.circular(12),
          child: Column(
            children: [
              FancyShimmerImage(
                //width: size.width * 0.35,
                //height: size.height * 0.18,
                height: size.height * 0.19,
                width: double.infinity,
                imageUrl: productsModel.imageUrl,
                boxFit: BoxFit.scaleDown,
              ),
              // Image.network(
              //   'https://i.ibb.co/F0s3FHQ/Apricots.png',
              //   //width: size.width * 0.22,
              //   height: size.width * 0.2,
              //   fit: BoxFit.fill,
              // ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        flex: 6,
                        child: TextWidget(
                          text: productsModel.title,
                          //text: 'ps margheritasssss',
                          color: color,
                          textSize: 20,
                          maxLines: 1,
                          isTitle: true,
                        ),
                      ),
                      Flexible(
                          flex: 1,
                          child: HeartBtn(
                            productId: productsModel.id,
                            isInWishlist: _isInWishlist,
                          )),
                    ]),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      flex: 2,
                      child: PriceWidget(
                          isOnSale: productsModel.isOnSale,
                          price: productsModel.price,
                          salePrice: productsModel.salePrice,
                          textPrice: _quantityTextController.text),
                    ),
                    const SizedBox(
                      width: 3,
                    ),
                    Flexible(
                      child: Row(
                        //crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          //Veg non veg here?
                          //Flexible(
                          //flex: 3,
                          // child: TextWidget(
                          //   text: productsModel.isPiece ? 'Veg' : 'Non-veg',
                          //   color: color,
                          //   textSize: 12,
                          //   isTitle: false,
                          // ),
                          // child: Icon(
                          //     productsModel.isPiece
                          //         ? Icons.energy_savings_leaf_sharp
                          //         : Icons.ac_unit,
                          //     color:
                          //         productsModel.isPiece ? Colors.red : color),
                          //),
                          // const SizedBox(width: 5),
                          // Flexible(
                          //     flex: 2,
                          //     child: TextFormField(
                          //       controller: _quantityTextController,
                          //       key: const ValueKey('10'),
                          //       style: TextStyle(color: color, fontSize: 18),
                          //       keyboardType: TextInputType.number,
                          //       maxLines: 1,
                          //       enabled: true,
                          //       onChanged: (value) {
                          //         setState(() {});
                          //       },
                          //       inputFormatters: [
                          //         FilteringTextInputFormatter.allow(
                          //           RegExp('[0-9]'),
                          //         ),
                          //       ],
                          //     )),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              Spacer(),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: _isInCart
                      ? null
                      : () async {
                          // if (_isInCart) {
                          //   print(size);
                          //   return;
                          final User? user = authInstance.currentUser;
                          if (user == null) {
                            GlobalMethods.errorDialog(
                                subtitle: "No user found. Please login",
                                context: context);
                            return;
                          } else {
                            await GlobalMethods.addToCart(
                                productId: productsModel.id,
                                quantity:
                                    int.parse(_quantityTextController.text),
                                context: context);
                            await cartProvider.fetchCart();
                            // cartProvider.addProductsToCart(
                            //     productId: productsModel.id,
                            //     quantity: int.parse(_quantityTextController.text));
                          }
                        },
                  child: TextWidget(
                    text: _isInCart ? 'Item in cart' : 'Add to Cart',
                    color: color,
                    textSize: 20,
                    maxLines: 1,
                  ),
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(Theme.of(context).cardColor),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(12.0),
                          bottomRight: Radius.circular(12.0),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
