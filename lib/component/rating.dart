import 'package:flutter/material.dart';
import 'package:tamasya/component/row-builder.dart';
import 'package:tamasya/style/style.dart';

class Rating extends StatelessWidget {
  final int rating;
  final double size;
  const Rating({Key key, this.rating, this.size = 16}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RowBuilder(
        itemCount: 5,
        itemBuilder: (_, int i) {
          int idx = i + 1;
          Widget widget = Icon(Icons.star,
              size: size,
              color: idx <= rating ? Style.primary : Style.greyDark);

          return Padding(
              padding: EdgeInsets.only(right: idx != 5 ? 4 : 0), child: widget);
        });
  }
}
