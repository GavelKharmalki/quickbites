import 'package:flutter/material.dart';
import 'package:food/widgets/text_widget.dart';

import '../inner_screens/feeds_screen.dart';
import '../services/global.dart';
import '../services/utils.dart';

class EmptyScreen extends StatelessWidget {
  const EmptyScreen(
      {Key? key,
      required this.imagePath,
      required this.title,
      required this.subtitle,
      required this.buttonText})
      : super(key: key);
  final String imagePath, title, subtitle, buttonText;

  @override
  Widget build(BuildContext context) {
    final Color color = Utils(context: context).color;
    Size size = Utils(context: context).getScreenSize;
    final themeState = Utils(context: context).getTheme;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 50,
            ),
            Image.asset(
              imagePath,
              width: double.infinity,
              height: size.height * 0.4,
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              'Whoops',
              style: TextStyle(
                  color: Colors.red, fontSize: 40, fontWeight: FontWeight.w700),
            ),
            SizedBox(
              height: 20,
            ),
            TextWidget(
              text: title,
              color: Colors.cyan,
              textSize: 20,
            ),
            SizedBox(
              height: 10,
            ),
            TextWidget(
              text: subtitle,
              color: Colors.cyan,
              textSize: 20,
            ),
            SizedBox(
              //height: size.height * 0.1,
              height: 20,
            ),
            ElevatedButton(
              onPressed: () {
                GlobalMethods.navigateTo(
                    context: context, routeName: FeedsScreen.routeName);
              },
              style: ElevatedButton.styleFrom(
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.secondary,
                    )),
                backgroundColor: Theme.of(context).colorScheme.secondary,
                foregroundColor: color,
                padding: EdgeInsets.symmetric(
                  horizontal: 50,
                  vertical: 20,
                ),
              ),
              child: TextWidget(
                text: buttonText,
                color: themeState ? Colors.grey.shade300 : Colors.grey.shade800,
                textSize: 20,
                isTitle: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
