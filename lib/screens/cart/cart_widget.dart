import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:food/providers/cart_provider.dart';
import 'package:food/widgets/heart_btn.dart';
import 'package:food/widgets/text_widget.dart';
import 'package:provider/provider.dart';
import '../../inner_screens/product_details_screen.dart';
import '../../models/cart_model.dart';
import '../../providers/products_provider.dart';
import '../../providers/wishlist_provider.dart';
import '../../services/global.dart';
import '../../services/utils.dart';

class CartWidget extends StatefulWidget {
  const CartWidget({Key? key, required this.quantity}) : super(key: key);
  final int quantity;
  @override
  State<CartWidget> createState() => _CartWidgetState();
}

class _CartWidgetState extends State<CartWidget> {
  final _quantityTextController = TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    _quantityTextController.text = widget.quantity.toString();
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
    final Color color = Utils(context: context).color;
    Size size = Utils(context: context).getScreenSize;
    final productProvider = Provider.of<ProductsProvider>(context);
    final cartProvider = Provider.of<CartProvider>(context);
    final cartModel = Provider.of<CartModel>(context);
    final getCurrProduct = productProvider.findProdByID(cartModel.productId);
    final wishlistProvider = Provider.of<WishlistProvider>(context);
    bool? _isInWishlist =
        wishlistProvider.getWishlistItems.containsKey(getCurrProduct.id);
    num usedPrice = getCurrProduct.isOnSale
        ? getCurrProduct.salePrice
        : getCurrProduct.price;
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, ProductDetails.routeName,
            arguments: cartModel.productId);
      },
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(3.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      width: size.width * 0.25,
                      height: size.width * 0.25,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: FancyShimmerImage(
                        imageUrl: getCurrProduct.imageUrl,
                        // height: size.width * 0.18,
                        // width: size.width * 0.22,
                        boxFit: BoxFit.fill,
                      ),
                      // Image.network(
                      //   'https://i.ibb.co/F0s3FHQ/Apricots.png',
                      //   fit: BoxFit.fill,
                      // ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextWidget(
                            text: getCurrProduct.title,
                            color: color,
                            textSize: 20,
                            isTitle: true,
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          SizedBox(
                            width: size.width * 0.3,
                            child: Row(
                              children: [
                                _quantityController(
                                    fct: () {
                                      if (_quantityTextController.text == '1') {
                                        return;
                                      } else {
                                        setState(() {
                                          cartProvider.reduceQuantityByOne(
                                              cartModel.productId);
                                          _quantityTextController.text =
                                              (int.parse(_quantityTextController
                                                          .text) -
                                                      1)
                                                  .toString();
                                        });
                                      }
                                    },
                                    icon: CupertinoIcons.minus,
                                    color: Colors.red),
                                Flexible(
                                  flex: 1,
                                  child: TextField(
                                    controller: _quantityTextController,
                                    keyboardType: TextInputType.number,
                                    maxLines: 1,
                                    decoration: InputDecoration(
                                        focusedBorder: UnderlineInputBorder(
                                            borderSide: BorderSide())),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                        RegExp('[0-9]'),
                                      ),
                                    ],
                                    onChanged: (value) {
                                      setState(() {
                                        if (value.isEmpty) {
                                          _quantityTextController.text = '1';
                                        } else {
                                          return;
                                        }
                                      });
                                    },
                                  ),
                                ),
                                _quantityController(
                                    fct: () {
                                      setState(() {
                                        cartProvider.increaseQuantityByOne(
                                            cartModel.productId);
                                        _quantityTextController.text =
                                            (int.parse(_quantityTextController
                                                        .text) +
                                                    1)
                                                .toString();
                                      });
                                    },
                                    icon: CupertinoIcons.plus,
                                    color: Colors.green),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    //Spacer(),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          InkWell(
                            onTap: () async {
                              await cartProvider.removeOneItem(
                                  cartId: cartModel.id,
                                  productId: cartModel.productId,
                                  quantity: cartModel.quantity);
                              //Flutter toast
                            },
                            child: Icon(
                              CupertinoIcons.cart_badge_minus,
                              color: Colors.red,
                              size: 20,
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          HeartBtn(
                            productId: getCurrProduct.id,
                            isInWishlist: _isInWishlist,
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          TextWidget(
                            text:
                                '\u20B9 ${(usedPrice * int.parse(_quantityTextController.text)).toStringAsFixed(2)}',
                            color: color,
                            textSize: 18,
                            maxLines: 1,
                          )
                        ],
                      ),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _quantityController({
    required Function fct,
    required IconData icon,
    required Color color,
  }) {
    return Flexible(
      flex: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: Material(
          color: color,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              fct();
            },
            child: Padding(
              padding: const EdgeInsets.all(6.0),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
          ),
        ),
      ),
    );
  }
}
