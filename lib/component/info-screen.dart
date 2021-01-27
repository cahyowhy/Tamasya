import 'package:flutter/material.dart';
import 'package:tamasya/style/style.dart';

class InfoScreen extends StatelessWidget {
  final String title;
  final String subtitle;

  const InfoScreen({Key key, this.title, this.subtitle}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      color: Style.background,
      child: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: TextStyle(
                    fontFamily: 'Raleway',
                    fontWeight: FontWeight.w800,
                    fontSize: 28)),
            SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(color: Style.greyDark),
            )
          ],
        ),
      ),
    );
  }
}
