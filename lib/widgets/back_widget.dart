import 'package:flutter/material.dart';

import '../services/utils.dart';

class BackWidget extends StatelessWidget {
  const BackWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final utils = Utils(context: context);
    Size size = utils.getScreenSize;
    final Color color = Utils(context: context).color;
    return InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.pop(context);
        },
        child: Icon(
          Icons.keyboard_arrow_left,
          color: color,
        ));
  }
}
