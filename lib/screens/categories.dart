import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:food/widgets/text_widget.dart';
import 'package:provider/provider.dart';

import '../providers/dark_theme_provider.dart';
import '../services/utils.dart';
import '../widgets/categories_widget.dart';

class CategoriesScreen extends StatelessWidget {
  CategoriesScreen({Key? key}) : super(key: key);
  List<Color> gridColors = [
    Color(0xff53B175),
    Color(0xffF8A44C),
    Color(0xffF7A593),
    Color(0xffD3B0E0),
    Color(0xffFDE598),
    Color(0xffB7DFF5),
    Color(0xffE1DFCB),
    Color(0xffACD5CA)
  ];
  List<Map<String, dynamic>> catInfo = [
    {'imgPath': 'assets/images/cat/noodles.png', 'catText': 'Noodles'},
    {'imgPath': 'assets/images/cat/pizza.png', 'catText': 'Pizza'},
    {'imgPath': 'assets/images/cat/burger.png', 'catText': 'Burgers'},
    {'imgPath': 'assets/images/cat/chicken.png', 'catText': 'Chicken'},
    {'imgPath': 'assets/images/cat/rice.png', 'catText': 'Rice'},
    {'imgPath': 'assets/images/cat/sandwich.png', 'catText': 'Sandwich'},
    {'imgPath': 'assets/images/cat/donuts.png', 'catText': 'Donuts'},
    {'imgPath': 'assets/images/cat/cake.png', 'catText': 'Cake'},
  ];
  @override
  Widget build(BuildContext context) {
    final utils = Utils(context: context);
    Color color = utils.color;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: TextWidget(
          text: 'Categories',
          color: color,
          textSize: 24,
          isTitle: true,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.count(
          crossAxisCount: 2,
          childAspectRatio: 260 / 250,
          crossAxisSpacing: 10, //Vertical Spacing
          mainAxisSpacing: 10, //Horizontal spacing
          children: List.generate(8, (index) {
            return CategoriesWidget(
              catText: catInfo[index]['catText'],
              imgPath: catInfo[index]['imgPath'],
              passedColor: gridColors[index],
            );
          }),
        ),
      ),
    );
  }
}
