import 'package:flutter/material.dart';
import 'package:food/widgets/text_widget.dart';

import '../services/utils.dart';

class PriceWidget extends StatelessWidget {
  const PriceWidget({
    Key? key,
    required this.salePrice,
    required this.price,
    required this.textPrice,
    required this.isOnSale,
  }) : super(key: key);
  final double price;
  final int salePrice;
  final String textPrice;
  final bool isOnSale;
  @override
  Widget build(BuildContext context) {
    final Color color = Utils(context: context).color;
    num userPrice = isOnSale ? salePrice : price;
    return FittedBox(
        child: Row(
      children: [
        TextWidget(
            text:
                '\u20B9${(userPrice * int.parse(textPrice)).toStringAsFixed(2)}',
            color: Colors.green,
            textSize: 22),
        const SizedBox(
          width: 10,
        ),
        Visibility(
          visible: isOnSale ? true : false,
          child:
              Text('\u20B9${(price * int.parse(textPrice)).toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 15,
                    color: color,
                    decoration: TextDecoration.lineThrough,
                    decorationThickness: 2.0,
                  )),
        )
      ],
    ));
  }
}
