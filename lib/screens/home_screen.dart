import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:food/providers/dark_theme_provider.dart';
import 'package:food/services/global.dart';
import 'package:food/widgets/text_widget.dart';
import 'package:provider/provider.dart';
import 'package:dots_indicator/dots_indicator.dart';
import '../consts/consts.dart';
import '../inner_screens/feeds_screen.dart';
import '../inner_screens/on_sale_screens.dart';
import '../models/products_model.dart';
import '../providers/products_provider.dart';
import '../services/utils.dart';
import '../widgets/feed_items.dart';
import '../widgets/on_sale_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final utils = Utils(context: context);
    final themeState = utils.getTheme;
    final Color color = Utils(context: context).color;
    Size size = utils.getScreenSize;
    //GlobalMethods globalMethods = GlobalMethods();
    final productsProvider = Provider.of<ProductsProvider>(context);
    List<ProductModel> allProducts = productsProvider.getProducts;
    List<ProductModel> productsOnSale = productsProvider.getOnSaleProducts;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: size.height * 0.33,
              child: Swiper(
                itemBuilder: (BuildContext context, int index) {
                  return Image.asset(
                    Consts.offerImages[index],
                    fit: BoxFit.fill,
                  );
                },
                itemCount: Consts.offerImages.length,
                pagination: SwiperPagination(
                  alignment: Alignment.bottomCenter,
                  builder: DotSwiperPaginationBuilder(
                      color: Colors.white, activeColor: Colors.blueAccent),
                ),
                viewportFraction: 0.8,
                scale: 0.9,
              ),
            ),
            SizedBox(
              height: 6,
            ),
            TextButton(
                onPressed: () {
                  GlobalMethods.navigateTo(
                      context: context, routeName: OnSaleScreen.routeName);
                },
                child: TextWidget(
                  text: "View all",
                  color: Colors.blue,
                  textSize: 20,
                  isTitle: false,
                  maxLines: 1,
                )),
            SizedBox(
              height: 6,
            ),
            Row(
              children: [
                RotatedBox(
                  quarterTurns: -1,
                  child: Row(
                    children: [
                      TextWidget(
                        text: 'On Sale'.toUpperCase(),
                        color: Colors.red,
                        textSize: 22,
                        isTitle: true,
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Icon(Icons.discount, color: Colors.red),
                    ],
                  ),
                ),
                SizedBox(
                  width: 8,
                ),
                Flexible(
                  child: SizedBox(
                    height: size.height * 0.23,
                    child: ListView.builder(
                        itemCount: productsOnSale.length < 10
                            ? productsOnSale.length
                            : 10,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          return ChangeNotifierProvider.value(
                              value: productsOnSale[index],
                              child: OnSaleWidget());
                        }),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextWidget(
                      text: "Our Products",
                      color: color,
                      textSize: 22,
                      isTitle: true),
                  TextButton(
                      onPressed: () {
                        GlobalMethods.navigateTo(
                            context: context, routeName: FeedsScreen.routeName);
                      },
                      child: TextWidget(
                        text: "Browse all",
                        color: Colors.blue,
                        textSize: 20,
                        isTitle: false,
                        maxLines: 1,
                      )),
                ],
              ),
            ),
            GridView.count(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              padding: EdgeInsets.zero,
              //crossAxisSpacing: 10,
              childAspectRatio: size.width / (size.height * 0.66),
              children: List.generate(
                  allProducts.length < 4 ? allProducts.length : 4, (index) {
                return ChangeNotifierProvider.value(
                    value: allProducts[index], child: FeedsWidget());
              }),
            ),
          ],
        ),
      ),
    );
  }
}
