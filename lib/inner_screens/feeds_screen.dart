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

class FeedsScreen extends StatefulWidget {
  const FeedsScreen({Key? key}) : super(key: key);
  static const routeName = "/FeedsScreen";
  @override
  State<FeedsScreen> createState() => _FeedsScreenState();
}

class _FeedsScreenState extends State<FeedsScreen> {
  final TextEditingController? _searchTextController = TextEditingController();
  final FocusNode _searchTextFocusNode = FocusNode();
  List<ProductModel> listProductSearch = [];
  @override
  void dispose() {
    // TODO: implement dispose
    _searchTextController!.dispose();
    _searchTextFocusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    final productsProvider =
        Provider.of<ProductsProvider>(context, listen: false);
    productsProvider.fetchProducts();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final utils = Utils(context: context);
    Size size = utils.getScreenSize;
    final Color color = Utils(context: context).color;

    final productsProvider = Provider.of<ProductsProvider>(context);
    List<ProductModel> allProducts = productsProvider.getProducts;

    return Scaffold(
      appBar: AppBar(
        leading: BackWidget(),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        centerTitle: true,
        title: TextWidget(
          text: 'All Products',
          color: color,
          textSize: 24,
          isTitle: true,
        ),
      ),
      body: SingleChildScrollView(
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
                      listProductSearch = productsProvider.searchQuery(value);
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
            _searchTextController!.text.isNotEmpty && listProductSearch.isEmpty
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
                            : allProducts.length, (index) {
                      return ChangeNotifierProvider.value(
                        value: _searchTextController!.text.isNotEmpty
                            ? listProductSearch[index]
                            : allProducts[index],
                        child: FeedsWidget(),
                      );
                    }),
                  ),
          ],
        ),
      ),
    );
  }
}
