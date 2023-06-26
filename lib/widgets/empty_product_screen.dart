import 'package:flutter/material.dart';
import 'package:food/services/utils.dart';

class EmptyProductWidget extends StatelessWidget {
  final String text;
  const EmptyProductWidget({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color color = Utils(context: context).color;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: Image.asset('assets/images/box.png'),
            ),
            Text(text,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: color, fontSize: 30, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}
