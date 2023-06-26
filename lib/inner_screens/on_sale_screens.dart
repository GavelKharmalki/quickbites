import 'package:flutter/material.dart';
import 'package:food/models/products_model.dart';
import 'package:food/providers/products_provider.dart';
import 'package:food/widgets/back_widget.dart';
import 'package:food/widgets/empty_product_screen.dart';
import 'package:food/widgets/text_widget.dart';
import 'package:provider/provider.dart';
import '../services/utils.dart';
import '../widgets/feed_items.dart';
import '../widgets/on_sale_widget.dart';

class OnSaleScreen extends StatelessWidget {
  static const routeName = "/OnSaleScreen";
  const OnSaleScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final productsProvider = Provider.of<ProductsProvider>(context);
    List<ProductModel> productsOnSale = productsProvider.getOnSaleProducts;
    final utils = Utils(context: context);
    Size size = utils.getScreenSize;
    final Color color = Utils(context: context).color;
    return Scaffold(
      appBar: AppBar(
        leading: BackWidget(),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: TextWidget(
          text: 'Products on Sale',
          color: color,
          textSize: 24,
          isTitle: true,
        ),
      ),
      body: productsOnSale.isEmpty
          ? EmptyProductWidget(text: 'No product on sale yet :(')
          : GridView.count(
              shrinkWrap: true,
              //physics: NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              padding: EdgeInsets.zero,
              //mainAxisSpacing: 30,
              crossAxisSpacing: 10,
              childAspectRatio: size.width / (size.height * 0.5),
              children: List.generate(productsOnSale.length, (index) {
                return ChangeNotifierProvider.value(
                    value: productsOnSale[index], child: OnSaleWidget());
              }),
            ),
    );
  }
}
