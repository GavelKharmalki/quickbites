// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../consts/firebase_consts.dart';
import '../providers/cart_provider.dart';
import '../providers/orders_provider.dart';
import '../providers/products_provider.dart';
import '../services/global.dart';

class StripeHelper {
  static StripeHelper instance = StripeHelper();

  Map<String, dynamic>? paymentIntent;
  Future<void> makePayment(String amount, BuildContext context) async {
    try {
      paymentIntent = await createPaymentIntent(amount, 'INR');

      var gpay = const PaymentSheetGooglePay(
          merchantCountryCode: "US", currencyCode: "USD", testEnv: true);

      //STEP 2: Initialize Payment Sheet
      await Stripe.instance
          .initPaymentSheet(
              paymentSheetParameters: SetupPaymentSheetParameters(
                  paymentIntentClientSecret: paymentIntent![
                      'client_secret'], //Gotten from payment intent
                  style: ThemeMode.light,
                  merchantDisplayName: 'QuickBites',
                  googlePay: gpay))
          .then((value) {});

      //STEP 3: Display Payment sheet
      displayPaymentSheet(context);
    } catch (err) {
      print(err);
    }
  }

  displayPaymentSheet(BuildContext context) async {
    try {
      await Stripe.instance.presentPaymentSheet().then((value) async {
        User? user = authInstance.currentUser;
        final orderId = const Uuid().v4();
        final productProvider =
            Provider.of<ProductsProvider>(context, listen: false);
        final cartProvider = Provider.of<CartProvider>(context);
        final ordersProvider = Provider.of<OrdersProvider>(context);
        // array to store the order items
        cartProvider.getCartItems.forEach((key, value) async {
          final getCurrProduct = productProvider.findProdByID(
            value.productId,
          );
          try {
            await FirebaseFirestore.instance.collection('orders').add({
              'orderId': orderId,
              'userId': user!.uid,
              'productId': value.productId,
              'price': (getCurrProduct.isOnSale
                      ? getCurrProduct.salePrice
                      : getCurrProduct.price) *
                  value.quantity,
              //'totalPrice': total,
              'quantity': value.quantity,
              'imageUrl': getCurrProduct.imageUrl,
              'userName': user.displayName,
              'orderDate': Timestamp.now(),
            });
            await cartProvider.clearOnlineCart();
            cartProvider.clearlocalCart();
            ordersProvider.fetchOrders();

            await Fluttertoast.showToast(
              msg: "Your order has been placed",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
            );
          } catch (error) {
            GlobalMethods.errorDialog(
                subtitle: error.toString(), context: context);
          } finally {}
        });
      });
    } catch (e) {}
  }

  createPaymentIntent(String amount, String currency) async {
    try {
      Map<String, dynamic> body = {
        'amount': amount,
        'currency': currency,
      };

      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization':
              'Bearer sk_test_51N6qqISGivbEzeqlxJ0fydu8OW5esdQYmrwGjMdSgtVlxfcLXnUXJNF7SBmj542ZYzGFfzlFvrRCwwFIseoaZqNb00Pu2Wdyvf',
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
