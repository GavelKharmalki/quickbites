import 'package:flutter/material.dart';
import 'package:food/providers/wishlist_provider.dart';
import 'package:food/screens/cart/cart_widget.dart';
import 'package:food/screens/wishlist/wishlist_widget.dart';
import 'package:food/widgets/back_widget.dart';
import 'package:food/widgets/text_widget.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';
import '../../services/global.dart';
import '../../services/utils.dart';
import '../../widgets/empty_screen.dart';

class WishlistScreen extends StatelessWidget {
  static const routeName = "/WishlistScreen";
  const WishlistScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color color = Utils(context: context).color;
    Size size = Utils(context: context).getScreenSize;
    final wishlistProvider = Provider.of<WishlistProvider>(context);
    final wishlistItems =
        wishlistProvider.getWishlistItems.values.toList().reversed.toList();

    return wishlistItems.isEmpty
        ? const EmptyScreen(
            imagePath: 'assets/images/wishlist.png',
            title: 'Your wishlist is empty',
            subtitle: 'No products has been added to favorites yet',
            buttonText: 'Add now')
        : Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              leading: BackWidget(),
              elevation: 0,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              title: TextWidget(
                  text: 'Wishlist (${wishlistItems.length})',
                  color: color,
                  textSize: 22,
                  isTitle: true),
              actions: [
                IconButton(
                  onPressed: () {
                    GlobalMethods.warningDialog(
                        title: 'Empty your wishlist',
                        subtitle: 'Are you sure?',
                        fct: () async {
                          await wishlistProvider.clearOnlineWishlist();
                          wishlistProvider.clearLocalWishlist();
                        },
                        context: context);
                  },
                  icon: Icon(Icons.delete_outline),
                  color: color,
                )
              ],
            ),
            body: MasonryGridView.count(
              itemCount: wishlistItems.length,
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              itemBuilder: (context, index) {
                return ChangeNotifierProvider.value(
                  value: wishlistItems[index],
                  child: WishlistWidget(),
                );
              },
            ));
  }
}
