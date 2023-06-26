import 'dart:convert';
import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:food/fetch_products_screen.dart';
import 'package:food/inner_screens/on_sale_screens.dart';
import 'package:food/inner_screens/product_details_screen.dart';
import 'package:food/providers/dark_theme_provider.dart';
import 'package:food/providers/cart_provider.dart';
import 'package:food/providers/orders_provider.dart';
import 'package:food/providers/products_provider.dart';
import 'package:food/providers/viewed_prod_provider.dart';
import 'package:food/providers/wishlist_provider.dart';
import 'package:food/screens/auth/forget_password.dart';
import 'package:food/screens/auth/login.dart';
import 'package:food/screens/auth/register.dart';
import 'package:food/screens/btm_bar.dart';
import 'package:food/screens/history/viewed_recently.dart';
import 'package:food/screens/home_screen.dart';
import 'package:food/screens/orders/orders_screen.dart';
import 'package:food/screens/wishlist/wishlist_screen.dart';
import 'package:provider/provider.dart';
import 'consts/theme_data.dart';
import 'inner_screens/category_screen.dart';
import 'inner_screens/feeds_screen.dart';
import 'package:http/http.dart' as http;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Stripe.publishableKey =
  //     "pk_test_51N6qqISGivbEzeqlGJwK5n1Ok4tjNSGoAY1yWl5GufXmr08E9OyXjnBQONKNNgSsRcz8Ml66mEYiSwwdDHxbMHcj00RtIIDRoz";
  // Stripe.publishableKey =
  //     "pk_test_51N6qqISGivbEzeqlGJwK5n1Ok4tjNSGoAY1yWl5GufXmr08E9OyXjnBQONKNNgSsRcz8Ml66mEYiSwwdDHxbMHcj00RtIIDRoz";
  Stripe.publishableKey =
      "pk_test_51N65xmSGiUn0LCjASwdhsVYerXM2ssswBKY0cihgOlsxpxNb5C1lYc3pkpOJ0R0YeU8tZmKAvC66rk6JT01t8gam00ZFC3X82t";
  await Stripe.instance.applySettings();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  DarkThemeProvider themeChangeProvider = DarkThemeProvider();

  void getCurrentAppTheme() async {
    themeChangeProvider.setDarkTheme =
        await themeChangeProvider.darkThemePrefs.getTheme();
  }

  @override
  void initState() {
    getCurrentAppTheme();
    super.initState();
  }

  // This widget is the root of application.
  final Future<FirebaseApp> _firebaseInitialization = Firebase.initializeApp();
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _firebaseInitialization,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const MaterialApp(
                debugShowCheckedModeBanner: false,
                home: Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                ));
          } else if (snapshot.hasError) {
            return const MaterialApp(
                debugShowCheckedModeBanner: false,
                home: Scaffold(
                  body: Center(
                    child: Text('An error occurred'),
                  ),
                ));
          }
          return MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (_) {
                return themeChangeProvider;
              }),
              ChangeNotifierProvider(create: (_) {
                return ProductsProvider();
              }),
              ChangeNotifierProvider(create: (_) {
                return CartProvider();
              }),
              ChangeNotifierProvider(create: (_) {
                return WishlistProvider();
              }),
              ChangeNotifierProvider(create: (_) {
                return ViewedProdProvider();
              }),
              ChangeNotifierProvider(create: (_) {
                return OrdersProvider();
              }),
            ],
            child: Consumer<DarkThemeProvider>(
                builder: (context, themeProvider, child) {
              return MaterialApp(
                debugShowCheckedModeBanner: false,
                title: 'Flutter Demo',
                theme: Styles.themeData(themeProvider.getDarkTheme, context),
                //home: LoginScreen(),
                home: FetchScreen(),
                routes: {
                  OnSaleScreen.routeName: (ctx) => const OnSaleScreen(),
                  FeedsScreen.routeName: (ctx) => const FeedsScreen(),
                  ProductDetails.routeName: (ctx) => const ProductDetails(),
                  WishlistScreen.routeName: (ctx) => const WishlistScreen(),
                  OrdersScreen.routeName: (ctx) => const OrdersScreen(),
                  ViewedRecentlyScreen.routeName: (ctx) =>
                      const ViewedRecentlyScreen(),
                  LoginScreen.routeName: (ctx) => const LoginScreen(),
                  RegisterScreen.routeName: (ctx) => const RegisterScreen(),
                  ForgetPasswordScreen.routeName: (ctx) =>
                      const ForgetPasswordScreen(),
                  CategoryScreen.routeName: (ctx) => const CategoryScreen(),
                },
              );
            }),
          );
        });
  }
}

