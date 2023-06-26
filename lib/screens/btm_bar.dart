import 'package:flutter/material.dart';
import 'package:food/providers/cart_provider.dart';
import 'package:food/screens/categories.dart';
import 'package:food/screens/home_screen.dart';
import 'package:food/screens/user.dart';
import 'package:cupertino_icons/cupertino_icons.dart';
import 'package:provider/provider.dart';
import 'package:badges/badges.dart' as badge;
import '../providers/dark_theme_provider.dart';
import '../widgets/text_widget.dart';
import 'cart/cart_screen.dart';

class BottomBarScreen extends StatefulWidget {
  const BottomBarScreen({Key? key}) : super(key: key);

  @override
  State<BottomBarScreen> createState() => _BottomBarScreenState();
}

class _BottomBarScreenState extends State<BottomBarScreen> {
  int _selectedIndex = 0;
  List<Map<String, dynamic>> _pages = [
    {'page': HomeScreen(), 'title': 'Home Screen'},
    {'page': CategoriesScreen(), 'title': 'Categories Screen'},
    {'page': CartScreen(), 'title': 'Cart Screen'},
    {'page': UserScreen(), 'title': 'User Screen'},
  ];
  void _selectedPage(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeState = Provider.of<DarkThemeProvider>(context);
    bool _isDark = themeState.getDarkTheme;

    return Scaffold(
      // appBar: AppBar(
      //   title: Text(_pages[_selectedIndex]['title']),
      // ),
      body: _pages[_selectedIndex]['page'],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: _isDark ? Theme.of(context).cardColor : Colors.white,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        currentIndex: _selectedIndex,
        unselectedItemColor: _isDark ? Colors.white10 : Colors.black12,
        selectedItemColor: _isDark ? Colors.lightBlue.shade200 : Colors.black87,
        onTap: _selectedPage,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon:
                  Icon(_selectedIndex == 0 ? Icons.home : Icons.home_outlined),
              label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(_selectedIndex == 1
                  ? Icons.category
                  : Icons.category_outlined),
              label: "Categories"),
          // BottomNavigationBarItem(
          //     icon: Icon(_selectedIndex == 2
          //         ? Icons.shopping_cart
          //         : Icons.shopping_cart_outlined),
          //     label: "Cart"),
          BottomNavigationBarItem(
            icon: Consumer<CartProvider>(
              builder: (_, myCart, ch) {
                return badge.Badge(
                  badgeAnimation: const badge.BadgeAnimation.slide(),
                  badgeStyle: badge.BadgeStyle(
                    shape: badge.BadgeShape.circle,
                    badgeColor: Colors.blue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  position: badge.BadgePosition.topEnd(top: -7, end: -7),
                  badgeContent: FittedBox(
                      child: TextWidget(
                          text: myCart.getCartItems.length.toString(),
                          color: Colors.white,
                          textSize: 15)),
                  child: Icon(_selectedIndex == 2
                      ? Icons.shopping_cart
                      : Icons.shopping_cart_outlined),
                );
              },
            ),
            label: "Cart",
          ),

          BottomNavigationBarItem(
              icon: Icon(
                  _selectedIndex == 3 ? Icons.person : Icons.person_outline),
              label: "User"),
        ],
      ),
    );
  }
}
