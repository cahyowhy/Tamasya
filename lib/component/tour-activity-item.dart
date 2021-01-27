import 'package:flutter/material.dart';
import 'package:tamasya/component/rating.dart';
import 'package:tamasya/model/tour-activity.dart';
import 'package:tamasya/style/style.dart';

class TourActivityItem extends StatelessWidget {
  final TourActivity tourActivity;
  const TourActivityItem({Key key, this.tourActivity}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double wh = Style.maxWidth();
    double hh = Style.maxWidth() / (9 / 6);

    Widget image = Style.renderImage(
        tourActivity.imageLink, tourActivity.name, wh,
        hh: hh);
    Widget title = Text(tourActivity.name,
        overflow: TextOverflow.visible,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700));
    Widget rating = Rating(
        rating: (double.tryParse(tourActivity.rating) ?? 0).floor() ?? 0,
        size: 16);
    Widget price = Text(tourActivity.priceFmt,
        textAlign: TextAlign.right,
        style: TextStyle(
            fontSize: 20, fontWeight: FontWeight.w700, color: Style.primary));
    Widget descFmt = Text(tourActivity.shortDescription,
        overflow: TextOverflow.visible,
        style: TextStyle(fontSize: 14, color: Style.greyDark));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        image,
        SizedBox(height: 16),
        Container(
          width: Style.maxWidth(),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            title,
            SizedBox(height: 2),
            rating,
            SizedBox(height: 8),
            descFmt,
            SizedBox(height: 16),
            Flex(
              direction: Axis.horizontal,
              children: [price],
              mainAxisAlignment: MainAxisAlignment.end,
            )
          ]),
        ),
      ],
    );
  }
}
