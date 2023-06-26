import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:food/inner_screens/product_details_screen.dart';
import 'package:food/services/global.dart';
import 'package:provider/provider.dart';

import '../../models/orders_model.dart';
import '../../providers/products_provider.dart';
import '../../services/utils.dart';
import '../../widgets/text_widget.dart';

class OrderWidget extends StatefulWidget {
  const OrderWidget({Key? key}) : super(key: key);

  @override
  State<OrderWidget> createState() => _OrderWidgetState();
}

class _OrderWidgetState extends State<OrderWidget> {
  late String orderDateToShow;

  @override
  void didChangeDependencies() {
    final ordersModel = Provider.of<OrderModel>(context);

    var orderDate = ordersModel.orderDate.toDate();

    orderDateToShow = '${orderDate.day}/${orderDate.month}/${orderDate.year}';
    //${orderDate.hour}/${orderDate.minute}/${orderDate.second}';

    ///${orderDate.day}/${orderDate.month}/${orderDate.year}
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final ordersModel = Provider.of<OrderModel>(context);
    final Color color = Utils(context: context).color;
    Size size = Utils(context: context).getScreenSize;
    final productProvider = Provider.of<ProductsProvider>(context);
    final getCurrProduct = productProvider.findProdByID(ordersModel.productId);
    return ListTile(
        subtitle: Text(
          'Paid: \u{20B9}${double.parse(ordersModel.price).toStringAsFixed(2)}',
          style: TextStyle(fontSize: 16),
        ),
        onTap: () {
          Navigator.pushNamed(context, ProductDetails.routeName,
              arguments: getCurrProduct.id);
          // GlobalMethods.navigateTo(
          //     context: context, routeName: ProductDetails.routeName);
        },
        leading: FancyShimmerImage(
          width: size.width * 0.2,
          imageUrl: getCurrProduct.imageUrl,
          boxFit: BoxFit.fill,
        ),
        title: TextWidget(
            //text: '${getCurrProduct.title}  x${ordersModel.quantity}',
            text: '${getCurrProduct.title}',
            color: color,
            textSize: 18),
        trailing:
            //TextWidget(text: orderDateToShow, color: color, textSize: 18),
            Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextWidget(
              text: "Payment Mode",
              color: color,
              textSize: 14,
            ),
            SizedBox(
              height: 10,
            ),
            TextWidget(
              text: ordersModel.paymentMethod.toString(),
              color: Colors.green,
              textSize: 16,
            ),
          ],
        ));
  }
}