//cloud- https://us-central1-quickbites-4e15d.cloudfunctions.net/stripePaymentIntentRequest
// class PaymentDemo extends StatelessWidget {
//   PaymentDemo({Key? key}) : super(key: key);
//   Map<String, dynamic>? paymentIntent;
//   Future<void> initPayment(
//       {required String email,
//       required double amount,
//       required BuildContext context}) async {
//     try {
//       print('2');
//       //1. Create a payment intent on the server
//       paymentIntent = await createPaymentIntent(email, amount, 'INR');
//
//       print('3');
//       await Stripe.instance.presentPaymentSheet();
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Payment is successfull'),
//         ),
//       );
//     } catch (error) {
//       if (error is StripeException) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('An error occurred ${error.error.localizedMessage}'),
//           ),
//         );
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('An error occurred ${error}'),
//           ),
//         );
//       }
//     }
//   }
//
//   createPaymentIntent(String email, double amount, String currency) async {
//     var gpay = const PaymentSheetGooglePay(
//         merchantCountryCode: "IN", currencyCode: "INR", testEnv: true);
//     try {
//       print("4");
//       Map<String, dynamic> body = {
//         'email': email,
//         'amount': amount.toString(),
//         'currency': currency,
//       };
//
//       var response = await http.post(
//         Uri.parse(
//             'https://us-central1-quickbites-4e15d.cloudfunctions.net/stripePaymentIntentRequest'),
//         body: body,
//       );
//       final jsonResponse = jsonDecode(response.body);
//       log(jsonResponse.toString());
//       await Stripe.instance
//           .initPaymentSheet(
//               paymentSheetParameters: SetupPaymentSheetParameters(
//             paymentIntentClientSecret: jsonResponse!['paymentIntent'],
//             merchantDisplayName: 'QUICK BITES',
//             customerId: jsonResponse['customer'],
//             customerEphemeralKeySecret: jsonResponse['ephemeralKey'],
//             googlePay: gpay,
//             //testEnv: true,
//             //merchantCountryCode: 'US',
//           ))
//           .then((value) {});
//       //return json.decode(response.body);
//     } catch (err) {
//       throw Exception(err.toString());
//     }
//   }
// class PaymentDemo extends StatelessWidget {
//   PaymentDemo({Key? key}) : super(key: key);
//
//   Map<String, dynamic>? paymentIntent;
//   Future<void> makePayment(String amount, BuildContext context) async {
//     try {
//       paymentIntent = await createPaymentIntent(amount, 'INR');
//
//       var gpay = const PaymentSheetGooglePay(
//           merchantCountryCode: "US", currencyCode: "USD", testEnv: true);
//
//       //STEP 2: Initialize Payment Sheet
//       await Stripe.instance
//           .initPaymentSheet(
//               paymentSheetParameters: SetupPaymentSheetParameters(
//             paymentIntentClientSecret:
//                 paymentIntent!['client_secret'], //Gotten from payment intent
//             style: ThemeMode.light,
//             customerId: paymentIntent!['customer'],
//             customerEphemeralKeySecret: paymentIntent!['ephemeralKey'],
//             merchantDisplayName: 'Quick Bites',
//             googlePay: gpay,
//           ))
//           .then((value) {});
//
//       //STEP 3: Display Payment sheet
//       displayPaymentSheet(context);
//     } catch (error) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('An error occurred ${error}'),
//         ),
//       );
//     }
//   }
//
//   displayPaymentSheet(BuildContext context) async {
//     try {
//       await Stripe.instance.presentPaymentSheet();
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Payment Successfull'),
//         ),
//       );
//     } catch (error) {
//       if (error is StripeException) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('An error occurred ${error.error.localizedMessage}'),
//           ),
//         );
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('An error occurred ${error}'),
//           ),
//         );
//       }
//     }
//   }
//
//   createPaymentIntent(String amount, String currency) async {
//     try {
//       Map<String, dynamic> body = {
//         //'email': email,
//         'amount': amount,
//         'currency': currency,
//       };
//
//       var response = await http.post(
//         //'https://us-central1-quickbites-4e15d.cloudfunctions.net/stripePaymentIntentRequest'
//         Uri.parse('https://api.stripe.com/v1/payment_intents'),
//         headers: {
//           'Authorization':
//               'Bearer sk_test_51N65xmSGiUn0LCjAOWJxKdppHSmZXxrZvyX8u0P9JBPjO2UpG04PyoNHbKHnd8KGp11JOxSIafOWC2rawpu1mMgT00oijs5MeV',
//           //'Bearer sk_test_51N6qqISGivbEzeqlxJ0fydu8OW5esdQYmrwGjMdSgtVlxfcLXnUXJNF7SBmj542ZYzGFfzlFvrRCwwFIseoaZqNb00Pu2Wdyvf',
//           'Content-Type': 'application/x-www-form-urlencoded'
//         },
//         body: body,
//       );
//       return json.decode(response.body);
//     } catch (err) {
//       throw Exception(err.toString());
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: ElevatedButton(
//           child: const Text('Pay 20\$'),
//           onPressed: () async {
//             print('YES');
//             await makePayment("300000", context);
//           },
//         ),
//       ),
//     );
//   }
// }

//TESTING
class PaymentScreen extends StatefulWidget {
  const PaymentScreen({Key? key}) : super(key: key);

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  Map<String, dynamic>? paymentIntent;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stripe Payment'),
      ),
      body: Center(
        child: TextButton(
          child: const Text('Make Payment'),
          onPressed: () async {
            await makePayment();
          },
        ),
      ),
    );
  }

  Future<void> makePayment() async {
    try {
      paymentIntent = await createPaymentIntent('10', 'INR');
      //Payment Sheet
      await Stripe.instance
          .initPaymentSheet(
              paymentSheetParameters: SetupPaymentSheetParameters(
                  paymentIntentClientSecret: paymentIntent!['client_secret'],
                  // applePay: const PaymentSheetApplePay(merchantCountryCode: '+92',),
                  googlePay: const PaymentSheetGooglePay(
                      testEnv: true,
                      currencyCode: "GBP",
                      merchantCountryCode: "GB"),
                  //style: ThemeMode.dark,
                  merchantDisplayName: 'QuickBites'))
          .then((value) {});

      ///now finally display payment sheeet
      displayPaymentSheet();
    } catch (e, s) {
      print('exception:$e$s');
    }
  }

  displayPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet().then((value) {
        showDialog(
            context: context,
            builder: (_) => AlertDialog(
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: const [
                          Icon(
                            Icons.check_circle,
                            color: Colors.green,
                          ),
                          Text("Payment Successfully"),
                        ],
                      ),
                    ],
                  ),
                ));
        // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("paid successfully")));

        paymentIntent = null;
      }).onError((error, stackTrace) {
        print('Error is:--->$error $stackTrace');
      });
    } on StripeException catch (e) {
      print('Error is:---> $e');
      showDialog(
          context: context,
          builder: (_) => const AlertDialog(
                content: Text("Cancelled "),
              ));
    } catch (e) {
      print('$e');
    }
  }

  //  Future<Map<String, dynamic>>
  createPaymentIntent(String amount, String currency) async {
    try {
      Map<String, dynamic> body = {
        'amount': calculateAmount(amount),
        'currency': currency,
      };
      //4000 0035 6000 0008
      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization':
              'Bearer sk_test_51N65xmSGiUn0LCjAOWJxKdppHSmZXxrZvyX8u0P9JBPjO2UpG04PyoNHbKHnd8KGp11JOxSIafOWC2rawpu1mMgT00oijs5MeV',
          'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: body,
      );
      // ignore: avoid_print
      print('Payment Intent Body->>> ${response.body.toString()}');
      return jsonDecode(response.body);
      log(response.body.toString());
    } catch (err) {
      // ignore: avoid_print
      print('err charging user: ${err.toString()}');
    }
  }

  calculateAmount(String amount) {
    final calculatedAmout = (int.parse(amount)) * 100;
    return calculatedAmout.toString();
  }
}
