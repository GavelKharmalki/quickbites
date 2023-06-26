import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:food/inner_screens/product_details_screen.dart';
import 'package:food/models/viewed_model.dart';
import 'package:food/services/global.dart';
import 'package:provider/provider.dart';
import '../../consts/firebase_consts.dart';
import '../../providers/cart_provider.dart';
import '../../providers/products_provider.dart';
import '../../services/utils.dart';
import '../../widgets/text_widget.dart';

class ViewedRecentlyWidget extends StatefulWidget {
  const ViewedRecentlyWidget({Key? key}) : super(key: key);

  @override
  _ViewedRecentlyWidgetState createState() => _ViewedRecentlyWidgetState();
}

class _ViewedRecentlyWidgetState extends State<ViewedRecentlyWidget> {
  @override
  Widget build(BuildContext context) {
    final viewedProdModel = Provider.of<ViewedProdModel>(context);
    final productProvider = Provider.of<ProductsProvider>(context);

    final getCurrProduct =
        productProvider.findProdByID(viewedProdModel.productId);

    num usedPrice = getCurrProduct.isOnSale
        ? getCurrProduct.salePrice
        : getCurrProduct.price;

    final cartProvider = Provider.of<CartProvider>(context);
    bool? _isInCart = cartProvider.getCartItems.containsKey(getCurrProduct.id);

    final Color color = Utils(context: context).color;
    Size size = Utils(context: context).getScreenSize;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () {
          // GlobalMethods.navigateTo(
          //     context: context, routeName: ProductDetails.routeName);
          Navigator.pushNamed(context, ProductDetails.routeName,
              arguments: getCurrProduct.id);
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FancyShimmerImage(
              imageUrl: getCurrProduct.imageUrl,
              boxFit: BoxFit.fill,
              height: size.width * 0.27,
              width: size.width * 0.25,
            ),
            const SizedBox(
              width: 12,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    getCurrProduct.title,
                    maxLines: 1,
                    style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        overflow: TextOverflow.ellipsis),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  TextWidget(
                    text: '\u{20B9} ${usedPrice.toStringAsFixed(2)}',
                    color: color,
                    textSize: 20,
                    isTitle: false,
                  ),
                ],
              ),
            ),
            //const Spacer(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Material(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.green,
                    child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: _isInCart
                            ? null
                            : () async {
                                final User? user = authInstance.currentUser;
                                if (user == null) {
                                  GlobalMethods.errorDialog(
                                      subtitle: "No user found. Please login",
                                      context: context);
                                  return;
                                }
                                await GlobalMethods.addToCart(
                                    productId: getCurrProduct.id,
                                    quantity: 1,
                                    context: context);
                                await cartProvider.fetchCart();
                                // cartProvider.addProductsToCart(
                                //     productId: getCurrProduct.id, quantity: 1);
                              },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(
                            _isInCart ? Icons.check : Icons.add,
                            color: Colors.white,
                            size: 20,
                          ),
                        )),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
