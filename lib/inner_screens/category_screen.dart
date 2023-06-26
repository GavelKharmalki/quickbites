import 'package:flutter/material.dart';
import 'package:food/consts/consts.dart';
import 'package:food/providers/products_provider.dart';
import 'package:food/widgets/back_widget.dart';
import 'package:food/widgets/empty_product_screen.dart';
import 'package:provider/provider.dart';
import '../models/products_model.dart';
import '../services/utils.dart';
import '../widgets/feed_items.dart';
import '../widgets/text_widget.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({Key? key}) : super(key: key);
  static const routeName = "/CategoryScreen";
  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final TextEditingController? _searchTextController = TextEditingController();
  final FocusNode _searchTextFocusNode = FocusNode();
  //Search using keyword
  List<ProductModel> listProductSearch = [];
  @override
  void dispose() {
    // TODO: implement dispose
    _searchTextController!.dispose();
    _searchTextFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final utils = Utils(context: context);
    Size size = utils.getScreenSize;
    final Color color = Utils(context: context).color;
    //PROVIDER
    final productsProvider = Provider.of<ProductsProvider>(context);
    //Getting the category by name from category widget
    final categoryName = ModalRoute.of(context)!.settings.arguments as String;
    List<ProductModel> productsByCat =
        productsProvider.findByCategory(categoryName);

    return Scaffold(
      appBar: AppBar(
        leading: BackWidget(),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        centerTitle: true,
        title: TextWidget(
          text: categoryName,
          color: color,
          textSize: 24,
          isTitle: true,
        ),
      ),
      body: productsByCat.isEmpty
          ? EmptyProductWidget(text: 'No products in this category \n :(')
          : SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      height: kBottomNavigationBarHeight,
                      child: TextField(
                        focusNode: _searchTextFocusNode,
                        controller: _searchTextController,
                        onChanged: (value) {
                          setState(() {
                            listProductSearch =
                                productsProvider.searchQuery(value);
                          });
                        },
                        decoration: InputDecoration(
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                BorderSide(color: Colors.greenAccent, width: 2),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                BorderSide(color: Colors.greenAccent, width: 2),
                          ),
                          hintText: "What's in your mind?",
                          prefixIcon: Icon(Icons.search),
                          suffix: IconButton(
                            onPressed: () {
                              _searchTextController!.clear();
                              _searchTextFocusNode.unfocus();
                            },
                            icon: Icon(Icons.close,
                                color: _searchTextFocusNode.hasFocus
                                    ? Colors.red
                                    : color),
                          ),
                        ),
                      ),
                    ),
                  ),
                  _searchTextController!.text.isNotEmpty &&
                          listProductSearch.isEmpty
                      ? EmptyProductWidget(
                          text: 'No products found. Please search for another')
                      : GridView.count(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          padding: EdgeInsets.zero,
                          //crossAxisSpacing: 10,
                          childAspectRatio: size.width / (size.height * 0.66),
                          children: List.generate(
                            _searchTextController!.text.isNotEmpty
                                ? listProductSearch.length
                                : productsByCat.length,
                            (index) {
                              final product =
                                  _searchTextController!.text.isNotEmpty
                                      ? listProductSearch[index]
                                      : productsByCat[index];

                              if (_searchTextController!.text.isNotEmpty &&
                                  (product.productCategoryName !=
                                      categoryName)) {
                                return SizedBox
                                    .shrink(); // Return an empty SizedBox to hide the product
                              }
                              return ChangeNotifierProvider.value(
                                value: product,
                                child: FeedsWidget(),
                              );
                            },
                          )
                              .where((widget) => widget != SizedBox.shrink())
                              .toList(), // Filter out the hidden products
                          // return ChangeNotifierProvider.value(
                          //   value: _searchTextController!.text.isNotEmpty
                          //       ? listProductSearch[index]
                          //       : productsByCat[index],
                          //   child: FeedsWidget(),
                          // );
                          //}),
                        ),
                ],
              ),
            ),
    );
  }
}
