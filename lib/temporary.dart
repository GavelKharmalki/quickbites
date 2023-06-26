import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:food/screens/cart/cart_widget.dart';
import 'package:food/widgets/text_widget.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import '../../consts/firebase_consts.dart';
import '../../main.dart';
import '../../providers/cart_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/orders_provider.dart';
import '../../providers/products_provider.dart';
import '../../services/global.dart';
import '../../services/utils.dart';
import '../../widgets/empty_screen.dart';

class CartScreen extends StatefulWidget {
  CartScreen({Key? key}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool isPaymentProcessing = false;
  bool paymentStatus = false;
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  Widget build(BuildContext context) {
    final Color color = Utils(context: context).color;
    Size size = Utils(context: context).getScreenSize;
    //Provider
    final cartProvider = Provider.of<CartProvider>(context);
    final cartItemsList =
        cartProvider.getCartItems.values.toList().reversed.toList();
    return cartItemsList.isEmpty
        ? EmptyScreen(
            title: 'Your cart is empty',
            subtitle: 'Add something in your cart',
            buttonText: 'Shop now',
            imagePath: 'assets/images/cart.png',
          )
        : Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              elevation: 0,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              title: TextWidget(
                  text: 'Cart(${cartItemsList.length.toString()})',
                  color: color,
                  textSize: 22,
                  isTitle: true),
              actions: [
                IconButton(
                  onPressed: () {
                    GlobalMethods.warningDialog(
                        title: 'Empty your cart',
                        subtitle: 'Are you sure?',
                        fct: () async {
                          await cartProvider.clearOnlineCart();
                          cartProvider.clearlocalCart();
                        },
                        context: context);
                  },
                  icon: Icon(Icons.delete_outline),
                  color: color,
                )
              ],
            ),
            body: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cartItemsList.length,
                    itemBuilder: (context, index) {
                      return ChangeNotifierProvider.value(
                          value: cartItemsList[index],
                          child: CartWidget(
                            quantity: cartItemsList[index].quantity,
                          ));
                    },
                  ),
                ),
                _checkOut(ctx: context),
              ],
            ),
          );
  }

  Widget _checkOut({required BuildContext ctx}) {
    final Color color = Utils(context: ctx).color;
    Size size = Utils(context: ctx).getScreenSize;
    final cartProvider = Provider.of<CartProvider>(ctx);
    //EXAMPLE
    final cartItemsList =
        cartProvider.getCartItems.values.toList().reversed.toList();
    for (int i = 0; i < cartItemsList.length; i++) {
      print(cartItemsList[i].id);
      print(cartItemsList[i].productId);
    }
    //Not needed code above
    final productProvider = Provider.of<ProductsProvider>(ctx);
    final ordersProvider = Provider.of<OrdersProvider>(ctx);
    double total = 0.0;
    cartProvider.getCartItems.forEach((key, value) {
      final getCurrProduct = productProvider.findProdByID(value.productId);
      total += (getCurrProduct.isOnSale
              ? getCurrProduct.salePrice
              : getCurrProduct.price) *
          value.quantity;
    });

    return SizedBox(
      width: double.infinity,
      height: size.height * 0.12,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            FittedBox(
              child: TextWidget(
                text: 'Total:  \u20B9 ${total.toStringAsFixed(2)}',
                color: color,
                textSize: 18,
                isTitle: true,
              ),
            ),
            Spacer(),
            isPaymentProcessing
                ? Center(
                    child: CircularProgressIndicator(
                      color: Colors.green,
                    ),
                  )
                : Material(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(10),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () async {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Choose payment method'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      print("COD");
                                    },
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        TextWidget(
                                          text: "Cash On Delivery",
                                          color: color,
                                          textSize: 18,
                                          isTitle: false,
                                        ),
                                        Icon(
                                          Icons.money,
                                          color: Colors.teal,
                                        ), // Cash icon
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  TextButton(
                                    onPressed: () async {
                                      Navigator.of(context).pop();
                                      //_processPayment('Card');
                                      print("card");
                                      try {
                                        setState(() {
                                          isPaymentProcessing = true;
                                        });
                                        print("BEFORE");
                                        bool success = await makePayment(
                                            (((total) * 100).toInt())
                                                .toString(),
                                            ctx);
                                        print("AFTER");
                                        print("total" +
                                            (((total) * 100).toInt())
                                                .toString());
                                        setState(() {
                                          paymentStatus = success;
                                          isPaymentProcessing = success;
                                        });
                                      } catch (error) {
                                        print(error);
                                        return;
                                      }
                                      if (paymentStatus == true) {
                                        print(
                                            "payment Status:  $paymentStatus");
                                        cartProvider.getCartItems
                                            .forEach((key, value) async {
                                          final getCurrProduct =
                                              productProvider.findProdByID(
                                            value.productId,
                                          );
                                          try {
                                            User? user =
                                                authInstance.currentUser;
                                            final orderId = const Uuid().v4();
                                            final productProvider =
                                                Provider.of<ProductsProvider>(
                                                    ctx,
                                                    listen: false);
                                            await FirebaseFirestore.instance
                                                .collection('orders')
                                                .add({
                                              'orderId': orderId,
                                              'userId': user!.uid,
                                              'productId': value.productId,
                                              'price': (getCurrProduct.isOnSale
                                                      ? getCurrProduct.salePrice
                                                      : getCurrProduct.price) *
                                                  value.quantity,
                                              //'totalPrice': total,
                                              'quantity': value.quantity,
                                              'imageUrl':
                                                  getCurrProduct.imageUrl,
                                              'userName': user.displayName,
                                              'orderDate': Timestamp.now(),
                                              'paymentMethod': 'card',
                                            });
                                            await cartProvider
                                                .clearOnlineCart();
                                            cartProvider.clearlocalCart();
                                            ordersProvider.fetchOrders();
                                            await Fluttertoast.showToast(
                                              msg: "Your order has been placed",
                                              toastLength: Toast.LENGTH_SHORT,
                                              gravity: ToastGravity.CENTER,
                                            );
                                          } catch (error) {
                                            GlobalMethods.errorDialog(
                                                subtitle: error.toString(),
                                                context: ctx);
                                          } finally {
                                            setState(() {
                                              isPaymentProcessing = false;
                                            });
                                            print("card");
                                          }
                                        });
                                      } else {
                                        print(
                                            "2. payment Status:  $paymentStatus");
                                      }
                                    },
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        TextWidget(
                                          text: "Card",
                                          color: color,
                                          textSize: 18,
                                          isTitle: false,
                                        ),
                                        Icon(
                                          Icons.credit_card,
                                          color: Colors.teal,
                                        ), // Cash icon
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextWidget(
                          text: 'Order Now',
                          color: Colors.white,
                          textSize: 20,
                        ),
                      ),
                    )),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic>? paymentIntent;
  Future<bool> makePayment(String amount, BuildContext context) async {
    try {
      paymentIntent = await createPaymentIntent(amount, 'INR');

      var gpay = const PaymentSheetGooglePay(
          merchantCountryCode: "US", currencyCode: "USD", testEnv: true);

      //STEP 2: Initialize Payment Sheet
      await Stripe.instance
          .initPaymentSheet(
              paymentSheetParameters: SetupPaymentSheetParameters(
            paymentIntentClientSecret:
                paymentIntent!['client_secret'], //Gotten from payment intent
            style: ThemeMode.light,
            customerId: paymentIntent!['customer'],
            customerEphemeralKeySecret: paymentIntent!['ephemeralKey'],
            merchantDisplayName: 'Quick Bites',
            googlePay: gpay,
          ))
          .then((value) {});

      //STEP 3: Display Payment sheet
      bool resultSheet = await displayPaymentSheet(context);
      return resultSheet;
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred ${error}'),
        ),
      );
      return false;
    }
  }

  Future<bool> displayPaymentSheet(BuildContext context) async {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final ordersProvider = Provider.of<OrdersProvider>(context, listen: false);
    try {
      await Stripe.instance.presentPaymentSheet();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment Successfull'),
        ),
      );
      return true;
      setState(() {
        paymentStatus = true;
      });
      setState(() {
        isPaymentProcessing = false;
      });
    } catch (error) {
      if (error is StripeException) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred ${error.error.localizedMessage}'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred ${error}'),
          ),
        );
      }
      return false;
    }
  }

  createPaymentIntent(String amount, String currency) async {
    try {
      Map<String, dynamic> body = {
        //'email': email,
        'amount': amount,
        'currency': currency,
      };

      var response = await http.post(
        //'https://us-central1-quickbites-4e15d.cloudfunctions.net/stripePaymentIntentRequest'
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization':
              'Bearer sk_test_51N65xmSGiUn0LCjAOWJxKdppHSmZXxrZvyX8u0P9JBPjO2UpG04PyoNHbKHnd8KGp11JOxSIafOWC2rawpu1mMgT00oijs5MeV',
          //'Bearer sk_test_51N6qqISGivbEzeqlxJ0fydu8OW5esdQYmrwGjMdSgtVlxfcLXnUXJNF7SBmj542ZYzGFfzlFvrRCwwFIseoaZqNb00Pu2Wdyvf',
          'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: body,
      );
      return json.decode(response.body);
    } catch (err) {
      throw Exception(err.toString());
    }
  }
}
