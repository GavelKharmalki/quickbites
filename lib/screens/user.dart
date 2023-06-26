import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:food/consts/firebase_consts.dart';
import 'package:food/screens/auth/forget_password.dart';
import 'package:food/screens/auth/login.dart';
import 'package:food/screens/history/viewed_recently.dart';
import 'package:food/screens/orders/orders_screen.dart';
import 'package:food/screens/wishlist/wishlist_screen.dart';
import 'package:food/services/global.dart';
import 'package:food/widgets/loading_widget.dart';
import 'package:food/widgets/text_widget.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import '../providers/dark_theme_provider.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({Key? key}) : super(key: key);

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  final TextEditingController _addressTextController =
      TextEditingController(text: "");
  final googleSignIn = GoogleSignIn();
  @override
  void dispose() {
    // TODO: implement dispose
    _addressTextController.dispose();
    super.dispose();
  }

  String? _email;
  String? _name;
  String? address;
  bool _isLoading = false;
  final User? user = authInstance.currentUser;
  @override
  void initState() {
    // TODO: implement initState
    getUserData();
    super.initState();
  }

  Future<void> getUserData() async {
    setState(() {
      _isLoading = true;
    });
    if (user == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }
    try {
      String _uid = user!.uid;
      final DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('users').doc(_uid).get();
      if (userDoc == null) {
        return;
      } else {
        _email = userDoc.get('email');
        _name = userDoc.get('name');
        address = userDoc.get('address');
        _addressTextController.text = userDoc.get('address');
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      GlobalMethods.errorDialog(subtitle: '$error', context: context);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeState = Provider.of<DarkThemeProvider>(context);
    final Color color = themeState.getDarkTheme ? Colors.white : Colors.black;
    final User? user = authInstance.currentUser;
    return Scaffold(
        body: LoadingManager(
      isLoading: _isLoading,
      child: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 25),
                RichText(
                    text: TextSpan(
                        text: 'Hi, ',
                        style: TextStyle(
                          color: Colors.cyan,
                          fontSize: 27,
                          fontWeight: FontWeight.bold,
                        ),
                        children: <TextSpan>[
                      TextSpan(
                          text: _name == null ? 'user' : _name!,
                          style: TextStyle(
                              color: color,
                              fontSize: 25,
                              fontWeight: FontWeight.w600),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              print("My Name is pressed");
                            })
                    ])),
                SizedBox(
                  height: 5,
                ),
                TextWidget(
                  text: _email == null ? 'user' : _email!,
                  color: color,
                  textSize: 18,
                  //isTitle: true,
                ),
                Divider(thickness: 2),
                SizedBox(
                  height: 20,
                ),
                _listTiles(
                    title: "Address",
                    subtitle: address,
                    icon: Icons.person_outline,
                    color: color,
                    onPressed: () async {
                      await _showAddressDialog();
                    }),
                _listTiles(
                    title: "Orders",
                    icon: Icons.shopping_bag_outlined,
                    color: color,
                    onPressed: () {
                      GlobalMethods.navigateTo(
                          context: context, routeName: OrdersScreen.routeName);
                    }),
                _listTiles(
                    title: "Wishlist",
                    icon: Icons.favorite_border,
                    color: color,
                    onPressed: () {
                      GlobalMethods.navigateTo(
                          context: context,
                          routeName: WishlistScreen.routeName);
                    }),
                _listTiles(
                    title: "Viewed",
                    icon: Icons.remove_red_eye_outlined,
                    color: color,
                    onPressed: () {
                      GlobalMethods.navigateTo(
                          context: context,
                          routeName: ViewedRecentlyScreen.routeName);
                    }),
                _listTiles(
                    title: "Forget Password",
                    icon: Icons.lock_open,
                    color: color,
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const ForgetPasswordScreen(),
                        ),
                      );
                    }),
                SwitchListTile(
                  title: TextWidget(
                    text: themeState.getDarkTheme ? 'Dark mode' : 'Light mode',
                    color: color,
                    textSize: 22,
                    //isTitle: true,
                  ),
                  secondary: Icon(themeState.getDarkTheme
                      ? Icons.dark_mode_outlined
                      : Icons.light_mode_outlined),
                  onChanged: (bool value) {
                    setState(() {
                      themeState.setDarkTheme = value;
                    });
                  },
                  value: themeState.getDarkTheme,
                ),
                _listTiles(
                    title: user == null ? "Login" : "Logout",
                    icon: user == null
                        ? Icons.login_outlined
                        : Icons.logout_outlined,
                    color: color,
                    onPressed: () {
                      if (user == null) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                        return;
                      }
                      // GlobalMethods.warningDialog(
                      //     title: 'Sign out',
                      //     subtitle: 'Do you want to sign out?',
                      //     fct: () async {
                      //       //if (GoogleSignIn().currentUser != null) {
                      //       await authInstance.signOut();
                      //       await GoogleSignIn().disconnect();
                      //       Navigator.of(context).push(
                      //         MaterialPageRoute(
                      //           builder: (context) => const LoginScreen(),
                      //         ),
                      //       );
                      //       //}
                      //       //else {
                      //       // await authInstance.signOut();
                      //       //Navigator.of(context).push(
                      //       //  MaterialPageRoute(
                      //       //   builder: (context) => const LoginScreen(),
                      //       //  ),
                      //       // );
                      //       // }
                      //     },
                      //
                      //     context: context);
                      GlobalMethods.warningDialog(
                          title: 'Sign out',
                          subtitle: 'Do you want to sign out?',
                          fct: () async {
                            //final googleSignIn = GoogleSignIn();
                            // if (googleSignIn.currentUser != null) {
                            //   await authInstance.signOut();
                            //   await googleSignIn.signOut();
                            //   final account =
                            //       await googleSignIn.signInSilently();
                            //   if (account != null) {
                            //     await account.clearAuthCache();
                            //   }
                            // } else {
                            //   await authInstance.signOut();
                            //   await googleSignIn.signOut();
                            // }
                            // Navigator.of(context).pushAndRemoveUntil(
                            //     MaterialPageRoute(
                            //         builder: (context) => const LoginScreen()),
                            //     (Route<dynamic> route) => false);
                            if (user.providerData.first.providerId ==
                                'google.com') {
                              _googleSignOut(); // Logout for Google Sign-In
                            } else {
                              _emailPasswordSignOut(); // Logout for email and password authentication
                            }
                          },
                          context: context);
                    }),
              ],
            ),
          ),
        ),
      ),
    ));
  }

  Future<void> _googleSignOut() async {
    await authInstance.signOut();
    await googleSignIn.signOut();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (Route<dynamic> route) => false,
    );
  }

  Future<void> _emailPasswordSignOut() async {
    try {
      await authInstance.signOut();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (Route<dynamic> route) => false,
      );
    } catch (error) {
      // Handle the error
    }
  }

  Future<void> _showAddressDialog() async {
    await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Update'),
            content: TextField(
              // onChanged: (value) {
              //   print(
              //       '_addressTextController.text: ${_addressTextController.text}');
              //   //_addressTextController.text;
              // },
              controller: _addressTextController,
              //maxLines: 5,
              decoration: InputDecoration(hintText: "Your address"),
            ),
            actions: [
              TextButton(
                  onPressed: () async {
                    String _uid = user!.uid;
                    try {
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(_uid)
                          .update({
                        'address': _addressTextController.text,
                      });
                      Navigator.pop(context);
                      setState(() {
                        address = _addressTextController.text;
                      });
                    } catch (error) {
                      GlobalMethods.errorDialog(
                          subtitle: error.toString(), context: context);
                    }
                  },
                  child: Text('Update'))
            ],
          );
        });
  }

  Widget _listTiles({
    required String title,
    String? subtitle,
    required IconData icon,
    required Function onPressed,
    required Color color,
  }) {
    return ListTile(
      title: TextWidget(
        text: title,
        color: color,
        textSize: 22,
        //isTitle: true,
      ),
      subtitle: TextWidget(
        text: subtitle == null ? "" : subtitle,
        color: color,
        textSize: 18,
      ),
      leading: Icon(icon),
      trailing: Icon(Icons.arrow_forward_ios_sharp),
      onTap: () {
        onPressed();
      },
    );
  }
}
