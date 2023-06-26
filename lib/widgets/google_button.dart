import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:food/consts/firebase_consts.dart';
import 'package:food/services/global.dart';
import 'package:food/widgets/loading_widget.dart';
import 'package:food/widgets/text_widget.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../fetch_products_screen.dart';
import '../screens/btm_bar.dart';

class GoogleButton extends StatefulWidget {
  const GoogleButton({Key? key}) : super(key: key);

  @override
  State<GoogleButton> createState() => _GoogleButtonState();
}

class _GoogleButtonState extends State<GoogleButton> {
  bool _isLoading = false;
  Future<void> _googleSignIn(context) async {
    final googleSignIn = GoogleSignIn();
    final googleAccount = await googleSignIn.signIn();
    if (googleAccount != null) {
      final googleAuth = await googleAccount.authentication;
      if (googleAuth.accessToken != null && googleAuth.idToken != null) {
        try {
          setState(() {
            _isLoading = true;
          });
          final authResult = await authInstance.signInWithCredential(
              GoogleAuthProvider.credential(
                  idToken: googleAuth.idToken,
                  accessToken: googleAuth.accessToken));
          //Saving user's data using google info
          if (authResult.additionalUserInfo!.isNewUser) {
            await FirebaseFirestore.instance
                .collection('users')
                .doc(authResult.user!.uid)
                .set({
              'id': authResult.user!.uid,
              'name': authResult.user!.displayName,
              'email': authResult.user!.email,
              'address': '',
              'mobileNo': '',
              'userWishlist': [],
              'userCart': [],
              'createdAt': Timestamp.now(),
            });
          }

          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const FetchScreen(),
            ),
          );
        } on FirebaseException catch (error) {
          GlobalMethods.errorDialog(
              subtitle: '${error.message}', context: context);
          setState(() {
            _isLoading = false;
          });
          print("YIKES1");
        } catch (error) {
          GlobalMethods.errorDialog(subtitle: '$error', context: context);
          setState(() {
            _isLoading = false;
          });
          print("YIKES2");
        } finally {
          print("YIKES3");
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoadingManager(
        isLoading: _isLoading,
        child: Material(
          color: Colors.blue,
          child: InkWell(
            onTap: () {
              _googleSignIn(context);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                    color: Colors.white,
                    child: Image.asset('assets/images/google.png', width: 40)),
                SizedBox(
                  width: 70,
                ),
                TextWidget(
                  text: 'Sign in with Google',
                  color: Colors.white,
                  textSize: 18,
                )
              ],
            ),
          ),
        ));
  }
}
